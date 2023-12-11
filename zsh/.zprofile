export BUN_INSTALL=~/.bun
export PARINIT='rTbgqR B=.,?_A_a Q=_s>|'
export EDITOR=vim

typeset -U path
path+=(/{usr/local/go/bin,opt/cosmocc/bin}(N))
path+=(~/{{,{go,.cargo,$BUN_INSTALL}/}bin,.local/share/bob/nvim-bin}(N))

typeset -U manpath
manpath+=(~/.nix-profile/share/man(N))

[[ -x $(which nvim) ]] && EDITOR=$(which nvim)
