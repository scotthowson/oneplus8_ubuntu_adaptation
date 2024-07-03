#!/bin/bash
systemctl mask usb-moded
systemctl add-wants sysinit.target usb-tethering
systemctl add-wants sysinit.target usb-moded-ssh