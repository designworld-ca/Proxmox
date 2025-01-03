# don'r forget to make the script executable with chmod +x <your scriptname>
#!/bin/sh
# cat shutdown_script.sh
# shut down the docker containers in vm 100.  A forced shutdown can cause file corruption
echo "UPS charge is half used for $(hostname)." | mail -s "Power Shutdown" <your email here>
qm guest exec 100 -- /bin/bash -c "home/<redacted>/safe_shutdown.sh"
shutdown -P +0

