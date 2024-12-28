# Preparation

## From the ESXI console
- make sure there are no snapshots present
- make a note of the CPU and sockets allocated to the guest
- export your VM's to another server or computer
- the export produces an .ova and a .vmdk file but you only need the .vmdk

## Set up the Proxmox install
- copy proxmox iso to a usb drive from  
- https://www.proxmox.com/downloads
- shut down the VmWare host
- reboot and change boot order from SD card first to USB drive

# Proxmox installation
- reboot into proxmox iso and install
- for login note that username is root not the email address you supplied
- configure Proxmox as desired
- if you are not paying for support select pve-no-subscription under subscription
- note that local(prox) where proxmox is installed is less than 100Gb
- suggestions to convert or copy your vmdk to the root install will not work if the .vmdk file is larger than ~80 Gb

# Connect VmWare guest .vmdk file
- copy vmdk from the VmWare export to a usb drive
- connect usb to host server
```
mkdir /mnt/usb
mount /dev/sdc1 /mnt/usb/
ls /mnt/usb
```
- and validate that vmdk is there

# Create a new Proxmox guest VM
- create a new VM with number of sockets and CPU closely matching the guest you wish to import
- default settings are fine for most uses
- under "Create virtual machine" "OS" select "do not use any media"
- note the VM ID which will start with 100 and you will need later
- you will need to add a disk but we will not use it so the settings are not important
- under Confirm do not select "start after created", just click finish
- note your new vm is located in local-lvm (prox)
- click on the left side listing for your VM
- go to Hardware and remove the hard disk by selecting "Detach from VM"
- the name for the disk will change to Unused Disk 0, remove it
- from the Prox host on the left side select the console

# Import and convert the VmWare .vmdk file to Proxmox
- enter this command, it will take a while to process
```
qm importdisk 100 /mnt/usb/disk-0.vmdk local-lvm -format qcow2
```

# Configure the Proxmox guest VM
- once import is complete go to the guest VM Hardware and you will see "Unused Disk 0" again 
- this time it contains the imported vmdk which has been converted to the preferred Proxmox format of qcow2
- click on the Unused Disk entry and click Edit.
- the default settings should be suitable for most use cases.  Click Add
- start the guest VM and review the messages seen at boot for any errors

## IP Address
- if you are using a static IP for the guest you will have to edit the network interfaces file
- from the guest console enter ip a and confirm which of the interfaces is not working

- For ubuntu enter
```
sudo nano /etc/netplan/00-installer-config.yaml
```
- change the name of the network interface from ens160 to ens18  (for my case)
- save and enter
```
sudo netplan apply
```
- validate everything is running

## Mods

### To remove the nag screen about not having an enterprise subscription
https://github.com/Meliox/PVE-mods

### To install the qemu guest agent
https://www.itsfullofstars.de/2021/04/proxmox-qemu-guest-agent-installation/
#### Install guest agent on the vm guest
```
sudo apt-get install qemu-guest-agent
```
-exit

#### Configure guest agent in the Proxmox GUI
- shut down the guest
- go to options, select the qemu guest agent entry and edit the value to enable the agent
- start the guest
- validate that the guest agent is running in the guest by entering on the console
```
systemctl status show
```
the proxmox gui should now show the IP address and Mac address


## Backout Plan
- shut down the host machine
- change the boot order back to the SD Card
- reboot into VmWare ESXI
  
## References

https://www.itsfullofstars.de/2019/07/import-ova-as-proxmox-vm/
 
https://www.proxmox.com/downloads

https://github.com/Meliox/PVE-mods

https://www.itsfullofstars.de/2021/04/proxmox-qemu-guest-agent-installation/

https://pve.proxmox.com/wiki/Migration_of_servers_to_Proxmox_VE

https://blog.galt.me/migrating-from-esxi-to-proxmox/

https://nicolas.busseneau.fr/en/blog/2021/07/esxi-to-proxmox-migration

https://pve.proxmox.com/wiki/Advanced_Migration_Techniques_to_Proxmox_VE#Server_self-migration
