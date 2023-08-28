#!/bin/bash
#
# Sets up environment. Can be run multiple times.

set -xueE -o pipefail

if [[ "$(</proc/version)" == *[Mm]icrosoft* ]] 2>/dev/null; then
  readonly WSL=1
else
  readonly WSL=0
fi

# Install a bunch of debian packages.
function install_packages() {
  local packages=(
    apt-transport-https
    autoconf
    bat
    ca-certificates
    command-not-found
    curl
    dialog
    dos2unix
    exa
    gawk
    git
    gzip
    htop
    jc
    jq
    locales
    mesa-va-drivers
    moreutils
    nano
    ripgrep
    software-properties-common
    tree
    tzdata
    ubuntu-release-upgrader-core
    unrar
    unzip
    vainfo
    wget
    zip
    zsh
  )

  sudo apt-get update
  sudo bash -c 'DEBIAN_FRONTEND=noninteractive apt-get -o DPkg::options::=--force-confdef -o DPkg::options::=--force-confold upgrade -y'
  sudo apt-get install -y "${packages[@]}"
  sudo apt-get autoremove -y
  sudo apt-get autoclean
}

function install_volta() {
  curl https://get.volta.sh | bash
}

function install_docker() {
  if (( WSL )); then
    sudo mkdir -p /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    echo \
      "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
      $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    sudo apt-get update -y
    sudo apt-get install -y docker-ce
    # Ref. https://github.com/microsoft/WSL/discussions/4872
    sudo touch /etc/fstab
    sudo update-alternatives --set iptables /usr/sbin/iptables-legacy
    sudo update-alternatives --set ip6tables /usr/sbin/ip6tables-legacy
  else
    sudo apt-get install -y docker.io
  fi
  sudo usermod -aG docker "$USER"
}

function add_to_sudoers() {
  # This is to be able to create /etc/sudoers.d/"$username".
  if [[ "$USER" == *'~' || "$USER" == *.* ]]; then
    >&2 echo "$BASH_SOURCE: invalid username: $USER"
    exit 1
  fi

  sudo usermod -aG sudo "$USER"
  sudo tee /etc/sudoers.d/"$USER" <<<"$USER ALL=(ALL) NOPASSWD:ALL" >/dev/null
  sudo chmod 440 /etc/sudoers.d/"$USER"
}

function fix_locale() {
  sudo locale-gen en_IN.UTF-8
  sudo localectl set-locale LANG=en_IN.UTF-8
  # or manually:
  # sudo dpkg-reconfigure locales
}

# Set preferences for various applications.
function set_preferences() {
  if (( WSL )); then
    sudo systemctl disable motd-news.timer
    gsettings set org.gnome.desktop.interface monospace-font-name 'MesloLGS Nerd Font 12'
    xdg-settings set default-web-browser google-chrome.desktop
  fi
}

if [[ "$(id -u)" == 0 ]]; then
  echo "$BASH_SOURCE: please run as non-root" >&2
  exit 1
fi

umask g-w,o-w

add_to_sudoers
fix_locale
set_preferences

install_packages
install_volta
install_docker

echo SUCCESS
