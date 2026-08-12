# 一键创建 Cursor Automations（约 3 分钟）

> 草稿 YAML 已放在 `.cursor/automations/`；本页为 **复制粘贴即用** 的 UI 操作说明。

---

## 前置条件（必看）

| 项 | 状态 | 说明 |
|----|------|------|
| Cursor 账号 + Cloud Agent | 需已开通 | [Dashboard → Cloud Agents](https://cursor.com/dashboard?tab=cloud-agents) |
| **Git 仓库** | ✅ 已 `git init` + 首次提交 | 仍需 **push 到远程** 并在 Automation 里绑定；见 [`推送到GitHub.md`](./推送到GitHub.md) |
| `OMNIBUS_ACCESS_TOKEN` | 周一任务需要 | 在 Cloud Agent Environment 或团队 Secrets 中配置 |

打开 Automations 页面：**https://cursor.com/automations/new**

（已在本地尝试 `open https://cursor.com/automations`，应已在浏览器打开。）

---

## 自动化 1 · 周一 10:30

1. **Name**：`AirBrush 周一-知识库+周报初版`
2. **Trigger** → **Scheduled** → 自定义 Cron：`30 10 * * 1`（时区选 **Asia/Shanghai**）
3. **Repository**：选择包含本项目的远程仓库 + 默认分支
4. **Instructions**：粘贴下方「周一 Prompt」全文
5. **Memories**：开启（默认）
6. **Save & Activate**

### 周一 Prompt（复制起点）

```
你是 AirBrush 数据周报 Agent。严格按项目内 Skill 执行，不要跳过步骤。

1. 读取并执行 `.cursor/skills/知识库/SKILL.md` 的「更新知识库」全流程（fetch marks → fetch CF → INGEST wiki → write-baseline）。
2. 读取并执行 `.cursor/skills/周报生成/SKILL.md` 的「默认完整流水线」：
   - Phase A: `cd .cursor/skills/周报生成 && python3 run_weekly_report.py --recent`
   - 默认输出: `app/AB-OCI/专项/AI周报月报/AI周报/{周期}/`
   - Phase B/D/C/E 生成 v2、v2 converted、v3、审核报告、v3 converted
3. 详细步骤见 `app/AB-OCI/专项/AI周报月报/定时任务/prompts/monday-kb-and-weekly.md`
4. 在审核报告中注明：活跃次留/新增次留含上周日数据可能不完整，周二 10:30 会刷新。

环境：需 OMNIBUS_ACCESS_TOKEN（知识库拉取）。完成后汇报周期标签、输出目录、产物清单。
```

---

## 自动化 2 · 周二 10:30

1. **Name**：`AirBrush 周二-周报刷新(含周日次留)`
2. **Trigger** → **Scheduled** → Cron：`30 10 * * 2`（**Asia/Shanghai**）
3. **Repository**：与周一相同
4. **Instructions**：粘贴下方「周二 Prompt」全文
5. **Save & Activate**

### 周二 Prompt（复制起点）

```
你是 AirBrush 数据周报 Agent。本任务为「周二刷新」：补全上周日次留后覆盖周一版周报。

1. **不要**跑知识库全量更新（除非用户另行要求）。
2. 读取 `.cursor/skills/周报生成/SKILL.md`，执行默认完整流水线：
   - Phase A: `cd .cursor/skills/周报生成 && python3 run_weekly_report.py --recent`（强制取数）
   - 输出目录: `app/AB-OCI/专项/AI周报月报/AI周报/{周期}/`（覆盖周一产物）
   - Phase B/D/C/E 全量重跑
3. 详细步骤见 `app/AB-OCI/专项/AI周报月报/定时任务/prompts/tuesday-weekly-refresh.md`
4. 重点核对活跃次留、新增次留（含分析周周日）；终审删除「待周二刷新」占位。

完成后汇报：周期、相对周一版的 diff 摘要、最终 v3 路径。
```

---

## 更省事的方式（Agents Window）

若你在 **Agents Window**（非普通 Chat）里对话，可直接说：

> 用 /automate 创建两个定时 Automation：周一 10:30 知识库+周报，周二 10:30 刷新周报。草稿在 `.cursor/automations/`。

该窗口支持 `open_automation` 预填表单；**当前 Chat 会话不支持**，需切换窗口。

---

## 验证

创建后可在 Automations 页面点 **Run now** 手动试跑；或本地：

```bash
bash .cursor/skills/知识库/计算脚本/run_kb_sync.sh
cd .cursor/skills/周报生成 && python3 run_weekly_report.py --recent
```

Phase B～E 仍建议在 Agent 中按 Skill 跑通一次后再依赖定时任务。
