unlimit
limit stack 3072
limit core 0
limit -s coredumpsize 0
umask 022

export WORDCHARS=''

autoload -U zcalc

autoload -Uz url-quote-magic
zle -N self-insert url-quote-magic

autoload -U zmv
alias mmv='noglob zmv -W'

unsetopt pushd_to_home
setopt pushd_ignore_dups
unsetopt auto_cd

setopt bang_hist
setopt hist_allow_clobber
setopt hist_fcntl_lock
setopt hist_ignore_space
setopt hist_reduce_blanks
setopt hist_save_no_dups hist_find_no_dups hist_ignore_all_dups
setopt inc_append_history
setopt share_history
unsetopt hist_beep

setopt auto_list
setopt auto_param_slash
setopt brace_ccl
setopt extended_glob
setopt interactive_comments
setopt long_list_jobs
setopt magic_equal_subst
setopt notify
setopt rec_exact
setopt sh_word_split
unsetopt beep
unsetopt clobber

setopt prompt_subst

autoload -Uz vcs_info
zstyle ':vcs_info:*' enable git cvs svn hg darcs

zstyle ':vcs_info:*' formats "%F{red}%B%s %F{blue}%b %u%c"
zstyle ':vcs_info:*' actionformats "%F{red}%B%s - %a%%b %B%F{blue}%b %u%c"
zstyle ':vcs_info:*' branchformat "%B%f%%b:%r"
zstyle ':vcs_info:*' hgrevformat "%r%b:%F{yellow}%7.7h"

zstyle ':vcs_info:*' stagedstr "%B%F{green}S%f%b"
zstyle ':vcs_info:*' unstagedstr "%B%F{red}U%f%b"

zstyle ':vcs_info:*' check-for-changes true
zstyle ':vcs_info:*' get-revision true
zstyle ':vcs_info:*' get-mq true
zstyle ':vcs_info:*' get-bookmarks true

zshaddhistory() {
  if [[ "$1" =~ '^\s*yt\s' || "$1" =~ '\bmagnet:\?\b' ]]; then
    return 1
  fi
}

precmd() {
  vcs_info

  if [ -w . ]; then
    current_dir_color='blue'
  else
    current_dir_color='red'
  fi
}

PROMPT=$' %B%1(j.%F{magenta}[%j]%f .)%F{${current_dir_color}}%3~ %(?..%B%K{red}%F{white} %? %f%k )%(#.%F{red}.%F{green})>>>%f%b '
RPROMPT=$'${vcs_info_msg_0_}'

if [ $TERM = "dumb" ]; then               # tramp
  unsetopt zle prompt_cr prompt_subst
  PS1='$ '
  RPROMPT=''
fi
