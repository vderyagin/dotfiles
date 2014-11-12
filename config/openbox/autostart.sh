#! /bin/sh

rake -g wp:active &
setxkbmap -option grp:ctrl_shift_toggle,grp_led:scroll -layout 'us,ua,ru' &
LC_ALL="uk_UA.UTF-8" lxpanel &
