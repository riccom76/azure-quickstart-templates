#!/bin/bash
set -xeu

numberOfDisks=5

disksToUse=""

for i in $(seq 0 $(($numberOfDisks - 1))); do
  disksToUse="$disksToUse /dev/data${i}"
done

# Create RAID-0 volume
apt-get install -y mdadm
mdadm --create /dev/md0 --level=0 --raid-devices=${numberOfDisks} ${disksToUse}
mkdir -p /etc/mdadm
mdadm --detail --scan > /etc/mdadm/mdadm.conf

update-initramfs -u

SUCCESS=$(cat /proc/mdstat | grep md0)
if [ -z "$SUCCESS" ]; then
  echo "Failed to create data partition on raid array"
  exit 43
fi

echo "`date` - Finished setup_raid.sh"
