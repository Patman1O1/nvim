#!/bin/sh
set -eu

# Parameters
FORCE_FLAG="${1:-}"

# Variables
TAB="    "
REPO_DIR="$(cd "$(dirname "${0}")" && pwd)/.."

if [ "${#}" -gt 1 ] || { [ "${FORCE_FLAG}" != "-f" ] && [ "${FORCE_FLAG}" != "--force" ]; }; then
    printf "USAGE\n${TAB}${0} [options]\nOPTIONS\n${TAB}-f --force${TAB}Replace ~/.config/nvim\n"
    exit 1
fi

if [ ! -e "${HOME}/.config/nvim" ]; then
    echo "${HOME}/.config/nvim is not empty"
    exit 1
fi

rm -rf "${HOME}/.config/nvim"
mkdir -p "${HOME}/.config"
cp -r "${REPO_DIR}" "${HOME}/.config/nvim"

echo "Successfully copied the Neovim configuration to ${HOME}/.config"
exit 0
