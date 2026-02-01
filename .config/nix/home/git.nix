{ primaryUser, ... }:
{
  programs.git = {
    enable = true;
    lfs.enable = true;

    settings = {
      user = {
        name = "Jason Hyde";
        email = "jason@xliberate.com";
        signingKey = "1DD86A347604AEF6";
      };
      gpg = {
        program = "/etc/profiles/per-user/${primaryUser}/bin/gpg";
        format = "openpgp";
      };
      commit = {
        gpgSign = true;
      };
      pull = {
        ff = "only";
      };
      rebase = {
        updateRefs = true;
      };
      tag = {
        forceSignAnnotated = false;
      };

      github = {
        user = "mrhyde";
      };

      init = {
        defaultBranch = "master";
      };
    };

    ignores = ["**/.DS_STORE" "**/CLAUDE.md" "**/.claude/settings.local.json" "**/.oxfmtrc.json"];
  };
}
