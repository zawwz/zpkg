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

# $1 = package , $2 = sudo
remove_files() {
  filetree=$(metadata_get tree < "$PKG_PATH/$1.dat" | base64 -d)
  printf "%s\n" "$filetree" | grep "^ROOT/" | to_delete - ROOT | sed 's|^ROOT/||g' | tac | delete_files "$ROOT_PATH/" $2
  printf "%s\n" "$filetree" | grep "^HOME/" | to_delete - HOME | sed 's|^HOME/||g' | tac | delete_files "$HOME"
}
