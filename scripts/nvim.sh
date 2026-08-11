#!/bin/sh

set -eu

OS="$(echo "$(uname -s)" | tr '[:upper:]' '[:lower:]')"
ARCH="$(echo "$(uname -m)" | tr '[:upper:]' '[:lower:]')"
BIN="${HOME}/.local/bin"

# Ensure the operating system is Linux
echo "Detecting operating system..."
if [ "${OS}" != "linux" ]; then
    printf "Error: \"${OS}\" is not a supported OS. Ensure your OS is \"Linux\".\n" >&2
    exit 1
fi
printf "Operating system detected. Running \"${OS}\".\n"

# Ensure the architecture is either aarch64 or x86_64
echo "Detecting system architecture..."
if [ "${ARCH}" != "x86_64" ] && [ "${ARCH}" != "aarch64" ]; then
    printf "Error: \"${ARCH}\" is not a supported architecture. Ensure your architecture is \"x86_64\" or \"aarch64\" (ARM64)\n" >&2
    exit 1
fi
printf "Architecture detected. Running \"${ARCH}\".\n"

# Set ${ARCH} to arm64 if it is aarch64 (Neovim refers to aarch64 as arm64)
if [ "${ARCH}" = "aarch64" ]; then
    ARCH="arm64"
fi

# Ensure the required commands are installed
echo "Checking if all required commands are installed..."
for cmd in curl tar; do
    if ! command -v "${cmd}" >/dev/null 2>&1; then
        printf "Error: Could not find \"${cmd}\". Make sure it is installed and accessable from \"PATH\".\n" >&2
        exit 1
    fi
    printf "Found \"${cmd}\".\n"
done
echo "All required commands installed."

# Query the GitHub API for the latest stable download URL
echo "Fetching latest Neovim release metadata..."
DOWNLOAD_URL=$(curl -s https://api.github.com/repos/neovim/neovim/releases/latest \
    | grep "browser_download_url.*nvim-${OS}-${ARCH}.tar.gz" \
    | cut -d '"' -f 4)

if [ -z "${DOWNLOAD_URL}" ]; then
    echo "Error: Failed to fetch the latest download URL from GitHub." >&2
    exit 1
fi

# Download and install Neovim
echo "Downloading and installing Neovim..."
mkdir -p "${HOME}/.local/bin"
mkdir -p "/tmp/nvim"
curl -L "${DOWNLOAD_URL}" -o /tmp/nvim/nvim.tar.gz
tar -xzf /tmp/nvim/nvim.tar.gz -C /tmp/nvim
cp -R "/tmp/nvim/nvim-${OS}-${ARCH}/"* "${HOME}/.local/"

echo "Cleaning up temporary files..."
rm -rf /tmp/nvim

echo "Neovim successfully installed."
echo "$("${HOME}/.local/bin/nvim" --version)"

exit 0
