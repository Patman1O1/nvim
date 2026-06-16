#!/bin/sh

# nvim/.local/bin

# Removed 'o pipefail' because standard sh doesn't support it
set -eu

# Check if the standard os-release file exists
if [ ! -f /etc/os-release ]; then
    # Fallback to locations found in older or specific legacy systems
    if [ -f /etc/lsb-release ]; then
        # Source lsb-release
        . /etc/lsb-release
        
        # Output the distro ID
        echo "${DISTRIB_ID:-unknown}" | tr '[:upper:]' '[:lower:]'
    elif [ -f /etc/debian_version ]; then
        echo "debian"
    elif [ -f /etc/redhat-release ]; then
        echo "redhat"
    else
        # Give up
        echo "unknown"
    fi
    exit 0
fi

# Source the standard os-release file
. /etc/os-release

# Output the distro ID
echo "${ID}" | tr '[:upper:]' '[:lower:]'

exit 0
