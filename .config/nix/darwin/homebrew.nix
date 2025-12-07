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
      "gitkraken"
      "ngrok"
      "ghostty"

      # communication
      "slack"
      "loom"
      "zoom"
      "microsoft-teams"

      # other
      "notion"
      "google-chrome"
      "iina"
      "daisydisk"
    ];
    brews = [
      "docker"
      "colima"
    ];
  };
}
