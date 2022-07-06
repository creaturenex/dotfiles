#!/bin/bash

sudo ()
{
    [[ $EUID = 0 ]] || set -- command sudo "$@"
    "$@"
}

SCRIPT_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

[ -f "$SCRIPT_DIR/install.log" ] && { echo >&2 "Dotfiles have already installed. Exiting!"; exit 1; }

echo "install.sh ran at $(date) from $SCRIPT_DIR" >> $SCRIPT_DIR/install.log

echo "Installing packages" >> $SCRIPT_DIR/install.log

if [ `which apt` ]; then

  # Add source for RCM
  wget https://thoughtbot.com/thoughtbot.asc && \
    sudo apt-key add - < thoughtbot.asc && \
    echo "deb https://apt.thoughtbot.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/thoughtbot.list

  # Install RCM
  sudo apt-get update
  sudo apt-get install -o Dpkg::Options::="--force-confold" -yq rcm netcat zsh iproute2

elif [ `which apk` ]; then
   apk add rcm zsh iproute2
else
   echo "UNKNOWN LINUX DISTRO"
   exit 1
fi

echo "Installing fzf" >> $SCRIPT_DIR/install.log
# Install fzf from source
git clone --depth 1 --branch 0.20.0 https://github.com/junegunn/fzf.git ~/.fzf && \
  ~/.fzf/install --all

echo "Installing oh my zsh if it does not exist" >> $SCRIPT_DIR/install.log

# Install oh-my-zsh
sh -c "$(wget -O- https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)" "" --unattended
# Install Powerlevel10k theme
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k

echo "Installing dotfiles with rcup" >> $SCRIPT_DIR/install.log

rcup -d $SCRIPT_DIR -f -B docker zshrc gitconfig p10k.zsh

echo "Installing solargraph" >> $SCRIPT_DIR/install.log
gem install solargraph
