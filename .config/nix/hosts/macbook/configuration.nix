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
      nerd-fonts.fira-code
      nerd-fonts.fira-mono
      nerd-fonts.meslo-lg
    ];

    programs.git.settings = {
      user = {
        name = "Jason Hyde";
        email = "github@2bad.me";
        signingKey = "31D6485A899EE1DE7AFD333FAC2E09DC81CD97DB";
      };
      gpg.program = "/etc/profiles/per-user/${primaryUser}/bin/gpg";
    };
  };
}
