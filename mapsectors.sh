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
  ZSH=$HOME/constellation/omz
  do_thing 'sh install.sh --unattended' " Installing oh-my-zsh "
  
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

  

################################################################################
#################################### PRELUDE ###################################
################################################################################

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

  

  install_omz
  echo "Installing zsh packages"
  # echo $CONFIGURE_ZSH
  # install $MAC_ZSH_PACKAGES
  # mkdir .tmp_zsh
  # mv ~/.*zsh* .tmp_zsh
  # mv ~/*zsh* .tmp_zsh
  # mv ~/.zprofile .tmp_zsh
  # chmod 555 .tmp_zsh
  # cp .zshenv $HOME
fi

################################################################################
#################################### MAP VIM ###################################
################################################################################

if $CONFIGURE_VIM; then
  echo "Installing vim packages"
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
