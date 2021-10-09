#!/bin/bash
xrandr --output eDP-1-0 --off
nvidia-settings --assign "CurrentMetaMode=DP-0.3: 1920x1080 @1920x1080 +0+1080 {ViewPortIn=1920x1080, ViewPortOut=1920x1080+0+0, ForceCompositionPipeline=On, ForceFullCompositionPipeline=On}, DP-0.1: nvidia-auto-select @2560x1080 +1920+1080 {ViewPortIn=2560x1080, ViewPortOut=2560x1080+0+0, ForceCompositionPipeline=On, ForceFullCompositionPipeline=On}, DP-0.2: 1920x1080_60_0 @1920x1080 +2240+0 {ViewPortIn=1920x1080, ViewPortOut=1824x1026+48+27, ForceCompositionPipeline=On, ForceFullCompositionPipeline=On}"
killall pw-loopback
pactl set-default-sink alsa_output.usb-Turtle_Beach_Turtle_Beach_PX22_000000001-00.iec958-stereo
pactl set-default-source alsa_input.usb-C-Media_Electronics_Inc._USB_Advanced_Audio_Device-00.analog-stereo
pw-loopback &
