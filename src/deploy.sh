#!/bin/sh

package()
{
  unset clean_needed
  src="$1"
  pkg="$2"
  echo "Packaging $(getname "$src"): $(du -sh "$src" | awk '{print $1}')iB"
  if [ ! -d "$src/ROOT" ] && [ ! -d "$src/HOME" ] && [ ! -f "$src/DEPS" ]
  then
    tmpdir="/tmp/zpkg$(random_string 5)"
    mkdir -p "$tmpdir"
    cp -r "$src" "$tmpdir/ROOT"
    src="$tmpdir"
    clean_needed=true
  fi
  (
  cd "$src"
  if which pv >/dev/null 2>&1
  then
    tar -cf - --owner=0 --group=0 -P * | pv -s "$(du -sb . | awk '{print $1}')" | xz > "$pkg"
  else
    tar -cvJf - --owner=0 --group=0 * > "$pkg"
  fi
  )
  mv "$src/$pkg" ./
  if [ -n "$clean_needed" ]
  then
    rm -rd "$tmpdir"
  fi
}

deploy_package()
{
  echo "Deploying $1: $(du -sh "$1" | awk '{print $1}')iB"
  scp "$1" $SSH_ADDRESS:~/'$(grep "PKG_PATH=" .config | cut -d"=" -f2-)'
}

deploy_folder()
{
  archive="$(getname "$1").tar.xz"
  if [ -n "$(echo "$1" | grep '\.tar\.xz$' )" ]
  then
    deploy_package "$1" || return 1
  else
    package "$1" "$archive" || return 1
    deploy_package "$archive" || return 1
    rm "$archive" 2> /dev/null
  fi
}

update_remote_database()
{
  ssh $SSH_ADDRESS "~/database_update.sh"
}
