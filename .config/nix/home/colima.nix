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
}