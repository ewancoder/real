#!/usr/bin/env bash
set -euo pipefail

# --- PARTUUIDs (GPT-level, never change unless you repartition) ---
PART_ROOT="0e0d3236-31ac-443d-a83c-dc65995b90d9"
PART_DATA="d83a27ee-70a6-4144-b96e-1b5155e5f7d9"
PART_EFI="753a16fd-1d50-42e0-aca6-9638e7a91245"
PART_LAB_HOT="e8155b11-e877-403f-aca8-db5b372f2fc2"
PART_LAB_COLD="52b70866-f92a-4c96-80a9-604bef09e088"

# --- Mapper names ---
MAP_ROOT="root"
MAP_DATA="data"

TARGET="/mnt"

resolve() {
    blkid -t PARTUUID="$1" -o device 2>/dev/null || {
        echo "FATAL: PARTUUID $1 not found" >&2; exit 1
    }
}

echo "=== Resolving partitions ==="
DEV_ROOT="$(resolve "$PART_ROOT")"
DEV_DATA="$(resolve "$PART_DATA")"
DEV_EFI="$(resolve "$PART_EFI")"
DEV_LAB_HOT="$(resolve "$PART_LAB_HOT")"
DEV_LAB_COLD="$(resolve "$PART_LAB_COLD")"

printf "  %-10s %s\n" "root:" "$DEV_ROOT" "data:" "$DEV_DATA" "efi:" "$DEV_EFI" "lab_hot:" "$DEV_LAB_HOT" "lab_cold:" "$DEV_LAB_COLD"

echo ""
echo "=== Opening LUKS ==="
for pair in "$DEV_ROOT:$MAP_ROOT" "$DEV_DATA:$MAP_DATA"; do
    dev="${pair%%:*}"
    name="${pair##*:}"
    if [ -e "/dev/mapper/$name" ]; then
        echo "  $name already open, skipping"
    else
        echo "  Opening $dev as $name..."
        cryptsetup luksOpen "$dev" "$name"
    fi
done

echo ""
echo "=== Mounting ==="
read -p "Format /dev/mapper/${MAP_ROOT} now on another TTY before proceeding"
mount /dev/mapper/$MAP_ROOT "$TARGET"
mkdir -p $TARGET/mnt/{data,lab-cold,lab-hot,usb}
mkdir -p "$TARGET/efi"
mount -o umask=0077,uid=0,gid=0 "$DEV_EFI" "$TARGET/efi"
mount /dev/mapper/$MAP_DATA   "$TARGET/mnt/data"
mount $DEV_LAB_HOT "$TARGET/mnt/lab-hot"
mount $DEV_LAB_COLD "$TARGET/mnt/lab-cold"

echo ""
echo "=== Result ==="
findmnt --target "$TARGET" --submounts --output TARGET,SOURCE,FSTYPE,OPTIONS
