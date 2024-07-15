#!/bin/bash
# My shared functions
# https://stackoverflow.com/questions/2990414/echo-that-outputs-to-stderr
# https://www.geeksforgeeks.org/how-to-change-the-output-color-of-echo-in-linux/
or_exit() {
    local exit_status=$?
    local message=$*

    if [[ $exit_status -gt 0 ]]
    then
        echo -e "\e[0;31m $(date '+%F %T') [$(basename "$0" .sh)] [ERROR] $message" >&2
        exit "$exit_status"
    fi
}