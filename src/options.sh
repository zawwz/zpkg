#!/bin/sh

unset opt_f opt_R

while getopts ":hc:fR" opt;
do
  case $opt in
    h) usage ; exit 1 ;;
    c) config_path="$OPTARG" ;;
    f) opt_f=y ;;
    R) opt_R=y ;;
    *) echo "Unknown option: $OPTARG" >&2 ; usage ; exit 1 ;;
    esac
done

shift $((OPTIND-1))
