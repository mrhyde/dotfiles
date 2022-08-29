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
    curl
    dialog
    dos2unix
    gawk
    git
    gzip
    htop
    jc
    jq
    locales
    moreutils
    nano
    python3
    # python3-pip
    ripgrep
    software-properties-common
    tree
    tzdata
    unrar
    unzip
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
    local release
    release="$(lsb_release -cs)"
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
    sudo apt-key fingerprint 0EBFCD88
    sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu
      $release
      stable"
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
  # pip3 install --user docker-compose
}

# Install Visual Studio Code.
function install_vscode() {
  (( !WSL )) || return 0
  ! command -v code &>/dev/null || return 0
  local deb
  deb="$(mktemp)"
  curl -fsSL 'https://go.microsoft.com/fwlink/?LinkID=760868' >"$deb"
  sudo dpkg -i "$deb"
  rm -- "$deb"
}

function install_exa() {
  local v="0.9.0"
  ! command -v exa &>/dev/null || [[ "$(exa --version)" != *" v$v" ]] || return 0
  local tmp
  tmp="$(mktemp -d)"
  pushd -- "$tmp"
  curl -fsSLO "https://github.com/ogham/exa/releases/download/v${v}/exa-linux-x86_64-${v}.zip"
  unzip exa-linux-x86_64-${v}.zip
  sudo install -DT ./exa-linux-x86_64 /usr/local/bin/exa
  popd
  rm -rf -- "$tmp"
}

function install_gh() {
  local v="1.6.1"
  ! command -v gh &>/dev/null || [[ "$(gh --version)" != */v"$v" ]] || return 0
  local deb
  deb="$(mktemp)"
  curl -fsSL "https://github.com/cli/cli/releases/download/v${v}/gh_${v}_linux_amd64.deb" > "$deb"
  sudo dpkg -i "$deb"
  rm "$deb"
}

function fix_locale() {
  sudo update-locale LC_ALL=C.UTF-8
  # sudo dpkg-reconfigure locales
}

function win_install_fonts() {
  local dst_dir
  dst_dir="$(cmd.exe /c 'echo %LOCALAPPDATA%\Microsoft\Windows\Fonts' 2>/dev/null | sed 's/\r$//')"
  dst_dir="$(wslpath "$dst_dir")"
  mkdir -p "$dst_dir"
  local src
  for src in "$@"; do
    local file="$(basename "$src")"
    if [[ ! -f "$dst_dir/$file" ]]; then
      cp -f "$src" "$dst_dir/"
    fi
    local win_path
    win_path="$(wslpath -w "$dst_dir/$file")"
    # Install font for the current user. It'll appear in "Font settings".
    reg.exe add                                                 \
      'HKCU\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts' \
      /v "${file%.*} (TrueType)" /t REG_SZ /d "$win_path" /f 2>/dev/null
  done
}

# Install a decent monospace font.
function install_fonts() {
  (( WSL )) || return 0
  win_install_fonts ~/.local/share/fonts/NerdFonts/*.ttf
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

umask g-w,o-w

add_to_sudoers
fix_locale

install_packages
install_volta
install_ripgrep
install_jc
install_bat
install_exa
install_fonts
# install_docker
# install_vscode
# install_gh

echo SUCCESS
