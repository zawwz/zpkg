#!/bin/sh

# files from stdin
# $1 = prefix
delete_files()
{
  while read -r in
  do
    if [ -n "in" ]
    then
      $1 rm -d "$in" 2>/dev/null
    fi
  done
}

remove_package()
{
  cd "$PKG_PATH"
  archive="$(pwd)/$1.tar.xz"
  if [ ! -f "$archive" ] || ! grep -q -w "^$1" installed
  then
    echo "Package '$1' not installed" >&2
    return 1
  fi
  echo "Removing $1"

  ( # delete root files
    cd /
    tar -tf "$archive" ROOT 2>/dev/null | sed 's|^ROOT/||g' | tac | delete_files sudo
  )
  ( # delete home files
    cd "$HOME"
    tar -tf "$archive" HOME 2>/dev/null | sed 's|^HOME/||g' | tac | delete_files
  )

  rm "$archive" 2>/dev/null
  sudo sed -i "/^$1 /d" installed
}
