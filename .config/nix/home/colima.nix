_: {
  launchd.agents.colima = {
    enable = true;
    config = {
      ProgramArguments = [
        "/opt/homebrew/bin/colima"
        "start"
      ];
      RunAtLoad = true;
      KeepAlive = false;
      StandardOutPath = "/tmp/colima.log";
      StandardErrorPath = "/tmp/colima.err";
      EnvironmentVariables = {
        PATH = "/opt/homebrew/bin:/usr/bin:/bin";
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