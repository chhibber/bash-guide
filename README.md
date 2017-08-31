# My Bashisms

1. Keep it simple and explicit

### Logging Script Output

1.  Log stdout and stderr output to files
2.  Keep stderr and stdout separate.  Apps or programs calling your script may want stderr output
3.  Preppend a time stamp to each line of output
4.  Add a separator to demarc each new run of the script 

Example:
```
LOG_FILE=log

# Prepend a timestamp to each line, send it to log.err and backout to stdout (via tee)
exec 2> >(while read line; do echo "$(date +%Y-%m-%d::%H:%M:%S) :: $line"; done | tee -a ${LOG_FILE}.err)

# Prepend a timestamp to each line, send it to log and backout to stdout (via tee)
exec > >(while read line; do echo "$(date +%Y-%m-%d::%H:%M:%S) :: $line"; done | tee -a ${LOG_FILE})

# Add a demarcation point to show a new run of the script
echo -e "###### NEW LOG ###### \n\n" >> ${LOG_FILE}.err
echo -e "###### NEW LOG ###### \n\n" >> ${LOG_FILE}
```
