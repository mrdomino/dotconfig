export BUN_INSTALL=~/.bun
export PARINIT='rTbgqR B=.,?_A_a Q=_s>|'
export EDITOR=nvim

push_path() {
  if [[ -d "$@" ]]
  then
    path+=("$@")
  fi
}
typeset -U path
push_path ~/bin
push_path ~/.local/share/bob/nvim-bin
push_path /usr/local/go/bin
push_path ~/go/bin
push_path ~/.cargo/bin
push_path $BUN_INSTALL/bin
