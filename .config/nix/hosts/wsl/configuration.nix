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
    packages = [
      (wrapWithNixGL pkgs.gitkraken "gitkraken")
    ];
  };

  programs.home-manager.enable = true;
  programs.zsh.enable = true;
}
