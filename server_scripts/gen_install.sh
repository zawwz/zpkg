#!/bin/sh

. "$(pwd)/.config"

# create install file
# header
echo '#!/bin/sh
' > install.sh
# add config
cat .config >> install.sh
# body
echo '

[ -z "$TMPDIR" ] && TMPDIR=/tmp

# resolve compression
[ -z "$COMPRESSION" ] && COMPRESSION="xz:xz:pixz"
extension=$(echo "$COMPRESSION" | cut -d":" -f1)
compress=$(echo "$COMPRESSION" | cut -d":" -f2)
pcompress=$(echo "$COMPRESSION" | cut -d":" -f3)
which $pcompress >/dev/null 2>&1 || pcompress=$compress
[ -z "$pcompress" ] && pcompress=$compress
which $compress >/dev/null 2>&1 || { echo "Compression $compress not installed" && exit 12; }

usage()
{
  echo "$(basename "$0")" [option...]
  echo "
Options:
  -h         Show this help message
  -c <path>  Use this path as config"
}

config_path=/etc/zpkg

while getopts ":hc:" opt;
do
  case $opt in
    h)
      usage
      exit 0
      ;;
    c)
      config_path="$OPTARG"
      ;;
    \?)
      echo "Uknown option: $OPTARG"
      usage
      exit 1
      ;;
    esac
done

shift $((OPTIND-1))

unset sudo
if [ "$(id | cut -d"=" -f2 | cut -d"(" -f1)" -eq 0 ]
then
  if [ "$1" != "force" ] ; then
    echo "Cannot run as root" >&2
    echo "Use '"'"'$(basename "$0") force'"'"' to force running as root"
    exit 10
  fi
else
  which sudo >/dev/null 2>&1 || { echo "sudo not installed" >&2 && exit 11; }
  sudo=sudo
fi

# Generate conf file
$sudo sh -c "echo \"# zpkg config file
SSH_ADDRESS=$SSH_ADDRESS
HTTP_ADDRESS=$HTTP_ADDRESS
COMPRESSION=$COMPRESSION
PKG_PATH=pkg
ALLOW_ROOT=false
UPDATE_REMOVE=true\" > zpkg.conf"

# install config file
$sudo mkdir -p "$config_path" || exit $?
$sudo mv zpkg.conf "$config_path" || exit $?

# download zpkg
tmpdir=$TMPDIR/zpkg$(tr -cd "[:alnum:]" < /dev/urandom | head -c5)
mkdir -p "$tmpdir" || exit $?
(
  cd "$tmpdir" || exit $?
  if ! wget "$HTTP_ADDRESS/zpkg.tar.$extension" -q -O "zpkg.tar.$extension"
  then
    echo "Cannot reach $HTTP_ADDRESS" > /dev/stderr
    exit 1
  fi
  cat "zpkg.tar.$extension" | $pcompress -dc 2>/dev/null | tar -xf - || exit $?

# install zpkg package
  ROOT/usr/bin/zpkg -f install zpkg || exit $?
)

# cleanup
rm -rd "$tmpdir" || exit $?
zpkg -f update-database >/dev/null || exit $?

' >> install.sh
mv install.sh "$HOME/$PKG_PATH"
