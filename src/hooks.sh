#!/bin/sh

# $1 = op , $2 = pre/post , $3 = sudo prefix
hook() {
  (
    set -e
    cd HOOKS 2>/dev/null || return 0
    file=${2}_${1}
    if [ -x "$file" ] ; then
      $3 "./$file"
    fi
    if [ -x "${file}_user" ] ; then
      "./${file}_user"
    fi
  )
}
