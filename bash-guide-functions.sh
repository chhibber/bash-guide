#!/usr/bin/env bash

function function_header() {

    # Where ever this is included it will write out the function header
    # and any message passed in.  The Header name will be parse and any
    # underscores will be replaced with a space

    local _message=$1

    echo ""
    echo "Function: ${FUNCNAME[1]//_/ }"
    echo "================================================================================"
    echo ""
    echo -e "  ${_message}"
    echo ""

}

function error() {

    local _return_code=$1
    local _message=$2

    if [ ${_return_code} -ne 0 ]; then

        echo    ""
        echo    " ----------------------------------------------------------------------------------------"
        echo    ""
        echo    "  Error in: ${FUNCNAME[1]}"
        echo    "    Return Code: ${_return_code}"
        echo -e "    Message: ${_message}"
        echo    ""
        echo    " ----------------------------------------------------------------------------------------"
        echo    ""

        exit 1
    fi

}

function example_pre_install() {

    # Example description if needed

    local _msg="Carrying out preinstall steps..."
    local _system=$(python -c 'import platform; print(platform.system());')
    local _dist=''

    function_header "${_msg}"

    if [[ ${_system} == "Darwin" ]]; then
        _dist=$(python -c "import platform; print(platform.mac_ver());")
    else
        _dist=$(python -c "import platform; print(platform.dist());")
    fi

    echo "  * ${_system}: ${_dist}"
    echo "  * Verifying system..."

    # Do Verification stuff.

    echo "  * Installing packages..."

    # Do Install stuff

    _http_return_code=$(curl -s -I http://www.example.org/exampleinstaller | head -n 1| cut -d$' ' -f2)
    if [[ ${_return_code} -ne 200 ]]; then
      error 1 "Unable to download file"
    fi

}