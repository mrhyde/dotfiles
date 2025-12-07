{ pkgs, ... }:
{
  home = {
    packages = with pkgs; [
      # dev tools
      bat
      curl
      eza
      fzf
      gh
      gnupg
      htop
      jc
      jq
      lazydocker
      lazygit
      neofetch
      openssh
      ripgrep
      tmux
      tree
      unrar
      unzip
      wget
      zip
      zoxide
      zsh

      # ctls
      flyctl
      kubectl
      zerotierone

      # programming languages
      volta
      uv

      # misc
      nil
      nixfmt-rfc-style
      yt-dlp
      ffmpeg
      ollama

      # fonts
      nerd-fonts.fira-code
      nerd-fonts.fira-mono
      nerd-fonts.meslo-lg
    ];
  };
}
