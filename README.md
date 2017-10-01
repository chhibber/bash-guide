# My Bashisms

1. Keep it simple and explicit

### Logging Script Output

1.  Log stdout and stderr output to files
2.  Keep stderr and stdout separate.  Apps or programs calling your script may want stderr output
3.  Prepend a time stamp to each line of output
4.  Add a separator to demarc each new run of the script 

Example:
```
LOG_FILE=log

# Prepend a timestamp to each line, send it to log.err and backout to stdout (via tee)
exec 2> >(while read line; do echo "$(date +%Y-%m-%d::%H:%M:%S) :: $line"; done | tee -a ${LOG_FILE}.err)

# Prepend a timestamp to each line, send it to log and backout to stdout (via tee)
exec > >(while read line; do echo "$(date +%Y-%m-%d::%H:%M:%S) :: $line"; done | tee -a ${LOG_FILE})

# Another alternative (But it combines both stderr and stdout)
# exec &> >(while read line; do echo "$(date +%Y-%m-%d::%H:%M:%S) :: $line"; done | tee -a ${LOG_FILE})


# Add a demarcation point to show a new run of the script
echo -e "###### NEW LOG ###### \n\n" >> ${LOG_FILE}.err
echo -e "###### NEW LOG ###### \n\n" >> ${LOG_FILE}
```

### Trapping Signals

Create a function to carry out cleanup tasks, then use the `trap` builtin to call the function in the event that users hits control+c or the script exits early for some reason.

Example:
```
#
# Add to the top of your script so you can catch things like:
#   * control + c
#   * script exiting unintentionally
#
function cleanup() {

    echo "Cleaning up"
    rm /file/with/sensitiveinfo
}

trap cleanup SIGHUP SIGINT SIGTERM EXIT
```

### My Bash Functions Guide 

* I have been using the following standards in my functions:
    * Use the keyword `local` for locally defined function variables.  
    * prefix local variables with an underscore: _varname <- python influenced
    * Function names: make them descriptive and use underscores between words
    * Define a function header, this has been good for standardizing output and having a clear definition of where the script exited or where you are in it as it runs.
    * Define an error function to be called on any errors
    

##### Function header:
```
function function_header() {

    # Where ever this is included it will write out the function header
    # and any message passed in.  The Header name will be parsed and any
    # underscores will be replaced with a space

    local _message=$1

    echo ""
    echo "Function: ${FUNCNAME[1]//_/ }"
    echo "================================================================================"
    echo ""
    echo -e "  ${_message}"
    echo ""

}

```

##### Error Function

Leverage a function to capture errors and print a standardized message followed by an exit.

```
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
```


Examples of using the `error` call with return code of the previous command:
```
# The redirect at the end is optional, if this is customer facing script
# you may want to hide stderr and present the user with another message.
ls /a/file/that/does/not/exist 2>/dev/null
error $? "Unable to list the file"
```

Output:
```
 ----------------------------------------------------------------------------------------

  Error: main
    Return Code: 1
    Message: Unable to list the file

 ----------------------------------------------------------------------------------------
```


Examples of using the  `error` call when the command returns 0 but result still constitutes an error:
```
# In cases where the return code returned is 0 but the result is not
# the expected result you can use the error function like this:
_http_return_code=$(curl -s -I http://www.example.org/doesnotexist | head -n 1| cut -d$' ' -f2)
if [[ ${_return_code} -ne 200 ]]; then
  error 1 "Unable to download file"
fi
```

Output:
```
 ----------------------------------------------------------------------------------------

  Error: main
    Return Code: 1
    Message: Unable to download file

 ----------------------------------------------------------------------------------------
```


##### Example Function

* Add a description at the top (But inside the function)
* Uses `local` to scope variables locally and predefine variables as needed at the top
* calls the function header
* calls the error function

```
function example__pre_install() {

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
```


#### Getting The System Distribution and OS info

Leverage python, it's generally available on most systems, has
builtins to obtain the OS and distribution details, and short snippets
can easily be pulled into your script.

* cross platform way to get the OS:
```
$ python -c 'import platform; print(platform.system());'
Darwin
```

* cross platform way to get the distribution:

``` 
$ python -c "import platform; print(platform.dist());"
('Ubuntu', '14.04', 'trusty')
```