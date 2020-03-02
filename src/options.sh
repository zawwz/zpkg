#!/bin/sh

unset opt_f

while getopts ":hc:f" opt;
do
  case $opt in
    h)
      usage
      exit 0
      ;;
    c)
      config_path="$OPTARG"
      ;;
    f)
      opt_f="y"
      ;;
    \?)
      echo "Uknown option: $OPTARG"
      usage
      exit 1
      ;;
    esac
done

shift $((OPTIND-1))
