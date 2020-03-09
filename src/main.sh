#!/bin/sh

if [ -z "$opt_f" ] ; then
  root_check || exit 10
fi


if [ -n "$1" ]
then

  if [ "$1" = "list" ]
  then
    awk '{print $1}' "$PKG_PATH/installed" 2>/dev/null

  elif [ "$1" = "list-all" ]
  then
    awk '{print $1}' "$PKG_PATH/pkglist" 2>/dev/null


  elif [ "$1" = "fetch" ]
  then

    if [ -z "$2" ]
    then
      echo "No package specified" > /dev/stderr
    else
      shift 1
      for I in $*
      do
        fetch_package "$I"
      done
    fi


  elif [ "$1" = "show" ]
  then

    if [ -z "$2" ]
    then
      echo "No package specified" > /dev/stderr
    else
      shift 1
      for I in $*
      do
        if is_installed "$I"
        then
          view_package "$I"
        else
          echo "No package '$I' installed" > /dev/stderr
        fi
      done
    fi

  elif [ "$1" = "deps" ]
  then

    if [ -z "$2" ]
    then
      echo "No package specified" > /dev/stderr
    else
      shift 1
      resolve_deps $*
    fi

  elif [ "$1" = "install" ]
  then

    fetch_pkglist sudo || exit $?
    if [ -z "$2" ]
    then
      echo "No package specified" > /dev/stderr
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

  elif [ "$1" = "remove" ]
  then

    if [ -z "$2" ]
    then
      echo "No package specified" > /dev/stderr
    else
      shift 1
      for I in $*
      do
        remove_package "$I"
      done
    fi

  elif [ "$1" = "update-database" ]
  then

    fetch_pkglist sudo

  elif [ "$1" = "update" ]
  then

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

  elif [ "$1" = "list-outdated" ]
  then

    tmpdir="/tmp/zpkg$(random_string 5)"
    virtual_config_path "$tmpdir" || exit $?
    fetch_pkglist sudo > /dev/null || exit $?
    outdated_packages
    sudo rm -rd "$tmpdir"

  elif [ "$1" = "list-removed" ]
  then

    tmpdir="/tmp/zpkg$(random_string 5)"
    virtual_config_path "$tmpdir" || exit $?
    fetch_pkglist sudo > /dev/null || exit $?
    removed_packages
    sudo rm -rd "$tmpdir"

  elif [ "$1" = "deploy" ]
  then

    shift 1
    for I in $*
    do
      deploy_folder "$I" || exit 1
    done
    update_remote_database

  else
    usage
  fi

else
  usage
fi
