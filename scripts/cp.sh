#!/bin/sh
set -eu

# Parameters
FORCE_FLAG="${1:-}"

# Variables
TAB="    "
REPO_DIR="$(cd -- "$(dirname -- "${0}")" >/dev/null 2>&1 && pwd)/.."

# Ensure correct usage
if [ "${#}" -gt 1 ] || [ "${#}" -eq 1 ] && { [ "${FORCE_FLAG}" != "-f" ] && [ "${FORCE_FLAG}" != "--force" ]; }; then
    printf "USAGE\n${TAB}${0} [options]\nOPTIONS\n${TAB}-f --force${TAB}Replace ~/.config/nvim\n"
    exit 1
fi

# Do nothing if ~/.config/nvim is not empty
if [ -e "${HOME}/.config/nvim" ]; then
    echo "${0}: ${HOME}/.config/nvim is not empty"
    exit 1
fi

# Ensure ~/.config exists
mkdir -p "${HOME}/.config"

# Ensure ~/.config/nvim is removed
rm -rf "${HOME}/.config/nvim"

# Copy every from the GitHub repo into ~/.config/nvim
cp -r "${REPO_DIR}" "${HOME}/.config/nvim"

# Go to the copied Neovim directory
cd "${HOME}/.config/nvim"

# Remove unnecessary files and directories
rm -rf .git
rm -f .gitignore LICENSE README.md

# Let the user know the operation was successful
echo "Successfully copied the Neovim configuration to ${HOME}/.config"
exit 0
