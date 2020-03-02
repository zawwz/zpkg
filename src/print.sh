#!/bin/sh

usage()
{
  echo "$fname [options] <operation>"
  echo '
Operations:
    update                Update packages
    update-database       Update only database
    install <pkg...>      Install packages
    remove  <pkg...>      Remove packages
    fetch   <pkg...>      Fetch packages into current directory
    show    <pkg...>      Show package files
    list                  List currently installed packages
    list-all              List all packages in repository
    list-outdated         List outdated packages
    list-removed          List outdated packages
Admin operations:
    deploy  <path...>     Deploy target to package server

Options:
  -h          Display this help
  -c <path>   Custom config path
  -f          Force run when root
'
}

error() {
    printf "\033[1;31m%s\033[0m\n" "$1" >&2
}
