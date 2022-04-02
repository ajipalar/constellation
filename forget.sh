#!/bin/bash

# Options


# Functions
show_usage() {
  echo "script to remove constellation and reinstall user settings
  bash forget.sh [options]
  none: test for and remove all options
  -z: forget oh-my-zsh and zsh plugins. Restore user setting
  -v: forget vim and vim plugins
  -T: forget tmux and tmux plugins
  --verbose: run in verbose mode
  *: unknown argument
  "
}

# SET VARIABLES

OLD_ZSH_CONFIG=$HOME/.old_zsh_config
OLD_VIM_CONFIG=$HOME/.old_vim_config

### Define Functions ###

error() {
  echo -e "\x1b[31m$1\x1b[0m" >&4
  exit 1
}

warning() {
  echo -e "\x1b[33m$1\x1b[0m" >&4
}

remove_zsh_solarsystem() {
  rm $HOME/.zshenv
  rm $HOME/.zshrc
  chmod 777 $OLD_ZSH_CONFIG
  cp -r $OLD_ZSH_CONFIG/ $HOME
  rm -rf $OLD_ZSH_CONFIG
  rm -rf omz 
}

remove_vim_solarsystem() {
  rm $HOME/.vimrc
  chmod 777 $OLD_VIM_CONFIG
  cp -r $OLD_VIM_CONFIG/ $HOME 
  rm -r $OLD_VIM_CONFIG
}

### Prepare Environment ###

exec 3>&1 4>&2;
if ! $VERBOSE; then
  exec 1>/dev/null 2>&1
fi

### PROCESS ARGS ###

[ $(pwd) = $HOME/constellation ] || error "Must run in $HOME/constellation."

### REMOVE ZSH ###
[ -d $HOME/.old_zsh_config ] || warning "$OLD_ZSH_CONFIG does not exist."
remove_zsh_solarsystem

### REMOVE VIM ###

[ -d $HOME/.old_vim_config ] || warning "$OLD_VIM_CONFIG does not exist."

remove_vim_solarsystem
