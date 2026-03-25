#!/usr/bin/env bash
set -euo pipefail

# --- PARTUUIDs (GPT-level, never change unless you repartition) ---
PART_ROOT="1837b3d2-2cc8-42a7-8991-9743e8ece11f"
PART_DATA="018f7190-3941-480f-b257-29e76ca0de71"
PART_BACKUP="eb79c573-a13d-475a-ab5e-6a2b29bbe69b"
PART_EFI="d72573b4-2c39-42b0-8117-9415ea39ab80"

# --- Mapper names ---
MAP_ROOT="root"
MAP_DATA="data"
MAP_BACKUP="backup"

TARGET="/mnt"

resolve() {
    blkid -t PARTUUID="$1" -o device 2>/dev/null || {
        echo "FATAL: PARTUUID $1 not found" >&2; exit 1
    }
}

echo "=== Resolving partitions ==="
DEV_ROOT="$(resolve "$PART_ROOT")"
DEV_DATA="$(resolve "$PART_DATA")"
DEV_BACKUP="$(resolve "$PART_BACKUP")"
DEV_EFI="$(resolve "$PART_EFI")"

printf "  %-10s %s\n" "root:" "$DEV_ROOT" "data:" "$DEV_DATA" "backup:" "$DEV_BACKUP" "efi:" "$DEV_EFI"

echo ""
echo "=== Opening LUKS ==="
for pair in "$DEV_ROOT:$MAP_ROOT" "$DEV_DATA:$MAP_DATA" "$DEV_BACKUP:$MAP_BACKUP"; do
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
mkdir -p "$TARGET/mnt/data" "$TARGET/mnt/backup" "$TARGET/efi"
mount /dev/mapper/$MAP_DATA   "$TARGET/mnt/data"
mount /dev/mapper/$MAP_BACKUP "$TARGET/mnt/backup"
mount -o umask=0077,uid=0,gid=0 "$DEV_EFI" "$TARGET/efi"

echo ""
echo "=== Result ==="
findmnt --target "$TARGET" --submounts --output TARGET,SOURCE,FSTYPE,OPTIONS
