#!/bin/sh

. "$(pwd)/.config"

[ -z "$TMPDIR" ] && TMPDIR=/tmp

[ -z "$COMPRESSION" ] && COMPRESSION="xz:xz:pixz"
extension=$(echo "$COMPRESSION" | cut -d':' -f1)
compress=$(echo "$COMPRESSION" | cut -d':' -f2)
pcompress=$(echo "$COMPRESSION" | cut -d':' -f3)
which $pcompress >/dev/null 2>&1 || pcompress=$compress
[ -z "$pcompress" ] && pcompress=$compress
which $compress >/dev/null 2>&1 || { echo "Compression '$compress' not installed" && exit 12; }

random_string()
{
  tr -cd '[:alnum:]' < /dev/urandom | head -c$1
}

# build
./compile.sh || exit $?

# add sources to server
ssh "$SSH_ADDRESS" mkdir -p "$PKG_PATH" || exit $?
scp .config server_scripts/* "$SSH_ADDRESS":~/ || exit $?

PKG=zpkg
DEST=/usr/bin
BASHDEST=/etc/bash_completion.d
tmpdir="$TMPDIR/zpkg$(random_string 5)"
fullpath="$tmpdir/$PKG/ROOT"
# setup package sources
mkdir -p "$fullpath$DEST" || exit $?
mkdir -p "$fullpath$BASHDEST" || exit $?
cp completion/zpkg.bash "$fullpath$BASHDEST" || exit $?
mv zpkg "$fullpath$DEST" || exit $?
# create and send package
(
  cd "$tmpdir/$PKG" || exit $?
  tar -cf - * | $pcompress > zpkg.tar.$extension || exit $?
  # send package
  scp zpkg.tar.$extension "$SSH_ADDRESS":~/"$PKG_PATH" || exit $?
)
# cleanup
rm -rd "$tmpdir"
# update database
ssh "$SSH_ADDRESS" sh database_update.sh zpkg || exit $?
# generate install script
ssh "$SSH_ADDRESS" sh gen_install.sh || exit $?
