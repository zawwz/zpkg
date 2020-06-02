#!/bin/sh

unpack()
{
  echo "Unpacking $1"
  $pcompress -dc "$1" | tar -xf -
}

# $1 = package , $2 = prefix
add_package_entry()
{
  (
    cd "$PKG_PATH"
    if grep -q -w "^$1" installed 2>/dev/null
    then
      $2 sed "s|$1 .*\$|$1 $(date +%s)|g" -i installed
    else
      $2 sh -c "echo '$1 $(date +%s)' >> installed"
    fi
  )
}

# $1 = source_dir, $2 = dest_dir, $3 = prefix for exec
copy_files() {
  $3 cp -r "$1/." "$2"
}

# $1 = package , $2 = prefix
install_package()
{
  echo "Installing $1"
  tmpdir="/tmp/zpkg_$(random_string 5)"
  mkdir -p "$tmpdir"
  (
    cd "$tmpdir"
    fetch_package "$1" || { echo "Package '$1' not found" >&2 && return 1; }
    $2 cp "$1.tar.$extension" "$PKG_PATH"
    unpack "$1.tar.$extension" || return $?
    copy_files ROOT / $2 2>/dev/null
    copy_files HOME "$HOME" 2>/dev/null
    add_package_entry "$1" $2
  )
  ret=$?
  rm -rd "$tmpdir" 2>/dev/null
  return $ret
}
