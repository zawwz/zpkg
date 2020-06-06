#!/bin/sh

usage()
{
  echo "$fname [options] <operation>

Operations:
    update                Update packages
    update-database       Update only database
    install <pkg...>      Install packages
    remove  <pkg...>      Remove packages
    fetch   <pkg...>      Fetch packages into current directory
    deps    <pkg...>      Show dependencies of package
    show    <pkg...>      Show package files
    info    <pkg...>      Show info of package
    list                  List currently installed packages
    list-all              List all packages in repository
    list-outdated         List outdated packages
    list-removed          List removed packages
Admin operations:
    deploy  <path...>     Deploy target to package server

Options:
  -h          Display this help
  -c <path>   Custom config path. Default /etc/zpkg
  -f          Force running when root

Config (zpkg.conf):
  SSH_ADDRESS         SSH access for deploy
  HTTP_ADDRESS        HTTP address for downloading packages
  PKG_PATH            Path to the local package database
  COMPRESSION         Compression configuration, extension:binary:parallel_binary:options
  ALLOW_ROOT          Set to true to allow running as root without -f. Default: false"
}

error() {
    printf "\033[1;31m%s\033[0m\n" "$1" >&2
}

# $1 = package name
package_info() {
  unset cleanup
  status="not installed"
  grep -q "^$1 " "$PKG_PATH/pkglist" 2>/dev/null || { echo "Package '$1' not found" && return 1; }
  grep -q "^$1 " "$PKG_PATH/installed" 2>/dev/null && status=installed
  tmpdir="/tmp/zpkg_$(random_string 5)"
  mkdir -p "$tmpdir" || return $?
  pwd="$(pwd)"

  cd "$tmpdir"
  if [ "$status" = "installed" ] && [ -f "$PKG_PATH/$1.tar.$extension" ]
  then
    pkg="$PKG_PATH/$1.tar.$extension"
  else
    fetch_package "$1" >/dev/null 2>&1 || { echo "Error fetching package" >&2 && ret=$?; }
    pkg="$1.tar.$extension"
  fi
  unpack "$pkg" >/dev/null
  deps=$(cat DEPS 2>/dev/null)
  desc=$(cat DESC 2>/dev/null)
  csize=$(stat -c '%s' "$pkg" | numfmt --to=iec-i --suffix=B --padding 6)
  isize=$(du -sb ROOT HOME 2>/dev/null | awk '{print $1}' | paste -sd+ | bc | numfmt --to=iec-i --suffix=B --padding 6)
  [ -n "$cleanup" ] && { cd "$pwd"; rm -rd "$tmpdir"; }

  cd "$pwd"
  rm -rf "$tmpdir"

  [ -n "$ret" ] && return $ret

  printf "Name:         %s\n" "$1"
  printf "Description:  %s\n" "$desc"
  echo ""
  printf "Status:  %s\n" "$status"
  printf "Dependencies:  %s\n" "$deps"
  printf "Package size:    %s\n" "$csize"
  printf "Installed size:  %s\n" "$isize"
}
