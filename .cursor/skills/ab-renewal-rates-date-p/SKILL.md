---
name: ab-renewal-rates-date-p
description: >-
  按「业务当前日 = 系统日期的前一天」作为分区 date_p，在神舟 OCI 拉取 AirBrush
  上传预测平台历次续费率宽表；产物落在 out/<调用日期YYYYMMDD>/。含历史续费率（全 cohort）
  与最新续费率（反向累积 num_k+天数），各含真实/真实和预估/纯预估 CSV；可导出
  最新续费率_展示.xlsx。主触发：根据当前日期计算历次续费率（默认全流水线）；
  历史下界可指定 21 年（20210101）。也响应幂律、展示表、date_p 对齐、神舟拉宽表。
---

# AirBrush 历次续费率（按「当前日 = 系统日前一天」）

## 参考提问（触发后按本文件执行）

用户可直接说：

- **「根据当前日期计算历次续费率」**（主触发句；默认：**神舟 → 历史 → 最新 → 幂律（历史+最新）**）
- 「按昨天 date_p 拉历次续费率并算长表」
- 「用系统日期的前一天做分区，重跑上传预测平台续费率」
- 「历史从 21 年开始」→ SQL `pay_date` 下界 **`20210101`**（上界 = `date_p`）
- 「历史从 24 年开始」→ SQL 下界 **`20240101`**
- 「只算历史 / 只算最新 / 只跑幂律 / 只出展示表」→ 跳过对应步骤
- 「幂律预估到 100 期」→ `forecast_renewal_rates_power.py`（`--pure-power-law` → `_纯预估.csv`）
- 「导出最新续费率展示表 / 按列展示」→ `export_renewal_rates_matrix.py` → `最新续费率_展示.xlsx`
- 「月SKU / 整体分端续费率」→ 在 `最新续费率_真实.csv` 上按国家加权汇总（见下文可选步骤）

Agent 识别后：先读本 `SKILL.md`，再用下方路径拼**绝对路径**执行。

## 本 skill 目录结构

以工作区根为 `项目/` 时，skill 根目录为：`项目/.cursor/skills/ab-renewal-rates-date-p/`

| 路径 | 说明 |
|------|------|
| `SKILL.md` | 本说明 |
| `sql/上传预测平台-历次续费率.sql` | 神舟取数 SQL（跑前改 `date_p` 与 `pay_date` 上下界） |
| `scripts/compute_renewal_rates.py` | 宽表 → **历史续费率**（全 cohort，1～52 期） |
| `scripts/compute_renewal_rates_reverse_cum.py` | 宽表 → **最新续费率**（反向累积，1～52 期） |
| `scripts/forecast_renewal_rates_power.py` | `_真实.csv` → 幂律 1～100 期（`_真实和预估` / `_纯预估`） |
| `scripts/export_renewal_rates_matrix.py` | `_真实和预估.csv` → **`最新续费率_展示.xlsx`** |
| `out/README.md` | `out/` 与产物说明 |
| `out/<调用日期YYYYMMDD>/` | **当次产出目录** |

**与 OKR 主 SQL 同步**：口径变更时与 `app/ab新sdk/OKR/上传预测平台-历次续费率.sql` 对齐。

## 两个「日期」不要混

| 名称 | 含义 | 典型取值 |
|------|------|----------|
| **`date_p`（分区 / 业务当前日）** | 数仓快照分区日 | **`date.today() - 1 天`** → SQL `WHERE date_p=`、`--date-p` |
| **调用日（目录名）** | 执行拉数/跑 Python 的当天 | **`date.today()`** → `out/YYYYMMDD/` |

用户要求产物落在指定目录（如 `out/20260519/`）时：用 **`--invocation-date`** 与 **`--input`/`--out`** 指向该目录，勿与 `date_p` 混淆。

## 产物命名（当次 `out/<调用日>/`）

| 口径 | 脚本 | 真实 | 真实+预估 | 纯预估 |
|------|------|------|-----------|--------|
| **历史续费率** | `compute_renewal_rates.py` | `历史续费率_真实.csv` | `历史续费率_真实和预估.csv` | `历史续费率_纯预估.csv` |
| **最新续费率** | `compute_renewal_rates_reverse_cum.py` | `最新续费率_真实.csv` | `最新续费率_真实和预估.csv` | `最新续费率_纯预估.csv` |

| 其他 | 说明 |
|------|------|
| `上传预测平台-历次续费率.csv` | 神舟宽表明细 |
| `最新续费率_展示.xlsx` | 列式展示表（见下文） |
| `月SKU续费率_*` / `月年SKU续费率_*` | 可选衍生汇总（整体/分端加权） |

- **`_真实`**：观测值（历史=全 cohort；最新=反向累积 + 日期范围）
- **`_真实和预估`**：1～100 期；`renewal_rate_source` 为 **`真实`** 或 **`预估`**
- **`_纯预估`**：全部为幂律 `y=a·k^b`，`renewal_rate_source=幂律`

`forecast` 根据输入文件名（含「历史」「最新」）或 `--kind historical|latest` 写对应前缀。

---

## 历史续费率（`compute_renewal_rates.py`）

- **含义**：`pay_date <= date_p` 的全量 cohort，按国家 × 端 × 周期类型汇总。
- **续费率**：第 k 期 = `sum(num_k) / sum(num_0)`，`period_type ∈ {月, 周, 年}`。
- **可观测**：月/年按账单纪念日，周按满周；未满 k 期不计入第 k 期。
- **SQL 下界**：默认 `20230101`；21 年起 **`20210101`**。

**列**：`country_name`, `os_type`, `period_type`, `renewal_k`, `renewal_rate`, `period_k_renewed_orders`, `first_period_paid_orders`, `n_source_pay_date_rows`

---

## 最新续费率（`compute_renewal_rates_reverse_cum.py`）

从**最新可观测 cohort** 起，按日历**逐日向更早**累积（分国家 × 端 × 周期类型 × 第 k 期）。

1. **锚点**：`date_p` 向前推 **k** 个订阅周期（月=整月、周=7 天、年=整年）。
2. **纳入**：`pay_date ≤ 锚点` 且已满 k 个续订机会；累加 `num_k`、`num_0`。
3. **停止**（须**同时**严格满足 **`>`**）：
   - 累计 **num_k > 1000**（`--min-orders`，看第 k 期，**不是 num_0**）
   - 纳入 **pay_date 天数 > 365**（`--min-days`，`n_pay_dates_included > 365`）
4. **未同时满足**：锚点 → 该分组**最早可观测 pay_date** 全量 cohort。
5. **续费率**：`sum(num_k) / sum(num_0)`。

**列**：`country_name`, `os_type`, `period_type`, `renewal_k`, `renewal_rate`, `period_k_renewed_orders`, `first_period_paid_orders`, `n_pay_dates_included`, `pay_date_range_end`, `pay_date_range_start`

---

## 幂律预估（`forecast_renewal_rates_power.py`）

- **模型**：`renewal_rate ≈ a · k^b`（对 `log k`、`log rate` 最小二乘）。
- **`num_k > 1000` 且 `renewal_rate > 0`**：标 **`真实`**，参与拟合。
- **单期 `num_k ≤ 1000`（累积不到 1000）**：

| 周期 | 保留真实（参与拟合） | 幂律预估 |
|------|---------------------|----------|
| 月 | 1～14 期 | 15 期起 |
| 年 | 1～3 期 | 4 期起 |
| 周 | 1～5 期 | 6 期起 |

- **`--pure-power-law`**：全部期数为幂律值，标 **`幂律`**。

---

## 展示表（`export_renewal_rates_matrix.py`）

基于 **`最新续费率_真实和预估.csv`**，横向并排 16 个单元（每单元 3 列：月/年/周）：

| 列 | 内容 |
|----|------|
| **A** | 续费次数 1～100（全表共用） |
| **B～D** | 美国Android（月/年/周） |
| **E～G** | 美国iOS |
| … | 英国Android → … → 其他iOS |

顺序：美国Android、美国iOS、英国Android、英国iOS、巴西、墨西哥、西班牙、加拿大、澳大利亚、其他（各 Android / iOS）。

- 第 1 行：单元标题；第 2 行：A=续费次数，各块=月/年/周
- 第 3～102 行：期数 + 续费率（**预估**=浅绿底 `#C6EFCE`，真实=白底）
- 冻结窗格 **`B3`**

---

## 一键参考命令（`SKILL` = 本 skill 根目录绝对路径）

### 0. 日期变量

```bash
eval "$(python3 -c "from datetime import date, timedelta; d=date.today()-timedelta(days=1); print('export DATE_P_YYYYMMDD='+d.strftime('%Y%m%d')); print('export DATE_P_ISO='+d.isoformat())")"
eval "$(python3 -c "from datetime import date; t=date.today(); print('export INVOKE_YYYYMMDD='+t.strftime('%Y%m%d'))")"
mkdir -p "$SKILL/out/$INVOKE_YYYYMMDD"
```

### 1. 改 SQL

在 **`SKILL/sql/上传预测平台-历次续费率.sql`**（及 OKR 主 SQL）中：

- 两处 **`WHERE date_p=`** → `$DATE_P_YYYYMMDD`
- **`pay_date between <下界> and <上界>`** → 上界 = `$DATE_P_YYYYMMDD`；下界默认 `20230101`，21 年起 **`20210101`**

### 2. 神舟（OCI / Airbrush / Presto 优先）

```bash
python3 "$HOME/.agents/skills/shenzhou-temp-query/scripts/temp_query.py" run \
  --sql-file "$SKILL/sql/上传预测平台-历次续费率.sql" \
  --project Airbrush \
  --env oci \
  --engine presto \
  --wait --download \
  -o "$SKILL/out/$INVOKE_YYYYMMDD/上传预测平台-历次续费率.csv"
```

Presto 失败再试 `--engine hive`。鉴权见 `~/.agents/skills/shenzhou-temp-query/SKILL.md`。

### 3. 历史续费率

```bash
python3 "$SKILL/scripts/compute_renewal_rates.py" \
  --date-p "$DATE_P_ISO" \
  --invocation-date "$INVOKE_YYYYMMDD"
```

### 4. 最新续费率

```bash
python3 "$SKILL/scripts/compute_renewal_rates_reverse_cum.py" \
  --date-p "$DATE_P_ISO" \
  --invocation-date "$INVOKE_YYYYMMDD"
```

默认 `--min-orders 1000`、`--min-days 365`。

### 5. 幂律预估（历史 + 最新各两套）

```bash
OUT="$SKILL/out/$INVOKE_YYYYMMDD"

python3 "$SKILL/scripts/forecast_renewal_rates_power.py" --input "$OUT/历史续费率_真实.csv"
python3 "$SKILL/scripts/forecast_renewal_rates_power.py" --pure-power-law --input "$OUT/历史续费率_真实.csv"

python3 "$SKILL/scripts/forecast_renewal_rates_power.py" --kind latest --input "$OUT/最新续费率_真实.csv"
python3 "$SKILL/scripts/forecast_renewal_rates_power.py" --kind latest --pure-power-law --input "$OUT/最新续费率_真实.csv"
```

### 6. 展示表 Excel

```bash
python3 "$SKILL/scripts/export_renewal_rates_matrix.py" \
  --input "$OUT/最新续费率_真实和预估.csv" \
  --out "$OUT/最新续费率_展示.xlsx"
```

依赖 **`openpyxl`**（`pip3 install openpyxl`）。

### 7. 可选：复制到 `reviews/2026/续费率/`

```bash
cp "$SKILL/out/$INVOKE_YYYYMMDD"/*.{csv,xlsx} "/Users/xuyunhui/Documents/项目/reviews/2026/续费率/" 2>/dev/null || \
cp "$SKILL/out/$INVOKE_YYYYMMDD"/*.csv "/Users/xuyunhui/Documents/项目/reviews/2026/续费率/"
```

---

## 反模式

- 把 **`date_p`（昨天）** 当成 **`out/` 子目录名**。
- 用「今天」当 `date_p`（除非用户明确要求）。
- SQL `pay_date` 上界大于 `date_p`，仅靠 Python 过滤。
- 神舟成功后对同一 `workflowId` 重复下载。
- **最新续费率**：用 **num_0** 或 **天数 ≤ 365** 作停止条件（应为 **num_k > 1000 且天数 > 365**）。
- **最新续费率**：仅满足订单或天数之一就停止（须**同时**满足）。
- **幂律**：`num_k ≤ 1000` 时，月 15+ / 年 4+ / 周 6+ 仍标真实（应标预估）。
- 把 **`最新续费率_真实`** 里单期 orders<1000 误解为幂律必须标真实（仅前 N 期真实，见上表）。

## 依赖

- Python 3；神舟脚本需 `requests`（见神舟 skill）。
- 展示表需 **`openpyxl`**。
