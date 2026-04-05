{
  pkgs,
  inputs,
  primaryUser,
  ...
}:
let
  nixGL = inputs.nixgl.packages.${pkgs.system}.nixGLDefault;
  wrapWithNixGL = pkg: binName:
    pkgs.writeShellScriptBin binName ''
      exec ${nixGL}/bin/nixGL ${pkg}/bin/${binName} "$@"
    '';
in
{
  home = {
    homeDirectory = "/home/${primaryUser}";
    packages = with pkgs; [
      autoconf
      dos2unix
      nano
      ngrok
      (wrapWithNixGL chromium "chromium")
      (wrapWithNixGL gitkraken "gitkraken")
    ];
  };

  programs.git.settings = {
    user = {
      name = "Jason Hyde";
      email = "github@2bad.me";
      signingKey = "CC6148AB62E23917";
    };
    gpg.program = "/usr/bin/gpg";
  };

  programs.home-manager.enable = true;
}
