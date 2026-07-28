{ pkgs, lib, ... }:
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
        e = "eza --icons --git -1 --sort=type";
        el = "eza --icons --git -l --sort=type";
        ea = "eza -a --icons --git -1 --sort=type";
        et = "eza -T -a -I \"node_modules|.git|.cache\" --icons --sort=type -L 3";
        eta = "eza -T -a -I \"node_modules|.git|.cache\" --color=always --icons | less -r --sort=type";
        fdir = "fzf-cd";
        fdcrm = "fzf-docker-container-rm";
        fde = "fzf-docker-exec";
        fdl = "fzf-docker-log";
        fgco = "fzf-git-checkout";
        fgl = "fzf-git-log";
        fgw = "fzf-git-worktree";
        ga = "git add";
        gs = "git status";
        gbr = "git branch";
        gco = "git checkout";
        gl = "git log";
        glo = "git log --oneline";
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

    initContent = lib.mkMerge [
      # compinit前に実行（Cursor Agent Mode対応の早期リターン）
      (lib.mkOrder 550 ''
        if [[ -n "$CURSOR_AGENT" ]]; then
          return
        fi
        export GPG_TTY=$TTY
      '')
      ''
        source "$HOME/zsh/init.zsh"
      ''
    ];

  };

  home.file = {
    "zsh/init.zsh".source = ./zsh/init.zsh;
    "zsh/functions/fzf-git-log".source = ./zsh/functions/fzf-git-log;
    "zsh/functions/fzf-repository".source = ./zsh/functions/fzf-repository;
    "zsh/functions/fzf-docker-log".source = ./zsh/functions/fzf-docker-log;
    "zsh/functions/fzf-docker-exec".source = ./zsh/functions/fzf-docker-exec;
    "zsh/functions/fzf-docker-container-rm".source = ./zsh/functions/fzf-docker-container-rm;
    "zsh/functions/fzf-git-checkout".source = ./zsh/functions/fzf-git-checkout;
    "zsh/functions/fzf-git-worktree".source = ./zsh/functions/fzf-git-worktree;
    "zsh/functions/fzf-cd".source = ./zsh/functions/fzf-cd;
    "zsh/functions/ghcr".source = ./zsh/functions/ghcr;
  };
}
