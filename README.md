# README

## Setup

```bash
git clone git@github.com:you/dotfiles.git ~/dotfiles
cd ~/dotfiles
stow zsh git nvim
```

```bash
echo /opt/homebrew/bin/zsh | sudo tee -a /etc/shells
chsh -s /opt/homebrew/bin/zsh
```

## Backup

### 2. Homebrew の移行

```bash
brew bundle dump
```

#### 移行元 (古いマシン)

```bash
brew bundle dump --file=~/dotfiles/Brewfile --force
```

### 注意
.zshrc.local
はgit管理していないのでメモする等する
