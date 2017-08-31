# My Bashisms

1. Keep it simple and explicit

### Loggin Script Output

1.  Log stdout and stderr output to files
2.  Keep stderr and stdout separate.  Apps or programs calling your script may want stderr output
3.  Preppend a time stamp to each line of output
4.  Add a separator to demarc each new run of the script 

Example:
```
exec 2> >(while read line; do echo "$(date +%Y-%m-%d::%H:%M:%S) :: $line"; done | tee -a ${LOG_FILE}.err)
exec > >(while read line; do echo "$(date +%Y-%m-%d::%H:%M:%S) :: $line"; done | tee -a ${LOG_FILE})

echo -e "###### NEW LOG ###### \n\n" >> ${LOG_FILE}.err
echo -e "###### NEW LOG ###### \n\n" >> ${LOG_FILE}
```
