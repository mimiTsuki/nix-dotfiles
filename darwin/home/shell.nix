{ lib, ... }:
{
  programs.zsh.initContent = ''
    eval "$(/opt/homebrew/bin/brew shellenv)"
  '';

  programs.zsh.zsh-abbr.abbreviations.pbjq = "pbpaste | jq . -S | pbcopy";
}
