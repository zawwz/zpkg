#/usr/bin/env bash

_zpkg_completion()
{
  _cw1="deploy update update-database install remove fetch show list list-all list-outdated list-removed"
  _cw1_pkgw="install remove fetch show"
  _cw1_file="deploy"
  if [ "$COMP_CWORD" = "1" ] ; then
    _compwords=$_cw1
  elif [ "$COMP_CWORD" -gt "1" ] && [ -n "$(echo "$_cw1_pkgw" | grep -w "${COMP_WORDS[1]}" 2>/dev/null)" ] ; then
    _compwords=$(zpkg list-all 2>/dev/null)
  fi
  COMPREPLY=($(compgen -W "$_compwords" "${COMP_WORDS[$COMP_CWORD]}" 2>/dev/null))
}

complete -F _zpkg_completion -o dirnames zpkg
