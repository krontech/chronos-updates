Updating Your Camera
====================
 * Extract the `.zip` file into the root directory of a FAT32 formatted USB drive.
    - This should result in a camUpdate folder in the root directory of the stick.
 * Turn on your camera and insert the USB drive into the USB/eSATA combo port.
 * From the main window, tap the `Util` button to open the utility window.
 * As a precaution, tap the `Backup Calibration Data` button on the utility window before starting the update.
    - This should take about 5 seconds. When the backup is completed, a pop-up window will be displayed.
    - Tap the `Done` button to close the pop-up window.
 * From the utility window, tap the `Apply Software Update` button to begin the software update.
    - A warning message will be displayed, tap the `Yes` button to confirm and begin the update.
    - If a pop-up that says 'No software update found' is displayed, even when a USB stick containing the update in the correct location is connected, reboot the camera and try again.
 * During the update, the screen will go blank and an `Applying Update` message may be displayed.
 * After approximately 30 to 60 seconds, the update will be complete and the camera will restart.
 
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
 * Run `scripts/chronos-debootstrap.sh` to create a new root filesystem at `$(pwd)/debian.`
   This script will require root privileges to chroot and configure the new filesystem.
 * Insert a micro-SD card of at least 4GB into your computer and locate the block
   device (eg: `/dev/sdb`).
 * Run `scripts/mksd-format.sh <block device>` to partition the micro-SD card and copy
   the bootloader and root filesystem onto the card. Note that this script will destroy all
   data on the SD card.
 * Remove the micro-SD card, and insert it into the slot on the bottom of the Chronos.
 * Power on the camera, and enjoy.

Building a Debian SD Card Image
----------------------------
The scripts directory contains some tools which you use to build an image of an SD card
containing the Debian OS for the Chronos Camera, which can be used with update-to-debian,
as follows:
 * Install the `multistrap` and `qemu-user-static` packages in your operating system.
 * Run `scripts/chronos-debootstrap.sh` to create a new root filesystem at `$(pwd)/debian.`
   This script will require root privileges to chroot and configure the new filesystem.
 * Insert a micro-SD card of at least 4GB into your computer and locate the block
   device (eg: `/dev/sdb`).
 * Zero the SD card to remove extra data that would bloat the image:
   `dd if=/dev/zero of=<block device> count=7460000`
 * Run `scripts/mksd-format-4gb.sh <block device>` to partition the micro-SD card and copy
   the bootloader and root filesystem onto the card. Note that this script will destroy all
   data on the SD card.
 * Before booting a camera with the new card, make a compressed image of it using:
   `sudo dd if=/dev/sdX count=7460000 | gzip --to-stdout --verbose > debian.img.gz`

