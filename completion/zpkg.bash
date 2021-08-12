#/usr/bin/env bash

_zpkg_completion()
{
  _cw1="deploy update update-database install remove fetch show deps info list list-all list-outdated list-removed"
  _cw1_pkg_all="install fetch show deps info"
  _cw1_pkg_installed="remove"
  _cw1_file="deploy"
  if [ "$COMP_CWORD" = "1" ] ; then
    _compwords="$_cw1"
  elif [ "$COMP_CWORD" -gt "1" ] && echo "$_cw1_pkg_all" | grep -qw -- "${COMP_WORDS[1]}" ; then
    _compwords=$(zpkg list-all 2>/dev/null)
  elif [ "$COMP_CWORD" -gt "1" ] && echo "$_cw1_pkg_installed" | grep -qw -- "${COMP_WORDS[1]}" ; then
    _compwords=$(zpkg list 2>/dev/null)
  fi
  COMPREPLY=($(compgen -W "$_compwords" "$2" 2>/dev/null))
}

complete -F _zpkg_completion -o dirnames zpkg
