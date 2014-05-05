alias -s ebuild=em
alias -s gif=animate
alias -s torrent=torrentinfo
alias -s pdf='mupdf -r 96'

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

if [ $EUID -ne 0 ]; then
  alias rfkill='/usr/sbin/rfkill'
fi
