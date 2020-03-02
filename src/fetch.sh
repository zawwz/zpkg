#!/bin/sh

fetch_package()
{
  wget "$HTTP_ADDRESS/$1.tar.xz" -q --show-progress -O "$1.tar.xz" 2>&1
  return $?
}

# $1 = prefix
fetch_pkglist()
{
  cd "$PKG_PATH"
  $1 mv pkglist pkglist_bak 2>/dev/null
  if ! $1 wget "$HTTP_ADDRESS/pkglist" -q --show-progress -O pkglist 2>&1
  then
    echo "Couldn't fetch server data" > /dev/stderr
    $1 mv pkglist_bak pkglist 2>/dev/null
    return 1
  else
    $1 rm pkglist_bak 2>/dev/null
    return 0
  fi
}
