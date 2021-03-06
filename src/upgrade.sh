#!/bin/sh

# stdin: old list
# $1 = old list , $1 = new path
to_delete()
{
  find "$2" -type d 2>/dev/null | sed 's|$|/|g' > tmplist
  find "$2" -type f 2>/dev/null >> tmplist
  sort tmplist > list
  diff --new-line-format="" --unchanged-line-format="" "$1" list
  rm tmplist list
}

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

    oldlist=$(cat "$PKG_PATH/$1.tar.$extension" | $pcompress -dc 2>/dev/null | tar -tf - 2>/dev/null | sort)
    echo "$oldlist" | grep "^ROOT/" | to_delete - ROOT | sed 's|^ROOT/||g' | tac | delete_files / $2
    echo "$oldlist" | grep "^HOME/" | to_delete - HOME | sed 's|^HOME/||g' | tac | delete_files "$HOME"

    copy_files ROOT / $2 2>/dev/null
    copy_files HOME "$HOME" 2>/dev/null
    $2 cp "$1.tar.$extension" "$PKG_PATH"
    $2 chmod a+r "$PKG_PATH/$1.tar.$extension"
    add_package_entry "$1" $2
  )
  ret=$?
  rm -r "$tmpdir" 2>/dev/null
  return $ret
}

## self upgrading mitigation

unset _self_update
do_self_update()
{
  _tmpzpkg="$TMPDIR/zpkg_bin_$(random_string 5)"
  # copy current file
  cp "$0" "$_tmpzpkg" || return $?
  exec sh -c '_ZPKG_SELF_UPGRADE=y "$1" -R install zpkg ; rm -f "$1"' sh "$_tmpzpkg"
}
