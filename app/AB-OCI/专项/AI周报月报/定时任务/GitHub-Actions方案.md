# GitHub Actions + Cursor Cloud Agent（方案①）

不依赖 Cursor Automations UI。用 **GitHub Actions cron** 到点调用 [Cloud Agents API](https://cursor.com/docs/cloud-agent/api/endpoints)，在云端跑完整周报流水线。

| Workflow | 本地时间 (Asia/Shanghai) | UTC cron | 任务 |
|----------|--------------------------|----------|------|
| `weekly-monday.yml` | 周一 10:30 | `30 2 * * 1` | 知识库更新 + 上周周报初版 |
| `weekly-tuesday.yml` | 周二 10:30 | `30 2 * * 2` | 刷新周报（含周日次留） |

产物默认以 **Pull Request** 形式回写到 `yunhuixu-prog/winne`（不直接推 main）。

---

## 一次性配置（约 5 分钟）

### 1. Cursor API Key

1. 打开 [Cursor Dashboard → API Keys](https://cursor.com/dashboard/api)
2. 生成 key，复制备用

### 2. 确认 Cloud Agent 能访问仓库

在 Cursor 里绑定 GitHub，并确保 Cloud Agent 对 `yunhuixu-prog/winne` 有读写权限。

### 3. 写入 GitHub Secrets

打开：https://github.com/yunhuixu-prog/winne/settings/secrets/actions

| Secret | 用途 |
|--------|------|
| `CURSOR_API_KEY` | 调用 Cloud Agents API（**必填**） |
| `OMNIBUS_ACCESS_TOKEN` | 北斗 / Confluence 拉取（**强烈建议**） |

### 4. 推送本目录代码到 `main`

确保 `.github/workflows/*.yml` 已在默认分支上，否则 cron 不会生效。

### 5. 手动试跑

仓库 → **Actions** → 选 `AirBrush Monday KB + Weekly Report` → **Run workflow**。

成功时日志会打印 `agent_url`，形如 `https://cursor.com/agents/bc-...`。

本地也可试：

```bash
export CURSOR_API_KEY=...
export OMNIBUS_ACCESS_TOKEN=...
python3 app/AB-OCI/专项/AI周报月报/定时任务/scripts/trigger_cloud_agent.py --task monday
```

---

## 文件

| 路径 | 说明 |
|------|------|
| `.github/workflows/weekly-monday.yml` | 周一定时 |
| `.github/workflows/weekly-tuesday.yml` | 周二定时 |
| `scripts/trigger_cloud_agent.py` | 调 `POST /v1/agents` |
| `prompts/*.md` | Agent 详细指令 |

---

## 说明

- GitHub Actions **只负责触发**；真正跑数与归因在 Cursor Cloud Agent VM 上。
- `envVars.OMNIBUS_ACCESS_TOKEN` 为 beta 能力；若云端取数失败，请到 [Cloud Agents 环境](https://cursor.com/dashboard?tab=cloud-agents) 另行配置同名 secret。
- 若希望直接推 `main`（不开 PR），本地加 `--push-main`；workflow 默认开 PR 更安全。
