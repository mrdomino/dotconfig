prompt='%(?.%F{green}✔.%F{red}☓%(1?.. %?))%f '
[[ "$(hostname)" == Mac* ]] || prompt="${prompt}%F{cyan}%m%f:"
prompt="${prompt}%1~ %# "

ssh_term() {
  ssh $@ -t tmux -CC new -As0
}

[[ dev = "$(hostname)" ]] || alias dev='ssh_term dev'
[[ nixos = "$(hostname)" ]] || alias nixos='ssh_term nixos'

alias cosmo='cd ~/{,src/}cosmo(N[1]) ; path=(/opt/cosmocc/bin $path)'
alias venv='source ~/venv/bin/activate'
alias vim=nvim
alias vimconf='nvim ~/.config/nvim/init.lua'
alias :q=sl

bindkey -e

backward-kill-dir() {
  local WORDCHARS=${WORDCHARS/\/}
  zle backward-kill-word
  zle -f kill
}
zle -N backward-kill-dir
bindkey '' backward-kill-dir

HISTFILE=~/.zsh_history
HISTSIZE=20000
SAVEHIST=10000
setopt hist_expire_dups_first
setopt append_history

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

[[ "$(hostname)" == Mac* ]] || autoload -Uz ssh-reagent
autoload -Uz zf_cat
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path ~/.cache/zsh
autoload -Uz compinit && compinit -w -d ~/.zcompdump
