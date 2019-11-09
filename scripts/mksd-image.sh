#!/bin/bash
DIR=$(cd $(dirname ${BASH_SOURCE[0]}) && pwd)
IMAGENAME=$1
FILENAME=$1
SUFFIX=

# Check if the filename ends with a compressed suffix.
if [ ! -z $(echo ${FILENAME} | grep '\.gz$') ]; then
    SUFFIX=".gz"
    IMAGENAME="${FILENAME%.*}"
elif [ ! -z $(echo ${FILENAME} | grep '\.bz2$') ]; then
    SUFFIX=".bz2"
    IMAGENAME="${FILENAME%.*}"
fi

# Create a 4GB file and loopback device.
touch ${IMAGENAME}
truncate -s 3950m ${IMAGENAME}
losetup -f ${IMAGENAME}
BLOCKDEV=$(losetup -n -j ${IMAGENAME} -O NAME)
echo "Setup ${IMAGENAME} as ${BLOCKDEV}"

# Format and install the partitions.
${DIR}/mksd-format.sh ${BLOCKDEV}
losetup -d ${BLOCKDEV}

# Final output and optional compression.
ESC_BOLD='\033[1m'
ESC_NORMAL='\033[0m'
echo ""
case ${SUFFIX} in
    ".gz")
        echo -e "${ESC_BOLD}Compressing image as ${FILENAME}${ESC_NORMAL}"
        gzip -v ${IMAGENAME}
        ;;
    ".bz2")
        echo -e "${ESC_BOLD}Compressing image as ${FILENAME}${ESC_NORMAL}"
        bzip2 -vk ${IMAGENAME}
        ;;
    *)
        echo -e "${ESC_BOLD}Created uncompressed image as ${FILENAME}${ESC_NORMAL}"
        ;;
esac
