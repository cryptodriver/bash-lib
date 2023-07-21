#!/usr/bin/env bash

# @file String
# @brief Functions for string operations and manipulations.

# @description Strip whitespace from the beginning and end of a string.
#
# @example
#   echo "$(string::trim "   Hello World!   ")"
#   #Output
#   Hello World!
#
# @arg $1 string The string to be trimmed.
#
# @exitcode 0 If successful.
# @exitcode 2 Function missing arguments.
#
# @stdout The trimmed string.
string::trim() {
    [[ $# = 0 ]] && printf "%s: Missing arguments\n" "${FUNCNAME[0]}" && return 2

    : "${1#"${1%%[![:space:]]*}"}"
    : "${_%"${_##*[![:space:]]}"}"
    printf '%s\n' "$_"
}

# @description Split a string to array by a delimiter.
#
# @example
#   array=( $(string::split "a,b,c" ",") )
#   printf "%s" "$(string::split "Hello!World" "!")"
#   #Output
#   Hello
#   World
#
# @arg $1 string The input string.
# @arg $2 string The delimiter string.
#
# @exitcode 0 If successful.
# @exitcode 2 Function missing arguments.
#
# @stdout Returns an array of strings created by splitting the string parameter by the delimiter.
string::split() {
    [[ $# -lt 2 ]] && printf "%s: Missing arguments\n" "${FUNCNAME[0]}" && return 2
    declare -a arr=()
    IFS=$'\n' read -d "" -ra arr <<< "${1//$2/$'\n'}"
    printf '%s\n' "${arr[@]}"
}

# @description Strip characters from the beginning of a string.
#
# @example
#   echo "$(string::lstrip "Hello World!" "He")"
#   #Output
#   llo World!
#
# @arg $1 string The input string.
# @arg $2 string The characters you want to strip.
#
# @exitcode 0 If successful.
# @exitcode 2 Function missing arguments.
#
# @stdout Returns the modified string.
string::lstrip() {
    [[ $# -lt 2 ]] && printf "%s: Missing arguments\n" "${FUNCNAME[0]}" && return 2
    printf '%s\n' "${1##$2}"
}

# @description Strip characters from the end of a string.
#
# @example
#   echo "$(string::rstrip "Hello World!" "d!")"
#   #Output
#   Hello Worl
#
# @arg $1 string The input string.
# @arg $2 string The characters you want to strip.
#
# @exitcode 0 If successful.
# @exitcode 2 Function missing arguments.
#
# @stdout Returns the modified string.
string::rstrip() {
    [[ $# -lt 2 ]] && printf "%s: Missing arguments\n" "${FUNCNAME[0]}" && return 2
    printf '%s\n' "${1%%$2}"
}

# @description Make a string lowercase.
#
# @example
#   echo "$(string::to_lower "HellO")"
#   #Output
#   hello
#
# @arg $1 string The input string.
#
# @exitcode 0 If successful.
# @exitcode 2 Function missing arguments.
#
# @stdout Returns the lowercased string.
string::to_lower() {
    [[ $# = 0 ]] && printf "%s: Missing arguments\n" "${FUNCNAME[0]}" && return 2
    if [[ ${BASH_VERSINFO:-0} -ge 4 ]]; then
        printf '%s\n' "${1,,}"
    else
        printf "%s\n" "${@}" | tr '[:upper:]' '[:lower:]'
    fi
}

# @description Make a string all uppercase.
#
# @example
#   echo "$(string::to_upper "HellO")"
#   #Output
#   HELLO
#
# @arg $1 string The input string.
#
# @exitcode 0 If successful.
# @exitcode 2 Function missing arguments.
#
# @stdout Returns the uppercased string.
string::to_upper() {
    [[ $# = 0 ]] && printf "%s: Missing arguments\n" "${FUNCNAME[0]}" && return 2
    if [[ ${BASH_VERSINFO:-0} -ge 4 ]]; then
        printf '%s\n' "${1^^}"
    else
        printf "%s\n" "${@}" | tr '[:lower:]' '[:upper:]'
    fi
}

# @description Check whether the search string exists within the input string.
#
# @example
#   string::contains "Hello World!" "lo"
#
# @arg $1 string The input string.
# @arg $2 string The search key.
# @exitcode 0  If match found.
# @exitcode 1  If no match found.
# @exitcode 2 Function missing arguments.
string::contains() {
    [[ $# -lt 2 ]] && printf "%s: Missing arguments\n" "${FUNCNAME[0]}" && return 2
    # Usage: string_contains hello he
    [[ "${1}" == *${2}* ]]
}

# @description Check whether the input string starts with key string.
#
# @example
#   string::starts_with "Hello World!" "He"
#
# @arg $1 string The input string.
# @arg $2 string The search key.
# @exitcode 0  If match found.
# @exitcode 1  If no match found.
# @exitcode 2 Function missing arguments.
string::starts_with() {
    # Usage: string_starts_with hello he
    [[ $# -lt 2 ]] && printf "%s: Missing arguments\n" "${FUNCNAME[0]}" && return 2
    [[ "${1}" == ${2}* ]]
}

# @description Check whether the input string ends with key string.
#
# @example
#   string::ends_with "Hello World!" "d!"
#
# @arg $1 string The input string.
# @arg $2 string The search key.
# @exitcode 0  If match found.
# @exitcode 1  If no match found.
# @exitcode 2 Function missing arguments.
string::ends_with() {
    [[ $# -lt 2 ]] && printf "%s: Missing arguments\n" "${FUNCNAME[0]}" && return 2
    # Usage: string_ends_wit hello lo
    [[ "${1}" == *${2} ]]
}

# @description Check whether the input string matches the given regex.
#
# @example
#   string::regex "HELLO" "^[A-Z]*$"
#
# @arg $1 string The input string.
# @arg $2 string The search key.
# @exitcode 0  If match found.
# @exitcode 1  If no match found.
# @exitcode 2 Function missing arguments.
string::regex() {
    [[ $# -lt 2 ]] && printf "%s: Missing arguments\n" "${FUNCNAME[0]}" && return 2
    if [[ ${1} =~ ${2} ]]; then
        return 0
    else
        return 1
    fi
}

# @description Computes the MD5 hash of a string.
#
# @example
#   echo "$(string::md5 "hello")"
#   #Output
#   5d41402abc4b2a76b9719d911017c592
#
# @arg $1 string The input string to compute the hash for.
#
# @exitcode 0 If the hash computation was successful.
# @exitcode 2 If the required command argument is missing.
#
# @stdout The MD5 hash of the input string.
string::md5() {
    [[ $# -lt 1 ]] && printf "%s: Missing arguments\n" "${FUNCNAME[0]}" && return 2
    echo -n "$1" | md5sum | awk '{print $1}'
}

# @description Computes the SHA-256 hash of a string.
#
# @example
#   echo "$(string::sha256 "hello")"
#   #Output
#   2cf24dba5fb0a30e26e83b2ac5b9e29e1b161e5c1fa7425e73043362938b9824
#
# @arg $1 string The input string to compute the hash for.
#
# @exitcode 0 If the hash computation was successful.
# @exitcode 2 If the required command argument is missing.
#
# @stdout The SHA-256 hash of the input string.
string::sha256() {
    [[ $# -lt 1 ]] && printf "%s: Missing arguments\n" "${FUNCNAME[0]}" && return 2
    echo -n "$1" | sha256sum | awk '{print $1}'
}

# @description Encodes or decodes a string using base64 encoding.
#
# @example
#   echo "$(string::base64 "hello")"
#   echo "$(string::base64 "hello" "-d")"
#   #Output
#   aGVsbG8=
#   hello
#
# @arg $1 string The string to be encoded or decoded.
# @arg $2 string The flag indicating the encoding or decoding operation.
#
# @exitcode 0 If the base64 operation was successful.
# @exitcode 2 If the required command argument is missing.
#
# @stdout The base64-encoded or base64-decoded string.
string::base64() {
    [[ $# -lt 1 ]] && printf "%s: Missing arguments\n" "${FUNCNAME[0]}" && return 2

    if [ "$2" == "-d" ]; then
        echo -n "$1" | base64 -d
    else
        echo -n "$1" | base64
    fi
    [[ "${1}" == *${2}* ]]
}