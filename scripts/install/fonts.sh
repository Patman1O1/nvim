#!/usr/bin/env bash

set -euo pipefail

FONT_NAME="${1:-JetBrainsMono}"
FONTS_DIR="${HOME}/.local/share/fonts"

# Go to the temporary directory
cd /tmp

# Ensure the fonts directory exists
mkdir -p "${FONTS_DIR}"

# Download the font
curl -LO "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/${FONT_NAME}.zip"

# Unzip the ZIP file
unzip "${FONT_NAME}.zip" -d "${FONTS_DIR}"

# Tell the system to recan the fonts directory
fc-cache -fv

# Clean up
rm -f "${FONT_NAME}.zip"
