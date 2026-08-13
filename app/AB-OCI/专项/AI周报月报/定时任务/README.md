# AirBrush 周报 · 定时任务

每周 **两次** Cloud Agent 定时跑数，产出目录固定为：

`app/AB-OCI/专项/AI周报月报/AI周报/{MMDD～MMDD}/`

| 时间 | 任务 | 说明 |
|------|------|------|
| **周一 10:30** | 知识库更新 + 上周周报初版 | marks/CF → wiki INGEST → 完整流水线至 **v3** |
| **周二 10:30** | 刷新上周周报 | 强制北斗取数，**覆盖**周一版；补全 **上周日次留** |

分析周口径与 `run_weekly_report.py --recent` 一致：**最近一个已结束的周一～周日**。

---

## 推荐方案：GitHub Actions + Cursor Cloud Agent

**不依赖 Automations UI。** 详见 [`GitHub-Actions方案.md`](./GitHub-Actions方案.md)。

| Workflow | UTC cron（= 上海 10:30） |
|----------|--------------------------|
| `.github/workflows/weekly-monday.yml` | `30 2 * * 1` |
| `.github/workflows/weekly-tuesday.yml` | `30 2 * * 2` |

需配置 GitHub Secrets：`CURSOR_API_KEY`、`OMNIBUS_ACCESS_TOKEN`。

---

## 备选：Cursor Automations UI

打开 [`一键创建Automations.md`](./一键创建Automations.md)，或在 Agents Window 用 `/automate`。

| 路径 | 用途 |
|------|------|
| `.cursor/automations/*.yaml` | Automation 草稿 |
| `cursor-automations/*.yaml` | 同内容副本 |

---

## 文件说明

| 路径 | 用途 |
|------|------|
| `GitHub-Actions方案.md` | 方案①配置说明 |
| `scripts/trigger_cloud_agent.py` | 调用 Cloud Agents API |
| `prompts/monday-kb-and-weekly.md` | 周一 Agent 指令 |
| `prompts/tuesday-weekly-refresh.md` | 周二 Agent 指令 |
| `.cursor/skills/知识库/计算脚本/run_kb_sync.sh` | 仅 raw 拉取（marks+CF） |

---

## 环境依赖

- `CURSOR_API_KEY` — GitHub Actions 触发 Cloud Agent
- `OMNIBUS_ACCESS_TOKEN` — 知识库 Confluence / 北斗拉取
- Python 3 + 项目 skill 依赖

---

## 手动触发（调试）

```bash
# 触发云端周一任务（需 CURSOR_API_KEY）
python3 app/AB-OCI/专项/AI周报月报/定时任务/scripts/trigger_cloud_agent.py --task monday

# 本地知识库 raw 拉取
bash .cursor/skills/知识库/计算脚本/run_kb_sync.sh

# 本地周报 Phase A
cd .cursor/skills/周报生成 && python3 run_weekly_report.py --recent
```
