# don'r forget to make the script executable with chmod +x <your scriptname>
#!/bin/sh
# cat shutdown_script.sh
# shut down the docker containers in vm 100.  A forced shutdown can cause file corruption
qm guest exec 100 -- /bin/bash -c "home/roo/safe_shutdown.sh"
shutdown -P +0

