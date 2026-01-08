{ config, pkgs, ... }:

{
  launchd.agents.colima = {
    enable = true;
    config = {
      ProgramArguments = [
        "${pkgs.colima}/bin/colima"
        "start"
      ];
      RunAtLoad = true;
      KeepAlive = false;
      StandardOutPath = "/tmp/colima.log";
      StandardErrorPath = "/tmp/colima.err";
      EnvironmentVariables = {
        PATH = "${pkgs.docker}/bin:${pkgs.colima}/bin:/usr/bin:/bin";
      };
    };
  };

  home.file.".docker/config.json".text = builtins.toJSON {
    auths = {};
    currentContext = "colima";
    # Set the CLI plugins extra dirs to include Homebrew's Docker CLI plugins such as docker-compose
    cliPluginsExtraDirs = [
      "/opt/homebrew/lib/docker/cli-plugins"
    ];
  };
}