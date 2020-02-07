#!/bin/bash

. "$(pwd)/.config"

cd "$HOME/$PKG_PATH" || exit $?
stat -c "%n %Y" ./*.tar.xz | sed 's|\.tar\.xz||g;s|^\./||g' > pkglist
