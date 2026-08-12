---
name: airbrush-weekly-report
description: "周报生成 — AirBrush AI 周报流水线（归因版 v1/v2/v3）。含北斗取数、s1～s5、memory 归因、v2/v3 converted；**默认完整流水线含 v3 终审**。知识库见 sibling skill 知识库。TRIGGER: /周报生成、输出近期周报、生成近期周报、生成0608～0614周报、生成周报、审核周报、生成v3、终审、生成converted、格式转换。"
---

# 周报生成

自包含 AirBrush 周报流水线。Skill 根目录 = 本文件所在目录（`SKILL_ROOT`）。

**知识库**（marks、Confluence、节日对照、产品变动）已独立为 sibling skill **[知识库](../知识库/SKILL.md)**（`KB_SKILL_ROOT`）。v2/v3 归因 QUERY 与拉取/同步均走该 skill。

## 目录结构

```
周报生成/                          # SKILL_ROOT
├── SKILL.md
├── run_weekly_report.py           # 流水线入口（至 v1）
├── memory/                        # 归因思路、指标库、双周会框架
├── raw_data/                      # 北斗 CSV（重跑覆盖）
├── 计算脚本/
│   ├── skill_paths.py
│   ├── 北斗取数/fetch_beidou.py
│   └── 数据处理/                  # s1～s5（**无 s6**）
└── output/
    └── {MMDD～MMDD}/              # 按周期归档，如 0608～0614/
```

## 触发与参数解析

| 用户说法 | 行为 |
|---------|------|
| **`输出近期周报`** / `生成近期周报` / **`生成周报`** | **完整流水线**（见下「默认完整流水线」）：Phase A → B → D → **C（v3 终审）** → E（v3 converted）；周期取最近已结束完整自然周；`--recent` 强制北斗取数覆盖 `raw_data` |
| `生成0608～0614周报` | 同上完整流水线；周期 = `0608～0614`（支持 `6.8～6.14`、`0608-0614`）；默认北斗取数，除非 `--skip-fetch` |
| `…输出在 /path/to/dir` | `-o /path/to/dir`，不写入默认可交付目录 |
| `审核周报` / `生成 v3` / `终审` | **仅** Phase C + E（须已有 `weekly_report_v2.md`） |
| `生成 converted` / `格式转换` | Phase D（v2）或 `--v3`（v3）；见 [v2convert.md](references/v2convert.md) |
| **`拉取最新北斗mark标识`** / **`拉取最新cf`** / **`更新知识库`** / **`拉取产品变动记录`** | 见 **[知识库](../知识库/SKILL.md)**（非本 skill 执行） |

### 默认完整流水线

调用本 skill **生成周报**时，Agent **默认执行全部阶段**，交付物以 **v3 终审版** 为准：

```
Phase A（脚本）→ Phase B（v2 归因）→ Phase D（v2 converted）
    → Phase C（v3 终审，不修改 v2）→ Phase E（v3 converted）
```

| Phase | 产物 |
|-------|------|
| A | v1、下钻/、贡献度/、下钻报告/ |
| B | `weekly_report_v2.md` |
| D | `weekly_report_v2_converted.md` |
| **C** | `审核报告.md`、`weekly_report_v3.md` |
| **E** | `weekly_report_v3_converted.md`（`convert_weekly_v2.py --v3`） |

### 近期完整周口径

与 `fetch_beidou.py` 一致：以**今天**为参照，取**上一个已结束的周一～周日**。

- 周期标签 = `{周一MMDD}～{周日MMDD}`（例：今天 2026-06-22 周一 → **0615～0621**，即 6/15 周一～6/21 周日）
- 当前周（6/22 起）尚未结束，**不**作为分析周
- `--recent` 会忽略 `--skip-fetch`，确保 raw_data 与看板同步

## 输出规则

**默认输出目录（可交付）**：`app/AB-OCI/专项/AI周报月报/AI周报/{周期}/`（例：`0713～0719/`）  
**可选 staging**：`SKILL_ROOT/output/{周期}/`（仅当显式 `-o` 指向该路径时）

**写入产物**（正常输出）：

| 路径 | 说明 |
|------|------|
| `weekly_report_v1.md` | s4 生成 |
| `weekly_report_v2.md` | Agent 按 `memory/归因思路.md` 生成 |
| `weekly_report_v2_converted.md` | Phase D：`md_convert` 格式转换（见 [references/v2convert.md](references/v2convert.md)） |
| `weekly_report_v3.md` | Phase C：Agent 按 `memory/终审专家.md` 终审修正（**不修改 v2**）；**默认可交付正文** |
| `weekly_report_v3_converted.md` | Phase E：v3 平台规范版（`convert_weekly_v2.py --v3`） |
| `审核报告.md` | Phase C：对 v2 的审计意见 |
| `下钻/` | s1 CSV |
| `贡献度/` | s2 CSV |
| `下钻报告/` | s3 Markdown |

**不输出**：`异常指标检测.md`（s5 仅作 s4 / v2 中间参考，流水线结束后删除）

环境变量 `ZHOUBAO_OUTPUT_DIR` 由 `run_weekly_report.py` 注入，各脚本通过 `skill_paths.output_dir()` 读取。

## 执行流程

### Phase A：数据流水线（脚本）

```bash
cd SKILL_ROOT

# 输出近期周报（日历最近完整周 + 强制北斗取数覆盖 raw_data）
python run_weekly_report.py --recent

# 近期周报默认写入 AI周报月报/AI周报/{周期}/；自定义目录用 -o
python run_weekly_report.py --recent -o /path/to/output

# 指定历史周期（会北斗取数；若已有 CSV 可加 --skip-fetch）
python run_weekly_report.py --period 0608～0614
```

顺序：`fetch_beidou` → `s1` → `s2` → `s3` → `s5` → `s4` → 删除 `异常指标检测.md`

`raw_data/*.csv` 每次 `fetch_beidou` **覆盖**原文件。

### Phase B：v2 归因周报（Agent，**不用 s6 脚本**）

**必读**：[memory/归因思路.md](memory/归因思路.md)

1. 读取 `{输出目录}/weekly_report_v1.md` 作为骨架参考
2. 读取 `{输出目录}/下钻报告/*.md`、`贡献度/s2_*贡献度.csv`
3. **知识库 QUERY**：调 `karpathy-wiki` skill，wiki 路径 = **`KB_SKILL_ROOT/wiki/`**（见 [知识库](../知识库/SKILL.md)）
   - raw 来源：`KB_SKILL_ROOT/raw_data/知识库/`、`KB_SKILL_ROOT/raw_data/北斗标注/`
   - 匹配优先级：**marks > 历史周报 > 节假日 > 产品需求**
4. 按归因思路生成 `weekly_report_v2.md` 写入**同一输出目录**：
   - 一、总结（600–800 字，不写下钻贡献度/逻辑链细节）
   - 二、下钻和归因（mermaid + 下钻总结 + 知识库命中 + 逻辑链）
   - 三、异常指标检测（从 s5 逻辑复述表格，**不单独落盘 md 文件**）

详细步骤见 [references/v2归因.md](references/v2归因.md)。

### Phase D：v2 格式转换（脚本）

**必读**：[references/v2convert.md](references/v2convert.md)（规范见 sibling **[md_convert](../md_convert/SKILL.md)**）

```bash
cd SKILL_ROOT
python 计算脚本/convert_weekly_v2.py -o output/{周期}/
```

- **输入**：`weekly_report_v2.md`（Phase B 产物）
- **输出**：`weekly_report_v2_converted.md`（**不覆盖** v2）
- 触发说法：`生成 converted`、`格式转换 v2`、`/md_convert`（在周报输出目录语境下）

### Phase C：v3 终审（Agent，**默认执行**，**不修改 v2**）

**必读**：[memory/终审专家.md](memory/终审专家.md)

1. 以 `{输出目录}/weekly_report_v2.md` 为**只读**审查对象
2. 对照 v1、下钻报告、贡献度 CSV、`KB_SKILL_ROOT/wiki/` 做数据与归因审计
3. 写入 `{输出目录}/审核报告.md`（漏洞 + 整改意见；全文见 v3 的指引）
4. 将所有修正写入 `{输出目录}/weekly_report_v3.md` — **禁止**修改或覆盖 v2

详细步骤见 [references/v3终审.md](references/v3终审.md)。

### Phase E：v3 格式转换（脚本，**默认执行**）

```bash
cd SKILL_ROOT
python 计算脚本/convert_weekly_v2.py -o output/{周期}/ --v3
```

- **输入**：`weekly_report_v3.md`（Phase C 产物）
- **输出**：`weekly_report_v3_converted.md`（**不覆盖** v3）
- 须在 Phase C 完成后执行；与 Phase D 对称

## 知识库

Wiki、raw 知识源、拉取脚本均在 **[知识库](../知识库/SKILL.md)**。`skill_paths.wiki_dir()` 已指向 `KB_SKILL_ROOT/wiki/`。

## 检查清单

```
- [ ] 默认可交付目录 `AI周报月报/AI周报/{周期}/`（或 `-o` / `ZHOUBAO_OUTPUT_DIR`）已创建
- [ ] Phase A 完成，weekly_report_v1.md 存在
- [ ] 异常指标检测.md 已从输出目录删除
- [ ] Phase B：weekly_report_v2.md 符合 memory/归因思路.md（含步骤 6 异常说明校验；续费波动触发时含 2.8；自然国家 DNU 满足 **贡献>20% 或 环比>50%** 且无知识库归因时含 2.9 **且须贴 Top10 表**；渠道大涨带动自然见 2.10）
- [ ] Phase D：weekly_report_v2_converted.md 已生成
- [ ] 知识库命中已 QUERY KB_SKILL_ROOT/wiki/，marks 优先
- [ ] Phase C：v2 未被修改；审核报告.md + weekly_report_v3.md 已生成（含 2.8 / 2.9 审计）
- [ ] Phase E：weekly_report_v3_converted.md 已生成（`python 计算脚本/convert_weekly_v2.py -o {OUT} --v3`）
- [ ] 产物已落在 `AI周报月报/AI周报/{周期}/`（非仅 skill/output）
```
