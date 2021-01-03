#!/bin/bash

if cat /proc/bus/pci/devices | grep vfio &>/dev/null; then
    echo "OFF"
else
    nvidia-settings -query GPUCoreTemp -t | head -n 1 | tr -d '\n'
    echo " C"
fi
