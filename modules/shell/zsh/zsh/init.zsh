eval "$($HOMEBREW_PREFIX/bin/brew shellenv)"

# 補完スタイル
zstyle ':completion:*' matcher-list "" 'm:{[:lower:]}={[:upper:]}' '+m:{[:upper:]}={[:lower:]}'
zstyle ':completion:*' format '%B%F{blue}%d%f%b'
zstyle ':completion:*' group-name ""
zstyle ':completion:*:default' menu select=2

# gh completion
eval "$(gh completion -s zsh)"

# mise
if type "mise" > /dev/null 2>&1; then
    eval "$(mise activate zsh)"
    export PATH="$HOME/.local/share/mise/shims:$PATH"
fi

# カスタム関数
fpath=("$HOME/zsh/functions" $fpath)

_zload() {
    autoload -Uz $1
    zle -N $1
    if [ "$2" != "" ]; then bindkey $2 $1; fi
}
_zload fzf-repository "^]"
_zload fzf-cd
_zload fzf-docker-container-rm
_zload fzf-docker-exec
_zload fzf-docker-log
_zload fzf-git-checkout
_zload fzf-git-log
_zload ghcr

# cdしたときにlsする
chpwd() {
    if [[ $(pwd) != $HOME ]]; then
        eza --icons --git
    fi
}

# マシン固有設定
if [ -e "$HOME/zsh/local.zsh" ]; then
    source "$HOME/zsh/local.zsh"
fi
