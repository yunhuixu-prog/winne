# AirBrush 周报 · 定时任务

每周 **两次** Cloud Agent 定时跑数，产出目录固定为：

`app/AB-OCI/专项/AI周报月报/AI周报/{MMDD～MMDD}/`

| 时间 | 任务 | 说明 |
|------|------|------|
| **周一 10:30** | 知识库更新 + 上周周报初版 | marks/CF → wiki INGEST → 完整流水线至 **v3** |
| **周二 10:30** | 刷新上周周报 | 强制北斗取数，**覆盖**周一版；补全 **上周日次留** |

分析周口径与 `run_weekly_report.py --recent` 一致：**最近一个已结束的周一～周日**。

---

## 在 Cursor 里创建（推荐）

**最快路径**：打开 [`一键创建Automations.md`](./一键创建Automations.md)，按步骤复制 Prompt 到 [cursor.com/automations/new](https://cursor.com/automations/new)。

1. **Trigger** 选 **Scheduled**
   - 周一：`30 10 * * 1`（时区 **Asia/Shanghai**）
   - 周二：`30 10 * * 2`
2. **Repository**：绑定远程 Git 仓库（⚠️ 本地 `项目` 目录当前非 git 仓库，需先 push 或在 UI 选已有远程）
3. **Instructions**：见 `prompts/*.md` 或 `.cursor/automations/*.yaml` 中 `prompts` 段
4. **Save & Activate**

草稿 YAML 位置：

| 路径 | 用途 |
|------|------|
| `.cursor/automations/*.yaml` | 标准 Automation 草稿（Agents Window `/automate` 可预填） |
| `cursor-automations/*.yaml` | 同内容副本，便于本目录浏览 |

**以 Automations 编辑器保存为准**。

---

## 文件说明

| 路径 | 用途 |
|------|------|
| `prompts/monday-kb-and-weekly.md` | 周一 Agent 逐步指令 |
| `prompts/tuesday-weekly-refresh.md` | 周二 Agent 逐步指令 |
| `cursor-automations/*.yaml` | Cursor Automation 预填草稿 |
| `.cursor/skills/知识库/计算脚本/run_kb_sync.sh` | 仅 raw 拉取（marks+CF）；INGEST 仍需 Agent |

---

## 环境依赖

- `OMNIBUS_ACCESS_TOKEN` — 知识库 Confluence / 北斗拉取
- Python 3 + 项目 skill 依赖（北斗 `requests` 等）
- 周二任务**不需要**重复拉 CF，除非业务要求

---

## 手动触发（调试）

```bash
# 知识库 raw 拉取
bash .cursor/skills/知识库/计算脚本/run_kb_sync.sh

# 周报 Phase A
cd .cursor/skills/周报生成 && python3 run_weekly_report.py --recent
```

Phase B～E 在 Cursor Agent 中按 `周报生成/SKILL.md` 继续。
