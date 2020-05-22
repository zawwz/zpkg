#!/bin/sh

deps()
{
  cd "$PKG_PATH"
  l=$(grep -w "^$1" pkglist) || return $?
  echo "$l" | cut -d' ' -f3-
}

# $1 = pkg file
desc() {
  tar -xOf "$1" DESC
}

resolve_packages()
{
  RET=0
  cd "$PKG_PATH"
  for I in $*
  do
    if ! grep -wq "^$I" pkglist 2>/dev/null
    then
      [ "$LOG" = "true" ] && echo "Package '$I' not found" >&2
      RET=1
    else
      echo "$I"
    fi
  done
  return $RET
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
  cd "$PKG_PATH"
  grep -qw "^$1" installed 2>/dev/null
  return $?
}

# $1 = file
view_package_file() {
  tree=$(tar -tJf "$1" 2>/dev/null) || exit $?
  echo "$tree" | grep -E '^ROOT/|^HOME/' | sed "/\/$/d ; s|^ROOT/|/|g ; s|^HOME/|$HOME/|g" 2>/dev/null
}

# $1 = package name
view_package() {
  cd "$PKG_PATH" && view_package_file "$1.tar.xz"
}

removed_packages()
{
  cd "$PKG_PATH"
  cat installed 2>/dev/null | while read -r in
  do
    name=$(echo "$in" | awk '{print $1}')
    rem=$(grep -w "^$name" pkglist | awk '{print $2}')
    if [ -z "$rem" ] ; then
      echo $name
    fi
  done
}

outdated_packages()
{
  cd "$PKG_PATH"
  cat installed 2>/dev/null | while read -r in
  do
    name=$(echo "$in" | awk '{print $1}')
    loc=$(echo "$in" | awk '{print $2}')
    rem=$(grep -w "^$name" pkglist | awk '{print $2}')
    if [ -n "$rem" ] && [ "$loc" -lt "$rem" ]
    then
      echo $name
    fi
  done
}
