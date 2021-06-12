set -e # Bail if something failed

# Hacky enum implementation
function _enum() {
   local list=("$@")
   local len=${#list[@]}

   for (( i=0; i < $len; i++ )); do
      eval "${list[i]}=$i"
   done
}


os_type=(OS_MAC_OS OS_ARCH_LINUX OS_DEBIAN_LINUX) && _enum "${os_type[@]}";

package_install_prefix=
os=

cyan="\033[0;36m"
green="\033[0;32m"
red="\033[0;31m"
bold="\033[1m"
no_colour="\033[0m"
bell="\a"
dotfile_git_url=https://github.com/IsaccBarker/dotfiles.git


prompt_confirm() {
  while true; do
    read -r -n 1 -p "${1:-Continue?} [y/n]: " REPLY
    case $REPLY in
      [yY]) echo ; return 0 ;;
      [nN]) echo ; return 1 ;;
      *) echo_error "\033[AInvalid input. Please type a 'y' or 'n' character!"
    esac 
  done  
}

function echo_info {
    echo -e  "$cyan$bold==> $no_colour$cyan$@$no_colour" # Print it
}

function echo_success {
    echo -e "$green$bold==> $no_colour$green$@$no_colour" # Print it
}

function echo_error {
    echo -e "$bell" # Ring the bell
    echo -e "$red$bold==> $no_colour$red$@$no_colour" # Print it
}


function preinstall_darwin {
    echo_info "Checking if xcode developer tools are installed...."
    if type xcode-select >&- && xpath=$( xcode-select --print-path ) &&
        test -d "${xpath}" && test -x "${xpath}" ; then
        echo_info "Developer tools not installed! Installing...."
        xcode-select --install
        echo_success "Developer tools installed!"
    else
        echo_success "Developer tools installed!"
    fi

    echo_info "Installing brew for package installation...."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    package_install_prefix="brew install"
    echo_success "Brew installed!"
}

function preinstall_arch {
    sudo pacman -Syyy
    package_install_prefix="sudo pacman -S"
}

function preinstall_debian {
    sudo apt-get update
    package_install_prefix="sudo apt-get install"
}


function install_generic {
    echo_info "Is ZSH installed?"
    if [ ! -x "$(command -v zsh)" ]; then
        echo_info "ZSH not installed! Installing...."
        $package_install_prefix zsh

        echo_success "ZSH installed!"
    else
        echo_success "ZSH installed!"
    fi


    echo_info "Is Oh-My-ZSH installed?"
    if [ ! -d "$HOME/.oh-my-zsh" ]; then
        echo_info "Oh-My-ZSH is not installed! Installing...."
        mv ~/.zshrc ~/.zshrc.bak.tmp
        ZSH= sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
        mv ~/.zshrc.bak.tmp ~/.zshrc

        echo_success "Oh-My-ZSH installed!"
    else
        echo_success "Oh-My-ZSH insatlled!"
    fi
}

function install_mac_os {
    echo_info "Nothing to do!"
}

function install_arch {
    echo_info "Nothing to do!"
}

function install_debian {
    echo_info "Nothing to do!"
}


function get_dotfiles {
    echo_info "Detecting if git is installed....."
    if [ -x "$(command -v git)" ]; then
        echo_info "Git not installed! Installing...."
        $package_install_prefix git
        echo_success "Git installed!"
    else
        echo_success "Git installed!"
    fi

    git clone $dotfile_git_url
    cd dotfiles
}

function install_dotfiles {
    for file in $(find . -type d \( -path ./.git -o -path ./_ \) -prune -o -print); do
        # Ignore all directories
        if [ -d "$file" ]; then
            continue
        fi

        # Ignore non dotfiles
        if [[ "$file" == "./README.md" || "$file" == "./install.sh" ]]; then
            continue
        fi
        
        file="${file:2}" # Remove ./ from filename
        
        echo_info "Creating directories that need to be created to symlink $HOME/$file...."
        # Is it just a file?
        if [[ "$file" == *"/"* ]]; then
            # It is a path to a file. Does the path exist?
            IFS="/"
            read -ra path <<< "$file"
            unset path[-1]

            echo_info "Creating directory ${path[*]}!"
            mkdir -p "${path[*]}"
        fi

        # We've created all the directories we need. Make the symlink
        echo_info "Backing up $HOME/$file if nessisary...."
        if [ -f "$HOME/$file" ]; then
            # File exists. Make a backup.
            cat "$HOME/$file" > "$HOME/$file.bak"
            rm "$HOME/$file"
            echo_success "Made backup of $HOME/$file at $HOME/$file.bak!"
        fi

        echo_info "Creating symlink from $(pwd)/$file to $HOME/$file...."
        ln -s "$(pwd)/$file" "$HOME/$file"

        echo
    done
}


# Don't run as root
if [[ ! $EUID -ne 0 ]]; then
    echo_error "Please do not run this script as root"
    exit
fi

echo -e "$bold==>$no_colour This script does not just automatically install the dotfiles. Rather, it is a"
echo -e "$bold==>$no_colour script to automatically bring $(whoami) (your computer) to a state where"
echo -e "$bold==>$no_colour development can occur. Yes, this involves installing the dotfiles. :D"
echo
prompt_confirm "Do you wish to continue?" || exit
echo

# Run preinstall if on darwin
if [[ $OSTYPE == 'darwin'* ]]; then
    os=OS_MAC_OS

    echo_info "Detected DarwinOS! Running preinstall...."
    preinstall_darwin

    echo_success "Ran preinstall for DarwinOS!"
elif [[ $OSTYPE == 'linux-gnu'* ]]; then
    echo_info "Detected some form of Linux distrobution! Detecting which one (and support status)...."
    
    if [ -x "$(command -v pacman)" ]; then
        os=OS_ARCH_LINUX

        echo_info "Detected Arch/Derivitive Linux! Running preinstall...."
        preinstall_arch
    elif [ -x "$(command -v apt-get)" ]; then
        os=OS_DEBIAN_LINUX

        echo_info "Detected Debian/Ubuntu/Derivitive Linux! Running preinstall...."
        preinstall_debian
    else
        echo_error "Your Linux distrobution ($(uname -a)) is not supported. Please add support to this script! :D"
        exit
    fi

    echo_success "Detected distrobution!"
else
    echo_error "Your OS ($OSTYPE) is not supported. Please add support to this script! :D"
    exit
fi


echo_info "Getting dotfiles (cloning repo $dotfile_git_url)...."
if [ ! -f "install.sh" ]; then
    get_dotfiles
    echo_success "Dotfiles cloned!"
else
    echo_info "Dotfiles already installed! No need to clone!"
fi


echo_info "Installing dotfiles...."
install_dotfiles

echo_success "Dotfiles installed!"


echo_info "Running generic install segment...."
install_generic
case $os in
    OS_MAC_OS )
        echo_info "Running install for Mac OS!"
        install_mac_os

        echo_success "Installed for Mac OS!"
    ;;

    OS_ARCH_LINUX )
        echo_info "Running install for Arch Linux!"
        install_arch

        echo_success "Installed for Arch Linux!"
    ;;

    OS_DEBIAN_LINUX )
        echo_info "Running install for Debian/Ubuntu/Derivitive Linux!"
        install_debian

        echo_success "Installed for Debian/Ubuntu/Derivitive Linux!"
    ;;
esac

echo_info "Finishing up...."
cd ../
echo_success "Installed! Please restart your terminal for all changes to take effect! :D"

