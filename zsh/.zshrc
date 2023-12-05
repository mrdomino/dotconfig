# history {{{1
HISTFILE=~/.zsh_history
HISTSIZE=20000
SAVEHIST=10000
setopt hist_expire_dups_first
setopt append_history

# prompt {{{1
prompt='%(?.%F{green}✔.%F{red}☓%(1?.. %?))%f '
[[ "$(hostname)" == Mac* ]] || prompt="${prompt}%F{cyan}%m%f:"
prompt="${prompt}%1~ %# "

# fpath {{{1
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

# aliases {{{1
ssh_term() { ssh $@ -t tmux -CC new -As0 }
[[ dev = "$(hostname)" ]] || alias dev='ssh_term dev'
[[ nixos = "$(hostname)" ]] || alias nixos='ssh_term nixos'

alias cosmo='cd ~/{,src/}cosmo(N[1]) ; path=(/opt/cosmocc/bin $path)'
alias venv='source ~/venv/bin/activate'
alias vim=nvim
alias vimconf='nvim ~/.config/nvim/init.lua'
alias zshrc="$EDITOR $ZDOTDIR/.zshrc && exec $SHELL"
alias :q=sl

[[ "$(hostname)" == Mac* ]] || autoload -Uz ssh-reagent
autoload -Uz zf_cat

# help function {{{2
autoload -Uz run-help
(( ${+aliases[run-help]} )) && unalias run-help
alias help=run-help

# autocomplete {{{1
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path ~/.cache/zsh
zstyle ':completion:*' completer _complete _match _approximate
zstyle ':completion:*:match:*' original only
zstyle ':completion:*:approximate:*' max-errors 1 numeric
zstyle ':completion:*:functions' ignored-patterns '_*'
zstyle ':completion:*:*:kill:*' menu yes select
zstyle ':completion:*:kill:*' force-list always
autoload -Uz compinit && compinit -w -d ~/.zcompdump

# keys {{{1
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
[[ -n "${key[Up]}"   ]] && bindkey -- "${key[Up]}"   up-line-or-beginning-search
[[ -n "${key[Down]}" ]] && bindkey -- "${key[Down]}" down-line-or-beginning-search

# application mode {{{2
if (( ${+terminfo[smkx]} && ${+terminfo[rmkx]} )); then
	autoload -Uz add-zle-hook-widget
	function zle_application_mode_start { echoti smkx }
	function zle_application_mode_stop { echoti rmkx }
	add-zle-hook-widget -Uz zle-line-init zle_application_mode_start
	add-zle-hook-widget -Uz zle-line-finish zle_application_mode_stop
fi

# tty {{{1
ttyctl -f
autoload -Uz add-zsh-hook
function reset_broken_terminal () {
	printf '%b' '\e[0m\e(B\e)0\017\e[?5l\e7\e[0;0r\e8'
}
add-zsh-hook -Uz precmd reset_broken_terminal
# colophon {{{1
# vim:fdm=marker
