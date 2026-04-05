{ primaryUser, ... }:
{
  imports = [
    ./packages.nix
    ./ghostty.nix
    ./git.nix
    ./shell.nix
  ];

  home = {
    username = primaryUser;
    stateVersion = "25.11";
    sessionVariables = {
      EDITOR = "nano";
      VISUAL = "nano";
    };

    # create .hushlogin file to suppress login messages
    file.".hushlogin".text = "";
  };
}
