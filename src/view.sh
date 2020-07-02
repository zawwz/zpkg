#!/bin/sh

deps()
{
  (
  cd "$PKG_PATH"
  l=$(grep "^$1 " pkglist) || return $?
  echo "$l" | cut -d' ' -f3-
  )
}

# $1 = pkg file
desc() {
  cat "$1" | $pcompress -dc 2>/dev/null | tar -xOf - DESC
}

resolve_packages()
{
  RET=0
  (
  cd "$PKG_PATH"
  for I in $*
  do
    if ! grep -q "^$I " pkglist 2>/dev/null
    then
      [ "$LOG" = "true" ] && echo "Package '$I' not found" >&2
      RET=1
    else
      echo "$I"
    fi
  done
  return $RET
  )
}

# env: INCLUDE_PACKAGES
resolve_deps()
{
  ALLDEPS=""
  RET=0
  for I in $*
  do
    ALLDEPS="$ALLDEPS $(deps $I)" || { echo "Package '$I' not found" >&2 ; RET=$((RET+1)) ; }
  done
  [ "$INCLUDE_PACKAGES" = "true" ] && ALLDEPS="$ALLDEPS $*"
  echo "$ALLDEPS" | tr -s ' \n' '\n' | sort | uniq | sed '/^$/d'
  return $RET
}

is_installed()
{
  (
  cd "$PKG_PATH"
  grep -q "^$1 " installed 2>/dev/null
  )
}

# $1 = file
view_package_file() {
  tree=$(cat "$1" | $pcompress -dc 2>/dev/null | tar -tf - 2>/dev/null) || exit $?
  echo "$tree" | grep -E '^ROOT/|^HOME/' | sed "/\/$/d ; s|^ROOT/|/|g ; s|^HOME/|$HOME/|g" 2>/dev/null
}

# $1 = package name
view_package() {
  ( cd "$PKG_PATH" && view_package_file "$1.tar.$extension" )
}

removed_packages()
{
  (
  cd "$PKG_PATH"
  cat installed 2>/dev/null | while read -r in
  do
    name=$(echo "$in" | awk '{print $1}')
    rem=$(grep "^$name " pkglist | awk '{print $2}')
    [ -z "$rem" ] && echo $name
  done
  )
}

outdated_packages()
{
  (
  cd "$PKG_PATH"
  cat installed 2>/dev/null | while read -r in
  do
    name=$(echo "$in" | awk '{print $1}')
    loc=$(echo "$in" | awk '{print $2}')
    rem=$(grep "^$name " pkglist | awk '{print $2}')
    [ -n "$rem" ] && [ "$loc" -lt "$rem" ] && echo $name
  done
  )
}
