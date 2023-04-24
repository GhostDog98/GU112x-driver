#!/bin/bash

# Make our uf2 file
cd ./build/
make
cd ..

name=$(find ./build/ -name "*.uf2")
echo "found: $name"
RPI="/run/media/$USER/RPI-RP2/"
echo "waiting for RPI..."
timeout=0

# Wait for the rpi to mount
while [ ! -d "$RPI" ]; do
    sleep 1
    timeout=$((timeout+1))
    if [ $timeout -gt 10 ]; then
        echo "RPI not found"
        exit 1
    fi
done
echo "found $RPI"
sleep 1
cp $name /run/media/$USER/RPI-RP2/
echo "written file"

# Wait for it to unmount automatically, as this means it's finished writing and is safe to unmount.
# If we unplugged it before this the program has not fully uploaded and been written, despite cp return a code of 1
while [ -d "$RPI" ]; do
    sleep 1
    timeout=$((timeout+1))
    if [ $timeout -gt 30 ]; then
        echo "RPI still mounted after 30 seconds, program may not have uploaded successfully"
        exit 1
    fi
done
echo "RPI has unmounted, program successfully written"
