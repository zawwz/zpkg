#!/bin/sh

cd "$(dirname "$(readlink -f "$0")")"

scripts/shcompile src/main.sh > zpkg
chmod +x zpkg
