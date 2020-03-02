#!/bin/sh

# config
# no spaces in srcdir or ordered files
SRCDIR=src
ordered='options.sh config.sh main.sh'

# process
COMMENTSCRIPT="/^\s*#/d;s/\s*#[^\"']*$//"

# order list
unset namefind list
for I in $ordered
do
  namefind="$namefind ! -name $I"
  list="$list $SRCDIR/$I"
done

findlist=$(find "$SRCDIR" -type f $namefind)

# create file
echo '#!/bin/sh' > zpkg
sed $COMMENTSCRIPT $findlist $list >> zpkg
chmod +x zpkg
