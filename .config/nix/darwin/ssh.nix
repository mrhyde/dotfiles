{ primaryUser, ... }:
{
  # macOS has no declarative "Remote Login" toggle, and `systemsetup
  # -setremotelogin` needs Full Disk Access, so drive launchd directly.
  system.activationScripts.postActivation.text = ''
    launchctl enable system/com.openssh.sshd
    launchctl bootstrap system /System/Library/LaunchDaemons/ssh.plist 2>/dev/null || true
  '';

  services.openssh.extraConfig = ''
    PasswordAuthentication no
    KbdInteractiveAuthentication no
    PermitRootLogin no
    AllowUsers ${primaryUser}
  '';

  users.users.${primaryUser}.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDM8PL6//9yTxZZaW4aYYuNW+WL2Lyz03pE12JGzR3K2 jason@macbook"
  ];
}
