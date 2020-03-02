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

if [ ! -d "$config_path" ]
then
  sudo mkdir -p "$config_path" 2>/dev/null
fi
if [ ! -f "$config_file" ]
then
  echo "Error: no config file '$config_file'" > /dev/stderr
  exit 1
fi

. "$config_file"

# resolve relative pkg_path
PKG_PATH="$(resolve_path "$PKG_PATH" "$config_path")"

if [ ! -d "$PKG_PATH" ]
then
  sudo mkdir -p "$PKG_PATH" 2>/dev/null
fi
