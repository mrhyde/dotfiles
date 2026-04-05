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
      "android-studio"
      "ghostty"
      "gitkraken"
      "http-toolkit"
      "mitmproxy"
      "ngrok"
      "postman"
      "tableplus"
      "visual-studio-code@insiders"

      # communication
      "microsoft-teams"
      "slack"
      "zoom"

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
      "lihaoyun6/tap"
    ];
  };
}
