export BUN_INSTALL=~/.bun
export EDITOR=nvim

typeset -U path
path+=(/usr/local/go/bin)
path+=(~/bin)
path+=(~/go/bin)
path+=($BUN_INSTALL/bin)
path+=(~/.local/share/bob/nvim-bin)

. "$HOME/.cargo/env"
