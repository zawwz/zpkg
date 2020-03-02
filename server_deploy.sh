#!/bin/sh

. "$(pwd)/.config"

ssh="$SSH_USER@$SSH_ADDR"

DIR=tmp
PKG=zpkg
DEST=/usr/local/bin
BASHDEST=/etc/bash_completion.d

# build
./compile.sh || exit $?

# add sources to server
ssh "$ssh" mkdir -p "$PKG_PATH" || exit $?
scp .config server_scripts/* "$ssh":~/ || exit $?

fullpath="$DIR/$PKG/ROOT"
# setup package sources
mkdir -p "$fullpath$DEST" || exit $?
mkdir -p "$fullpath$BASHDEST" || exit $?
cp completion/zpkg.bash "$fullpath$BASHDEST" || exit $?
mv zpkg "$fullpath$DEST" || exit $?
# create and send package
(
  cd tmp/zpkg || exit $?
  tar -cvJf zpkg.tar.xz * || exit $?
  # send package
  scp zpkg.tar.xz "$ssh":~/"$PKG_PATH" || exit $?
)
# cleanup
rm -rd "$DIR"
# update database
ssh "$ssh" sh database_update.sh || exit $?
# generate install script
ssh "$ssh" sh gen_install.sh || exit $?
