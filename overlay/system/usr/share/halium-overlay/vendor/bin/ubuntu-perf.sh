#!/bin/bash

# Check for root privileges
if [ "$EUID" -ne 0 ]; then
  echo "Please run as root"
  exit 1
fi

# Initialize variables
CORE_FIRST=$(awk '$1 == "processor" {print $3; exit}' /proc/cpuinfo)
CORE_LAST=$(awk '$1 == "processor" {print $3}' /proc/cpuinfo | tail -1)

# Loop through each CPU core
for ((i=$CORE_FIRST; i<=$CORE_LAST; i++)); do
  # Get the maximum frequency
  MAXFREQ=$(cat /sys/devices/system/cpu/cpu${i}/cpufreq/scaling_available_frequencies | awk '{print $NF}')
  
  # Determine the governor
  if [ -f "/var/lib/batman/default_cpu_governor" ]; then
    GOVERNOR=$(</var/lib/batman/default_cpu_governor)
  else
    GOVERNOR=$(</sys/devices/system/cpu/cpu${i}/cpufreq/scaling_governor)
  fi

  # Set scheduler load boost
  if [ -f "/sys/devices/system/cpu/cpu${i}/sched_load_boost" ]; then
    echo -6 > /sys/devices/system/cpu/cpu${i}/sched_load_boost
    echo -n "/sys/devices/system/cpu/cpu${i}/sched_load_boost "
    cat /sys/devices/system/cpu/cpu${i}/sched_load_boost
  fi

  # Set high-speed frequency
  if [ -d "/sys/devices/system/cpu/cpu${i}/cpufreq/$GOVERNOR" ]; then
    if [ -f "/sys/devices/system/cpu/cpu${i}/cpufreq/${GOVERNOR}/hispeed_freq" ]; then
      echo "$MAXFREQ" > /sys/devices/system/cpu/cpu${i}/cpufreq/${GOVERNOR}/hispeed_freq
      echo -n "/sys/devices/system/cpu/cpu${i}/cpufreq/${GOVERNOR}/hispeed_freq "
      echo "$MAXFREQ"
    fi
  fi
done

# Create and mount schedtune cgroup
mkdir -p /sys/fs/cgroup/schedtune

if mount -t cgroup -o schedtune stune /sys/fs/cgroup/schedtune; then
  echo "Mounted schedtune cgroup successfully"
else
  echo "Failed to mount schedtune cgroup"
  exit 1
fi

# Set schedtune parameters
if [ -f /sys/fs/cgroup/schedtune/schedtune.boost ]; then
  echo 20 > /sys/fs/cgroup/schedtune/schedtune.boost
fi

if [ -f /sys/fs/cgroup/schedtune/schedtune.prefer_idle ]; then
  echo 1 > /sys/fs/cgroup/schedtune/schedtune.prefer_idle
fi

# Disable autogroup scheduling
if [ -f /proc/sys/kernel/sched_autogroup_enabled ]; then
  echo 0 > /proc/sys/kernel/sched_autogroup_enabled
fi

echo "CPU optimization script completed successfully"