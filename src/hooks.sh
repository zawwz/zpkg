#!/bin/sh

# $1 = package , $2 = hook name , $3 = sudo
one_hook() {
  tmpfile="$TMPDIR/zpkg_hook_$(random_string 5)"
  contents=$(metadata_get "${2}" < "$PKG_PATH/$1.dat")
  local ret=0
  if [ -n "$contents" ] ; then
    printf "%s\n" "$contents" | base64 -d > "$tmpfile"
    chmod +x "$tmpfile"
    $3 "$tmpfile"
    ret=$?
  fi
  rm -f "$tmpfile"
  return $ret
}

# $1 = op , $2 = pre/post , $3 = package , $4 = sudo prefix
hook() {
  (
    set -e
    one_hook "$3" "${2}_${1}" $4
    one_hook "$3" "${2}_${1}_user"
  )
}
