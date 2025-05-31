# Use case
- Power is reliable until it's not
- A power failure is likely to be short but will be followed by power starting and stopping one or more times in short succession
- The priority is a safe shutdown of the server and a manual restart when there is confidence that power is back and will stay back
- Powering down the server allows the UPS to continue powering the modem and router for much longer
- verify that the BIOS of your system is not set to power up automatically when power is supplied or a series of power outages could damage the operating system

# Installation
- plug UPS into a USB port
- note that out of the box proxmox uses the root user so sudo not required
```
apt install nut
```

# Detect UPS

## Scan USB devices only
```
nut-scanner -U
```

# Configuration

## nut.conf located in /etc/nut
- set standalone mode which is for my use case of server connected to UPS
- this line is the only line you need for this use case
```
MODE=standalone
```
## upsd.conf located in /etc/nut
- add both these lines
```
LISTEN 127.0.0.1 3493
LISTEN ::1 3493
```
## ups.conf located in /etc/nut
```
# Add some spacing and UPS details
echo -e "\n# Detected UPS from USB" | tee -a /etc/nut/ups.conf

# Add detected UPS details

nut-scanner -UNq 2>/dev/null | tee -a /etc/nut/ups.conf

# Check the result
cat /etc/nut/ups.conf
[nutdev1]
        driver = "usbhid-ups"
        port = "auto"
        vendorid = "051D"
        productid = "0002"
        product = "Back-UPS RS 1500MS2 FW:969.e2 .D USB FW:e2"
        serial = "0B2138N08003"
        vendor = "American Power Conversion"
        bus = "002"

```

### Edit the results to add your name and description for the UPS
- Formatting is important!  Do not have extra spaces before [BACKUPSPRO]
- by overiding the battery.charge.low the shutdown command will be issued when there is still plenty of runtime
- this is useful in case of slow or repeated shutdowns
```
# Detected UPS from USB
[BACKUPSPRO]
        driver = "usbhid-ups"
        port = "auto"
        desc = "APC BACK-UPS 1500 865W"
        vendorid = "051D"
        productid = "0002"
        product = "Back-UPS RS 1500MS2 FW:969.e2 .D USB FW:e2"
        serial = "0B2138N08003"
        vendor = "American Power Conversion"
        bus = "002"
        ignorelb
        override.battery.charge.low=50
```

## upsd.users located in /etc/nut
- add a user that is only recognized by nut and is not part of the OS users

```
nano /etc/nut/upsd.users
# add this to allow the user to SET the battery.charge.low
[monitor]
	password = [REDACTED]
        actions = SET
        instcmds = ALL
	upsmon master
```

## upsmon.conf located in /etc/nut
- add the user and UPS you are monitoring just below the MONITOR section that has examples
- change the location of the shutdown script to the custom script
```
MONITOR BACKUPSPRO@localhost 1 monitor [REDACTED] master
SHUTDOWNCMD "/etc/nut/shutdown_script.sh"
NOTIFYCMD /etc/nut/upssched-cmd
```
- this is also the file to configure what alerts you want to know about by removing the # at the start of the line

```
NOTIFYMSG ONLINE        "UPS %s on line power"
NOTIFYMSG ONBATT        "UPS %s on battery"
NOTIFYMSG LOWBATT       "UPS %s battery is low"
NOTIFYMSG COMMBAD       "Communications with UPS %s lost"
NOTIFYMSG REPLBATT      "UPS %s battery needs to be replaced"
NOTIFYMSG NOCOMM        "UPS %s is unavailable"
```
- and the notify settings
```

NOTIFYFLAG ONLINE       SYSLOG+WALL+EXEC
NOTIFYFLAG ONBATT       SYSLOG+WALL+EXEC
NOTIFYFLAG LOWBATT      SYSLOG+WALL+EXEC
NOTIFYFLAG COMMBAD      SYSLOG+WALL+EXEC
NOTIFYFLAG REPLBATT     SYSLOG+WALL+EXEC
NOTIFYFLAG NOCOMM       SYSLOG+WALL+EXEC

```
## upssched.conf located in /etc/nut
```
# cat upssched.conf

CMDSCRIPT etc/nut/upssched-cmd

PIPEFN /var/db/nut/upssched.pipe
LOCKFN /var/db/nut/upssched.lock

AT ONLINE   BACKUPSPRO@localhost EXECUTE online
AT ONBATT   BACKUPSPRO@localhost EXECUTE onbatt
AT LOWBATT  BACKUPSPRO@localhost EXECUTE lowbatt
AT COMMBAD  BACKUPSPRO@localhost EXECUTE commbad
AT REPLBATT BACKUPSPRO@localhost EXECUTE replbatt
AT NOCOMM   BACKUPSPRO@localhost EXECUTE nocomm

```

## upssched-cmd located in /etc/nut
See [here](https://github.com/designworld-ca/Proxmox/blob/3b2099eeb186c48c978b7f2c64baaafef17e8d75/upssched-cmd.sh)

## shutdown_script.sh located in /etc/nut
See [here](https://github.com/designworld-ca/Proxmox/blob/3b2099eeb186c48c978b7f2c64baaafef17e8d75/shutdown_script.sh)
