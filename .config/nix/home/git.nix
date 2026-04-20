_: {
  programs.git = {
    enable = true;
    lfs.enable = true;

    settings = {
      gpg.format = "openpgp";
      commit.gpgSign = true;
      pull.ff = "only";
      rebase.updateRefs = true;
      tag.forceSignAnnotated = false;
      github.user = "mrhyde";
      init.defaultBranch = "master";
    };

    ignores = ["**/.DS_STORE" "**/CLAUDE.md" "**/.claude/settings.local.json" "**/.claude/skills/*"];
  };
}
