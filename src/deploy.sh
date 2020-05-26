#!/bin/sh


# $1 = source , $2 = package , $3 = name
package()
{
  src="$1"
  pkg="$2"

  unset tmpdir
  if [ ! -d "$src/ROOT" ] && [ ! -d "$src/HOME" ] && [ ! -f "$src/DEPS" ] && [ ! -f "$src/DESC" ]
  then
    tmpdir="/tmp/zpkg_$(random_string 5)"
    mkdir -p "$tmpdir"
    cp -r "$src" "$tmpdir/ROOT"
    src="$tmpdir"
  fi
  (
  cd "$src"
  unset list
  [ -f DEPS ] && list=DEPS
  [ -f DESC ] && list="$list DESC"
  [ -d HOME ] && list="$list HOME"
  [ -d ROOT ] && list="$list ROOT"
  size=$(du -sb $list | awk '{print $1}' | paste -sd+ | bc)
  echo "Packaging $(basename "$pkg"): $(echo "$size" | numfmt --to=iec-i)B"
  cc=$compress
  [ $size -gt 1048576 ] && cc=$pcompress
  tar -cf - --owner=0 --group=0 $list | $cc $comparg > "$pkg"
  )
  [ -n "$tmpdir" ] && rm -rd "$tmpdir"
  return 0
}

# $1 = file
deploy_package()
{
  echo "Deploying $(basename "$1"): $(du -sh "$1" | awk '{print $1}')iB"
  scp "$1" $SSH_ADDRESS:~/'$(grep "PKG_PATH=" .config | cut -d"=" -f2-)'
}

deploy_folder()
{
  if [ -f "$1" ] && echo "$1" | grep -q '\.tar\.'"$extension\$" # file and valid extension
  then
    $pcompress -dc >/dev/null 2>&1 | tar -tf - >/dev/null 2>&1|| { echo "File '$1' is not a valid archive" && return 1; }
    deploy_package "$1" "$1" || return $?
  elif [ -d "$1" ] # folder
  then
    tmpdirar="/tmp/zpkg_$(random_string 5)"
    mkdir -p "$tmpdirar"
    archive="$(getname "$1").tar.$extension"
    package "$1" "$tmpdirar/$archive" || return $?
    deploy_package "$tmpdirar/$archive" || return $?
    rm "$tmpdirar"
  else
    echo "Target '$1' doesn't exist"
  fi
}

update_remote_database()
{
  ssh $SSH_ADDRESS sh database_update.sh $*
}
