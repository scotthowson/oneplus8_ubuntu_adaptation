#!/bin/sh

for i in $(seq 1 30); do
    vbs_status=$(getprop init.svc.vendor.qti.vibrator-1-2)
    if [ "$vbs_status" = "running" ] ; then
        echo "vibrator service running"
        sleep 1
        exit 0
    fi
    echo "Waiting for vibrator service"
    sleep 1
done
exit 0
