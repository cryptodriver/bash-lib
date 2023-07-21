#!/bin/bash

# @file Submission
# @brief Functions for config submission servers.

# Import libraries
source "init.sh"

# @description Reads configuration from the database and performs necessary actions based on the retrieved data.
#
# @noargs
#
# @exitcode 0 If the configuration is successfully retrieved and processed.
# @exitcode 1 If there is an error during the configuration retrieval or processing.
_apply_config() {
    logger::info "$(basename "$0")->${FUNCNAME[0]}() START"

    # Logic for reading the configuration from db
    local _token=$(config::get "api" "token")
    local _url=$(config::get "api" "host")
    local _data="{'oem': '$_OEM_'}"

    # local _resp=$(network::http_get "$_url" "" "$_token")
    local _resp="{\"smtpd_sasl_auth_enable\":true}"

    if [ -n "$_resp" ]; then
        local _value=$(json::get_value "smtpd_sasl_auth_enable" <<< "${_resp}")

        if variable::is_bool "$_value"; then
            # config::set "/etc/postfix/main.cf" "smtpd_sasl_auth_enable=$_value"
            logger::info "$(basename "$0")->${FUNCNAME[0]}() set smtpd_sasl_auth_enable=$_value"
        fi
    else
        logger::error "$(basename "$0")->${FUNCNAME[0]}() reponse data not exists: $_resp"
        return 1
    fi

    logger::info "$(basename "$0")->${FUNCNAME[0]}() END"
}


# @description Performs post-config tasks after applying the custom settings.
#
# @noargs
#
# @exitcode 0 If the post-config tasks are successfully executed.
# @exitcode 1 If there is an error during the post-processing tasks.
#
_post_config() {
    logger::info "$(basename "$0")->${FUNCNAME[0]}() START"

    # Perform reload postfix 
    local _exists=$(check::command_exists "postfix")
    
    if [[ -n $_exists && $_exists -eq 0 ]]; then
        postfix check

        # Check the exit code of the previous command
        if [ $? -eq 0 ]; then
            systemctl restart postfix
        else
            logger::error "$(basename "$0")->${FUNCNAME[0]}() postfix check failed."
        fi
    else
        logger::warn "$(basename "$0")->${FUNCNAME[0]}() postfix not found."
    fi

    # Perform reload XXXX


    logger::info "$(basename "$0")->${FUNCNAME[0]}() END"
}

# @description Main function responsible for executing the main logic of the script.
#
# @arg $1 string The first argument representing the OEM.
#
# @exitcode 2 If there are missing arguments.
#
# @example
#   main "FB00"
#
# @stdout Logs informational messages.
main() {
    logger::info "$(basename "$0")->${FUNCNAME[0]}() START <<<<<<<<<<"

    # [[ $# -lt 1 ]] && printf "%s: Missing arguments\n" "${FUNCNAME[0]}" && return 2

    # _OEM_="${1}"

    # # validation check for paramters
    # if ! variable::is_match_regex "$_OEM_" "^[A-Z0-9]{4}$"; then
    #     logger::error "$(basename "$0")->${FUNCNAME[0]}() invalid oem code: $_OEM_"
    #     exit 1
    # fi

    # _apply_config

    # if [[ $? -eq 0 ]]; then
    #     _post_config
    # fi

    logger::info "$(basename "$0")->${FUNCNAME[0]}() END   >>>>>>>>>>"
}

# Execute the main function
main "$@"