#!/bin/sh

# $1 = package , $2 = prefix
add_package_entry()
{
  (
    set -e
    cd "$PKG_PATH"
    if grep -q "^$1 " installed 2>/dev/null ; then
      $2 sed "s|$1 .*\$|$1 $(date +%s)|g" -i installed
    else
      $2 sh -c "echo '$1 $(date +%s)' >> installed"
      $2 chmod a+r installed
    fi
  )
}

deps()
{
  (
  cd "$PKG_PATH"
  l=$(grep "^$1 " pkglist) || return $?
  echo "$l" | cut -d' ' -f3-
  )
}

# $1 = package
is_installed()
{
  (
  cd "$PKG_PATH"
  grep -q "^$1 " installed 2>/dev/null
  )
}

# stdin = metadata
# $1 = value
metadata_get() {
  grep "^$1=" | cut -d= -f2-
}

# $1 = metadata , $2 = value
metadata_arg_get() {
  printf "%s\n" "$1" | metadata_get "$2"
}

gen_hook_metadata() {
  find HOOKS -type f -maxdepth 1 -perm -0100 2>/dev/null | while read -r ln ; do
    printf "%s=%s\n" "$(basename "$ln")" $(base64 -w0 "$ln")
  done
}

# $1 = file
gen_metadata() {
  # extract values
  deps=$(cat DEPS 2>/dev/null | tr -s ' \t\n' ' ')
  desc=$(cat DESC 2>/dev/null)
  csize=$(stat -c '%s' "$1")
  isize=$(du -sb ROOT HOME 2>/dev/null | awk '{print $1}' | paste -sd+ | bc)

  printf "desc=%s\n" "$desc"
  printf "deps=%s\n" "$deps"
  printf "pkgsize=%s\n" "$csize"
  printf "installsize=%s\n" "$isize"
  gen_hook_metadata
  printf "tree=%s\n" "$(find ROOT HOME ! -type d 2>/dev/null | base64 -w0)"
  printf "dirtree=%s\n" "$(find ROOT HOME -mindepth 1 -type d 2>/dev/null | base64 -w0)"
}

# $1 = sudo
convert_to_metadata() {
  find "$PKG_PATH" -maxdepth 1 -type f -name "*.tar.$extension" |
  while read -r I ; do
    pkgname=$(basename "${I%.tar.$extension}")
    echo "Migrate $pkgname"
    tmpdir="$TMPDIR/zpkg_$(random_string 5)"
    mkdir -p "$tmpdir"
    (
      cd "$tmpdir" || exit $?
      unpack "$I" $1 >/dev/null || exit $?
      gen_metadata "$I" | $1 tee "$PKG_PATH/$pkgname.dat" >/dev/null
    )
    rm -rf "$tmpdir" 2>/dev/null
    $1 rm -f "$I"
  done
}
