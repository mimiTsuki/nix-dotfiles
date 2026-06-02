{ ... }:
{
  imports = [
    ./zsh
  ];

  programs.direnv = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.starship = {
    enable = true;
    enableZshIntegration = true;
    settings = {
      aws = {
        disabled = false;
        format = "[$symbol($profile)(\($region\))]($style) ";
        symbol = "☁️  ";
        style = "bold yellow";
      };
      kubernetes = {
        disabled = false;
        format = "[$symbol$context(\($namespace\))]($style) ";
        symbol = "⎈ ";
        style = "bold cyan";
      };
    };
  };

  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
    defaultOptions = [ "--layout reverse" ];
  };
}
