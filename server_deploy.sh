#!/bin/sh

. "$(pwd)/.config"

ssh="$SSH_USER@$SSH_ADDR"

# add sources to server
ssh "$ssh" mkdir -p "$PKG_PATH" || exit $?
scp .config scripts/* "$ssh":~/ || exit $?

# make zpkg package
DIR=tmp
PKG=zpkg
DEST=/usr/local/bin
BASHDEST=/etc/bash_completion.d
mkdir -p "$DIR/$PKG$DEST" || exit $?
mkdir -p "$DIR/$PKG$BASHDEST" || exit $?
cp src/zpkg.bash "$ZPKG_PKG_PATH/$PKG$BASHDEST" || exit $?
cp src/zpkg "$ZPKG_PKG_PATH/$PKG$DEST" || exit $?
(
  cd pkg/zpkg || exit $?
  tar -cvJf zpkg.tar.xz * || exit $?
  # send package
  scp zpkg.tar.xz "$ssh":~/"$PKG_PATH" || exit $?
)
rm -rd "$DIR"
# update database
ssh "$ssh" sh database_update.sh || exit $?
# generate install script
ssh "$ssh" sh gen_install.sh || exit $?
