# Prerequisites

- you must have the [qemu guest installed and working](https://github.com/designworld-ca/Proxmox/blob/main/Migration.md#configure-the-proxmox-guest-vm) .

# From the host command line
- I used my [custom script](https://github.com/designworld-ca/Proxmox/blob/a6bb9097c43c580be0d67adedf5baca72d8867ba/shutdown_script.sh) which shuts down the docker containers then the guest OS
```
qm guest exec 100 -- /bin/bash -c "/home/<redacted>/safe_shutdown.sh"
```
