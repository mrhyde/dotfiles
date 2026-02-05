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
      frida-tools
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

      # fonts
      nerd-fonts.fira-code
      nerd-fonts.fira-mono
      nerd-fonts.meslo-lg
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
