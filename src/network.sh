#!/usr/bin/env bash

# @file Network
# @brief Functions for handling with network.

# @description Checks the reachability of a host by sending a single ICMP echo request (ping)
# @example
#   network::ping 127.0.0.1
#   #Output
#   0
#
# @arg $1 string Host name or IP address to ping.
#
# @exitcode 0 If the host is reachable.
# @exitcode 1 If the host is unreachable.
# @exitcode 2 If the required command argument is missing.
#
# @stdout Return the result whether the host is reachable.
network::ping() {
    [[ $# -lt 1 ]] && printf "%s: Missing arguments\n" "${FUNCNAME[0]}" && return 2
    ping -c 1 $1 >/dev/null
    if [ $? -eq 0 ]; then
        echo "Host $1 is reachable."
        return 0
    else
        echo "Host $1 is unreachable."
        return 1
    fi
}

# @description Get the IP address of a host.
#
# @example
#   network::get_ip example.com
#   # Output:
#   # IP address of example.com is: 93.184.216.34
#
# @arg $1 string Host name to retrieve IP address.
#
# @exitcode 0 If the IP address is successfully retrieved.
# @exitcode 1 If failed to retrieve the IP address.
# @exitcode 2 If the required command argument is missing.
#
# @stdout Print the IP address of the host.
network::get_ip() {
    [[ $# -lt 1 ]] && printf "%s: Missing arguments\n" "${FUNCNAME[0]}" && return 2
    local host=$1
    local ip=$(getent hosts $host | awk '{ print $1 }')
    if [ -n "$ip" ]; then
        echo "IP address of $host is: $ip"
        return 0
    else
        echo "Failed to get IP address of $host."
        return 1
    fi
}

# @description Check the status of a network port on a host.
#
# @example
#   network::check_port example.com 80
#   # Output:
#   # Port 80 on example.com is open.
#
# @arg $1 string Host name or IP address.
# @arg $2 int Port number.
#
# @exitcode 0 If the port is open.
# @exitcode 1 If the port is closed.
# @exitcode 2 If the required command argument is missing.
#
# @stdout Print the status of the port on the host.
network::check_port() {
    [[ $# -lt 2 ]] && printf "%s: Missing arguments\n" "${FUNCNAME[0]}" && return 2
    local host=$1
    local port=$2
    nc -z -w 5 $host $port >/dev/null
    if [ $? -eq 0 ]; then
        echo "Port $port on $host is open."
        return 0
    else
        echo "Port $port on $host is closed."
        return 1
    fi
}

# @description Download a file from a specified URL.
#
# @example
#   network::download https://example.com/file.txt /path/to/destination/file.txt
#   # Output:
#   # File downloaded successfully: /path/to/destination/file.txt
#
# @arg $1 string URL of the file to download.
# @arg $2 string Destination path to save the downloaded file.
#
# @exitcode 0 If the file is downloaded successfully.
# @exitcode 1 If failed to download the file.
# @exitcode 2 If the required command argument is missing.
#
# @stdout Print the status message indicating whether the file is downloaded successfully.
network::download() {
    [[ $# -lt 2 ]] && printf "%s: Missing arguments\n" "${FUNCNAME[0]}" && return 2
    local url=$1
    local destination=$2
    wget -q $url -O $destination
    if [ $? -eq 0 ]; then
        echo "File downloaded successfully: $destination"
        return 0
    else
        echo "Failed to download file from $url."
        return 1
    fi
}

# @description Send an HTTP GET request to a specified URL and retrieve the response.
#
# @example
#   local response=$(network::http_get "https://api.example.com/users/1" "$data")
#   local response=$(network::http_get "https://api.example.com/users/1" "$data" "user:password")
#   local response=$(network::http_get "https://api.example.com/users/1" "$data" "API-TOKEN")
#
# @arg $1 string URL to send the GET request.
# @arg $2 string (optional) Authentication method and credentials.
#
# @exitcode 0 If the request is successful.
# @exitcode 1 If the request fails.
# @exitcode 2 If the required command argument is missing.
#
# @stdout Print the response body of the GET request.
network::http_get() {
    [[ $# -lt 1 ]] && printf "%s: Missing arguments\n" "${FUNCNAME[0]}" && return 2

    local command="curl -s -X GET -H 'Content-Type: application/json' -d '$2'"

    if [ -n "$2" ]; then
        command+=" -d '$2'"
    fi

    if [ -n "$3" ]; then
        if [[ $3 =~ ":" ]]; then
            command+=" --user $3"
        else
            command+=" -H 'Authorization: Bearer $3'"
        fi
    fi

    local response=$(eval "$command")
    if [ $? -eq 0 ]; then
        echo "$response"
        return 0
    else
        echo "Failed to send HTTP GET request to $1."
        return 1
    fi
}

# @description Send an HTTP POST request to a specified URL with data and retrieve the response.
#
# @example
#   local data="{\"name\":\"John\",\"age\":30}"
#   local response=$(network::http_post "https://api.example.com/users" "$data")
#   local response=$(network::http_post "https://api.example.com/users" "$data" "user:password")
#   local response=$(network::http_post "https://api.example.com/users" "$data" "API-TOKEN")
#
# @arg $1 string URL to send the POST request.
# @arg $2 string Data to send in the request body.
#
# @exitcode 0 If the request is successful.
# @exitcode 1 If the request fails.
# @exitcode 2 If the required command argument is missing.
#
# @stdout Print the response body of the POST request.
network::http_post() {
    [[ $# -lt 1 ]] && printf "%s: Missing arguments\n" "${FUNCNAME[0]}" && return 2

    local command="curl -s -X POST -H 'Content-Type: application/json' -d '$2'"
    if [ -n "$3" ]; then
        if [[ $3 =~ ":" ]]; then
            command+=" --user $3"
        else
            command+=" -H 'Authorization: Bearer $3'"
        fi
    fi
    command+=" $1"

    local response=$(eval "$command")
    if [ $? -eq 0 ]; then
        echo "$response"
        return 0
    else
        echo "Failed to send HTTP POST request to $1."
        return 1
    fi
}