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
    $2 cp "$1.tar.$extension" "$PKG_PATH"
    $2 chmod a+r "$PKG_PATH/$1.tar.$extension"
    (
      umask a+rx
      unpack "$1.tar.$extension" $2 || return $?
      hook install pre $2
      [ -d "ROOT" ] || return 0
      copy_files ROOT "$ROOT_PATH/" $2 2>/dev/null || return $?
    ) || return $?
    copy_files HOME "$HOME" 2>/dev/null
    add_package_entry "$1" $2
    hook install post $2
  )
  ret=$?
  rm -rf "$tmpdir" 2>/dev/null
  return $ret
}
