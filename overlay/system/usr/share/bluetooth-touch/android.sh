#!/bin/sh

# Bluetooth initialization script for Ubuntu Touch devices

# Add any device-specific initialization here
echo "Starting bluetoothctl to initialize Bluetooth Agent..."
echo "agent on\npower on\ndiscoverable on\nexit" | /usr/bin/bluetoothctl

# Use bluebinder to initialize Bluetooth
echo "Starting bluebinder to initialize Bluetooth..."
/usr/sbin/bluebinder
