alias -s ebuild=em
alias -s gif=animate
alias -s torrent=torrentinfo
alias -s pdf=mupdf

for ext in htm html; do
  alias -s $ext=firefox
done

for ext in log nfo csv cue txt; do
  alias -s $ext=most
done

for ext in png jpg jpeg tif tiff bmp ico; do
  alias -s $ext=feh
done

for command in cp mv rm mkdir rmdir; do
  alias $command="nocorrect $command"
done

if [ ! -z $TMUX ]; then
  for command in ncmpcpp htop alsamixer mc make elogv; do
    alias $command="TERM='screen-256color' $command"
  done

  alias most="TERM='screen-256color' most -w"
fi

alias grep='grep --color=auto'
alias ls='ls --group-directories-first --color=auto --classify'
alias la='ls --almost-all'
alias dirs='dirs -v'

autoload -U zmv
alias mmv='noglob zmv -W'

if [ $EUID -ne 0 ]; then
  alias rfkill='/usr/sbin/rfkill'
fi

alias -g NUL='> /dev/null 2>&1'
alias -g ENUL='2> /dev/null'
alias -g ERR='2>>( sed --unbuffered --expression="s/.*/$fg_bold[red]&$reset_color/" 1>&2 )'
alias -g P="2>&1 | $PAGER"
alias -g L='| wc --lines'
alias -g D='DISPLAY=:0.0'
