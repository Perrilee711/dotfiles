#!/usr/bin/env bash
# Codespaces 启动时自动跑 · 也可手动在 mac 跑

set -e
DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
echo "[dotfiles] install from $DOTFILES"

# 1. git config
if [ -f "$DOTFILES/.gitconfig" ]; then
  ln -sf "$DOTFILES/.gitconfig" "$HOME/.gitconfig"
  echo "  ✓ ~/.gitconfig symlinked"
fi

# 2. VS Code settings (Codespaces 用 ~/.vscode-server · 本地 mac 用 ~/Library/Application Support/Code)
mkdir -p "$HOME/.vscode-server/data/Machine"
ln -sf "$DOTFILES/vscode/settings.json" "$HOME/.vscode-server/data/Machine/settings.json" 2>/dev/null || true
echo "  ✓ VS Code settings symlinked"

# 3. shell aliases (bashrc / zshrc 里 source)
SHELL_RC=""
[ -n "$BASH_VERSION" ] && SHELL_RC="$HOME/.bashrc"
[ -n "$ZSH_VERSION" ] && SHELL_RC="$HOME/.zshrc"
[ -f "$HOME/.bashrc" ] && SHELL_RC="$HOME/.bashrc" # codespaces 默认 bash
if [ -n "$SHELL_RC" ] && ! grep -q "dotfiles/shell/aliases.sh" "$SHELL_RC" 2>/dev/null; then
  echo "[ -f $DOTFILES/shell/aliases.sh ] && source $DOTFILES/shell/aliases.sh" >> "$SHELL_RC"
  echo "  ✓ aliases sourced in $SHELL_RC"
fi

# 4. 装 Claude Code CLI (Codespaces 主要价值 · 浏览器内可用 claude)
if ! command -v claude >/dev/null 2>&1; then
  echo "[dotfiles] installing Claude Code CLI..."
  npm install -g @anthropic-ai/claude-code 2>&1 | tail -3 || echo "  ⚠️ Claude Code 装失败 · 可手动 npm i -g @anthropic-ai/claude-code"
else
  echo "  ✓ Claude Code already installed: $(claude --version 2>/dev/null || echo unknown)"
fi

echo "[dotfiles] done"
