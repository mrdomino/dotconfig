export ZDOTDIR="$HOME/.config/zsh"
[[ ! -o interactive ]] && TRAPUSR1(){}
# following line stops bun from editing this file on upgrade:
# bun completions

if [[ -f "$ZDOTDIR/.zshenv.local" ]]; then
  source "$ZDOTDIR/.zshenv.local"
fi
