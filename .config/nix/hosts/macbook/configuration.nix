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

    programs.git.settings = {
      user = {
        name = "Jason Hyde";
        email = "jason@xliberate.com";
        signingKey = "1DD86A347604AEF6";
      };
      gpg.program = "/etc/profiles/per-user/${primaryUser}/bin/gpg";
    };

    programs.zsh.initContent = ''
      # Source shell functions
      source ${./shell-functions.sh}
    '';
  };
}
