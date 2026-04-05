{ pkgs, ... }:
{
  home = {
    packages = with pkgs; [
      # dev tools
      awscli2
      bat
      bc
      cloc
      curl
      dnsutils
      eza
      fd
      figlet
      fzf
      gawk
      gh
      gnupg
      graphicsmagick
      granted
      htop
      jc
      jq
      k6
      lazydocker
      lazygit
      lz4
      moreutils
      neofetch
      nmap
      openssh
      rainfrog
      ripgrep
      rsync
      ssm-session-manager-plugin
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
      asciinema
      nil
      nixfmt-rfc-style
      yt-dlp
      ffmpeg
      ollama

    ];
  };

  programs = {
    direnv = {
      enable = true;
      config.global.load_dotenv = true;
    };
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
