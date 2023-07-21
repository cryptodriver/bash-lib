#!/usr/bin/env bash

# @file Config
# @brief Simply get item value from config file.

# @description Read the value of the specified item from the given config file
#
# @example
#   config::get "api" "host"
#   #Output
#   https://example.com
#
# @arg $1 string Id of config file.
# @arg $2 string Name of the item to retrieve.
#
# @exitcode 0 If the item is found in the config file.
# @exitcode 1 If any error occurs during the process.
# @exitcode 2 If the required arguments are missing.
#
# @stdout The value of the requested item if found, otherwise an error message.
config::get() {
    [[ $# -lt 2 ]] && printf "%s: Missing arguments\n" "${FUNCNAME[0]}" && return 2

    local _file="$_BASE_/etc/$1.conf"

    if [ ! -f "$_file" ]; then
        echo "Config file '$_file' not found."
        return 1
    fi

    local value=$(grep -E "^$2[[:space:]]*=" "$_file" | cut -d '=' -f2-)
    value=$(echo "$value" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')
    echo "$value"
}

# @description Process configuration file by modifying or commenting out configuration items.
#
# @example
#   config::set "config.txt" "item=new_value"
#   config::set "$conf_file" "new_item=value"
#   config::set "$conf_file" "item"
#   #Output
#   item = new_value
#   new_item=value
#   # item=value
#
# @arg $1 string Path to the configuration file.
# @arg $2 string Configuration item and value in the format "item=value".
#
# @exitcode 0  If the configuration item is modified or added successfully.
# @exitcode 1 If the configuration file does not exist.
config::set() {
    local conf_file="$1"
    local item_value="$2"

    # Check if the configuration file exists
    if [ ! -f "$conf_file" ]; then
        echo "Configuration file does not exist: $conf_file"
        return 1
    fi

    # Split the configuration item and new value
    IFS='=' read -r item new_value <<< "$item_value"

    # Check if the configuration item exists
    if grep -q "^[[:space:]]*$item[[:space:]]*=" "$conf_file"; then
        if [[ "$item_value" == *"="* ]]; then
            # Modify the value of the existing configuration item while preserving the original format
            sed -i "s|^\([[:space:]]*$item[[:space:]]*=.*\)$|$item=$new_value|" "$conf_file"
            echo "Modified configuration item: $item = $new_value"
        else
            # Comment out the existing configuration item
            sed -i "s|^\([[:space:]]*$item[[:space:]]*=.*\)$|# \1|" "$conf_file"
            echo "Commented out configuration item: $item"
        fi
    else
        # Determine the indentation of the new configuration item based on the existing configuration items
        local indentation=""
        while IFS= read -r line; do
            if [[ "$line" =~ ^([[:space:]]*)$item ]]; then
                indentation="${BASH_REMATCH[1]}"
                break
            fi
        done < "$conf_file"

        # Add the new configuration item with the determined indentation
        if [[ $(tail -c 1 "$conf_file") ]]; then
            echo "" >> "$conf_file"
        fi
        echo "$indentation$item = $new_value" >> "$conf_file"
        echo "Added new configuration item: $item=$new_value"

        if [ -z "$new_value" ]; then
            # Comment out the existing configuration item
            sed -i "s|^\([[:space:]]*$item[[:space:]]*=.*\)$|# \1|" "$conf_file"
            echo "Commented out configuration item: $item"
        fi
    fi
}
