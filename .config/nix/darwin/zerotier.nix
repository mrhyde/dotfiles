_: {
  system.activationScripts.postActivation.text = ''
    if [ -x /usr/local/bin/zerotier-cli ]; then
      /usr/local/bin/zerotier-cli join 272f5eae1610cc39 || true
    fi
  '';
}
