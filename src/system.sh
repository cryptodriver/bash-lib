#!/usr/bin/env bash

# @file System
# @brief Functions for system operations and manipulations.

# @description Get CPU usage.
# 
# @example
#   system::cpu_usage
#   #Output
#   18
#
# @noargs
#
# @exitcode 0 If successful.
# @exitcode 2 Function missing arguments.
#
# @stdout Returns the CPU usage percentage as a decimal value.
system::cpu_usage() {
    local usage=$(top -bn1 | grep "Cpu(s)" | awk '{print $2 + $4}')
    printf "%s" "${usage}"
}

# @description Get MEM usage.
# 
# @example
#   system::memory_usage
#   #Output
#   18
#
# @noargs
#
# @exitcode 0 If successful.
#
# @stdout Returns the MEM usage percentage as a decimal value.
system::memory_usage() {
    local total=$(free -m | awk '/Mem/ {print $2}')
    local used=$(free -m | awk '/Mem/ {print $3}')
    local usage=$(awk "BEGIN {printf \"%.2f\", $used / $total * 100}")
    printf "%s" "${usage}"
}

# @description Get disk usage.
# 
# @example
#   system::disk_usage
#   #Output
#   18
#
# @noargs
#
# @exitcode 0 If successful.
#
# @stdout Returns the disk usage percentage as a decimal value.
system::disk_usage() {
    local usage=$(df -h / | awk '/\// {print $5}')
    printf "%s" "${usage}"
}