#!/bin/sh

# files from stdin
# $1 = from where , $2 = prefix
delete_files()
{
  cd "$1" || return $?
  $2 xargs -d '\n' rm -d 2>/dev/null
}

# $1 = package , $2 = prefix
remove_package()
{
  cd "$PKG_PATH"
  archive="$(pwd)/$1.tar.$extension"
  if [ ! -f "$archive" ] || ! grep -q -w "^$1" installed
  then
    echo "Package '$1' not installed" >&2
    return 1
  fi
  echo "Removing $1"

  list=$($pcompress -dc "$archive" | tar -tf - 2>/dev/null)
  echo "$list" | grep "^ROOT/" | sed 's|^ROOT/||g' | tac | delete_files / $2
  echo "$list" | grep "^HOME/" | sed 's|^HOME/||g' | tac | delete_files "$HOME"

  $2 rm "$archive" 2>/dev/null
  $2 sed -i "/^$1 /d" installed
}
