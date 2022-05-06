#!/bin/sh

# $1 = file , $2 = prefix , $3 = target to extract
unpack()
{
  echo "Unpacking $1"
  $pcompress -dc < "$1" 2>/dev/null | tar -xf - $3
}

# $1 = source_dir , $2 = dest_dir , $3 = prefix
copy_files() {
  $3 cp -r "$1/." "$2"
}


install_files() {
  (
    umask a+rx
    set -e
    if [ -d "ROOT" ] ; then
      copy_files ROOT "$ROOT_PATH/" $2 2>/dev/null
    fi
    if [ -d "HOME" ] ; then
      copy_files HOME "$HOME" 2>/dev/null
    fi
    add_package_entry "$1" $2
  )
}

# files from stdin
# $1 = from where , $2 = prefix
delete_files()
{
  cd "$1" || return $?
  list=$(cat)
  printf "%s\n" "$list" | tr '\n' '\0' | $2 xargs -0 rm -d 2>/dev/null
  printf "%s\n" "$list" | tr '\n' '\0' | xargs -0 -n1 dirname | uniq |
    tr '\n' '\0' | $2 xargs -0 rmdir -p 2>/dev/null
}

# stdin: old list
# $1 = old list , $2 = new path
to_delete()
{
  find "$2" -type d 2>/dev/null | sed 's|$|/|g' > tmplist
  find "$2" -type f 2>/dev/null >> tmplist
  sort tmplist > list
  diff --new-line-format="" --unchanged-line-format="" "$1" list
  rm tmplist list
}

# $1 = package , $2 = sudo
remove_files() {
  filetree=$(metadata_get tree < "$PKG_PATH/$1.dat" | base64 -d)
  printf "%s\n" "$filetree" | grep "^ROOT/" | to_delete - ROOT | sed 's|^ROOT/||g' | tac | delete_files "$ROOT_PATH/" $2
  printf "%s\n" "$filetree" | grep "^HOME/" | to_delete - HOME | sed 's|^HOME/||g' | tac | delete_files "$HOME"
}
