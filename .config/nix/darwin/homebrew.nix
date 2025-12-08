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
      "cleanshot"
      "raycast"
      # "hiddenbar"
      # "betterdisplay"

      # dev
      "visual-studio-code"
      "ghostty"
      "gitkraken"
      "ngrok"
      "zerotier-one"

      # communication
      "microsoft-teams"
      "slack"
      "loom"
      "zoom"

      # other
      "google-chrome"
      "notion"
      "iina"
      "daisydisk"
    ];
    brews = [
      "docker"
      "colima"
    ];
    taps = [];
  };
}
