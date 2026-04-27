# Perri 的 dotfiles

GitHub Codespaces 启动时自动 clone 这个 repo 并执行 `install.sh`,
让我在任何浏览器/iPad 打开 Codespace 都有一致的开发环境。

## 启用方式 (一次性)

1. 访问 https://github.com/settings/codespaces
2. 滑到 **"Dotfiles"** 区域
3. 勾 ☑ "Automatically install dotfiles"
4. 选择 `Perrilee711/dotfiles`
5. 之后任何 repo 启动 Codespace 都自动 install

## 内容

```
dotfiles/
├── install.sh           Codespaces 启动时自动跑(symlink + 装 Claude Code)
├── .gitconfig           git user / aliases
├── vscode/settings.json VS Code 个人偏好
├── shell/aliases.sh     shell 别名(可选 source)
└── templates/           跨项目复用模板(EMERGENCY-PLAYBOOK 等)
```

## 安装做了什么

- symlink `.gitconfig` → `~/.gitconfig`
- symlink VS Code settings → `~/.vscode-server/data/Machine/settings.json`
- 装 Claude Code CLI: `npm install -g @anthropic-ai/claude-code`
- shell rc 加 source `aliases.sh`

## 本地 mac 也想用?

```bash
cd ~/dotfiles && bash install.sh
```

## 跨项目设计

- `templates/CHECKLIST-DEPLOY.md` — 上线前检查清单 · 三层修复 L1 模板（2026-04-27 落地）
  - 用法：`cp ~/dotfiles/templates/CHECKLIST-DEPLOY.md ~/path/to/project/` 然后替换 `<PLACEHOLDER>`
- `templates/EMERGENCY-PLAYBOOK.md` — 紧急事故 Playbook · 10 节通用模板
  - 30 秒分诊 / 紧急回滚 / DB/PM2/nginx/SSL/限流/DDoS 全覆盖
- `vscode/settings.json` — 所有 Codespaces 共享统一 VS Code 配色
- 后续接的客户项目也吃这套
