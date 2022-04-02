#!/bin/bash

# Options


# Functions
show_usage () {
  echo "script to remove constellation and reinstall user settings
  bash forget.sh [options]
  none: test for and remove all options
  -z: forget oh-my-zsh and zsh plugins. Restore user setting
  -v: forget vim and vim plugins
  -T: forget tmux and tmux plugins
  --verbose: run in verbose mode
  *: unknown argument
}

# SET VARIABLES

OLD_ZSH_CONFIG=$HOME/.old_zsh_config

if [ $(pwd) != $HOME/constellation ]; then
  echo "Must run in $HOME/constellation";
  exit 1;
fi

### PROCESS ARGS ###

### REMOVE ZSH ###

TEMP_ZSH_DIR="$HOME/.old_zsh_config"

rm ~/.zshenv # unlink

cp -r .tmp_zsh/ $HOME
chmod 777 .tmp_zsh
rm -r .tmp_zsh
rm -r oh-my-zsh


