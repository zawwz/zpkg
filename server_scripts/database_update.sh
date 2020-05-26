#!/bin/sh

. "$(pwd)/.config"

# resolve compression
[ -z "$COMPRESSION" ] && COMPRESSION="xz:xz:pxz"
extension=$(echo "$COMPRESSION" | cut -d':' -f1)
compress=$(echo "$COMPRESSION" | cut -d':' -f2)
pcompress=$(echo "$COMPRESSION" | cut -d':' -f3)
which $pcompress >/dev/null 2>&1 || pcompress=$compress
[ -z "$pcompress" ] && pcompress=$compress
which $compress >/dev/null 2>&1 || { echo "Compression '$compress' not installed" && exit 12; }

# iterate packages
cd "$HOME/$PKG_PATH" || exit $?
PKGLIST="$(ls ./*.tar.$extension)"
{
for I in $PKGLIST
do
  NAME=$(echo "$I" | sed 's|\.tar\..*$||g;s|^\./||g')
  TIME=$(stat -c "%Y" "$I")
  DEPS=$($pcompress -dc "$I" | tar -xOf - DEPS 2>/dev/null | tr -s '\n\t ' ' ')
  echo "$NAME $TIME $DEPS"
done
} > pkglist
