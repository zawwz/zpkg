#!/bin/sh

# $1 = package , $2 = prefix
upgrade_package()
{
  [ "$1" = "$fname" ] && [ -z "$opt_R" ] && _self_update=y && return 0
  echo "Updating $1"
  tmpdir="$TMPDIR/zpkg_$(random_string 5)"
  mkdir -p "$tmpdir"
  (
    # fetch package
    cd "$tmpdir"
    fetch_package "$1" || { echo "Package '$1' not found" >&2 && return 1; }
    unpack "$1.tar.$extension" || return $?

    hook upgrade pre "$1" $2
    remove_files "$1" $2
    gen_metadata . | $2 tee "$PKG_PATH/$1.dat" >/dev/null
    install_files "$1" $2
    hook upgrade post "$1" $2
  )
  ret=$?
  rm -rf "$tmpdir" 2>/dev/null
  return $ret
}

## self upgrading mitigation

unset _self_update
do_self_update()
{
  _tmpzpkg="$TMPDIR/zpkg_bin_$(random_string 5)"
  # copy current file
  cp "$0" "$_tmpzpkg" || return $?
  exec sh -c '_ZPKG_SELF_UPGRADE=y "$1" -c "$2" -R install zpkg ; rm -f "$1"' sh "$_tmpzpkg" "$config_path"
}
