#!/bin/sh

# files from stdin
# $1 = prefix
delete_files()
{
  while read -r in
  do
    [ -n "$in" ] && $1 rm -d "$in" 2>/dev/null
  done
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

  ( # delete root files
    cd /
    $pcompress -dc "$archive" | tar -tf - ROOT 2>/dev/null | sed 's|^ROOT/||g' | tac | delete_files $2
  )
  ( # delete home files
    cd "$HOME"
    $pcompress -dc "$archive" | tar -tf - HOME 2>/dev/null | sed 's|^HOME/||g' | tac | delete_files
  )

  $2 rm "$archive" 2>/dev/null
  $2 sed -i "/^$1 /d" installed
}
