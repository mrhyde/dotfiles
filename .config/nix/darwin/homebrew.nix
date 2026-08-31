{ ... }:
{
  homebrew = {
    enable = true;

    onActivation = {
      autoUpdate = false;
      upgrade = true;
      cleanup = "uninstall";
    };

    global.brewfile = true;

    # homebrew is best for GUI apps
    # nixpkgs is best for CLI tools
    casks = [
      # OS enhancements
      "raycast"
      # "hiddenbar"
      # "betterdisplay"

      # dev
      "ghostty"
      "gitkraken"
      "http-toolkit"
      "mitmproxy"
      "ngrok"
      "tableplus"
      "visual-studio-code@insiders"
      "zerotier-one"

      # communication
      # "microsoft-teams"
      "slack"
      # "zoom"

      # other
      "claude"
      "cleanshot"
      "daisydisk"
      "google-chrome"
      "iina"
      "notion"
      "quickrecorder"
    ];
    brews = [
      "docker"
      "docker-buildx"
      "docker-compose"
      "colima"
    ];
    taps = [
      {
        name = "lihaoyun6/tap";
        trusted = true;
      }
    ];
  };
}
