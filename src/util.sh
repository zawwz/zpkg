#!/bin/sh

# random alphanumeric string of $1 chars
random_string()
{
  tr -cd '[:alnum:]' < /dev/urandom | head -c$1
}

# $1 = input , $2 = prefix absolute path
resolve_path()
{
  if [ "$(echo $1 | cut -c1)" != "/" ]
  then
    echo "$2/$1"
  else
    echo "$1"
  fi
}

# get name of the folder
getname()
{
  basename "$(readlink -f "$1")"
}

# return error if user is root
root_check()
{
  if [ "$(id | cut -d'=' -f2 | cut -d'(' -f1)" -eq 0 ]
  then
    echo "Cannot run as root" > /dev/stderr
    return $1
  fi
  return 0
}
