#!/bin/bash

# Check for root privileges
if [ "$EUID" -ne 0 ]; then
  echo "Please run as root"
  exit 1
fi

# Initialize variables
CORE_FIRST=$(awk '$1 == "processor" {print $3; exit}' /proc/cpuinfo)
CORE_LAST=$(awk '$1 == "processor" {print $3}' /proc/cpuinfo | tail -1)

echo "CORE_FIRST: $CORE_FIRST"
echo "CORE_LAST: $CORE_LAST"

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

  echo "CPU$i GOVERNOR: $GOVERNOR"
  echo "CPU$i MAXFREQ: $MAXFREQ"

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

# Check and set schedtune parameters
for dir in /sys/fs/cgroup/schedtune/*; do
  if [ -d "$dir" ]; then
    echo "Processing $dir"
    if [ -f "$dir/schedtune.boost" ]; then
      echo 20 > "$dir/schedtune.boost"
      echo "Set $dir/schedtune.boost to 20"
    fi
    if [ -f "$dir/schedtune.prefer_idle" ]; then
      echo 1 > "$dir/schedtune.prefer_idle"
      echo "Set $dir/schedtune.prefer_idle to 1"
    fi
  fi
done

# Disable autogroup scheduling
if [ -f /proc/sys/kernel/sched_autogroup_enabled ]; then
  echo 0 > /proc/sys/kernel/sched_autogroup_enabled
  echo "Disabled autogroup scheduling"
else
  echo "/proc/sys/kernel/sched_autogroup_enabled not found"
fi

echo "CPU optimization script completed successfully"
