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
    eza
    gawk
    git
    gnupg2
    gzip
    htop
    jc
    jq
    libglib2.0-bin
    locales
    mesa-va-drivers
    moreutils
    nano
    ripgrep
    software-properties-common
    sudo
    systemd
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

  sudo apt update
  sudo DEBIAN_FRONTEND=noninteractive apt -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" upgrade -y
  sudo apt install -y "${packages[@]}"
  sudo apt autoremove -y
  sudo apt autoclean
}

function install_volta() {
  curl https://get.volta.sh | bash -s -- --skip-setup
}

function install_docker() {
  if (( WSL )); then
    sudo install -m 0755 -d /etc/apt/keyrings
    sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
    sudo chmod a+r /etc/apt/keyrings/docker.asc
    echo \
      "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
      $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
      sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    sudo apt update
    sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
    # Ref. https://github.com/microsoft/WSL/discussions/4872
    sudo touch /etc/fstab
    sudo update-alternatives --set iptables /usr/sbin/iptables-legacy
    sudo update-alternatives --set ip6tables /usr/sbin/ip6tables-legacy
  fi
  sudo groupadd -f docker
  sudo usermod -aG docker "$USER"

  # start docker on boot with systemd
  sudo systemctl enable docker.service
  sudo systemctl enable containerd.service
}

function add_to_sudoers() {
  # This is to be able to create /etc/sudoers.d/"$username".
  if [[ "$USER" =~ ['~'\.] ]]; then
    echo "$0: invalid username: $USER" >&2
    return 1
  fi

  sudo usermod -aG sudo "$USER"
  echo "$USER ALL=(ALL) NOPASSWD:ALL" | sudo tee /etc/sudoers.d/"$USER" > /dev/null
  sudo chmod 440 /etc/sudoers.d/"$USER"
}

function fix_systemd() {
  if (( WSL )); then
    sudo apt install -y systemd
    # Ref. https://github.com/microsoft/WSL/issues/9602#issuecomment-1421897547
    if [[ ! -e /sbin/init ]]; then
      sudo ln -s /usr/lib/systemd/systemd /sbin/init
    fi
  fi
}

function fix_locale() {
  sudo apt install -y locales
  sudo locale-gen en_IN.UTF-8
  sudo localectl set-locale LANG=en_IN.UTF-8
  # or manually:
  # sudo dpkg-reconfigure locales
}

function fix_wsl_interop() {
  if (( WSL )); then
    # Ref. https://github.com/microsoft/WSL/issues/8952
    echo ':WSLInterop:M::MZ::/init:PF' | sudo tee /usr/lib/binfmt.d/WSLInterop.conf > /dev/null
    sudo systemctl unmask systemd-binfmt.service
    sudo systemctl restart systemd-binfmt
    sudo systemctl mask systemd-binfmt.service
  fi
}

function fix_time_sync() {
  if (( WSL )); then
    # Ref. https://github.com/microsoft/WSL/issues/8204#issuecomment-1338334154
    sudo mkdir -p /etc/systemd/system/systemd-timesyncd.service.d
    echo -e "[Unit]\nConditionVirtualization=" | sudo tee /etc/systemd/system/systemd-timesyncd.service.d/override.conf > /dev/null
    sudo systemctl start systemd-timesyncd
  fi
}

# Set preferences for various applications.
function set_preferences() {
  if (( WSL )); then
    sudo systemctl disable motd-news.timer
    if command -v gsettings &> /dev/null; then
      gsettings set org.gnome.desktop.interface monospace-font-name 'MesloLGS Nerd Font 12'
    fi
    if command -v xdg-settings &> /dev/null; then
      xdg-settings set default-web-browser google-chrome.desktop
    fi
  fi
}

main() {
  if [[ $EUID -eq 0 ]]; then
    echo "$0: please run as non-root" >&2
    exit 1
  fi

  umask 0022

  install_packages
  install_volta
  install_docker
  add_to_sudoers
  fix_systemd
  fix_locale
  fix_wsl_interop
  fix_time_sync
  set_preferences

  echo "SUCCESS"
}

main "$@"