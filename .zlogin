if [ $EUID -ne 0 ]; then
  eval `keychain --eval`

  if [ -z "$DISPLAY" ] && [ $(tty) = /dev/tty1 ]; then
    startx
  fi
fi
