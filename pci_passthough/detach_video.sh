#!/bin/bash
# Uncomment for debug
# set -x

SimpleFB="/sys/bus/platform/devices/simple-framebuffer.0/driver/unbind"
ConsoleDir="/sys/class/vtconsole/"

# If driver unbinder exists
if [ -e ${SimpleFB} ]; then
    echo "simple-framebuffer.0" > ${SimpleFB}
fi
# Detach console if any
Consoles=`ls ${ConsoleDir}`
for Console in ${Consoles}; do
    echo 0 > ${ConsoleDir}/${Console}/bind
done
# Find NVIDIA devices PCI bus numbers and detach
NvidiaPCI=`lspci | awk '/NVIDIA/ {print $1}'`
for Device in ${NvidiaPCI}; do
    echo 1 > "/sys/bus/pci/devices/0000:${Device}/remove"
done
# Rescan PCI devices
echo 1 > /sys/bus/pci/rescan
