[[ -e ~/.bun ]] && export BUN_INSTALL=~/.bun
[[ -e ~/.gem ]] && export GEM_HOME=~/.gem
export PARINIT='rTbgqR B=.,?_A_a Q=_s>|'
export EDITOR=vim
for d in ~{,/src}/cosmo; do
  if [ -e $d ]; then
    export COSMO=$d
    break
  fi
done

typeset -U path
if [[ -f /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh ]]; then
  source /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
fi
path+=(/{usr/local/go,opt/cosmocc/current}/bin(N))
path+=(~/bin)
path+=(~/{go,.{cargo,bun,gem}}/bin(N))
path+=(~/.local/share/bob/nvim-bin(N))
path+=(~/venv/bin(N))

typeset -U manpath
manpath+=(~/.nix-profile/share/man(N))

[[ -x $(which nvim) ]] && EDITOR=$(which nvim)

typeset -UT CPATH cpath
typeset -UT LIBRARY_PATH library_path
cpath+=(/opt/local/include(N))
library_path+=(/opt/local/lib(N))
cpath+=(/usr/local/include(N))
library_path+=(/usr/local/lib(N))
export CPATH LIBRARY_PATH
