#!/bin/sh

_OUTPUT=/dev/stdin
[ "$_ZPKG_SELF_UPGRADE" = "y" ] && _OUTPUT=/dev/null

config_path=/etc/zpkg
fname="$(basename "$0")"
ALLOW_ROOT=false
UPDATE_REMOVE=true

[ -z "$TMPDIR" ] && TMPDIR=/tmp
