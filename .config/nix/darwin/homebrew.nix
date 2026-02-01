{ ... }:
{
  homebrew = {
    enable = true;

    onActivation = {
      autoUpdate = false;
      upgrade = true;
      cleanup = "uninstall";
    };

    caskArgs.no_quarantine = true;
    global.brewfile = true;

    # homebrew is best for GUI apps
    # nixpkgs is best for CLI tools
    casks = [
      # OS enhancements
      "raycast"
      # "hiddenbar"
      # "betterdisplay"

      # dev
      "visual-studio-code@insiders"
      "ghostty"
      "gitkraken"
      "ngrok"
      "orbstack"
      "postman"
      "tableplus"
      "zerotier-one"

      # communication
      "microsoft-teams"
      "slack"
      "zoom"

      # other
      "google-chrome"
      "notion"
      "iina"
      "daisydisk"
      "cleanshot"
      "quickrecorder"
    ];
    brews = [
      "docker"
      "docker-buildx"
      "docker-compose"
      "colima"
    ];
    taps = [
      "lihaoyun6/tap"
    ];
  };
}
