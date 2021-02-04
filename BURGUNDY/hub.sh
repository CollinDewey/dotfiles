#!/bin/bash
xrandr --output eDP-1-0 --off
nvidia-settings --assign "CurrentMetaMode=DP-0.1: nvidia-auto-select +1920+1080 {ForceCompositionPipeline=On, ForceFullCompositionPipeline=On}, DP-0.2: 1920x1080 +2239+0 {viewportin=1920x1080, viewportout=1824x1026+48+27, ForceCompositionPipeline=On, ForceFullCompositionPipeline=On}, DP-0.3: 1920x1080 +0+1080 {ForceCompositionPipeline=On, ForceFullCompositionPipeline=On}"
pactl unload-module module-loopback
pactl load-module module-loopback latency_msec=1
