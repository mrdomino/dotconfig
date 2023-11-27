prompt='%(?.%F{green}✔.%F{red}☓%(1?.. %?))%f '
[[ dev = "$(hostname)" ]] && prompt="${prompt}%F{cyan}%m%f:"
prompt="${prompt}%1~ %# "
alias venv='source ~/venv/bin/activate'
[[ dev = "$(hostname)" ]] || alias dev='ssh dev -t tmux -CC new -As0'
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

fpath+=(~/.config/zsh/site-functions)
[[ -d /opt/local/share/zsh/site-functions ]] && \
  fpath+=(/opt/local/share/zsh/site-functions)

[[ -x $(which rustup) ]] && {
  local rust_toolchain=$(dirname $(dirname $(rustup which rustc)))
  local rust_fpath=$rust_toolchain/share/zsh/site-functions
  [[ -d $rust_fpath ]] && fpath+=($rust_fpath)
}

[[ dev = "$(hostname)" ]] && autoload -Uz ssh-reagent

zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path ~/.cache/zsh
autoload -Uz compinit && compinit -d ~/.zcompdump
