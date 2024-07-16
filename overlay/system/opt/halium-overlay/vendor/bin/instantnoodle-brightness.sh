#!/bin/sh

mkdir -p /home/phablet/.config
touch /home/phablet/.config/backlight-brightness

while true; do
  if [ "$(wlr-randr | grep -i "enabled" | awk '{print $2}')" = 'yes' ]; then
    cat /sys/class/backlight/panel0-backlight/brightness > ~/.config/backlight-brightness
    sleep 1
  elif [ "$(wlr-randr | grep -i "enabled" | awk '{print $2}')" = 'no' ]; then
    sleep 1
    cat ~/.config/backlight-brightness > /sys/class/backlight/panel0-backlight/brightness
  fi
done
