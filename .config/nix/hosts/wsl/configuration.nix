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

  programs.home-manager.enable = true;
}
