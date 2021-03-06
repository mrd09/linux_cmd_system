print("")
print("- Table 2: Selenium: Action")
row_6 = '+ {:-^15} + {:-^60} +'.format('','')
print(row_6)
row_6_1 = '+ {:^15} + {:^60} +'.format('Method name','Action in Webpage')
print(row_6_1)
row_6 = '+ {:-^15} + {:-^60} +'.format('','')
print(row_6)

row_24 = '| {:^15} | {:^60} |'.format('send_keys()',"Sending keystrokes to text fields on a web page")
print(row_24)
row_25 = '| {:<15} | {:^60} |'.format('',"of finding the <input> or <textarea> element ")
print(row_25)
print(row_6)


print("- Boot Process ")
row_1 = '+ {:-^60} +'.format('')
print(row_1)
row_2 = '+ {:^60} +'.format('Power on the machine')
print(row_2)
print(row_1)

row_3 = ' {:^60} '.format('|')
print(row_3)
row_4 = ' {:^60} '.format('V')
print(row_4)

row_1 = '+ {:-^60} +'.format('')
print(row_1)
row_5 = '| {:^60} |'.format('BIOS')
print(row_5)
row_1 = '+ {:-^60} +'.format('')
print(row_1)
row_6 = '| {:^60} |'.format('- BIOS check if all basic hardware of machine are working')
print(row_6)
row_7 = '| {:<60} |'.format('  properly or not (POST process): Ex: keyboard, RAM..')
print(row_7)
row_8 = '| {:<60} |'.format(' - Search for bootable device to load MBR in next stage:')
print(row_8)
row_9 = '| {:<60} |'.format('  Ex:  hard disk, floppy disk, pen drive')
print(row_9)
print(row_1)

row_3 = ' {:^60} '.format('|')
print(row_3)
row_4 = ' {:^60} '.format('V')
print(row_4)

row_1 = '+ {:-^60} +'.format('')
print(row_1)
row_10 = '| {:^60} |'.format('MBR(Master Boot Record)')
print(row_10)
row_1 = '+ {:-^60} +'.format('')
print(row_1)
row_11 = '| {:<60} |'.format('- MBR is the First Sector(512B) of any bootable device')
print(row_11)
row_12 = '| {:^60} |'.format('- MBR job: look for boot loader (LILO/GRUB IN case of Linux)')
print(row_12)
row_13 = '| {:<60} |'.format(' and then  HAND OVER CONTROL to it')
print(row_13)
row_13_1 = '| {:^60} |'.format('- MBR include 3 component:')
print(row_13_1)
print(row_1)

row_14_1 = '  {:^18}   {:^18}   {:^18}  '.format('|','|','|')
print(row_14_1)

row_14 = '+ {:-^18} + {:-^18} + {:-^18} +'.format('','','')
print(row_14)
row_15 = '| {:^18} | {:^18} | {:^18} |'.format('PrimaryBoot loader','Partition Table','Error checking')
print(row_15)
row_16 = '| {:^18} | {:^18} | {:^18} |'.format('(GRUB)','(lsblk -f)','MBR validate check')
print(row_16)
row_16_1 = '| {:^18} | {:^18} | {:^18} |'.format('','(/proc/partitions)','')
print(row_16_1)
print(row_14)
print(row_1)

row_3 = ' {:^60} '.format('|')
print(row_3)
row_4 = ' {:^60} '.format('V')
print(row_4)

row_1 = '+ {:-^60} +'.format('')
print(row_1)
row_10 = '| {:^60} |'.format('Bootloader(GRUB or LILO)')
print(row_10)
row_1 = '+ {:-^60} +'.format('')
print(row_1)
row_17 = '| {:<60} |'.format('- It gives you options from which OS or kernel ')
print(row_17)
row_17 = '| {:<60} |'.format('  you would like to boot your machine')
print(row_17)
row_17 = '| {:<60} |'.format(' Ex: Redhat...(3.10.0.el6..)')
print(row_17)
row_17 = '| {:<60} |'.format('- Load kernel and /boot/initrd or ./initramfs image in RAM')
print(row_17)
row_17 = '| {:<60} |'.format('	+ traditional Initrd image (kernel <=2.4)')
print(row_17)
row_17 = '| {:<60} |'.format('	+ new Initramfs image (kernel >= 2.6).')
print(row_17)

row_17 = '| {:<60} |'.format('- configuration file is /boot/grub/grub.conf (for BIOS)')
print(row_17)
row_17 = '| {:<60} |'.format('	or /boot/efi/EFI/redhat/grub.conf (for UEFI)')
print(row_17)
    
row_17 = '| {:<60} |'.format('- Once kernel and initramfs is loaded into memory')
print(row_17)
row_17 = '| {:<60} |'.format('	=> boot control is taken by kernel')
print(row_17)
print(row_1)

row_3 = ' {:^60} '.format('|')
print(row_3)
row_4 = ' {:^60} '.format('V')
print(row_4)

row_1 = '+ {:-^60} +'.format('')
print(row_1)
row_10 = '| {:^60} |'.format('Kernel and initrd/initramfs')
print(row_10)
row_1 = '+ {:-^60} +'.format('')
print(row_1)
#Kernel control the overall system, it initializes the first process: init(RHEL 6)/systemd(RHEL 7)
#initrd/initramfs contain a minimum set of dirs and acts as bridge to the real/actual file system

https://kerneltalks.com/linux/rhel6-boot-process/
http://www.linuxbuzz.com/step-by-step-linux-rhel-6-7-boot-process-for-beginners/
https://wiki.debian.org/BootProcess
https://www.thegeekstuff.com/2011/02/linux-boot-process/6/