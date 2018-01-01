#!/usr/bin/env bash

FILE="DHCP.cfg"
exec 3<$FILE
IFS=" = "
while read -u 3 -r name value
do
    if [[ $value == "{}" ]]
    then
        read -u 3 -r varname varvalue
        MAC=`echo $varvalue | sed -e "s/\"//g"`
        read -u 3 -r varname varvalue
        HST=`echo $varvalue | sed -e "s/\"//g"`
        read -u 3 -r varname varvalue
        ADR=`echo $varvalue | sed -e "s/\"//g"`
        echo -e "host $HST {\n	hardware ethernet $MAC;\n	fixed-address $ADR;\n	}" >> formatted.cfg
    fi
done