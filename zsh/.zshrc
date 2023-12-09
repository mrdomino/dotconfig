# history ⟬1
HISTFILE=~/.zsh_history
HISTSIZE=20000
SAVEHIST=10000
setopt hist_expire_dups_first
setopt append_history

# prompt ⟬1
prompt='%(?.%F{green}✔.%F{red}☓%(1?.. %?))%f '
[[ "$(hostname)" = Mac* ]] || prompt="${prompt}%F{cyan}%m%f:"
prompt="${prompt}%1~ %# "

# fpath ⟬1
push_fpath() {
  [[ -d "$@" ]] && fpath+=("$@")
}
typeset -U fpath
push_fpath /opt/local/share/zsh/site-functions
push_fpath ~/.config/zsh/site-functions
push_fpath ~/.local/share/zsh/site-functions
[[ -x $(which rustup) ]] && push_fpath \
  ${$(rustup which rustc)%/*/*}/share/zsh/site-functions
unfunction push_fpath

# aliases ⟬1
ssh_term() { ssh $@ -t tmux -CC new -As0 }
edit_zsh() {
  local f=$1; shift
  ${EDITOR:-vim} "$f" && exec $SHELL "$@"
}
[[ "$(hostname)" = dev ]] || alias dev='ssh_term dev'
[[ "$(hostname)" = nixos ]] || alias nixos='ssh_term nixos'
[[ "$(hostname)" = Mac* ]] && alias nixvm='ssh_term nixvm'
[[ "$(hostname)" = nix* ]] && {
  nixedit() {
    sudo -e "${1:-/etc/nixos/configuration.nix}" &&
      sudo nixos-rebuild switch
  }
}
[[ "$(hostname)" = cuda ]] || alias cuda='ssh_term cuda'

alias cosmo='cd ~/{,src/}cosmo(N[1]) ; path=(/opt/cosmocc/bin(N) $path)'
alias venv='source ~/venv/bin/activate'
[[ -x $(which nvim) ]] && {
  alias vim=nvim
  alias vimconf='nvim ~/.config/nvim/init.lua'
}
alias zprofile="edit_zsh $ZDOTDIR/.zprofile -l"
alias zshrc="edit_zsh $ZDOTDIR/.zshrc"
alias :q=sl

[[ "$(hostname)" = Mac* ]] || autoload -Uz ssh-reagent
autoload -Uz is-at-least
autoload -Uz zf_cat

# help builtin ⟬2
autoload -Uz run-help
(( ${+aliases[run-help]} )) && unalias run-help
alias help=run-help

# autocomplete ⟬1
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path ~/.cache/zsh
zstyle ':completion:*' completer _complete _match _approximate
zstyle ':completion:*:match:*' original only
zstyle ':completion:*:approximate:*' max-errors 1 numeric
zstyle ':completion:*:functions' ignored-patterns '_*'
zstyle ':completion:*:*:kill:*' menu yes select
zstyle ':completion:*:kill:*' force-list always
autoload -Uz compinit && {
  if is-at-least 5.9; then
    compinit -d ~/.zcompdump -w
  else
    compinit -d ~/.zcompdump
  fi
}

# keys ⟬1
bindkey -e

backward-kill-dir() {
  local WORDCHARS=${WORDCHARS/\/}
  zle backward-kill-word
  zle -f kill
}
zle -N backward-kill-dir
bindkey '' backward-kill-dir

autoload -Uz up-line-or-beginning-search down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search
[[ -n "${key[Up]}"   ]] &&
  bindkey -- "${key[Up]}"   up-line-or-beginning-search
[[ -n "${key[Down]}" ]] &&
  bindkey -- "${key[Down]}" down-line-or-beginning-search

# zle app mode ⟬2
if (( ${+terminfo[smkx]} && ${+terminfo[rmkx]} )); then
	autoload -Uz add-zle-hook-widget
	function zle_application_mode_start { echoti smkx }
	function zle_application_mode_stop { echoti rmkx }
	add-zle-hook-widget -Uz zle-line-init zle_application_mode_start
	add-zle-hook-widget -Uz zle-line-finish zle_application_mode_stop
fi

# tty ⟬1
ttyctl -f
autoload -Uz add-zsh-hook
function reset_broken_terminal () {
	printf '%b' '\e[0m\e(B\e)0\017\e[?5l\e7\e[0;0r\e8'
}
add-zsh-hook -Uz precmd reset_broken_terminal

# colophon ⟬1
# vim:fdm=marker fmr=⟬,⟭
