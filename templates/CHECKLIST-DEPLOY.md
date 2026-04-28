# 上线前检查清单 · 通用模板

> 跨项目复用模板。新项目用法：
> ```bash
> cp ~/dotfiles/templates/CHECKLIST-DEPLOY.md ~/path/to/project/
> # 然后用编辑器全文替换 <PLACEHOLDER> 为项目实际值
> ```
>
> 占位符（用编辑器全文替换）：
> - `<PROD_DOMAIN>` 主生产域名（如 `myapp.com`）
> - `<STAGING_DOMAIN>` staging 域名（如 `staging.myapp.com`）
> - `<SSH_ALIAS>` 主生产 SSH 别名（如 `myapp-aws`）
> - `<PROJECT_PATH>` 服务器项目路径（如 `/home/deploy/myapp`）
> - `<DB_PATH>` 数据库路径（如 `src/database.sqlite`）

---

## 改动分级

| 级别 | 范围 | 流程 |
|---|---|---|
| **P0** | auth、支付、租户切换、首页 redirect、API 字段增减、数据库迁移 | 全流程（含 staging 30min） |
| **P1** | UI 调整、文案、组件样式、单租户行为 | 跳过 staging，但上线后 5min 监控 |
| **P2** | 日志、注释、文档、CI 配置 | 直接 push，无监控要求 |

---

## 1. 改动前 · 影响面评估（30 秒，3 个问题）

如果有 1 个答不上来，**停下来想清楚再写代码**。

- [ ] **谁受影响？** 匿名访客 / 付费用户 / 管理员 / 超管？
- [ ] **哪些已有流程被打断？** 至少把核心 5 个流程跑一遍脑子（按项目实际情况列）
- [ ] **可逆吗？** 上线后发现问题，能 1 分钟内 `git revert + push` 回滚吗？

---

## 2. 改动中 · 测试覆盖（5 分钟）

- [ ] `npm test` 全部通过
- [ ] 改动跨 ≥2 个文件 → 用 curl/手动验一次集成
- [ ] 改动涉及关键模块（auth/支付/敏感数据）→ 必须跑相关 .test.js

---

## 3. P0 改动专用 · staging 缓冲（最少 30 分钟）

```bash
# ① 先合到 develop，触发 staging 部署
git checkout develop && git merge main && git push origin develop

# ② 等 CI 跑完
# ③ 在 https://<STAGING_DOMAIN> 跑主流程
# ④ 等 30 分钟，看监控（Sentry/飞书）有无意外
# ⑤ 无异常 → 合 main 上生产
git checkout main && git merge develop && git push origin main
```

---

## 4. 上线后 · 主动监控（5 分钟）

- [ ] **Sentry/飞书机器人** 5 分钟内无新错误
- [ ] **健康检查**：
  ```bash
  curl -s https://<PROD_DOMAIN>/health
  ```
- [ ] **错误日志**：
  ```bash
  ssh <SSH_ALIAS> "sudo tail -30 <PROJECT_PATH>/logs/error.log"
  ```
- [ ] **关键业务表监控**（按项目自定义，如 login_failures、transactions、orders 等）

---

## 5. 紧急回滚（贴屏幕角落）

```bash
cd ~/path/to/project
git log --oneline -3                    # 看上次好的 commit
git revert HEAD --no-edit               # 撤销最新 commit
git push origin main                    # CI 自动部署回滚版本
# 约 3 分钟生产恢复
```

---

## 6. 历史教训（每次出 bug 后追加）

| 日期 | commit | bug | 当时漏掉的检查 |
|---|---|---|---|
| YYYY-MM-DD | `abc1234` | <一句话描述> | <如何避免> |

---

## 7. AI Review · /ultrareview 手动触发

PR 大改动想要 AI 二次审查时，在本地项目目录跑：

```bash
/ultrareview <PR#>          # review 指定 PR (有 GitHub remote)
/ultrareview                # review 当前 branch 本地修改 (无需 remote)
```

走你的 Claude Max 订阅 quota · 不另外付 API token 费。

适用：P0 改动 / 不熟悉的领域 / 想要二次合伙人意见。
不适用：typo / 简单修改 / 跑通了测试的小改。

---

## 与 CLAUDE.md 三条规则配合

如果你和 Claude（技术合伙人）合作，CLAUDE.md 全局指令要求：
1. 改动前 Claude 主动报"影响面"
2. P0 必给"走 staging 流程吗？"选项
3. 上线后 5min 主动报"无异常"

> 🎯 严格执行 6 个月，bug 漏到生产的概率从 ~50% 降到 ~5%。
