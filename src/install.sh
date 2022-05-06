#!/bin/sh

# $1 = file , $2 = prefix , $3 = target to extract
unpack()
{
  echo "Unpacking $1"
  $pcompress -dc < "$1" 2>/dev/null | tar -xf - $3
}

# $1 = package , $2 = prefix
add_package_entry()
{
  (
    set -e
    cd "$PKG_PATH"
    if grep -q "^$1 " installed 2>/dev/null
    then
      $2 sed "s|$1 .*\$|$1 $(date +%s)|g" -i installed
    else
      $2 sh -c "echo '$1 $(date +%s)' >> installed"
      $2 chmod a+r installed
    fi
  )
}

# $1 = source_dir , $2 = dest_dir , $3 = prefix
copy_files() {
  $3 cp -r "$1/." "$2"
}

# $1 = package , $2 = prefix
install_package()
{
  [ "$1" = "$fname" ] && [ -z "$opt_R" ] && _self_update=y && return 0
  echo "Installing $1"
  tmpdir="$TMPDIR/zpkg_$(random_string 5)"
  mkdir -p "$tmpdir"
  (
    cd "$tmpdir" || exit $?
    fetch_package "$1" || { echo "Package '$1' not found" >&2 && return 1; }
    unpack "$1.tar.$extension" $2 || exit $?
    gen_metadata "$1.tar.$extension" | $2 tee "$PKG_PATH/$1.dat" >/dev/null
    hook install pre "$1" $2
    install_files "$1" $2
    hook install post "$1" $2
    add_package_entry "$1" $2
  )
  ret=$?
  rm -rf "$tmpdir" 2>/dev/null
  return $ret
}
