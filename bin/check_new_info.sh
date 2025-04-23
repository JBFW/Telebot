#!/bin/sh

PATH=$HOME/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin; export PATH

SAVE_DIR="$HOME/NewInfo"

if [ -d "$SAVE_DIR" ]; then
  files=$(ls $SAVE_DIR | wc -l)

  if [ $files -gt 1 ]; then
    echo "You have $files unsorted files!" | send-tlg
  elif [ $files -eq 1 ]; then
    echo "You have $files unsorted file!" | send-tlg
  fi
fi
