# Testing

## Nut stopped working after upgrading to Proxmox 8.3.2
- appears to be a permissions issue
- started working again after a shutdown and restart
  
### restart all services and get status
```
for S in nut-client.service nut-monitor.service nut-server.service ; do systemctl restart $S ; done
```
- wait a minute or two for services to restart and issue this
```
for S in nut-client.service nut-monitor.service nut-server.service ; do systemctl status $S -l ; done
```
### Results of status check
- note that after changing configuration files some errors can be resolved with a reboot
```
● nut-monitor.service - Network UPS Tools - power device monitor and shutdown controller
     Loaded: loaded (/lib/systemd/system/nut-monitor.service; enabled; preset: enabled)
     Active: active (running) since Fri 2025-01-03 15:14:09 EST; 4min 1s ago
   Main PID: 1026 (upsmon)
      Tasks: 2 (limit: 18843)
     Memory: 4.2M
        CPU: 14ms
     CGroup: /system.slice/nut-monitor.service
             ├─1026 /lib/nut/upsmon -F
             └─1075 /lib/nut/upsmon -F

Jan 03 15:14:09 <redacted> systemd[1]: Started nut-monitor.service - Network UPS Tools - power device monitor and shutdown controller.
Jan 03 15:14:09 <redacted> nut-monitor[1026]: fopen /run/nut/upsmon.pid: No such file or directory
Jan 03 15:14:09 <redacted> nut-monitor[1026]: Could not find PID file to see if previous upsmon instance is already running!
Jan 03 15:14:09 <redacted> nut-monitor[1026]: UPS: BACKUPSPRO@localhost (primary) (power value 1)
Jan 03 15:14:09 <redacted> nut-monitor[1026]: Using power down flag file /etc/killpower
Jan 03 15:14:09 <redacted> nut-monitor[1075]: Init SSL without certificate database
● nut-monitor.service - Network UPS Tools - power device monitor and shutdown controller
     Loaded: loaded (/lib/systemd/system/nut-monitor.service; enabled; preset: enabled)
     Active: active (running) since Fri 2025-01-03 15:14:09 EST; 4min 1s ago
   Main PID: 1026 (upsmon)
      Tasks: 2 (limit: 18843)
     Memory: 4.2M
        CPU: 14ms
     CGroup: /system.slice/nut-monitor.service
             ├─1026 /lib/nut/upsmon -F
             └─1075 /lib/nut/upsmon -F

Jan 03 15:14:09 <redacted> systemd[1]: Started nut-monitor.service - Network UPS Tools - power device monitor and shutdown controller.
Jan 03 15:14:09 <redacted> nut-monitor[1026]: fopen /run/nut/upsmon.pid: No such file or directory
Jan 03 15:14:09 <redacted> nut-monitor[1026]: Could not find PID file to see if previous upsmon instance is already running!
Jan 03 15:14:09 <redacted> nut-monitor[1026]: UPS: BACKUPSPRO@localhost (primary) (power value 1)
Jan 03 15:14:09 <redacted> nut-monitor[1026]: Using power down flag file /etc/killpower
Jan 03 15:14:09 <redacted> nut-monitor[1075]: Init SSL without certificate database
● nut-server.service - Network UPS Tools - power devices information server
     Loaded: loaded (/lib/systemd/system/nut-server.service; enabled; preset: enabled)
     Active: active (running) since Fri 2025-01-03 15:14:09 EST; 4min 1s ago
   Main PID: 1025 (upsd)
      Tasks: 1 (limit: 18843)
     Memory: 1.1M
        CPU: 12ms
     CGroup: /system.slice/nut-server.service
             └─1025 /lib/nut/upsd -F

Jan 03 15:14:09 <redacted> nut-server[1025]: Could not find PID file '/run/nut/upsd.pid' to see if previous upsd instance is already running!
Jan 03 15:14:09 <redacted> nut-server[1025]: listening on ::1 port 3493
Jan 03 15:14:09 <redacted> nut-server[1025]: listening on 127.0.0.1 port 3493
Jan 03 15:14:09 <redacted> upsd[1025]: listening on 127.0.0.1 port 3493
Jan 03 15:14:09 <redacted> nut-server[1025]: Connected to UPS [BACKUPSPRO]: usbhid-ups-BACKUPSPRO
Jan 03 15:14:09 <redacted> nut-server[1025]: Running as foreground process, not saving a PID file
Jan 03 15:14:09 <redacted> upsd[1025]: Connected to UPS [BACKUPSPRO]: usbhid-ups-BACKUPSPRO
Jan 03 15:14:09 <redacted> upsd[1025]: Running as foreground process, not saving a PID file
Jan 03 15:14:09 <redacted> nut-server[1025]: User monitor@127.0.0.1 logged into UPS [BACKUPSPRO]
Jan 03 15:14:09 <redacted> upsd[1025]: User monitor@127.0.0.1 logged into UPS [BACKUPSPRO]

```
- some permission issues are possible as upsd.users should not be world readable
- this error indicates the file ownership or permissions are wrong "/etc/nut/upsd.users is world readable"
- try this command

```
chown nut:nut /etc/nut/upsd.users
chown -R nut:nut /run/nut
```
### check what commands can be issued to the UPS
- this is not accurate as you can set the battery.charge.low value from ups.conf
```
upscmd -l BACKUPSPRO
Instant commands supported on UPS [BACKUPSPRO]:

beeper.disable - Disable the UPS beeper
beeper.enable - Enable the UPS beeper
beeper.mute - Temporarily mute the UPS beeper
beeper.off - Obsolete (use beeper.disable or beeper.mute)
beeper.on - Obsolete (use beeper.enable)
load.off - Turn off the load immediately
load.off.delay - Turn off the load with a delay (seconds)
shutdown.reboot - Shut down the load briefly while rebooting the UPS
shutdown.stop - Stop a shutdown in progress
test.battery.start.deep - Start a deep battery test
test.battery.start.quick - Start a quick battery test
test.battery.stop - Stop the battery test
test.panel.start - Start testing the UPS panel
test.panel.stop - Stop a UPS panel test
```
### check UPS status
```
upsc BACKUPSPRO@localhost ups.status
```
- Should show OL for "Online"
### check properties of running configuration of UPS
- note that battery.charge.low is now 50 due to the ups.conf file settings
```
upsc BACKUPSPRO
Init SSL without certificate database
battery.charge: 100
battery.charge.low: 50
battery.charge.warning: 50
battery.date: 2001/09/25
battery.mfr.date: 2021/09/17
battery.runtime: 2883
battery.runtime.low: 120
battery.type: PbAc
battery.voltage: 27.4
battery.voltage.nominal: 24.0
device.mfr: American Power Conversion
device.model: Back-UPS RS 1500MS2
device.serial: 0B2138N08003
device.type: ups
driver.flag.ignorelb: enabled
driver.name: usbhid-ups
driver.parameter.bus: 002
driver.parameter.pollfreq: 30
driver.parameter.pollinterval: 2
driver.parameter.port: auto
driver.parameter.product: Back-UPS RS 1500MS2 FW:969.e2 .D USB FW:e2
driver.parameter.productid: 0002
driver.parameter.serial: 0B2138N08003
driver.parameter.synchronous: auto
driver.parameter.vendor: American Power Conversion
driver.parameter.vendorid: 051D
driver.version: 2.8.0
driver.version.data: APC HID 0.98
driver.version.internal: 0.47
driver.version.usb: libusb-1.0.26 (API: 0x1000109)
input.sensitivity: medium
input.transfer.high: 144
input.transfer.low: 88
input.transfer.reason: input voltage out of range
input.voltage: 119.0
input.voltage.nominal: 120
ups.beeper.status: disabled
ups.delay.shutdown: 20
ups.firmware: 969.e2 .D
ups.firmware.aux: e2
ups.load: 15
ups.mfr: American Power Conversion
ups.mfr.date: 2021/09/17
ups.model: Back-UPS RS 1500MS2
ups.productid: 0002
ups.realpower.nominal: 900
ups.serial: 0B2138N08003
ups.status: OL
ups.test.result: No test initiated
ups.timer.reboot: 0
ups.timer.shutdown: -1
ups.vendorid: 051d
```
# References

https://gist.github.com/Jiab77/0778ef11a441f49df62e2b65f3daef76

https://zackreed.me/installing-nut-on-ubuntu/

https://dan.langille.org/2020/09/07/monitoring-your-ups-using-nut-on-freebsd/

https://community.ipfire.org/t/nut-ups-howto-shut-down-client-after-2-min-on-battery/9096/6
