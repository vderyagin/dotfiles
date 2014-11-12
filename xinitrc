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
        dbus-launch nm-applet --sm-disable &
        setxkbmap -layout 'us,ua,ru'
        xmodmap "${HOME}/.xmodmaprc"
        ;;
    esac

    ck-launch-session dbus-launch --exit-with-session --sh-syntax "${session}"
    ;;
  (thinkpad)
    xbacklight -set 80%
    xsetroot -cursor_name left_ptr
    unclutter -root -idle 2 -noevents -jitter 3 &
    setxkbmap -layout 'us,ua,ru'
    xmodmap "${HOME}/.xmodmaprc"
    xmodmap "${HOME}/.xmodmaprc_remap_print_screen_to_super"
    rake --system wp:random

    ssh-add -l || ssh-add < /dev/null &

    stalonetray &
    CopyAgent &
    dbus-launch nm-applet --sm-disable &
    # make ptbatterysystemtray happy:
    upower -i /org/freedesktop/UPower/devices/battery_BAT0 >/dev/null 2>&1
    (sleep 3; ptbatterysystemtray) &

    ck-launch-session dbus-launch --exit-with-session --sh-syntax xmonad
    ;;
  (*)
    echo 'unknown machine'
    exit 1
    ;;
esac
