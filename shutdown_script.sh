# don't forget to make the script executable with chmod +x <your scriptname>
#!/bin/sh
# cat shutdown_script.sh
# shut down the docker containers in vm 100.  A fast shutdown can cause file corruption
now = "$(date)"
echo "UPS charge is half used for $(hostname) on $now." | mail -s "Power Shutdown" <your email here>
qm guest exec 100 -- /bin/bash -c "home/<redacted>/safe_shutdown.sh"
shutdown -P +0

