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

if [ "$(id | cut -d"=" -f2 | cut -d"(" -f1)" -eq 0 ]
then
  echo "Cannot run as root" > /dev/stderr
  exit 10
fi

# Generate conf file
sudo sh -c "{
  echo SSH_ADDRESS=$SSH_USER@$SSH_ADDR
  echo HTTP_ADDRESS=$HTTP_ADDR/$HTTP_PATH
  echo PKG_PATH=pkg
} > zpkg.conf"

# install config file
sudo mkdir -p "$config_path" || exit $?
sudo mv zpkg.conf "$config_path" || exit $?

# download zpkg
mkdir -p tmp || exit $?
(
  cd tmp || exit $?
  if ! wget "$HTTP_ADDR/$HTTP_PATH/zpkg.tar.xz" -q -O "zpkg.tar.xz"
  then
    echo "Cannot reach $HTTP_ADDR/$HTTP_PATH" > /dev/stderr
    exit 1
  fi
  tar xf zpkg.tar.xz || exit $?

# install zpkg package
  ROOT/usr/local/bin/zpkg install zpkg || exit $?
)

# cleanup
rm -rd tmp || exit $?
zpkg update-database >/dev/null || exit $?

' >> install.sh
mv install.sh "$HOME/$PKG_PATH"