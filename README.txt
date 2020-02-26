Updating Your Camera
====================
Applying an update from a camUpdate.zip package
----------------------------
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
 * If updating to Debian (software v0.4.0 or later):
    - Follow the directions onscreen to write the new software to the SD card in the top slot of the camera.
 * If updating to Arago (software v0.3.2-patch2 or earlier):
    - During the update, the screen will go blank and an `Applying Update` message may be displayed.
    - After approximately 30 to 60 seconds, the update will be complete and the camera will restart.
 
Updating Chronos software on Debian
----------------------------
 * Connect your camera to the internet via the ethernet port on the side of the camera.
 * Press the Apply Software Update button under Util->Storage. A window titled Software updates will show.
 * Package Repository:
    - Choose “voyager” (default) if you want to use the stable release.
    - Choose “unstable” only if you want to try out the latest untested, and usually buggy, software where development occurs.
 * User Interface:
    - Choose “Chronos Legacy” if you want the old UI
    - Choose “Chronos 2.1” if you want the newer, more intuitive “GUI 2” written in the Python programing language. GUI 2 is still buggy and incomplete, but you can record and save videos.

Building a Release Package to be applied on top of Arago (software v0.3.2-patch2 or earlier) 
----------------------------
You can build a release package directly from the git repository as follows:
 * Install the `git-lfs` package for your operating system, or follow the installation
        instructions at https://git-lfs.github.com/
 * Clone the https://github.com/krontech/chronos-updates/ repository.
 * run `make` to build a `.zip` package.
    - Run `make` to build a `.zip` package for updating to newer software on arago.
    - Run `make debian` to build a `.zip` package containing a compressed Debian image and the update-to-debian app, which runs on the camera and uncompresses the image and writes it to the SD card in the camera's top slot.
