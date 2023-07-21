#!/usr/bin/env bash

# @file Logger
# @brief Simple logger utility.

# Default log level is 1.
# 0 debug
# 1 info
# 2 warn
# 3 error
declare -g _LEVEL_=1

# @description Initializes the logger by creating the log directory and log file.
# @example
#   logger::init
#
# @noargs
#
# @exitcode 0 If the logger initialization is successful.
# @exitcode 1 If failed to create the log directory.
#
# @stdout Path of the log file.
logger::init() {
    local _path="$_BASE_/log"  
    local _name=`basename "$0"`
    
    mkdir -p "${_path}"
    if [ $? -ne 0 ]; then
        exit 1
    fi

    local _logfile="${_path}/${_name%.*}-$(date +'%Y%m%d').log"

    if [ ! -f "$_logfile" ]; then
        touch $_logfile
    fi

    local _level=$(config::get "logger" "level")
    if [ -n "$_level" ]; then
        _LEVEL_=$_level
    fi

    echo $_logfile
}

# @description Logs a debug message to the log file.
#
# @example
#   logger::debug "debug message.
#
# @arg $1 string The debug message to be logged.
#
# @exitcode 0 If successful.
#
# @stdout The debug message.
logger::debug() {
    local _logfile=$(logger::init)
    if [ "$_LEVEL_" -le "0" ]; then
        echo -e "$(date +'%Y-%m-%d %H:%M:%S') debug: $1" | tee -a $_logfile
    fi
}

# @description Logs a info message to the log file.
#
# @example
#   logger::info "info message.
#
# @arg $1 string The info message to be logged.
#
# @exitcode 0 If successful.
#
# @stdout The info message.
logger::info() {
    local _logfile=$(logger::init)
    if [ "$_LEVEL_" -le "1" ]; then
        echo -e "$(date +'%Y-%m-%d %H:%M:%S') info : $1" | tee -a $_logfile
    fi
}

# @description Logs a warn message to the log file.
#
# @example
#   logger::warn "warn message.
#
# @arg $1 string The warn message to be logged.
#
# @exitcode 0 If successful.
#
# @stdout The warn message.
logger::warn() {
    local _logfile=$(logger::init)
    if [ "$_LEVEL_" -le "2" ]; then
        echo -e "$(date +'%Y-%m-%d %H:%M:%S') warn : $1" | tee -a $_logfile
    fi
}

# @description Logs a error message to the log file.
#
# @example
#   logger::error "error message.
#
# @arg $1 string The error message to be logged.
#
# @exitcode 0 If successful.
#
# @stdout The error message.
logger::error() {
    local _logfile=$(logger::init)
    if [ "$_LEVEL_" -le "3" ]; then
        echo -e "$(date +'%Y-%m-%d %H:%M:%S') error: $1" | tee -a $_logfile
    fi
}
