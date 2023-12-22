[[ -e ~/.bun ]] && export BUN_INSTALL=~/.bun
export PARINIT='rTbgqR B=.,?_A_a Q=_s>|'
export EDITOR=vim
export COSMO=$(echo ~{,/src}/cosmo(N[1]))
[[ -n $COSMO ]] || unset COSMO

typeset -U path
if [[ -f /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh ]]; then
  source /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
fi
path+=(/{usr/local/go/bin,opt/cosmocc/bin}(N))
path+=(~/bin)
path+=(~/{go,.{cargo,bun}}/bin(N))
path+=(~/.local/share/bob/nvim-bin(N))

typeset -U manpath
manpath+=(~/.nix-profile/share/man(N))

[[ -x $(which nvim) ]] && EDITOR=$(which nvim)
