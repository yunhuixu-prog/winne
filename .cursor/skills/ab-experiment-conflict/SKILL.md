---
name: ab-experiment-conflict
description: >-
  AirBrush AB 实验「商业化冲突指标」一键分析（必须读本 skill 后执行）。包含：step1 留存 +
  幂律/LT/拟合曲线，以及冲突定量 step2 arpdau、step3 enter_ratio、YAU、step4 bookings。
  主触发句：「计算{实验名}的商业化冲突指标，实验日期为{起}～{止}，实验 code 为{a,b,c}，
  是否限制新用户{是/否}」。也响应「商业化冲突」「冲突定量」「留存率+arpdau」等同义说法。
  默认 run_all.py、默认不限新用户（step1～step4 均无 enter_new 过滤）；明确限制新用户时
  --new-users-only。是否限制决定 out 子目录（所有用户/新用户）。
metadata:
  version: "1.3.1"
---

# AB 实验商业化冲突指标（留存 + 冲突定量四表）

一次请求产出：**留存**（step1 → 幂律预估 / LT / 拟合曲线）+ **冲突定量**（arpdau、enter_ratio、yau、bookings）。  
产物落在 **`out/<实验名>/`** 或 **`out/<实验名>/新用户|所有用户/`**。

## 主触发话术（优先识别）

用户标准句式（Agent 识别后**必须**执行 `run_all.py`，不要只跑其中一段）：

```text
计算激励广告实验的商业化冲突指标，实验日期为 20260428～20260514，实验 code 为 28905,28906,28907，是否限制新用户：否
```

### 参数解析

| 话术片段 | 映射 |
|----------|------|
| `计算{名称}的商业化冲突指标` / `商业化冲突` / `冲突定量` | 实验名 `{名称}` → `--experiment` 前缀 |
| `实验日期为 A～B` / `A到B` / `A-B` | `--start-date A` `--end-date B`（yyyymmdd） |
| `实验 code 为 x,y,z` / `abcode` | `--abcodes x,y,z` |
| **是否限制新用户：否** / 不限制 / 全量 / 所有用户 | **不传** `--new-users-only`；建议 `--experiment "{名称}/所有用户"` |
| **是否限制新用户：是** / 限制 / 只要新用户 / 仅新设备 | **`--new-users-only`**；建议 `--experiment "{名称}/新用户"` 或 `{名称}` |
| 未说明是否限制 | **默认不限制**（全量进组），`experiment="{名称}/所有用户"` |

### 默认执行（Agent 必须实际运行）

```bash
SKILL_ROOT="项目/.cursor/skills/ab-experiment-conflict"

python3 "$SKILL_ROOT/scripts/run_all.py" \
  --experiment "激励广告实验/所有用户" \
  --start-date 20260428 \
  --end-date 20260514 \
  --abcodes 28905,28906,28907
# 若用户要求限制新用户，追加：--new-users-only，且 --experiment 改为 "激励广告实验/新用户"
```

环境默认：**神舟 `oci` + `Airbrush` + Presto**，失败再 **Hive on Spark**。

### 仅跑子集时（用户明确要求）

| 用户意图 | 脚本 |
|----------|------|
| 只要留存 / LT / 幂律 | `run_analysis.py` |
| 只要 arpdau 等四表 | `run_conflict_steps.py` |
| **商业化冲突指标（默认）** | **`run_all.py`** |

## 目录结构

根目录：`项目/.cursor/skills/ab-experiment-conflict/`

| 路径 | 说明 |
|------|------|
| `SKILL.md` | 本说明 |
| `sql/step1_retention.sql` | step1 留存模板 |
| `sql/step2_arpdau.sql` | step2 单用户价值（arpdau） |
| `sql/step3_enter_ratio.sql` | step3 进实验 DAU 占比 |
| `sql/yau.sql` | 过去 365 天活跃（按 os） |
| `sql/step4_bookings.sql` | step4 订阅 GMV（按日×周期） |
| `scripts/run_analysis.py` | step1 神舟 + 幂律/LT/曲线 |
| `scripts/run_conflict_steps.py` | step2～4 + YAU 神舟 |
| `scripts/run_all.py` | 上述两者串联 |
| `scripts/process_retention.py` | 仅 step1 后处理 |
| `out/<实验名>/` | 当次产出 |

主仓库口径源：`app/ab新sdk/实验/<实验名>/冲突定量选择.sql`。同步时请将 step1～step4 中写死的 `AND enter_new = 1` 改为 `WHERE ranks = 1${enter_new_sql}`，与 `skill/sql/` 一致。

## 日期占位符

| 占位符 | 用途 |
|--------|------|
| `${start_date}` | 实验开始 |
| `${end_date}` | 实验结束 |
| `${end_date_p90}` | end + 90 天（step1 活跃右界） |
| `${end_date_p7}` | end + 7 天（step2 观察窗） |
| `${end_date_m365}` | end − 365 天（YAU 左界） |
| `${abcode_in_list}` | `'28905','28906'` |
| `${enter_new_sql}` | **step1～step4 统一**：默认替换为**空**（不限新设备）；传 `--new-users-only` 时替换为 `AND enter_new = 1`（写在各段 `WHERE ranks = 1` 后） |

**新用户口径（留存 + 四表冲突定量一致）**

- 模板中**不写死** `AND enter_new = 1`，一律用 `${enter_new_sql}`。
- 用户**未**明确「限制新用户 / 只要新用户 / 仅新设备」→ **不要**传 `--new-users-only`。
- 用户**明确限制**→ 传 `--new-users-only`（`run_analysis.py` 与 `run_conflict_steps.py` / `run_all.py` 均生效）。

## 一键命令（子命令参考）

`SKILL_ROOT` = 本 skill 绝对路径。主路径见上文 **默认执行**。

### 仅 step1 留存 → 幂律 / LT / 曲线

```bash
python3 "$SKILL_ROOT/scripts/run_analysis.py" \
  --experiment "激励广告实验/所有用户" \
  --start-date 20260428 \
  --end-date 20260514 \
  --abcodes 28905,28906,28907
```

### 仅 step2～4 + YAU

```bash
python3 "$SKILL_ROOT/scripts/run_conflict_steps.py" \
  --experiment "激励广告实验/所有用户" \
  --start-date 20260428 \
  --end-date 20260514 \
  --abcodes 28905,28906,28907
```

### 限制新用户

上述任一脚本追加 **`--new-users-only`**（step1 留存 + step2 arpdau + step3 enter_ratio + step4 bookings 均加过滤）。

可选：`--skip-shenzhou`（`run_analysis.py`，需已有 `step1留存率_presto.csv`）、`--skip-retention` / `--skip-conflict`（`run_all.py`）。

神舟依赖：`~/.agents/skills/shenzhou-temp-query/scripts/temp_query.py`、`OMNIBUS_ACCESS_TOKEN`。

## 产出文件

### step1 后处理（3 个最终 CSV/图）

| 文件 | 说明 |
|------|------|
| **`幂律预估-长表.csv`** | 1～365 期，调整前/后 |
| **`LT汇总.csv`** | LT7 / LT14 / LT365 |
| **`拟合曲线.png`** | 幂律拟合 |

中间件：`step1_retention.sql`、`step1留存率_presto.csv`

### 冲突定量神舟（4 个 CSV）

| 文件 | SQL 段 | 主要字段 |
|------|--------|----------|
| **`arpdau.csv`** | step2 | abcode, active_dau, bookings, arpdau |
| **`enter_ratio.csv`** | step3 | abcode, abtest_ratio |
| **`yau.csv`** | YAU | os_p, yau |
| **`bookings.csv`** | step4 | abcode, dt, types, gmv |

审计用 SQL：`step2.sql` … `step4.sql`（与模板同名，写入 out 目录）

## 留存后处理口径

1. 按 `abcode × lcx` 均值 → 调整前  
2. 星期系数：周一=1，星期 X = 该日留存均值/周一均值；调整后 = 原留存/系数  
3. 幂律 \(y \approx a k^b\)，lcx 1～14 拟合，15～365 预估  
4. LTN = \(\sum_{lcx=1}^{N}\) retention_rate  

## 硬性规则

- 出现 **「商业化冲突指标」** 或等价表述时：**默认 `run_all.py`**（留存 + 四表），除非用户只要其中一块。  
- 「是否限制新用户」为 **否** / 未提及 / 「所有用户」→ **不要**传 `--new-users-only`（留存与四表均为全量进组）。为 **是** / 「限制新用户」→ 必须传 `--new-users-only`。  
- 实验名、日期、abcode **必须由用户给出**；不得猜测 abcode。  
- 神舟 Presto 失败再 Hive；`run --wait --download` 期间勿重复 progress/download。  
- 完成后汇报 **`out/<实验名>/`** 路径，并摘要 **LT汇总** + **arpdau / enter_ratio**（及 yau、bookings 行数）。  
- 不要改主仓库 SQL，除非用户要求同步；优先改 `skill/sql/` 模板。

## 参考提问

- **主触发**：「计算激励广告实验的商业化冲突指标，日期 20260428～20260514，code 28905,28906,28907，是否限制新用户：否」→ `run_all.py` + `experiment=激励广告实验/所有用户`  
- 「是否限制新用户：是」→ `run_all.py` + `--new-users-only` + `experiment=激励广告实验/新用户`  
- 「只要留存 LT」→ `run_analysis.py`（仍解析日期/code/是否限制用户）  
- 「只要 arpdau 四表」→ `run_conflict_steps.py`  
- 「已有 step1 csv，补跑四表」→ `run_all.py --skip-retention --skip-shenzhou`  
