#!/bin/sh

. "$(pwd)/.config"

[ -z "$TMPDIR" ] && TMPDIR=/tmp

# resolve compression
[ -z "$COMPRESSION" ] && COMPRESSION="xz:xz:pixz"
extension=$(echo "$COMPRESSION" | cut -d':' -f1)
compress=$(echo "$COMPRESSION" | cut -d':' -f2)
pcompress=$(echo "$COMPRESSION" | cut -d':' -f3)
which $pcompress >/dev/null 2>&1 || pcompress=$compress
[ -z "$pcompress" ] && pcompress=$compress
which $compress >/dev/null 2>&1 || { echo "Compression '$compress' not installed" && exit 12; }

# prepare
cd "$HOME/$PKG_PATH" || exit $?
PKGLIST="$(ls ./*.tar.$extension)"

# arg process
fulllist=$(find . -name "*.tar.$extension" | sed "s|^\./||g;s|\.tar\.$extension$||g")
if [ $# -ge 1 ]
then
  list=$*
else
  list=$fulllist
fi

# iterate
for I in $list
do
  TIME=$(stat -c "%Y" "$I.tar.$extension")
  DEPS=$(cat "$I.tar.$extension" | $pcompress -dc 2>/dev/null | tar -xOf - DEPS 2>/dev/null | tr -s '\n\t ' ' ')
  if grep -q -w "^$I" pkglist 2>/dev/null
  then
    sed -i "s|^$I .*\$|$I $TIME $DEPS|g" pkglist
  else
    echo "$I $TIME $DEPS" >> pkglist
  fi
done

# remove inexistant
tmpfile="$TMPDIR/pkglist_$(tr -cd '[:alnum:]' </dev/urandom | head -c10)"
awk '{print $1}' pkglist | sort > "$tmpfile"
for I in $(echo "$fulllist" | sort | diff --new-line-format="" --unchanged-line-format="" "$tmpfile" -)
do
  sed -i "/$I/d" pkglist
done
rm "$tmpfile"
