#!/bin/sh

[ "$DEBUG" = true ] && set -x

# ordered requirements
%include util.sh options.sh config.sh

# everything else
%include *.sh

case "$1" in
migrate) convert_to_metadata $sudo ;;
list) awk '{print $1}' "$PKG_PATH/installed" 2>/dev/null | sort ;;
list-all) awk '{print $1}' "$PKG_PATH/pkglist" 2>/dev/null | sort ;;
update-database) fetch_pkglist $sudo ;;
fetch)
  if [ -z "$2" ]
  then
    echo "No package specified" >&2
  else
    shift 1
    for I in $*
    do
      fetch_package "$I"
    done
  fi
  ;;
show)
  if [ -z "$2" ]
  then
    echo "No package specified" >&2
  else
    shift 1
    for I in $*
    do
      if is_installed "$I"
      then
        view_package "$I"
      else
        fetch_package "$1" /dev/stdout 2>/dev/null | view_package_file - || { echo "Could not fetch package '$I'" >&2 ; return 1 ; }
      fi
    done
  fi
  ;;
deps)
  if [ -z "$2" ]
  then
    echo "No package specified" >&2
  else
    shift 1
    resolve_deps $* || exit $?
  fi
  ;;
info)
  if [ -z "$2" ]
  then
    echo "No package specified" >&2
  else
    shift 1
    for N
    do
      package_info $N || exit $?
    done
  fi
  ;;
install)
  if [ -z "$2" ]
  then
    echo "No package specified" >&2
  else
    fetch_pkglist $sudo > $_OUTPUT || exit $?
    shift 1
    pkglist=$(LOG=true resolve_packages $*) || exit $?
    pkglist=$(INCLUDE_PACKAGES=true resolve_deps $* | tr '\n' ' ')
    echo "Installing packages: $pkglist" > $_OUTPUT
    for I in $pkglist
    do
      if is_installed $I
      then upgrade_package $I $sudo
      else install_package $I $sudo
      fi
    done
  fi
  ;;
remove)
  if [ -z "$2" ]
  then
    echo "No package specified" >&2
  else
    shift 1
    for I in $*
    do
      remove_package "$I" $sudo
    done
  fi
  ;;
update)
  fetch_pkglist $sudo || exit 1
  r_pkg=$(removed_packages)
  o_pkg=$(outdated_packages)
  if [ -n "$r_pkg" ] && [ "$UPDATE_REMOVE" = "true" ]
  then
    echo "Packages to remove: "$r_pkg
    for I in $r_pkg
    do
      remove_package $I $sudo
    done
  fi
  if [ -n "$o_pkg" ]
  then
    echo "Packages to update: "$o_pkg
    for I in $o_pkg
    do
      upgrade_package $I $sudo
    done
  fi
  ;;
list-outdated)
  tmpdir="$TMPDIR/zpkg_$(random_string 5)"
  virtual_config_path "$tmpdir" || exit $?
  fetch_pkglist > /dev/null || exit $?
  outdated_packages
  rm -r "$tmpdir"
  ;;
list-removed)
  tmpdir="$TMPDIR/zpkg_$(random_string 5)"
  virtual_config_path "$tmpdir" || exit $?
  fetch_pkglist > /dev/null || exit $?
  removed_packages
  rm -r "$tmpdir"
  ;;
deploy)
  shift 1
  unset pkglist
  for I
  do
    deploy_folder "$I"
    pkglist="$pkglist $(getname "$I")"
  done
  update_remote_database $pkglist
  ;;
*) usage && exit 1 ;;
esac

if [ -n "$_self_update" ] ; then
 do_self_update
fi
