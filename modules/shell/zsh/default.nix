{ pkgs, ... }:
{
  programs.zsh = {
    enable = true;
    enableCompletion = true;

    history = {
      ignoreDups = true;
      share = true;
    };

    zsh-abbr = {
      enable = true;
      abbreviations = {
        e = "eza --icons --git";
        ea = "eza -a --icons --git";
        ee = "eza -aahl --icons --git";
        et = "eza -T -L 3 -a -I \"node_modules|.git|.cache\" --icons";
        eta = "eza -T -a -I \"node_modules|.git|.cache\" --color=always --icons | less -r";
        fdir = "fzf-cd";
        fdcrm = "fzf-docker-container-rm";
        fde = "fzf-docker-exec";
        fdl = "fzf-docker-log";
        fgco = "fzf-git-checkout";
        fgl = "fzf-git-log";
        ga = "git add";
        gs = "git status";
        gbr = "git branch";
        gch = "git checkout";
        gco = "claude --no-session-persistence --strict-mcp-config --model haiku -p \"/commit-jp\"";
        gl = "git log";
      };
    };

    plugins = [
      {
        name = "zsh-autosuggestions";
        src = pkgs.zsh-autosuggestions;
        file = "share/zsh-autosuggestions/zsh-autosuggestions.zsh";
      }
      {
        name = "zsh-syntax-highlighting";
        src = pkgs.zsh-syntax-highlighting;
        file = "share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh";
      }
    ];

    # compinit前に実行（Cursor Agent Mode対応の早期リターン）
    initExtraBeforeCompInit = ''
      if [[ -n "$npm_config_yes" ]] || [[ -n "$CI" ]] || [[ "$-" != *i* ]]; then
        return
      fi
      export GPG_TTY=$TTY
    '';

    initExtra = ''
      source "$HOME/zsh/init.zsh"
    '';

  };

  home.file = {
    "zsh/init.zsh".source = ./zsh/init.zsh;
    "zsh/functions/fzf-git-log".source = ./zsh/functions/fzf-git-log;
    "zsh/functions/fzf-repository".source = ./zsh/functions/fzf-repository;
    "zsh/functions/fzf-docker-log".source = ./zsh/functions/fzf-docker-log;
    "zsh/functions/fzf-docker-exec".source = ./zsh/functions/fzf-docker-exec;
    "zsh/functions/fzf-docker-container-rm".source = ./zsh/functions/fzf-docker-container-rm;
    "zsh/functions/fzf-git-checkout".source = ./zsh/functions/fzf-git-checkout;
    "zsh/functions/fzf-cd".source = ./zsh/functions/fzf-cd;
    "zsh/functions/ghcr".source = ./zsh/functions/ghcr;
  };
}
