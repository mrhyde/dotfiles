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

  sudo apt update
  sudo bash -c 'DEBIAN_FRONTEND=noninteractive apt -o DPkg::options::=--force-confdef -o DPkg::options::=--force-confold upgrade -y'
  sudo apt install -y "${packages[@]}"
  sudo apt autoremove -y
  sudo apt autoclean
}

function install_volta() {
  curl https://get.volta.sh | bash
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
  sudo groupadd docker
  sudo usermod -aG docker "$USER"

  # start docker on boot with systemd
  sudo systemctl enable docker.service
  sudo systemctl enable containerd.service
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
  sudo apt install -y locales
  sudo locale-gen en_IN.UTF-8
  sudo localectl set-locale LANG=en_IN.UTF-8
  # or manually:
  # sudo dpkg-reconfigure locales
}

function fix_systemd() {
  if (( WSL )); then
    sudo apt install -y systemd
    # Ref. https://github.com/microsoft/WSL/issues/9602#issuecomment-1421897547
    sudo ln -s /usr/lib/systemd/systemd /sbin/init
  fi
}

function fix_wsl_interop() {
  if (( WSL )); then
    # Ref. https://github.com/microsoft/WSL/issues/8952
    sudo sh -c 'echo :WSLInterop:M::MZ::/init:PF > /usr/lib/binfmt.d/WSLInterop.conf'
    sudo systemctl unmask systemd-binfmt.service
    sudo systemctl restart systemd-binfmt
    sudo systemctl mask systemd-binfmt.service
  fi
}

function fix_time_sync() {
  if (( WSL )); then
    # Ref. https://github.com/microsoft/WSL/issues/8204#issuecomment-1338334154
    sudo mkdir -p /etc/systemd/system/systemd-timesyncd.service.d
    sudo tee /etc/systemd/system/systemd-timesyncd.service.d/override.conf > /dev/null <<'EOF'
[Unit]
ConditionVirtualization=
EOF
    sudo systemctl start systemd-timesyncd
  fi
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
fix_systemd
fix_wsl_interop
fix_time_sync
set_preferences

install_packages
install_volta
install_docker

echo SUCCESS
