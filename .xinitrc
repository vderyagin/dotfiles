#! /bin/sh

case `hostname` in
  (desktop)
    case $1 in
      (openbox)
        session=openbox-session
        ;;
      (xmonad|*)
        session=xmonad
        rake --system wp:random
        xsetroot -cursor_name left_ptr &
        unclutter -root -idle 2 -noevents -jitter 3 &
        stalonetray &
        CopyAgent &
        setxkbmap -layout 'us,ua,ru'
        xmodmap "${HOME}/.xmodmaprc"
        xmodmap -e 'pointer = 3 2 1 4 5 6 7 8 9 10'
        ;;
    esac

    ck-launch-session dbus-launch --exit-with-session --sh-syntax "${session}"
    ;;
  (thinkpad)
    xsetroot -cursor_name left_ptr
    unclutter -root -idle 2 -noevents -jitter 3 &
    setxkbmap -layout 'us,ua,ru'
    xmodmap "${HOME}/.xmodmaprc"
    rake --system wp:random

    stalonetray &
    CopyAgent &
    dbus-launch nm-applet --sm-disable &
    blueman-applet &
    (sleep 3; batti) &

    ssh-add < /dev/null

    ck-launch-session dbus-launch --exit-with-session --sh-syntax xmonad
    ;;
  (*)
    echo 'unknown machine'
    exit 1
    ;;
esac
