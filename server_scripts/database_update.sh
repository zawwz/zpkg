#!/bin/sh

. "$(pwd)/.config"

cd "$HOME/$PKG_PATH" || exit $?
PKGLIST="$(ls ./*.tar.xz)"
{
for I in $PKGLIST
do
  NAME=$(echo "$I" | sed 's|\.tar\.xz||g;s|^\./||g')
  TIME=$(stat -c "%Y" "$I")
  DEPS=$(tar -xOf "$I" DEPS 2>/dev/null | tr -s '\n\t ' ' ')
  echo "$NAME $TIME $DEPS"
done
} > pkglist
