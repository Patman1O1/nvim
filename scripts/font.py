#!/usr/bin/env python3

# Builtin Imports
import argparse
import io
import json
import os
import platform
import shutil
import subprocess
import sys
import urllib.request
import zipfile
from pathlib import Path


# ── Platform detection ────────────────────────────────────────────────────────
def is_wsl() -> bool:
    # 1. Check kernel release name (e.g., '5.15.153.1-microsoft-standard-WSL2')
    release = platform.release().lower()
    if 'microsoft' in release or 'wsl' in release:
        return True

    # 2. Fallback check for WSL environment variables
    return 'WSL_DISTRO_NAME' in os.environ or 'WSL_INTEROP' in os.environ


def is_linux() -> bool: return platform.system() == 'Linux'


def is_macos() -> bool: return platform.system() == 'Darwin'


# ── Helpers ───────────────────────────────────────────────────────────────────

def run(cmd: list[str], **kwargs) -> subprocess.CompletedProcess:
    return subprocess.run(cmd, check=True, capture_output=True, text=True, **kwargs)


def download_zip(url: str, font_name: str) -> bytes:
    print(f"  Downloading {font_name} Nerd Font from GitHub...")
    try:
        with urllib.request.urlopen(url) as resp:
            total: int = int(resp.headers.get("Content-Length", 0))
            data: bytearray = bytearray()
            chunk_size: int = 65536
            while chunk := resp.read(chunk_size):
                data.extend(chunk)
                if total != 0:
                    pct = len(data) / total * 100
                    print(f"\r  {pct:.1f}%", end="", flush=True)
            print()  # newline after progress
        return bytes(data)
    except urllib.error.HTTPError as e:
        print(f"\n  [Error] Failed to download {url}")
        print(f"  HTTP Error {e.code}: {e.reason}. Please check if '{font_name}' is a valid Nerd Font release name.")
        sys.exit(1)


def extract_ttf(zip_data: bytes, dest_dir: Path) -> list[str]:
    """Extract .ttf files only (used for WSL/Linux). Returns list of installed names."""
    installed = []
    with zipfile.ZipFile(io.BytesIO(zip_data)) as zf:
        for name in zf.namelist():
            if not name.endswith(".ttf"):
                continue
            dest = dest_dir / Path(name).name
            with zf.open(name) as src, open(dest, "wb") as dst:
                dst.write(src.read())
            installed.append(Path(name).name)
    return installed


# ── macOS installation / uninstallation ───────────────────────────────────────

def macos_fonts_dir(font_name: str) -> Path:
    return Path.home() / "Library/Fonts" / font_name


def extract_fonts(zip_data: bytes, dest_dir: Path) -> list[str]:
    """Extract .ttf and .otf files from zip. Returns list of installed filenames."""
    installed = []
    with zipfile.ZipFile(io.BytesIO(zip_data)) as zf:
        for name in zf.namelist():
            if not (name.endswith(".ttf") or name.endswith(".otf")):
                continue
            dest = dest_dir / Path(name).name
            with zf.open(name) as src, open(dest, "wb") as dst:
                dst.write(src.read())
            installed.append(Path(name).name)
    return installed


def macos_register_fonts(fonts_dir: Path) -> None:
    """
    Use macOS CoreText via ctypes to register fonts without requiring a logout.
    Falls back to a osascript nudge if ctypes approach fails.
    """
    try:
        import ctypes, ctypes.util
        ct = ctypes.cdll.LoadLibrary(ctypes.util.find_library("CoreText"))
        cf = ctypes.cdll.LoadLibrary(ctypes.util.find_library("CoreFoundation"))

        cf.CFURLCreateFromFileSystemRepresentation.restype = ctypes.c_void_p
        cf.CFURLCreateFromFileSystemRepresentation.argtypes = [
            ctypes.c_void_p, ctypes.c_char_p, ctypes.c_long, ctypes.c_bool
        ]
        ct.CTFontManagerRegisterFontsForURL.restype = ctypes.c_bool
        ct.CTFontManagerRegisterFontsForURL.argtypes = [
            ctypes.c_void_p, ctypes.c_uint32, ctypes.c_void_p
        ]
        kCTFontManagerScopeUser = 1

        registered = 0
        for font_file in fonts_dir.iterdir():
            if font_file.suffix not in (".ttf", ".otf"):
                continue
            path_bytes = str(font_file).encode("utf-8")
            url = cf.CFURLCreateFromFileSystemRepresentation(None, path_bytes, len(path_bytes), False)
            if url:
                ct.CTFontManagerRegisterFontsForURL(url, kCTFontManagerScopeUser, None)
                registered += 1

        print(f"  Registered {registered} font(s) with CoreText (no logout needed).")
    except Exception as e:
        print(f"  [warn] CoreText registration failed ({e}), fonts will be available after next login.")


def macos_unregister_fonts(fonts_dir: Path) -> None:
    """
    Use macOS CoreText via ctypes to dynamically unregister fonts.
    """
    try:
        import ctypes, ctypes.util
        ct = ctypes.cdll.LoadLibrary(ctypes.util.find_library("CoreText"))
        cf = ctypes.cdll.LoadLibrary(ctypes.util.find_library("CoreFoundation"))

        cf.CFURLCreateFromFileSystemRepresentation.restype = ctypes.c_void_p
        cf.CFURLCreateFromFileSystemRepresentation.argtypes = [
            ctypes.c_void_p, ctypes.c_char_p, ctypes.c_long, ctypes.c_bool
        ]
        ct.CTFontManagerUnregisterFontsForURL.restype = ctypes.c_bool
        ct.CTFontManagerUnregisterFontsForURL.argtypes = [
            ctypes.c_void_p, ctypes.c_uint32, ctypes.c_void_p
        ]
        kCTFontManagerScopeUser = 1

        unregistered = 0
        for font_file in fonts_dir.iterdir():
            if font_file.suffix not in (".ttf", ".otf"):
                continue
            path_bytes = str(font_file).encode("utf-8")
            url = cf.CFURLCreateFromFileSystemRepresentation(None, path_bytes, len(path_bytes), False)
            if url:
                ct.CTFontManagerUnregisterFontsForURL(url, kCTFontManagerScopeUser, None)
                unregistered += 1

        print(f"  Unregistered {unregistered} font(s) from CoreText.")
    except Exception as e:
        print(f"  [warn] CoreText unregistration failed ({e}).")


def patch_iterm2(font_display_name: str) -> bool:
    """
    Patch iTerm2's com.googlecode.iterm2.plist to set the font for all profiles.
    Returns True if any changes were written.
    """
    plist_path = Path.home() / "Library/Preferences/com.googlecode.iterm2.plist"
    if not plist_path.exists():
        return False

    try:
        # Convert binary plist to XML so we can parse it
        result = run(["plutil", "-convert", "xml1", "-o", "-", str(plist_path)])
        xml = result.stdout
    except subprocess.CalledProcessError:
        print("  [warn] Could not read iTerm2 plist.")
        return False

    import xml.etree.ElementTree as ET
    root = ET.fromstring(xml)

    changed = False
    target_key = "Normal Font"
    # Font value format iTerm2 expects: "FontName Size"
    font_value = f"{font_display_name} 13"

    # iTerm2 stores profiles as an array of dicts under "New Bookmarks"
    top_dict = root.find("dict")
    if top_dict is None:
        return False

    keys = list(top_dict)
    i = 0
    while i < len(keys) - 1:
        if keys[i].tag == "key" and keys[i].text == "New Bookmarks":
            profiles_array = keys[i + 1]
            for profile_dict in profiles_array.findall("dict"):
                profile_keys = list(profile_dict)
                j = 0
                while j < len(profile_keys) - 1:
                    if profile_keys[j].tag == "key" and profile_keys[j].text == target_key:
                        val_elem = profile_keys[j + 1]
                        if val_elem.text != font_value:
                            val_elem.text = font_value
                            changed = True
                    j += 1
        i += 1

    if changed:
        backup = plist_path.with_suffix(".plist.bak")
        shutil.copy2(plist_path, backup)
        print(f"  Backed up iTerm2 plist to {backup}")

        new_xml = ET.tostring(root, encoding="unicode", xml_declaration=False)
        tmp = plist_path.with_suffix(".plist.tmp")
        tmp.write_text(f'<?xml version="1.0" encoding="UTF-8"?>\n'
                       f'<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" '
                       f'"http://www.apple.com/DTDs/PropertyList-1.0.dtd">\n{new_xml}')
        # Convert back to binary plist
        run(["plutil", "-convert", "binary1", str(tmp)])
        shutil.move(str(tmp), str(plist_path))
        print(f"  Patched iTerm2 plist — restart iTerm2 to apply.")
    else:
        print(f"  iTerm2 font already set, no changes needed.")

    return changed


def install_macos(font_name: str):
    download_url = f"https://github.com/ryanoasis/nerd-fonts/releases/latest/download/{font_name}.zip"
    font_display_name = f"{font_name} Nerd Font"

    print("\n[macOS] Installing font...\n")

    fonts_dir = macos_fonts_dir(font_name)
    fonts_dir.mkdir(parents=True, exist_ok=True)
    print(f"  Font directory: {fonts_dir}")

    zip_data = download_zip(download_url, font_name)

    print("  Extracting .ttf / .otf files...")
    installed = extract_fonts(zip_data, fonts_dir)
    print(f"  Installed {len(installed)} font file(s).")

    print("\n[macOS] Registering fonts with CoreText...")
    macos_register_fonts(fonts_dir)

    print("\n[macOS] Patching iTerm2 (if installed)...")
    iterm_patched = patch_iterm2(font_display_name)
    if not iterm_patched:
        print("  iTerm2 not found or already configured.")

    print("\n✓ Done!")
    print(f'  If using Terminal.app: Preferences → Profiles → Text → Font → change to "{font_display_name}".')
    print(f'  If using iTerm2: restart it — the plist was patched automatically.')
    print(f'  If using Alacritty / Kitty / WezTerm: set font_family to "{font_display_name}" in your config.')
    print('  Test with: echo "\ue0b0 \u26a1 \ue23a"')


def uninstall_macos(font_name: str):
    print("\n[macOS] Uninstalling font...\n")
    fonts_dir = macos_fonts_dir(font_name)

    if fonts_dir.exists():
        print("  Unregistering fonts with CoreText...")
        macos_unregister_fonts(fonts_dir)

        print(f"  Removing directory {fonts_dir}...")
        try:
            shutil.rmtree(fonts_dir, ignore_errors=True)
            print("  Uninstalled font files.")
        except Exception as e:
            print(f"  [error] Failed to remove directory: {e}")
    else:
        print(f"  [warn] Font directory {fonts_dir} not found. Nothing to remove.")

    print("\n✓ Done!")
    print(f"  Remember to change your terminal settings away from {font_name} Nerd Font!")


# ── WSL installation / uninstallation ─────────────────────────────────────────
def wsl_windows_path(win_path: str) -> Path:
    """Convert a Windows path (e.g. C:\\Users\\...) to a WSL /mnt/... path."""
    drive, rest = win_path.strip().split(":\\", 1)
    return Path(f"/mnt/{drive.lower()}/{rest.replace(chr(92), '/')}")


def wsl_get_env(var: str) -> str:
    result = run(["cmd.exe", "/c", f"echo %{var}%"])
    return result.stdout.strip()


def wsl_fonts_dir() -> Path:
    localappdata = wsl_get_env("LOCALAPPDATA")
    return wsl_windows_path(localappdata) / "Microsoft/Windows/Fonts"


def wsl_terminal_settings_paths() -> list[Path]:
    """Return candidate paths for Windows Terminal settings.json."""
    localappdata = wsl_get_env("LOCALAPPDATA")
    base = wsl_windows_path(localappdata) / "Packages"
    candidates = []
    if base.exists():
        # Stable and Preview both show up here
        for pkg in base.iterdir():
            if "WindowsTerminal" in pkg.name:
                candidate = pkg / "LocalState/settings.json"
                if candidate.exists():
                    candidates.append(candidate)
    return candidates


def patch_windows_terminal(settings_path: Path, font_display_name: str) -> bool:
    """
    Patch WSL profiles in Windows Terminal settings.json to use the given font.
    Makes a .bak backup first. Returns True if changes were written.
    """
    raw = None
    # Try reading with utf-8-sig first (which automatically strips the 0xFF 0xFE BOM)
    for enc in ("utf-8-sig", "utf-16", "utf-8"):
        try:
            with open(settings_path, encoding=enc) as f:
                raw = f.read()
            break
        except (UnicodeDecodeError, UnicodeError):
            continue

    if raw is None:
        print(f"  [error] Could not decode {settings_path} with supported encodings.")
        return False

    # Remove any stray leading zero-width spaces or null bytes if present
    raw = raw.lstrip("\ufeff\x00")

    try:
        data = json.loads(raw)
    except json.JSONDecodeError as e:
        print(f"  [warn] Could not parse {settings_path}: {e}")
        return False

    # Backup original file
    backup = settings_path.with_suffix(".json.bak")
    shutil.copy2(settings_path, backup)
    print(f"  Backed up settings to {backup}")

    changed = False

    def set_font(profile: dict) -> None:
        nonlocal changed
        font_obj = profile.setdefault("font", {})
        if font_obj.get("face") != font_display_name:
            font_obj["face"] = font_display_name
            changed = True

    profiles = data.get("profiles", {})

    # 1. Update global defaults block
    defaults = profiles.get("defaults", {})
    set_font(defaults)
    profiles["defaults"] = defaults

    # 2. Update individual WSL profiles (matching both source naming conventions)
    for profile in profiles.get("list", []):
        source = profile.get("source", "")
        if source in ("Windows.Terminal.Wsl", "Microsoft.WSL") or "wsl" in profile.get("commandline", "").lower():
            set_font(profile)

    data["profiles"] = profiles

    if changed:
        # Save as standard UTF-8 WITHOUT BOM so Windows Terminal reads it cleanly
        with open(settings_path, "w", encoding="utf-8") as f:
            json.dump(data, f, indent=4, ensure_ascii=False)
        print(f"  Patched: {settings_path}")
    else:
        print(f"  Font already set in {settings_path}, no changes needed.")

    return changed

def install_wsl(font_name: str):
    download_url = f"https://github.com/ryanoasis/nerd-fonts/releases/latest/download/{font_name}.zip"
    font_display_name = f"{font_name} Nerd Font"

    print("\n[WSL] Installing font to Windows...\n")

    fonts_dir = wsl_fonts_dir()
    fonts_dir.mkdir(parents=True, exist_ok=True)
    print(f"  Font directory: {fonts_dir}")

    zip_data = download_zip(download_url, font_name)

    print("  Extracting .ttf files...")
    installed = extract_ttf(zip_data, fonts_dir)

    print(f"  Installed {len(installed)} font file(s).")

    # Patch Windows Terminal
    print("\n[WSL] Patching Windows Terminal settings.json...\n")
    settings_paths = wsl_terminal_settings_paths()
    if not settings_paths:
        print("  [warn] Could not find Windows Terminal settings.json.")
        print("  Set the font manually: open Windows Terminal → Settings →")
        print(f'  your WSL profile → Appearance → Font face → "{font_display_name}"')
    else:
        for path in settings_paths:
            print(f"  Found: {path}")
            patch_windows_terminal(path, font_display_name)

    print("\n✓ Done!")
    print(f'  Restart Windows Terminal and verify the font is set to "{font_display_name}".')
    print('  Test with: echo "\ue0b0 \u26a1 \ue23a"')


def uninstall_wsl(font_name: str):
    print("\n[WSL] Uninstalling font from Windows...\n")

    fonts_dir = wsl_fonts_dir()
    print(f"  Searching for {font_name} files in {fonts_dir}...")

    if not fonts_dir.exists():
        print("  [error] Windows fonts directory not found.")
        return

    removed = 0
    search_str = font_name.lower().replace(" ", "")

    for font_file in fonts_dir.iterdir():
        if font_file.is_file() and search_str in font_file.name.lower():
            try:
                font_file.unlink()
                removed += 1
            except PermissionError:
                print(f"  [warn] Could not remove {font_file.name} - File is locked.")
                print("         Change your font in Windows Terminal and close it, then try again.")
            except Exception as e:
                print(f"  [warn] Could not remove {font_file.name}: {e}")

    print(f"  Removed {removed} file(s).")

    print("\n✓ Done!")
    print(f"  Remember to open Windows Terminal and change your settings away from {font_name} Nerd Font!")


# ── Linux installation / uninstallation ───────────────────────────────────────

def linux_fonts_dir(font_name: str) -> Path:
    return Path.home() / ".local/share/fonts" / font_name


def refresh_font_cache():
    print("  Refreshing font cache (fc-cache)...")
    try:
        run(["fc-cache", "-fv"])
        print("  Font cache refreshed.")
    except (subprocess.CalledProcessError, FileNotFoundError):
        print("  [warn] fc-cache failed or not found. You may need to run it manually.")


def install_linux(font_name: str):
    download_url = f"https://github.com/ryanoasis/nerd-fonts/releases/latest/download/{font_name}.zip"
    font_display_name = f"{font_name} Nerd Font"

    print("\n[Linux] Installing font...\n")

    fonts_dir = linux_fonts_dir(font_name)
    fonts_dir.mkdir(parents=True, exist_ok=True)
    print(f"  Font directory: {fonts_dir}")

    zip_data = download_zip(download_url, font_name)

    print("  Extracting .ttf files...")
    installed = extract_ttf(zip_data, fonts_dir)
    print(f"  Installed {len(installed)} font file(s).")

    refresh_font_cache()

    print("\n✓ Done!")
    print(f'  Set your terminal font to "{font_display_name}" in your terminal\'s settings.')
    print('  Test with: echo "\ue0b0 \u26a1 \ue23a"')


def uninstall_linux(font_name: str):
    print("\n[Linux] Uninstalling font...\n")
    fonts_dir = linux_fonts_dir(font_name)

    if fonts_dir.exists():
        print(f"  Removing directory {fonts_dir}...")
        try:
            shutil.rmtree(fonts_dir, ignore_errors=True)
            print("  Uninstalled font files.")
        except Exception as e:
            print(f"  [error] Failed to remove directory: {e}")
    else:
        print(f"  [warn] Font directory {fonts_dir} not found. Nothing to remove.")

    refresh_font_cache()

    print("\n✓ Done!")
    print(f"  Remember to change your terminal settings away from {font_name} Nerd Font!")


# ── Entry point ───────────────────────────────────────────────────────────────

def main():
    parser = argparse.ArgumentParser(description="Manage Nerd Fonts installations.")
    parser.add_argument(
        "action",
        choices=["install", "uninstall"],
        help="Action to perform: install or uninstall"
    )
    parser.add_argument(
        "font_name",
        nargs="?",
        default="JetBrainsMono",
        help="Name of the Nerd Font release (e.g., FiraCode, Hack, Meslo). Default: JetBrainsMono"
    )
    args = parser.parse_args()

    action = args.action
    font_name = args.font_name

    if is_wsl():
        detected = "WSL"
    elif is_macos():
        detected = "macOS"
    elif is_linux():
        detected = "Linux"
    else:
        print("Unsupported platform. This script supports Linux, WSL, and macOS.")
        sys.exit(1)

    print("Nerd Font Installer")
    print("===================")
    print(f"Action  : {action.capitalize()}")
    print(f"Font    : {font_name} Nerd Font")

    if action == "install":
        download_url = f"https://github.com/ryanoasis/nerd-fonts/releases/latest/download/{font_name}.zip"
        print(f"Source  : {download_url}")

    print(f"Platform: {detected}")

    if action == "install":
        if detected == "WSL":
            install_wsl(font_name)
        elif detected == "macOS":
            install_macos(font_name)
        else:
            install_linux(font_name)
    elif action == "uninstall":
        if detected == "WSL":
            uninstall_wsl(font_name)
        elif detected == "macOS":
            uninstall_macos(font_name)
        else:
            uninstall_linux(font_name)


if __name__ == "__main__":
    main()