#!/bin/bash

. "$(pwd)/.config"

# create install file
echo '#!/bin/sh
' > install.sh
cat .config >> install.sh
echo '

# Generate conf file
{
  echo "SSH_ADDRESS=$SSH_USER@$SSH_ADDR"
  echo "HTTP_ADDRESS=$HTTP_ADDR/$HTTP_PATH"
  echo "PKG_PATH=pkg"
} > zpkg.conf
if [ ! -f "/etc/zpkg/zpkg.conf ]
then
  mkdir -p /etc/zpkg || exit $?
  mv zpkg.conf /etc/zpkg || exit $?
fi

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
  usr/local/bin/zpkg install zpkg || exit $?
)

# cleanup
rm -rd tmp || exit $?
zpkg update-database >/dev/null || exit $?

' >> install.sh
mv install.sh "$HOME/$PKG_PATH"
