#!/usr/bin/env bash

# Enable strict mode for the script
set -Eeuo pipefail

# Global variables
export _VER_="1.0.1"
export _BASE_="$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")"

export _OEM_="0000"

# Source all the shell script files in lib(src) directory
for _FILE_ in "$_BASE_"/src/*.sh; do
    source $_FILE_
done

# Prevent multiple instances of script
export _LOCK="${_BASE_}/tmp/$(basename "${0%.*}").lock"

if [ -f "$_LOCK" ]; then
    echo "Another instance of the script is already running."
    logger::warn "$(basename "$0")->${FUNCNAME[1]}@L${BASH_LINENO[0]} : Another instance of the script is already running."
    exit 1
else
    touch $_LOCK
fi

# @description Handle exit function to some information.
#
# @param $1 int Exit code
#
# @exitcode None
#
cleanup() {
    if [[ $1 -gt 0 ]]; then
        logger::error "${BASH_SOURCE[1]}->${FUNCNAME[1]}@L${BASH_LINENO[0]} : EXITCODE=$1"
    fi
    
    rm $_LOCK
}
trap 'cleanup "$?"' EXIT