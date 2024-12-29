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

## nut.conf
- set standalone mode which is for my use case of server connected to UPS
- add this
```
MODE=standalone
```
## upsd.conf
- add both these lines
```
LISTEN 127.0.0.1 3493
LISTEN ::1 3493
```
## ups.conf
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
```

## upsd.users
- add a user that is only recognized by nut and is not part of the OS users

```
nano /etc/nut/upsd.users
# add this
[monitor]
	password = [REDACTED]
	upsmon master
```

## upsmon.conf
- add the user and UPS you are monitoring just below the MONITOR section that has examples
```
  MONITOR BACKUPSPRO@localhost 1 monitor [REDACTED] master
```
# Testing
### restart all services and get status
```
for S in nut-client.service nut-monitor.service nut-server.service ; do systemctl restart $S ; done
```
- wait for services to restart and issue this
```
for S in nut-client.service nut-monitor.service nut-server.service ; do systemctl status $S -l ; done
```

- some permission issues are possible as upsd.users should not be world readable
- this error indicates the file ownership or permissions are wrong "/etc/nut/upsd.users is world readable"
- try this command

```
chown nut:nut /etc/nut/upsd.users
```
### check UPS status
```
upsc BACKUPSPRO@localhost ups.status
```
- Should show OL for "Online"

# References

https://gist.github.com/Jiab77/0778ef11a441f49df62e2b65f3daef76

https://zackreed.me/installing-nut-on-ubuntu/
