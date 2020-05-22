#!/bin/sh

if [ -z "$opt_f" ] ; then
  root_check || exit 10
fi


case "$1" in
list) awk '{print $1}' "$PKG_PATH/installed" 2>/dev/null ;;
list-all) awk '{print $1}' "$PKG_PATH/pkglist" 2>/dev/null ;;
update-database) fetch_pkglist sudo ;;
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
        wget "$HTTP_ADDRESS/$1.tar.xz" -q -O - 2>/dev/null | view_package_file - || { echo "Could not fetch package '$I'" >&2 ; return 1 ; }
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
  fetch_pkglist sudo || exit $?
  if [ -z "$2" ]
  then
    echo "No package specified" >&2
  else
    shift 1
    pkglist=$(LOG=true resolve_packages $*) || exit $?
    pkglist=$(INCLUDE_PACKAGES=true resolve_deps $* | tr '\n' ' ')
    echo "Installing packages: $pkglist"
    for I in $pkglist
    do
      if is_installed "$I"
      then
        remove_package "$I"
      fi
      install_package "$I"
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
      remove_package "$I"
    done
  fi
  ;;
update)
  fetch_pkglist sudo || exit 1
  r_pkg=$(removed_packages)
  o_pkg=$(outdated_packages)
  if [ -n "$r_pkg" ]
  then
    echo "Removing packages: "$r_pkg
    for I in $r_pkg
    do
      remove_package $I
    done
  fi
  if [ -n "$o_pkg" ]
  then
    echo "Updating packages: "$o_pkg
    for I in $o_pkg
    do
      remove_package $I
      install_package $I
    done
  fi
  ;;
list-outdated)
  tmpdir="/tmp/zpkg_$(random_string 5)"
  virtual_config_path "$tmpdir" || exit $?
  fetch_pkglist > /dev/null || exit $?
  outdated_packages
  rm -rd "$tmpdir"
  ;;
list-removed)
  tmpdir="/tmp/zpkg_$(random_string 5)"
  virtual_config_path "$tmpdir" || exit $?
  fetch_pkglist > /dev/null || exit $?
  removed_packages
  rm -rd "$tmpdir"
  ;;
deploy)
  shift 1
  for I in $*
  do
    deploy_folder "$I" || exit 1
  done
  update_remote_database
  ;;
*) usage && exit 1 ;;
esac
