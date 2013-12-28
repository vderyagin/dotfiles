#! /bin/sh

case $1 in
  (openbox)
    session=openbox-session
    ;;
  (xmonad|*)
    session=xmonad
    rake --system wp:random
    xsetroot -cursor_name left_ptr &
    unclutter -root -idle 2 -noevents -jitter 3 &
    CopyConsole -daemon &
    setxkbmap -layout 'us,ua,ru'
    xmodmap "${HOME}/.xmodmaprc"
    ;;
esac

ck-launch-session dbus-launch --exit-with-session --sh-syntax "${session}"
