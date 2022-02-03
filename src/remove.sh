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
  archive="$PKG_PATH/$1.tar.$extension"
  if [ ! -f "$archive" ] || ! grep -q "^$1 " "$PKG_PATH/installed"
  then
    echo "Package '$1' not installed" >&2
    return 1
  fi

  tmpdir="$TMPDIR/zpkg_$(random_string 5)"
  mkdir -p "$tmpdir"
  (
    cd "$tmpdir" || exit $?
    echo "Removing $1"

    unpack "$archive" $2 HOOKS >/dev/null 2>&1 || true

    hook remove pre $2
    list=$(cat "$archive" | $pcompress -dc 2>/dev/null | tar -tf - 2>/dev/null)
    echo "$list" | grep "^ROOT/" | sed 's|^ROOT/||g' | tac | delete_files "$ROOT_PATH/" $2
    echo "$list" | grep "^HOME/" | sed 's|^HOME/||g' | tac | delete_files "$HOME"

    $2 rm "$archive" 2>/dev/null
    $2 sed -i "/^$1 /d" "$PKG_PATH/installed"

    hook remove post $2
  )
  ret=$?
  rm -rf "$tmpdir" 2>/dev/null
}
