# 🛡️ AI Continuity Plan · 防 AI 单点失效

> 起因：当 AI（Claude / OpenAI）成为日常工具，「AI 服务挂掉 = 工程能力消失」是真实焦虑。
> 解法：5 层防御 · ¥120/年 · 完全消除单点风险。
> Last updated: 2026-04-28

---

## 🎯 核心认知

**你的资产不是 AI，是体系**。AI 帮你写出来的代码、流程、文档已经在 git 永久存储。Anthropic 关了你今天的资产**不会消失**。

防御目标 = **保证 AI 服务降级时，工程能力不间断**。

---

## 🛡️ 5 层防御策略

### Layer 1 · 流程沉淀（永久 · 0 成本 · 最重要）

**原则**：所有 commands 写进 markdown · 不依赖 AI 也能照抄。

✅ 你已有：
- `EMERGENCY-PLAYBOOK.md` 10 节生产事故 SOP
- `CHECKLIST-DEPLOY.md` P0/P1/P2 上线清单
- `ROUTE-MAP.md` 路线回顾
- iPhone 沙滩急救包（10 个一键命令）

**真出事时优先级**：抄 PLAYBOOK > 用 AI 思考。AI 是辅助，不是必需。

---

### Layer 2 · 多 AI 备份（关键 · 中国友好 · 30 分钟配）

| AI | 月成本 | 中国直连 | 性能 vs Claude | 备用价值 |
|---|---|---|---|---|
| Claude Max | $20 | ⚠️ 需海外网 | 100% | 主用 |
| **DeepSeek** | API ¥10 充够用半年 | ✅ 直连 | 95% Claude 3.5 | 🥇 最强备用 · 国产 |
| **Kimi (Moonshot)** | 免费 | ✅ 直连 | 80% · 长文本强 | 🥈 浏览器应急 |
| **通义千问 Qwen Max** | 按量 ¥10/月 | ✅ 直连 | 85% Claude | 🥉 阿里云生态 |

**配置 SOP**：
1. DeepSeek API key 存 1Password（命名 "DeepSeek API · backup"）
2. Cursor IDE 或 Continue.dev 配 DeepSeek 备用 endpoint
3. Kimi 浏览器收藏栏 · 紧急时 1 click 打开
4. 每月 1 号试用一次 DeepSeek 写一段代码 · 验证可用

---

### Layer 3 · 本地 LLM 兜底（永久免费 · 离线可用）

**装一次永远不挂**。Mac M1/M2/M3 跑 Ollama：

```bash
# 安装(一次性)
brew install ollama

# 拉模型(适合 Mac · 选其一)
ollama pull qwen2.5-coder:14b      # 9GB · 代码强 · 平衡
ollama pull deepseek-coder-v2:16b  # 9GB · DeepSeek 同源
ollama pull llama3.2:8b            # 5GB · 通用问答

# 后台运行(自动启动)
brew services start ollama

# 测试
ollama run qwen2.5-coder:14b "用 Node.js 写一个简单 HTTP server"
```

**性能对标**：
- qwen2.5-coder:14b ≈ Claude 3.5 Haiku（写简单代码 / 应急问答够）
- 真断网 / Anthropic 挂 → 这是你的最终堡垒

---

### Layer 4 · GitHub Repos 物理备份（每月跑 · 防 GitHub + Anthropic 双断）

**脚本**：`~/Backups/scripts/backup-github.sh`

```bash
#!/bin/bash
set -e
BACKUP_DIR="$HOME/Backups/github-mirrors"
ICLOUD_DIR="$HOME/Library/Mobile Documents/com~apple~CloudDocs/github-backup"
mkdir -p "$BACKUP_DIR" "$ICLOUD_DIR"

REPOS=(
  "chinawholesalebuy" "dotfiles" "starter-template" "perrilee-com"
  # ... 你的关键 repos
)

cd "$BACKUP_DIR"
for repo in "${REPOS[@]}"; do
  if [ -d "$repo.git" ]; then
    (cd "$repo.git" && git remote update --prune)
  else
    gh repo clone "$YOUR_GITHUB_USER/$repo" "$repo.git" -- --mirror
  fi
done
rsync -aq --delete "$BACKUP_DIR/" "$ICLOUD_DIR/"
```

**自动化**（可选）：
```bash
# 每月 1 号自动跑(macOS launchd 或 cron)
crontab -e
# 加: 0 9 1 * * /bin/bash $HOME/Backups/scripts/backup-github.sh
```

**3 重保险**：
1. ~/Backups/github-mirrors（本地）
2. iCloud Drive（云端）
3. GitHub remote（在线）

---

### Layer 5 · 客户合作 / 外包（最终兜底 · 不到万不得已不用）

**真所有 AI 全挂的应急** ：
- 招中国独立工程师 ¥8000-15000/月
- 你的 EMERGENCY-PLAYBOOK + CHECKLIST + 256 测试 = 外包 1 周 onboard
- 接客户成本反映这个 buffer · 利润率仍能撑

**这是兜底 · 不要轻易触发**。Layer 1-4 已经覆盖 99% 场景。

---

## 🚨 应急切换 SOP（Anthropic 服务挂时）

### 场景 A · 几小时短期 outage（最常见）

```
1. 暂停今天的"创造性"工作（写新功能）
2. 用 AI 备用栈应急：
   - Cursor + DeepSeek API（已配）
   - 或 Kimi 浏览器（紧急）
3. 等 Anthropic 恢复 · 通常 < 12h
4. 不写代码就改文档 / 看 metrics / 接客户电话
```

### 场景 B · 几天 outage（罕见）

```
1. Cursor + DeepSeek 全量切换主用
2. .cursor/settings.json 设 DeepSeek 为默认
3. 复杂任务用本地 Ollama
4. 客户沟通：诚实告知"AI 工具临时调整 · 交付时间不变"
```

### 场景 C · 永久挂 / 政策变化（极罕见）

```
1. 一次性切换工作流到 DeepSeek + Cursor
2. ~/dotfiles 里所有 Claude 相关 reference 改成 DeepSeek
3. 评估 DeepSeek + Ollama 长期工作流稳定性
4. 如果性能不够 → 加 OpenAI 订阅（需 VPN）
```

---

## 📅 平时维护清单

| 频率 | 做什么 | 时间 |
|---|---|---|
| **每月 1 号** | 跑 backup-github.sh | 5 min |
| **每月** | DeepSeek API 试用一次（防接口变化） | 5 min |
| **每季度** | 更新 Ollama 模型（拉最新版） | 10 min |
| **每半年** | 重新评估备用 AI 性价比 | 30 min |
| **每年** | 复盘是否真触发过应急（提取经验） | 30 min |

---

## 💰 完全冗余成本

| 组件 | 月成本 | 年成本 |
|---|---|---|
| Claude Max（主） | $20 | $240 |
| DeepSeek API（备 1） | ¥1-3 | ¥12-36 |
| Kimi 免费版（备 2） | $0 | $0 |
| Ollama 本地（备 3） | $0 | $0 |
| GitHub backup（自动） | $0 | $0 |
| **完全冗余** | **+¥10** | **+¥120** |

**¥120/年 = 一杯星巴克 = 永远不再担心 AI 单点**。

---

## 🎯 重新认识"AI 依赖"

| 错认知 | 正确认知 |
|---|---|
| Claude 是我的能力 | Claude 是工具 · **体系**才是能力 |
| Claude 挂了我废了 | 工具坏了换工具 · 体系不挂 |
| 我必须 100% 依赖 Claude | 我用 Claude 80% · 备用 20% 切换零成本 |
| AI 单点 = 一人公司风险 | 5 层防御 ¥120/年 = 风险归零 |

---

## 🔗 相关文档

- `~/dotfiles/templates/CHECKLIST-DEPLOY.md` - 上线纪律
- `~/dotfiles/templates/EMERGENCY-PLAYBOOK.md` - 紧急 SOP
- `~/Backups/scripts/backup-github.sh` - GitHub 备份脚本

---

> 📌 **最重要的一件事**：你今天做的所有工程化护栏 = 抵抗 AI 单点的最强武器。
> 比任何"换 AI 供应商"都重要。
> 流程沉淀 > 多 AI 备份 > 本地兜底 > 物理备份 > 招外包
