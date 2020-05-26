#!/bin/sh

. "$(pwd)/.config"

ssh="$SSH_USER@$SSH_ADDR"

[ -z "$COMPRESSION" ] && COMPRESSION="xz:xz:pxz"
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
ssh "$ssh" mkdir -p "$PKG_PATH" || exit $?
scp .config server_scripts/* "$ssh":~/ || exit $?

PKG=zpkg
DEST=/usr/local/bin
BASHDEST=/etc/bash_completion.d
tmpdir="/tmp/zpkg$(random_string 5)"
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
  scp zpkg.tar.$extension "$ssh":~/"$PKG_PATH" || exit $?
)
# cleanup
rm -rd "$tmpdir"
# update database
ssh "$ssh" sh database_update.sh || exit $?
# generate install script
ssh "$ssh" sh gen_install.sh || exit $?
