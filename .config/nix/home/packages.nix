{ pkgs, ... }:
{
  home = {
    packages = with pkgs; [
      # dev tools
      bat
      cloc
      curl
      direnv
      eza
      fd
      fzf
      gh
      gnupg
      granted
      htop
      jc
      jq
      lazydocker
      lazygit
      neofetch
      openssh
      rainfrog
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

  programs = {
    eza = {
      enable = true;
      enableZshIntegration = true;
      icons = "auto";
      git = true;
    };
    bat = {
      enable = true;
    };
    fzf = {
      enable = true;
    };
  };
}
