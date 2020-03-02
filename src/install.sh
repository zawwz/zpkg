#!/bin/sh

unpack()
{
  echo "Unpacking $1"
  tar -xf "$1"
}

add_package_entry()
{
  (
    cd "$PKG_PATH"
    if grep -q -w "$1" installed 2>/dev/null
    then
      sudo sed "s|$1 .*\$|$1 $(date +%s)|g" -i installed
    else
      sudo sh -c "echo '$1 $(date +%s)' >> installed"
    fi
  )
}

# $1 = source_dir, $2 = dest_dir, $3 = prefix for exec
move_files()
{
  # create dirs
  FOLDERS=$(find "$1" -mindepth 1 -type d | sed "s|^$1/||g")
  echo "$FOLDERS" | while read -r I
  do
    $3 mkdir -p "$2/$I"
  done

  # move files
  FILES=$(find "$1" -mindepth 1 ! -type d | sed "s|^$1/||g")
  echo "$FILES" | while read -r I
  do
    $3 mv "$1/$I" "$2/$I"
  done
}

install_package()
{
  tmpdir="/tmp/zpkg$(random_string 5)"
  mkdir -p "$tmpdir"
  (
    cd "$tmpdir"
    if ! fetch_package "$1"
    then
      echo "Package '$1' not found" > /dev/stderr
      return 1
    fi
    unpack "$1.tar.xz"
    sudo mv "$1.tar.xz" "$PKG_PATH"
    move_files ROOT / sudo 2>/dev/null
    move_files HOME "$HOME" 2>/dev/null
    add_package_entry "$1"
  ) || return $?
  rm -rd "$tmpdir" 2>/dev/null
}
