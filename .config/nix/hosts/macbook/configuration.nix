{
  pkgs,
  primaryUser,
  ...
}:
{
  networking.hostName = "macbook";

  # host-specific homebrew casks
  homebrew.casks = [
    # "slack"
  ];

  # host-specific home-manager configuration
  home-manager.users.${primaryUser} = {
    home.packages = with pkgs; [
      frida-tools
      nerd-fonts.fira-code
      nerd-fonts.fira-mono
      nerd-fonts.meslo-lg
    ];

    programs = {
      zsh = {
        initContent = ''
          # Source shell functions
          source ${./shell-functions.sh}
        '';
      };
    };
  };
}
