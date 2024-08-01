#!/bin/bash

primary_preference="lte"
saving_preference="umts"
sim_slot="/ril_0"

interface=org.freedesktop.DBus.Properties
member=PropertiesChanged

dbus-monitor --session "type=signal,interface='${interface}',member='${member}'" |
while read -r line; do
        if [[ ${line} == *"com.lomiri.LomiriGreeter"* ]]; then
                read; read; read -r line
                if [[ ${line} == *"IsActive"* ]]; then
                        read -r line
                        [[ ${line} == *"true"* ]] && /usr/share/ofono/scripts/set-tech-preference "${sim_slot}" "${saving_preference}" 1>/dev/null
                        [[ ${line} == *"false"* ]] && /usr/share/ofono/scripts/set-tech-preference "${sim_slot}" "${primary_preference}" 1>/dev/null
                fi
        fi
done
