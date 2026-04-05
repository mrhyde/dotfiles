{ pkgs, ... }:
{
  home = {
    packages = with pkgs; [
      # dev tools
      awscli2
      bat
      cloc
      curl
      eza
      fd
      fzf
      gawk
      gh
      gnupg
      granted
      htop
      jc
      jq
      lazydocker
      lazygit
      moreutils
      neofetch
      openssh
      rainfrog
      ripgrep
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
