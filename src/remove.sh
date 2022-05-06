#!/bin/sh

# files from stdin
# $1 = from where , $2 = prefix
delete_files()
{
  cd "$1" || return $?
  list=$(cat)
  printf "%s\n" "$list" | tr '\n' '\0' | $2 xargs -0 rm -d 2>/dev/null
  printf "%s\n" "$list" | tr '\n' '\0' | xargs -0 -n1 dirname | uniq |
    tr '\n' '\0' | $2 xargs -0 rmdir -p 2>/dev/null
}

# stdin: old list
# $1 = old list , $2 = new path
to_delete()
{
  find "$2" -type d 2>/dev/null | sed 's|$|/|g' > tmplist
  find "$2" -type f 2>/dev/null >> tmplist
  sort tmplist > list
  diff --new-line-format="" --unchanged-line-format="" "$1" list
  rm tmplist list
}

# $1 = package , $2 = prefix
remove_package()
{
  if [ ! -f "$PKG_PATH/$1.dat" ] || ! grep -q "^$1 " "$PKG_PATH/installed"
  then
    echo "Package '$1' not installed" >&2
    return 1
  fi

  echo "Removing $1"

  hook remove pre "$1" $2
  remove_files "$1" $2
  hook remove post "$1" $2
  $2 rm -f "$PKG_PATH/$1.dat" 2>/dev/null
  $2 sed -i "/^$1 /d" "$PKG_PATH/installed"

}
