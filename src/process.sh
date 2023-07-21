#!/usr/bin/env bash

# @file Process
# @brief Functions for process operations and manipulations.

# @description Start a background process by executing the specified command using `nohup`.
#   　　　　　　The output of the command is redirected to /dev/null to suppress any output.
# @example
#   process::start "myapp --options"
#   #Output
#   0
#
# @arg $1 string The command to be executed as a background process.
#
# @exitcode 0 If the background process started successfully.
# @exitcode 2 If the required command argument is missing.
#
# @stdout Return the result whether the process is started.
process::start() {
    [[ $# -lt 1 ]] && printf "%s: Missing arguments\n" "${FUNCNAME[0]}" && return 2
    nohup $1 >/dev/null 2>&1 &

    # Check if the background process started successfully
    if [[ $? -eq 0 ]]; then
        echo "Background process started."
        return 0
    else
        echo "Failed to start the background process."
        return 2
    fi
}

# @description Stop a background process by executing the specified command using `pkill`.
#
# @example
#   process::stop "myapp"
#   #Output
#   0
#
# @arg $1 string The command to be stopped.
#
# @exitcode 0 If the background process stopped successfully.
# @exitcode 1 If process not found or failed to stopped.
# @exitcode 2 If the required command argument is missing.
#
# @stdout Return the result whther the process is started.
process::stop() {
    [[ $# -lt 1 ]] && printf "%s: Missing arguments\n" "${FUNCNAME[0]}" && return 2
    pkill -f $1

    # Check if the background process stopped successfully
    if [[ $? -eq 0 ]]; then
        echo "Background process stopped."
        return 0
    elif [[ $? -eq 1 ]]; then
        echo "No matching background process found."
        return 1
    else
        echo "Failed to stop the background process."
        return 1
    fi
}

# @description Check if a process is running based on the process name.
# 
# @example
#   process::is_running "ssh"
#   #Output
#   1
#
# @arg $1 string The name of the process to check.
#
# @exitcode 0 If the process is not running.
# @exitcode 1 If the process is running.
#
# @stdout No standard output.
process::is_running() {
    [[ $# -lt 1 ]] && printf "%s: Missing arguments\n" "${FUNCNAME[0]}" && return 2
    if pgrep -f "$1" >/dev/null; then
        return 1
    fi
    return 0
}