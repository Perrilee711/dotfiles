# Perri 一人公司常用别名 · 在 Codespaces 自动 source
# 也可在本地 mac 手动 source(从 ~/.zshrc 加一行)

# git 短名
alias gs="git status -sb"
alias gd="git diff"
alias gl="git log --oneline --decorate -20"
alias gp="git push"
alias gpl="git pull --rebase"
alias gco="git checkout"
alias gcb="git checkout -b"

# 项目快速 cd (Codespaces 里通常 /workspaces/<repo>)
alias shop="cd /workspaces/chinawholesalebuy 2>/dev/null || cd ~/Desktop/shop 2>/dev/null"

# npm 短名
alias n="npm"
alias nr="npm run"
alias nt="npm test"
alias ni="npm install"

# ssh 服务器短名(在 Codespaces 也能用 · 假设你把 SSH key 上传)
alias aws="ssh fishgoo-aws"
alias tencent="ssh tencent-chinawholesalebuy"

# 健康快速检查
alias health-aws="curl -s https://freefishbuy.com/health"
alias health-tencent="ssh tencent-chinawholesalebuy 'curl -s http://localhost:3002/health'"

# 跑测试 + 看结果尾部
alias t="npm test 2>&1 | tail -8"
