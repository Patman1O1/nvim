$fonts = (New-Object -ComObject Shell.Application).Namespace(0x14)
Get-ChildItem "$env:LOCALAPPDATA\Microsoft\Windows\Fonts\*.ttf" | ForEach-Object {
    $fonts.CopyHere($_.FullName, 0x10)
}
