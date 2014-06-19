bindkey -e                                # emacs-style bindings

bindkey ' ' magic-space

bindkey '\C-xu' universal-argument
bindkey '\e[2~' overwrite-mode            # INS

bindkey '\eq' push-line-or-edit
bindkey '\ep' history-beginning-search-backward
bindkey '\en' history-beginning-search-forward

bindkey '\C-xk' kill-region
bindkey '\e[Z' reverse-menu-complete      # S-tab

bindkey -r '\e[A' '\e[B' '\e[C' '\e[D'    # good bye, arrow keys

rationalise-dot() {
  if [[ $LBUFFER = *.. ]]; then
    LBUFFER+=/..
  else
    LBUFFER+=.
  fi
}
zle -N rationalise-dot
bindkey . rationalise-dot

autoload -U edit-command-line
zle -N edit-command-line
bindkey '\ee' edit-command-line
