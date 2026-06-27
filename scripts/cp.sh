#!/bin/sh
set -eu

# Parameters
FORCE_FLAG="${1:-}"

# Variables
TAB="    "
REPO_DIR="$(cd -- "$(dirname -- "${0}")" >/dev/null 2>&1 && pwd)/.."

# Functions
show_usage() {
    printf "USAGE\n${TAB}${0} [options]\nOPTIONS\n${TAB}-f --force${TAB}Replace ~/.config/nvim\n"
}

copy() {
    # Ensure ~/.config exists
    mkdir -p "${HOME}/.config"

    # Copy the GitHub repo into ~/.config/nvim
    cp -r "${REPO_DIR}" "${HOME}/.config/nvim"

    # Go to ~/.config/nvim
    cd "${HOME}/.config/nvim"

    # Remove unnecessary files and directories
    rm -rf .git
    rm -f .gitignore LICENSE README.md

    # Let the user know the operation was successful
    echo "Successfully copied the Neovim configuration to ${HOME}/.config"
}

if [ "${#}" -eq 1 ]; then
    if [ "${1}" != "-f" ] && [ "${1}" != "--force" ]; then
        show_usage
	exit 1
    fi
    
    # Remove everything inside of ~/.config/nvim including the directory itself
    rm -rf "${HOME}/.config/nvim"

    # Copy the GitHub repo
    copy
    exit 0
elif [ "${#}" -eq 0 ]; then
    if [ -e "${HOME}/.config/nvim" ]; then
        printf "${0}: ${HOME}/.config/nvim already exists and is not empty\n"
	exit 1
    fi

    # Copy the GitHub repo
    copy
    exit 0
else
    show_usage
    exit 1
fi
