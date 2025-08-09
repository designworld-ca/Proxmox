# Preparation
- Read the upgrade page a few times.  
- Wait a few days for first upgraders to report back
- Make a list of the changes you have made in files.  I made changes to the nut files and did not want them overwritten
- Run the upgrade script from the Proxmox command shell
```
 pve8to9 --full
```

# Resolving Issues and Warnings
- Upgrade Proxmox to 8.4.0 or higher using the automatic check and patch
- After running pve8to9 these issues were found
- NOTICE: Starting with PVE 9, autoactivation will be disabled for new LVM/LVM-thin guest volumes. This system has some volumes that still have autoactivation enabled. All volumes with autoactivations reside on local storage, where this normally does not causes any issues.
- Resolve with
  ```
  /usr/share/pve-manager/migrations/pve-lvm-disable-autoactivation
  ```
- WARN: The matching CPU microcode package 'intel-microcode' could not be found! Consider installing it to receive the latest security and bug fixes for your CPU.
- Resolve with
```
cd /etc/apt
nano sources.list
```
- add these three lines
```
deb http://deb.debian.org/debian bookworm main contrib non-free non-free-firmware

deb http://deb.debian.org/debian-security bookworm-security main contrib non-free non-free-firmware

deb http://deb.debian.org/debian bookworm-updates main contrib non-free non-free-firmware
```
- then update the package repositories with
```
  apt update
  apt install --reinstall grub-efi-amd64
  apt dist-upgrade
```
- Update ceph respositories even if not used, it flags a warning regardless. Create a new file ceph.sources
```
nano /etc/apt/sources.list.d/ceph.sources
Types: deb
URIs: https://enterprise.proxmox.com/debian/ceph-squid
Suites: trixie
Components: enterprise
Signed-By: /usr/share/keyrings/proxmox-archive-keyring.gpg
```
- then remove the old /etc/apt/sources.list.d/ceph.list file and issue
```
apt update
apt policy
```
- WARN: systemd-boot meta-package installed but the system does not seem to use it for booting. This can cause problems on upgrades of other boot-related packages. Consider removing 'systemd-boot'
- Resolve with
```
apt remove systemd-boot
```
- turn off all virtual machines, run a backup to a storage site not on the server

## Migration

- run pve8to9 to check there are no errors or warnings
- run the migration command
```
apt dist-upgrade
```
- skip the list of changes by pressing q
- do not allow service restarts during the process as you will be rebooting the server
- do not let files you changed such as nut files or SSL to be overwritten
- keep your currently installed version of /etc/issue
- if you did not make changes keep the new version of /etc/lvm/lvm.conf
- when dist-upgrade completes run pve8to9 one last time
- it will probably note that is an older kernel version and suggest rebooting
- reboot the system
- from the Proxmox command shell run
  ```
  apt modernize-sources
  ```
## References

https://pve.proxmox.com/wiki/Upgrade_from_8_to_9
