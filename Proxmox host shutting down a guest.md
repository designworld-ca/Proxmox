# Prerequisites

- you must have the qemu guest installed and working

# From the host command line
- I used my custom script which shuts down the docker containers then the guest OS
```
qm guest exec 100 -- /bin/bash -c "/home/<redacted>/safe_shutdown.sh"
```
