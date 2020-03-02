#!/bin/sh

. "$(pwd)/.config"

ssh="$SSH_USER@$SSH_ADDR"


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
  tar -cvJf zpkg.tar.xz * || exit $?
  # send package
  scp zpkg.tar.xz "$ssh":~/"$PKG_PATH" || exit $?
)
# cleanup
rm -rd "$tmpdir"
# update database
ssh "$ssh" sh database_update.sh || exit $?
# generate install script
ssh "$ssh" sh gen_install.sh || exit $?
