#!/bin/sh

# $1 = package name , $2 = output
fetch_package()
{
  out="$2"
  [ -z "$out" ] && out="$1.tar.$extension"
  wget "$HTTP_ADDRESS/$1.tar.$extension" -q --show-progress -O "$out" 2>&1
}

# $1 = prefix
fetch_pkglist()
{
  (
  cd "$PKG_PATH" || exit $?
  $1 mv pkglist pkglist_bak 2>/dev/null
  if ! $1 wget "$HTTP_ADDRESS/pkglist" -q --show-progress -O pkglist 2>&1
  then
    echo "Couldn't fetch server data" >&2
    $1 mv pkglist_bak pkglist 2>/dev/null
    return 1
  else
    $1 chmod a+r pkglist
    $1 rm pkglist_bak 2>/dev/null
    return 0
  fi
  )
}
