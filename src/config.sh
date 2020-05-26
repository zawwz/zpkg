#!/bin/sh

virtual_config_path()
{
  old_cfg_path="$config_path"
  old_pkg_path="$PKG_PATH"
  export config_path="$1"
  export PKG_PATH="$config_path/pkg"
  mkdir -p "$PKG_PATH"
  ln -sf "$old_pkg_path/installed" "$PKG_PATH/installed"
}

# resolve relative config_path
config_path="$(resolve_path "$config_path" "$(pwd)")"
config_file="$config_path/zpkg.conf"

# setup sudo prefix
unset sudo
if ! root_check ; then
  which sudo >/dev/null || { echo "sudo not installed" && exit 11; }
  sudo=sudo
fi

[ ! -d "$config_path" ] && { $sudo mkdir -p "$config_path" 2>/dev/null || exit $?; }
[ ! -f "$config_file" ] && echo "Error: no config file '$config_file'" >&2 && exit 1

. "$config_file"

# resolve relative pkg_path
PKG_PATH="$(resolve_path "$PKG_PATH" "$config_path")"

root_check && [ -z "$opt_f" ] && [ "$ALLOW_ROOT" != "true" ] && echo "Cannot run as root" >&2 && exit 10

[ ! -d "$PKG_PATH" ] $sudo mkdir -p "$PKG_PATH" 2>/dev/null

