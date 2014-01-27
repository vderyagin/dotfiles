#! /bin/sh

read SCREEN_WIDTH SCREEN_HEIGHT <<<$(xdpyinfo | grep dimensions | awk '{print $2}' | awk -Fx '{print $1, $2}')

export SCREEN_WIDTH
export SCREEN_HEIGHT

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
        mail-notification &
        stalonetray &
        CopyAgent &
        setxkbmap -layout 'us,ua,ru'
        xmodmap "${HOME}/.xmodmaprc"
        xmodmap "${HOME}/.xmodmaprc_left_handed_mouse"
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

    ssh-add < /dev/null &

    stalonetray &
    CopyAgent &
    dbus-launch nm-applet --sm-disable &
    blueman-applet &
    mail-notification &
    (sleep 3; batti) &

    ck-launch-session dbus-launch --exit-with-session --sh-syntax xmonad
    ;;
  (*)
    echo 'unknown machine'
    exit 1
    ;;
esac
