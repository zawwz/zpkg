#!/bin/sh

deps()
{
  cd "$PKG_PATH"
  grep -w "^$1" pkglist | cut -d' ' -f3-
}

resolve_packages()
{
  RET=0
  cd "$PKG_PATH"
  for I in $*
  do
    if ! grep -wq "^$I" pkglist
    then
      [ "$LOG" = "true" ] && echo "Package '$I' not found" > /dev/stderr
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
  for I in $*
  do
    ALLDEPS="$ALLDEPS $(deps $I)"
  done
  [ "$INCLUDE_PACKAGES" = "true" ] && ALLDEPS="$ALLDEPS $*"
  echo "$ALLDEPS" | tr -s ' \n' '\n' | sort | uniq | sed '/^$/d'
}

is_installed()
{
  cd "$PKG_PATH"
  grep -qw "^$1" installed
  return $?
}

view_package()
{
  cd "$PKG_PATH"
  tar -tf "$1.tar.xz" | sed "s|^ROOT/|/|g ; /\/$/d ; s|^HOME/|$HOME/|g ; /^DEPS/d"
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
