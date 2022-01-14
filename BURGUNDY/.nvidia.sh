#!/bin/bash

if lspci | grep NVIDIA &>/dev/null; then
    nvidia-smi --query-gpu=temperature.gpu --format=csv,noheader,nounits | tr -d '\n'
    #nvidia-settings -query GPUCoreTemp -t | head -n 1 | tr -d '\n'
    echo " C"
else
    echo "OFF"
fi
