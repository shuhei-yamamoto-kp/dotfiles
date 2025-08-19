# --- ローカル専用設定を読み込み ---
if [ -f ~/.zshrc.local ]; then
  source ~/.zshrc.local
fi


autoload -Uz edit-command-line
zle -N edit-command-line
bindkey "^O" edit-command-line

# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

source /opt/homebrew/share/powerlevel10k/powerlevel10k.zsh-theme

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh


# パスを通す
# export GOPATH=$HOME/go
# export PATH=$PATH:$GOPATH/bin
export PATH="$(go env GOPATH)/bin:$PATH"

# private repository を使っているので以下を追加
export GOPRIVATE=github.com/kabu-peace

# The next line updates PATH for the Google Cloud SDK.
if [ -f "$(brew --prefix)/share/google-cloud-sdk/path.zsh.inc" ]; then . "$(brew --prefix)/share/google-cloud-sdk/path.zsh.inc"; fi

# The next line enables shell command completion for gcloud.
if [ -f "$(brew --prefix)/share/google-cloud-sdk/completion.zsh.inc" ]; then . "$(brew --prefix)/share/google-cloud-sdk/completion.zsh.inc"; fi

# https://www.notion.so/kabu-peace/10441abaea198045b1c8fbd0ec1b3b52?pvs=4#11241abaea1980ccbc1fc26dc08891b4
export GITHUB_TOKEN=$(gh auth token)

# https://github.com/zsh-users/zsh-autosuggestions/blob/master/INSTALL.md#homebrew
source $(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh


# test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh"

# ターミナル共通でヒストリーを持つようにする
setopt share_history
# ! を使った履歴展開の際に、一度確認してから実行できるようになります。
# setopt HIST_VERIFY
#  履歴展開 (!) 自体を無効にする
setopt NO_BANG_HIST

export PATH="$(brew --prefix python)/libexec/bin:$PATH"
export PATH=$PATH:/Users/syamamoto/Library/Python/3.9/bin

export PATH=$PATH:${HOME}/work/sy-other/tool/bin

alias sqlfmt="pbpaste | sqlformat - --reindent --keywords upper --use_space_around_operators"
source "${HOME}/work/pass.txt"

alias quenchat="aichat -m ollama:qwen2.5-coder"

phichat() {
    aichat -m ollama:phi4 "$@"
}
fxtee() { tee >(fx); }
diff() {
  command diff -u --color=auto "$@"
}
html_unescape() {
  sed 's/&amp;/\&/g; s/&lt;/</g; s/&gt;/>/g; s/&quot;/"/g; s/&#39;/'"'"'/g; s/&nbsp;/ /g'
}

unescape_unicode() { zsh -c 'echo -e $0' $1; }

plan-command() {
  if [ $# -eq 0 ]; then
    echo "使い方: plan-command 'コマンド説明'"
    return 1
  fi
  local prompt="$*"
  aichat -r plan-command "$prompt"
}

# 短縮形
alias pc='plan-command'


# Set up fzf key bindings and fuzzy completion
source <(fzf --zsh)


# dotfiles ディレクトリ
DOTFILES="$HOME/dotfiles/zsh"

# 補完関数を fpath に追加
fpath=($DOTFILES/completions $fpath)

for file in $DOTFILES/functions/*.sh; do
  source "$file"
done

# compinit を有効化
autoload -Uz compinit
compinit

complete -o nospace -C $(which terraform) terraform
