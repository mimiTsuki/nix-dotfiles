{ lib, ... }:
{
  programs.zsh.initContent = ''
    eval "$($HOMEBREW_PREFIX/bin/brew shellenv)"
  '';

  programs.zsh.zsh-abbr.abbreviations.pbjq = "pbpaste | jq . -S | pbcopy";
}
