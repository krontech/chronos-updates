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
    - If a pop-up that says 'No software update found' is displayed, even when a USB stick containing the update in the correct location is connected, follow the steps listed in the section below.
 * During the update, the screen will go blank and an `Applying Update` message will be displayed.
 * After approximately 60 seconds, the update will be complete and the camera will restart.

 Workaround for "No software update found" pop-up
--------------------------
 * Use a Linux computer to log into the camera from a console by running the command 'ssh -oKexAlgorithms=+diffie-hellman-group1-sha1 root@192.168.12.1'
 * Then, use the 'df' command to view the available mount points.  See whether '/media/sda1' or '/media/sdb1' is listed in the 'Mounted on' column.
 * Use the 'cd' command, followed by whichever path was listed, and camUpdate.  For example: 'cd /media/sda1/camUpdate/'
 * 'ls' to confirm that 'update.sh' and five other files are in this directory.
 * To run the update: 'sh ./update.sh'
 
 Building a Release Package
--------------------------
You can build a release package directly from the git repository as follows:
 * Install the `git-lfs` package for your operating system, or follow the installation
        instructions at https://git-lfs.github.com/
 * Clone the https://github.com/krontech/chronos-updates/ repository.
 * Run `make` to build the `.zip` package.
