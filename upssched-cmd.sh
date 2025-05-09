# cat upssched-cmd
# dont forget to chmod +x this file
# the use case here is that we will be notified by email of a shutdown from the shutdown script
# notifications here are for log entries 
# we do want an email in the event of an edge case
# like bad or no communication or replace battery messages from the battery
#!/bin/sh
# upssched-cmd for workstation
# note that the replbatt and nocomm flags are handled by the last (default) option
now="$(date)"
logger -i -t upssched-cmd Calling upssched-cmd $1


UPS="BACKUPSPRO"
STATUS=$( upsc $UPS ups.status )
CHARGE=$( upsc $UPS battery.charge )
CHMSG="[$STATUS]:$CHARGE%"

case $1 in
  online)
    MSG="$UPS, $CHMSG - power supply has been restored."
    ;;
  onbatt)
    MSG="$UPS, $CHMSG - power failure - save your work!"
    ;;
  lowbatt)
    MSG="$UPS, $CHMSG - shutdown now!"
    ;;
  commbad)
    MSG="NUT heart beat fails. $CHMSG"
    # Email to sysadmin
    MSG1="Hello, upssched-cmd reports NUT heartbeat has failed."
    MSG2="Current status: $CHMSG \n\n$0 $1"
    MSG3="\n\n$( ps -elf | grep -E 'ups[dms]|nut' )"
    # there can be no space after the -s argument.
    echo -e "$MSG1 $MSG2 $MSG3" | mail -s"NUT heart beat fails. Currently $CHMSG" <an email address>
    ;;
 *)
    logger -i -t upssched-cmd "Unusual event: \"$1\", $CHMSG"
    echo -e "$MSG1 $MSG2 $MSG3" | mail -s"APC UPS unusual event at $now. Currently $CHMSG" <an email address>
    exit 1
    ;;
esac
logger -i -t upssched-cmd $MSG
