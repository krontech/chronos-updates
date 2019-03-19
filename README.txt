Updating Your Camera
====================
 * Extract the `.zip` file into the root directory of a FAT32 formatted USB drive.
 * Turn on your camera and insert the USB drive into the USB/eSATA combo port, not the one labeled 'OTG'.
 * From the main window, tap the `Util` button to open the utility window.
 * As a precaution, tap the `Backup Calibration Data` button on the utility window before
    starting the update.
    - When the backup is completed, a pop-up window will be displayed.
    - Tap the `Done` button to close the pop-up window.
 * From the utility window, tap the `Apply Software Update` button to begin the software update.
    - A warning message will be displayed, tap the `Yes` button to confirm and begin the update.
    - If a pop-up that says 'No software update found' is displayed, even when a USB stick containing the update in the correct location is connected, reboot the camera and try again.
 * During the update, the screen will go blank and an `Applying Update` message will be displayed.
 * After approximately 60 seconds, the update will be complete and the camera will restart.
 
Building a Release Package
--------------------------
You can build a release package directly from the git repository as follows:
 * Install the `git-lfs` package for your operating system, or follow the installation
        instructions at https://git-lfs.github.com/
 * Clone the https://github.com/krontech/chronos-updates/ repository.
 * Run `make` to build the `.zip` package.

Building a Debian Filesystem
----------------------------
The scripts directory contains some tools which you use to build a Debian filesystem
for the Chronos Camera as follows:
 * Install the `multistrap` and `qemu-user-static` packages in your operating system.
 * `scripts/chronos-debootstrap.sh` will create a new root filesystem at `$(pwd)/debian.` This
   script will require root privileges in order to chroot and configure the new filesystem.
 * Insert an micro-SD card with any version of firmware from 0.3.x or earlier into your PC, this
   should detect and mount two partitions named `BOOT` and `ROOTFS`.
 * Locate the mount device of the `ROOTFS` partition (eg: `/dev/sdb2`), and write the contents
   of the new filesystem onto the `ROOTFS` partition using the `scripts/mksd-rootfs.sh` script
   with the command: `scripts/mkfs-rootfs.sh /dev/sdb2`
 * Copy the kernel image from `debian/boot/vmlinuz-3.2` onto the `BOOT` partition and rename
   the file to `uImage` (eg: `cp debian/boot/vmlinuz-3.2 /media/user/BOOT/uImage`).
 * Unmount the micro-SD card, and install it into a camera.
