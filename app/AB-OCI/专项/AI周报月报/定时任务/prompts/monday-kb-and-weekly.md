# 周一定时任务 · 知识库更新 + 上周周报（初版）

**调度**：每周一 10:30（Asia/Shanghai）  
**说明**：周一北斗通常**尚未包含上周日完整次留**，本任务产出「初版」周报；周二任务会全量刷新。

---

## 必读 Skill

1. `.cursor/skills/知识库/SKILL.md` — **更新知识库**
2. `.cursor/skills/周报生成/SKILL.md` — **默认完整流水线**（Phase A → B → D → C → E）

---

## Step 1 · 更新知识库

`cwd = .cursor/skills/知识库/`

1. `python3 计算脚本/北斗mark提取/北斗标识提取skill/scripts/fetch_marks.py`
2. `python3 计算脚本/提取cf/提取cf文档.py`
3. 两步均成功后：`python3 计算脚本/check_wiki_updates.py` → 按 karpathy-wiki **INGEST** 写入 `wiki/` → `python3 计算脚本/check_wiki_updates.py --write-baseline`
4. **禁止**：拉取失败仍 `--write-baseline`；**禁止**修改 `raw_data/`

---

## Step 2 · Phase A（脚本）

`cwd = .cursor/skills/周报生成/`

```bash
python3 run_weekly_report.py --recent
```

- 周期 = **最近一个已结束的完整自然周**（周一～周日）
- 输出目录（默认）：`app/AB-OCI/专项/AI周报月报/AI周报/{MMDD～MMDD}/`
- `--recent` 强制北斗取数覆盖 `raw_data/*.csv`

---

## Step 3 · Phase B～E（Agent）

| Phase | 产物 |
|-------|------|
| B | `weekly_report_v2.md`（读 `memory/归因思路.md` + `知识库/wiki/` QUERY） |
| D | `python3 计算脚本/convert_weekly_v2.py -o {输出目录}` |
| C | `weekly_report_v3.md` + `审核报告.md`（读 `memory/终审专家.md`，**不修改 v2**） |
| E | `python3 计算脚本/convert_weekly_v2.py --v3 -o {输出目录}` |

---

## Step 4 · 交付检查

- [ ] `weekly_report_v3.md` / `weekly_report_v3_converted.md` 已写入 `AI周报/{周期}/`
- [ ] 在 `审核报告.md` 注明：**活跃次留/新增次留含上周日口径，待周二 10:30 刷新**
