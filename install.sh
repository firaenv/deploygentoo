#!/usr/bin/env bash

# Show the available disks.
lsblk

# Allow user to select the drives
echo "Enter the drive: "
read drive
cfdisk $drive

# Enter the Root Partition
echo "Enter the linux partition: "
read partition
mkfs.ext4 $partition

echo "Enter the Swap partition: "
read swap
mkswap $swap
swapon $swap
read -p "Did you also create efi partition? [y/n]" answer
if [[ $answer = y ]] ; then
  echo "Enter EFI partition: "
  read efipartition
  mkfs.vfat -F 32 $efipartition
fi


# Create the mount directory
mkdir --parents /mnt/gentoo

# Mount the Root Partion to /mnt/gentoo
mount $partition /mnt/gentoo

# Mount the efi partition
mount $efipartition /mnt/gentoo/boot

# Cd to /mnt/gentoo for the stage 3 tarball
cd /mnt/gentoo

# Download Stage3 via wget
wget https://bouncer.gentoo.org/fetch/root/all/releases/amd64/autobuilds/20220719T233724Z/stage3-amd64-desktop-openrc-20220719T233724Z.tar.xz

# Extract the tarball
tar xpvf stage3-*.tar.xz --xattrs-include='*.*' --numeric-owner

# Configure the compile options.
nano -w /mnt/gentoo/etc/portage/make.conf

# Create the ebuild repository
mkdir --parents /mnt/gentoo/etc/portage/repos.conf
cp /mnt/gentoo/usr/share/portage/config/repos.conf /mnt/gentoo/etc/portage/repos.conf/gentoo.conf

# Copy the DNS information.
cp --dereference /etc/resolv.conf /mnt/gentoo/etc/

# Mount the necessary filesystems.
mount --types proc /proc /mnt/gentoo/proc
mount --rbind /sys /mnt/gentoo/sys
mount --make-rslave /mnt/gentoo/sys
mount --rbind /dev /mnt/gentoo/dev
mount --make-rslave /mnt/gentoo/dev
mount --bind /run /mnt/gentoo/run
mount --make-slave /mnt/gentoo/run

printf "\e[1;32mPlease run install_base.sh.\e[0m\n"
