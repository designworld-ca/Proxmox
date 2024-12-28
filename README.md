# Proxmox
How to migrate from VmWare and maintenance of a Proxmox installation

## Why Migrate from VmWare?

- Existing install of VmWare Esxi 6.0 is out of support
- VmWare Operating System is installed on SD cards which did not do well during unplanned power shutdowns.
- Settings such as root password, guest machines are not updated, probably due to VmWare OS corruption
- The effort to reinstall an OS which needs to be updated seems to be more work than installing Proxmox
- Getting a UPS to configure VmWare Esxi to gracefully power down the guests and the hosts is challenging

## Use Case

- Dell Server with two drives running software RAID
- All VM's are one drive leaving a second drive free
- Extensive downtime is allowed
