#!/bin/bash
################################################################################
################################## CONSTANTS ###################################
################################################################################

MAC_ZSH_PACKAGES=(zsh)
MAC_VIM_PACKAGES=(cmake macvim python)
MAC_TOOLS_PACKAGES=(macvim)


OH_MY_ZSH_SETUP_COMMAND='sh -c "$(wget https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh -O -)" "" --unattended'
FZF_SETUP_COMMAND="/usr/local/opt/fzf/install --key-bindings --completion --no-update-rc"

YCM_COMPILE_COMMAND="git submodule update --init --recursive; python3 install.py --all"

INSTALL_DIR=$(pwd)

################################################################################
################################# PROCESS ARGS #################################
################################################################################



CONFIGURE_VIM=false
CONFIGURE_ZSH=false
CONFIGURE_TMUX=false
INSTALL_TOOLS=false
MANAGE_CONFIGS=false
INSTALL_FONTS=false
VERBOSE=false
FORCE_YCM=false
FORCE=false

if [ $# -eq 0 ];
then
     CONFIGURE_VIM=true
     CONFIGURE_ZSH=true
     CONFIGURE_TMUX=true
     INSTALL_TOOLS=true
     MANAGE_CONFIGS=true
     INSTALL_FONTS=true
fi 

show_usage() {
  echo "mapsectors.sh [options]
  a helper script to install a variety of command line tools and settings
  options:
  -v: Setup vim
  -z: Setup zsh
  -T: Setup tmux
  -t: miscellaneous tools
  -c: Manage configuration files (rcfiles)
  -f: Install fonts
  -ycm: Compile YouCompleteMe
  --verbose: Show verbose output
  --force: Continue when errors are encountered
  -h: Show this help
  "
}

while test $# != 0
do
    case "$1" in
    -z) CONFIGURE_ZSH=true;;
    -v) CONFIGURE_VIM=true;;
    -T) CONFIGURE_TMUX=true;;
    --verbose) VERBOSE=true;;
    -h) show_usage; exit 0;;
    *) echo "Unknown argument: $1";;
    esac
    shift
done


################################################################################
############################# PREPARE ENVIRONMENT ##############################
################################################################################

exec 3>&1 4>&2;
if ! $VERBOSE; then
  exec 1>/dev/null 2>&1
fi

################################################################################
############################### DEFINE FUNCTIONS ###############################
################################################################################

message() {
  echo -e "$1" >&3
}


error() {
  echo -e "\x1b[31m$1\x1b[0m" >&4
  exit 1
}

warning() {
  echo -e "\x1b[33m$1\x1b[0m" >&4
}

status() {
  echo -n -e "$1" >&3
}

show_banner() {
  message "\x1b[34m======================= $1 =======================\x1b[0m"
}


do_thing() {
  command="$1"
  description="$2"
  status "$2"
  eval $1
  if [ $? -ne 0 ]; then
    if $FORCE; then
      message ": \x1b[31mFAILED - BUT CONTINUING DUE TO FORCED MODE,,,\x1b[0m"
    else
      message ": \x1b[31mFAIL\x1b[0m"
      error "\nError encountered. Please re-run with --verbose for more details"
    fi
  else
    message ": \x1b[32mOK\x1b[0m"
  fi
}

install_omz() {
  wget https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh
  ZSH=./omz do_thing 'sh install.sh --unattended' "Installing oh-my-zsh"
  rm install.sh
}

ycm_mac_install_dependencies() {
  brew install cmake python
  brew install vim
  cd ~/.vim/bundle/YouCompleteMe
  xcode-select --install
  python3 install.py --clangd-completer
}

install () {
  packages=("$@")
  for package_name in "${packages[@]}"
  do
    echo $package_name
  done
}

test_file_and_move() {
  [ -f $1 ] && mv $1 $2
}

# Zsh Plugin functions

################################################################################
#################################### PRELUDE ###################################
################################################################################

[ "$HOME/constellation" = "$INSTALL_DIR" ] || error "constellation expects to be installed in $HOME"

message "Configure VIM: $CONFIGURE_VIM"
message "Configure ZSH: $CONFIGURE_ZSH"
message "Install tools: $INSTALL_TOOLS"


################################################################################
#################################### MAP ZSH ###################################
################################################################################
if $CONFIGURE_ZSH;
then
  OLD_ZSH_CONFIG=$HOME/.old_zsh_config
  [ -d $OLD_ZSH_CONFIG ] && error "$OLD_ZSH_CONFIG already exists. Cannot install"
  mkdir $OLD_ZSH_CONFIG
  test_file_and_move $HOME/.zshenv $OLD_ZSH_CONFIG
  test_file_and_move $HOME/.zshrc  $OLD_ZSH_CONFIG
  test_file_and_move $HOME/.zlogin  $OLD_ZSH_CONFIG
  test_file_and_move $HOME/.zlogout $OLD_ZSH_CONFIG
  test_file_and_move $HOME/.zprofile $OLD_ZSH_CONFIG
  chmod 444 $OLD_ZSH_CONFIG

  install_omz
  [ -f $HOME/.zshrc ] && rm $HOME/.zshrc # remove the .zshrc that oh-my-zsh installs

  # Install Zsh Plugins

    git clone https://github.com/jeffreytse/zsh-vi-mode $INSTALL_DIR/omz/custom/plugins/zsh-vi-mode

  # Configure zsh dotfiles

  ZSHENV=$INSTALL_DIR/solarsystems/.zshenv
  echo "ZDOTDIR=$INSTALL_DIR/solarsystems" > $ZSHENV
  
  # Path to your oh-my-zsh installation.
  echo "export ZSH=$INSTALL_DIR/omz" >> $ZSHENV

  ln -s $INSTALL_DIR/solarsystems/.zshenv $INSTALL_DIR/solarsystems/.zshrc $HOME
  ln -s $INSTALL_DIR/themes/my-lambda.zsh-theme $INSTALL_DIR/omz/themes 
fi

################################################################################
#################################### MAP VIM ###################################
################################################################################

if $CONFIGURE_VIM; then
  OLD_VIM_CONFIG=$HOME/.old_vim_config
  [ -d $OLD_VIM_CONFIG ] && error "$OLD_VIM_CONFIG already exits. Cannot install"
  do_thing 'mkdir $OLD_VIM_CONFIG' 'hide $OLD_VIM_CONFIG'
  test_file_and_move $HOME/.vimrc $OLD_VIM_CONFIG
  [ -d $HOME/.vim ] && mv $HOME/.vim $OLD_VIM_CONFIG
  
  do_thing 'chmod 444 $OLD_VIM_CONFIG' 'Set $OLD_VIM_CONFIG to read only'
  
  do_thing 'ln -s $INSTALL_DIR/solarsystems/.vimrc $HOME' "symlink .vimrc"
  do_thing 'ln -s $INSTALL_DIR/solarsystems/.vim $HOME' "symlink .vim"

  do_thing 'git clone https://github.com/VundleVim/Vundle.vim.git $INSTALL_DIR/solarsystems/.vim/bundle/Vundle.vim' 'Install Vundle'
  do_thing 'brew install python cmake vim' 'Install python cmake vim'
  do_thing 'vim +PluginInstall +qall' 'Install Vundle Plugins'

  # Compile YCM
  do_thing 'cd $INSTALL_DIR/solarsystems/.vim/bundle/YouCompleteMe && ./install.py --clangd-completer' "Compile YCM"
  cd $INSTALL_DIR
  
fi


################################################################################
################################### MAP TMUX ###################################
################################################################################


################################################################################
################################## MAP TOOLS ###################################
################################################################################

################################################################################
######################### MANAGE CONFIG FILES ##################################
################################################################################


################################################################################
########################### INSTALL FONTS  #####################################
################################################################################
