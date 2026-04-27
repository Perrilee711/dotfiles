# 🚨 紧急事故 Playbook · 通用模板

> 跨项目复用模板。新项目用法：
> ```bash
> cp ~/dotfiles/templates/EMERGENCY-PLAYBOOK.md ~/path/to/project/
> # 然后用编辑器全文替换 <PLACEHOLDER>
> ```
>
> 占位符：
> - `<PROD_DOMAIN>` 主生产域名
> - `<SSH_ALIAS>` 主生产 SSH 别名
> - `<PROJECT_PATH>` 服务器项目路径
> - `<DB_PATH>` 数据库路径（如 `src/database.sqlite`）
> - `<PM2_PROCESS_NAME>` PM2 进程名
> - `<APP_PORT>` 应用端口（如 3002）

---

## 0. 30 秒分诊 · 出事先做这 3 件事

```bash
curl -s https://<PROD_DOMAIN>/health && \
ssh <SSH_ALIAS> "sudo tail -20 <PROJECT_PATH>/logs/error.log" && \
ssh <SSH_ALIAS> "sudo sqlite3 <PROJECT_PATH>/<DB_PATH> \"SELECT * FROM <KEY_AUDIT_TABLE> WHERE created_at > strftime('%Y-%m-%dT%H:%M:%fZ', 'now', '-15 minutes') LIMIT 5;\""
```

输出三段：① health 进程状态 ② error 日志 ③ 关键审计表（如登录失败/异常订单）

---

## 1. 紧急回滚（永远的兜底）

```bash
cd ~/path/to/project
git log --oneline -5
git revert HEAD --no-edit
git push origin main
```

3 分钟生产恢复。**永远先回滚再排查**。

---

## 2. 数据库异常

### `/health` 返回 `db: not connected`
```bash
ssh <SSH_ALIAS> "sudo ls -la <PROJECT_PATH>/<DB_PATH>*"  # 检查 wal/shm 锁
ssh <SSH_ALIAS> "sudo -u deploy bash -c 'source ~/.nvm/nvm.sh && pm2 restart <PM2_PROCESS_NAME>'"
```

### 磁盘满
```bash
ssh <SSH_ALIAS> "df -h"
ssh <SSH_ALIAS> "sudo journalctl --vacuum-size=100M; sudo find <PROJECT_PATH>/logs -name '*.log' -mtime +7 -delete"
```

### 数据被误删 · 用 backup 回滚
```bash
ssh <SSH_ALIAS> "sudo ls -lt <PROJECT_PATH>/backup/ | head -10"
ssh <SSH_ALIAS> "sudo -u deploy pm2 stop <PM2_PROCESS_NAME>"
ssh <SSH_ALIAS> "sudo cp <PROJECT_PATH>/backup/<BACKUP_FILE> <PROJECT_PATH>/<DB_PATH>"
ssh <SSH_ALIAS> "sudo -u deploy pm2 start <PM2_PROCESS_NAME>"
```

---

## 3. PM2 进程崩溃

```bash
ssh <SSH_ALIAS> "sudo -u deploy bash -c 'source ~/.nvm/nvm.sh && pm2 list'"
# 如果 errored/stopped:
ssh <SSH_ALIAS> "sudo -u deploy bash -c 'source ~/.nvm/nvm.sh && pm2 restart <PM2_PROCESS_NAME>'"
sleep 3 && curl -s https://<PROD_DOMAIN>/health
```

频繁重启看日志：
```bash
ssh <SSH_ALIAS> "sudo tail -50 <PROJECT_PATH>/logs/error.log"
```

---

## 4. nginx 502/504 / SSL 异常

### 502 → 通常是后端死了，先做 §3

### 502 持续 → nginx 配置问题
```bash
ssh <SSH_ALIAS> "sudo nginx -t && sudo systemctl reload nginx"
```

### SSL 证书过期
```bash
echo | openssl s_client -servername <PROD_DOMAIN> -connect <PROD_DOMAIN>:443 2>/dev/null | openssl x509 -noout -dates
ssh <SSH_ALIAS> "sudo certbot renew && sudo systemctl reload nginx"
```

---

## 5. 速率限制误锁正常用户

```bash
# 重启进程清内存里的 rate limit
ssh <SSH_ALIAS> "sudo -u deploy bash -c 'source ~/.nvm/nvm.sh && pm2 reload <PM2_PROCESS_NAME>'"
```

---

## 6. 流量突增 / DDoS

```bash
# 看连接数 by IP
ssh <SSH_ALIAS> "sudo netstat -tn | awk '{print \$5}' | cut -d: -f1 | sort | uniq -c | sort -rn | head -10"
# 临时封单 IP
ssh <SSH_ALIAS> "sudo iptables -I INPUT -s <BAD_IP> -j DROP"
# 解封
ssh <SSH_ALIAS> "sudo iptables -D INPUT -s <BAD_IP> -j DROP"
```

---

## 7. 远程响应链路（不在 Mac 旁边时）

如果配过 Tailscale + Termius + 1Password：
1. iPhone 确认 Tailscale ON
2. iPhone Termius 选 Mac → Face ID 解锁 1Password → ssh
3. 进 Mac 后跑 `claude` 让 AI 协助
4. 或直接 ssh 生产：`ssh <SSH_ALIAS> "<命令>"`

详见 `~/.claude/projects/.../memory/reference_remote_ops_stack.md`

---

## 8. 通知链路

| 渠道 | 触发 | 实时性 |
|---|---|---|
| **Sentry** | 5xx 错误 | 1-3 分钟 |
| **飞书机器人** | 5xx 错误 | 1-3 分钟 |
| **邮件**（Sentry） | 新错误类型 | 5-15 分钟 |

测试链路：
```bash
ssh <SSH_ALIAS> "ALERT_TEST_ENABLED=1 curl https://<PROD_DOMAIN>/api/internal/alert-test"
```

---

## 9. 事故复盘模板

事故后 24h 内填一份 `docs/incidents/YYYY-MM-DD-<标题>.md`：

```markdown
# Incident: <一句话标题>

## TL;DR
<发生了什么 + 影响 + 多久恢复>

## Timeline (UTC)
- HH:MM 用户首次报错
- HH:MM 我收到告警
- HH:MM 定位根因
- HH:MM 部署修复
- HH:MM 确认恢复

## Root Cause
<详细技术原因>

## Why didn't we catch this earlier?
<staging 没拦住的原因 / test 没覆盖的原因>

## Action Items
- [ ] 补测试 X
- [ ] 加监控 Y
- [ ] 改流程 Z

## Lessons Learned
<给未来的自己/合伙人>
```

---

## 一页速查（贴屏幕）

```
出事 → 30 秒分诊（§0）
不知道怎么办 → git revert + push（§1）
db 挂 → §2 / pm2 挂 → §3 / nginx 502 → §4
被锁 → §5 / DDoS → §6 / 不在 Mac 旁 → §7
```

🚨 **第一条铁律**：**先回滚，后排查**。生产不是调试环境。
