---
name: ai-monthly-report
description: AirBrush AI 月报生成流水线。Use when the user says AI月报、月报生成、生成近期月报、生成YYYYMM月报、拉取月报北斗数据、月报下钻、月报贡献度、月报异常检测，或需要基于 MAU、Bookings、月有效会员数生成月报 v1。知识库见 sibling skill 知识库。
---

# AI 月报生成

自包含 AirBrush AI 月报流水线。Skill 根目录 = 本文件所在目录（`SKILL_ROOT`）。

**知识库**（marks、Confluence、节日对照、产品变动）已独立为 sibling skill **[知识库](../知识库/SKILL.md)**（`KB_SKILL_ROOT`）。归因 QUERY 与拉取/同步均走该 skill；`skill_paths.wiki_dir()` 已指向 `KB_SKILL_ROOT/wiki/`。

## 目录结构

```text
AI月报/
├── SKILL.md
├── run_monthly_report.py
├── memory/
│   ├── MAU指标库.csv
│   ├── Bookings指标库.csv
│   ├── 月有效会员数指标库.csv
│   ├── 月报框架.md
│   └── 归因思路.md
├── raw_data/
│   ├── mau.csv
│   ├── bookings.csv
│   └── valid_vip.csv
├── output/
│   └── {YYYYMM}/
└── 计算脚本/
    ├── skill_paths.py
    ├── convert_monthly_v2.py
    ├── 北斗取数/fetch_beidou.py
    └── 数据处理/
        ├── s1下钻csv生成.py
        ├── s2贡献度csv生成.py
        ├── s3导出下钻md脚本.py
        ├── s5异常检测.py
        └── s4生成v1月报md.py
```

## 触发与参数

| 用户说法 | 行为 |
| --- | --- |
| `生成近期月报` / `输出近期月报` | 取最近一个已结束的完整自然月，运行 `python run_monthly_report.py --recent`，强制北斗取数覆盖 `raw_data/*.csv` |
| `生成202605月报` / `生成 2026-05 月报` | 周期 = `202605`，默认北斗取数；已有 CSV 可加 `--skip-fetch` |
| `月报输出在 /path/to/dir` | `-o /path/to/dir`，不写入默认 `output/{YYYYMM}/` |
| **`拉取最新北斗mark标识`** / **`拉取最新cf`** / **`更新知识库`** / **`拉取产品变动记录`** | 见 **[知识库](../知识库/SKILL.md)** |

## 北斗取数

默认输出到 `raw_data/`，每次取数覆盖同名 CSV。

| 文件 | 来源与口径 |
| --- | --- |
| `mau.csv` | OCI `oci` 环境，Dashboard `10015823`，Chart `89215` 和 `89254`；筛选：平台=整体/iOS/Android，国家/地区=所有筛选值（包括整体），渠道/自然=整体/Organic/non-Organic；新增列 `新老`，Chart 89215 为 `整体`，Chart 89254 为 `New`；日期近 **14** 个完整月，`MONTH` + `SUM` |
| `bookings.csv` | **订阅毛利**：OCI Dashboard `10015810`；**2025 年及以前** Chart `89046`（`MONTH` + `SUM`，列 `每日毛利（剔除退款，$美元）`）；**2026 年** Chart `89060`（日粒度年累计美元，月末快照差分：1 月取月末快照，其余月=当月末−上月末）。筛选项：产品=AirBrush、平台=整体、内地/海外=整体、大洲=整体、国家地区=所有筛选值（含整体）、订阅类型=整体、支付渠道=整体。**新增/续订毛利**：Dashboard `10015839` Chart `89280`/`89281`，近 **14** 个月 `MONTH` + `SUM` |
| `valid_vip.csv` | **月有效会员数**：OCI `oci` 环境 Dashboard `10015810` Chart `89058`；筛选：产品=AirBrush、平台=整体、内地/海外=整体、大洲=整体、国家地区=所有筛选值（含整体）、订阅类型=整体、支付渠道=整体。**流动指标**（本月新增/流失/留存有效会员数）：OCI `oci` 环境 Dashboard `10016073` Chart `91006`（本月新增有效会员数）/`91009`（本月流失会员数）/`91010`（本月留存会员数）；筛选：产品线=AirBrush、国家/地区=所有筛选值（含整体）、地区=整体、SKU类型=整体；图表响应无国家字段且多国同批会聚合相加，故 **逐国**（`country_batch_size=1`）拉取；近 **14** 个月 `MONTH`+`SUM`；输出列：日期、国家、订阅类型、月有效会员数、本月新增有效会员数、本月流失会员数、本月留存会员数 |

## 执行流程

```bash
cd SKILL_ROOT

# 近期完整自然月 + 强制北斗取数
python run_monthly_report.py --recent

# 指定月份
python run_monthly_report.py --period 202605

# 已有 raw_data，跳过取数
python run_monthly_report.py --period 202605 --skip-fetch
```

顺序：`fetch_beidou` → `s1` → `s2` → `s3` → `s5` → `s4`。

### Phase B：v2 归因月报（Agent，**不用 s6 脚本**）

**必读**：[memory/归因思路.md](memory/归因思路.md)、[references/v2归因.md](references/v2归因.md)

1. 读取 `{输出目录}/monthly_report_v1.md`、下钻报告、贡献度 CSV
2. **知识库 QUERY**：`KB_SKILL_ROOT/wiki/`（见 [知识库](../知识库/SKILL.md)）
3. **业务重要举措**（若有）：圈定窗口内**全部实验 + 功能类**→ **先**读需求正文判实验（标题无 AB 亦可能为实验）→ **先**在 26 汇总/双周会找分析：**实验全进路径 A**；**有分析的功能类进路径 A**；**仅**两源无分析的功能类跑路径 B → 总结只写明显正向或路径 B 过门槛；二章路径 A/B **表格**；converted 须保持表格
4. 生成 `{输出目录}/monthly_report_v2.md`：**一、OKR完成度** → **二、总结** → **三、下钻和归因**（含「业务举措」）→ **四、异常指标检测**（见 `memory/归因思路.md`「v2 文档结构」；OKR 取数见 OKR 模块 + data_analysis `看板.csv`）

### 功能进入保存率 / 进入渗透率补取数（路径 B）

```bash
cd SKILL_ROOT
# 列出二级功能
python 计算脚本/北斗取数/fetch_feature_enter_save.py --list-features

# 单条
python 计算脚本/北斗取数/fetch_feature_enter_save.py \
  --launch 20260617 --feature Face --name "Face新增3D骨相还原" \
  -o output/{YYYYMM}/业务举措/

# 批量（JSON 数组：launch/feature/name/desc）
python 计算脚本/北斗取数/fetch_feature_enter_save.py \
  --candidates /path/to/candidates.json \
  -o output/{YYYYMM}/业务举措/
```

- 看板：OCI `oci`，Dashboard `10015706`
  - Chart **90628**：进入保存率=`保存uv/进入uv`（前后各 14 天 Daily 日均）
  - Chart **90774**：进入渗透率（字段 `进入渗透率`，筛选/日期与保存率一致）
- **二级功能匹配**：先原名；未命中或取数无效再试 `AI ` 前缀；**拆解到 Skin 时**看板无整体 Skin 聚合，须从需求名/述再映射至子功能（如 Smooth、Clean Skin、Redness Fix）后取数（脚本自动匹配 options）
- **版本后最低日数**：不足 7 天不对比、不入选总结；二章门槛列写「数据不足7天」
- **未找到数据时门槛列二选一**：`未从看板拉取到对应功能（XX功能）`（需求已抽功能名但看板无/取数空）；或 `未提取到功能`（需求抽不出功能名）
- **总结门槛（满足任一）**：
  - 规则1：进入保存率相对变动 **>5%** 且 进入渗透率相对变动 **>-3%**
  - 规则2：进入保存率相对变动 **>-3%** 且 进入渗透率相对变动 **>10%**
  - 规则3：**完全新增**（上线前测试量级：日均渗透率≤1%、日均进入 uv≤300，允许灰度）；两列相对变动记 **「新功能」**；**上线后日均进入渗透率 >5%** 可入选总结
- 产物：`feature_enter_save_rate.csv` / `.json`、`业务举措_进入保存率.md`（含二章备案表）
- 二章：路径 A **表格**覆盖窗口内**全部实验**（无分析写「未找到对应的实验分析」）+ **有分析的功能类**；路径 B 表格仅**无分析的功能类**补取数结果；Phase D converted 对 `## 业务举措` 原文保留，路径 A/B 均须仍为表格

### Phase D：v2 格式转换（脚本）

**必读**：[references/v2convert.md](references/v2convert.md)（规范见 sibling **[md_convert](../md_convert/SKILL.md)**）

```bash
cd SKILL_ROOT
python 计算脚本/convert_monthly_v2.py -o output/{YYYYMM}/
```

- **输入**：`monthly_report_v2.md`（Phase B 产物）
- **输出**：`monthly_report_v2_converted.md`（**不覆盖** v2）
- 触发说法：`生成 converted`、`格式转换 v2`、`/md_convert`（在月报输出目录语境下）
- **树节点须含贡献占比**（如 `老用户 22.23%`），从 ASCII 树 `（XX%）` / `（占比XX%）` 提取

## 输出规则

默认输出目录：`SKILL_ROOT/output/{YYYYMM}/`。

| 路径 | 说明 |
| --- | --- |
| `monthly_report_v1.md` | v1 月报（s4 生成） |
| `monthly_report_v2.md` | v2 归因月报（Agent 按归因思路生成） |
| `monthly_report_v2_converted.md` | Phase D：`md_convert` 格式转换（见 [references/v2convert.md](references/v2convert.md)） |
| `业务举措/` | 路径 B：功能进入保存率补取数产物 |
| `下钻/s1_{mau,bookings,valid_vip}下钻.csv` | 下钻结果 |
| `贡献度/s2_{mau,bookings,valid_vip}贡献度.csv` | 贡献度结果 |
| `下钻报告/{mau,bookings,valid_vip}下钻分析报告.md` | 下钻分析 |
| `异常指标检测.md` | 月度异常检测 |

## 指标库口径

- `MAU` 和 `Bookings` 的下钻、贡献度计算参考 AI 周报的 `DAU` 和 `Bookings`。
- `月有效会员数` 拆解恒等式：**本月有效会员数 = 上月有效会员数 + 本月新增订阅会员数 - 月流失订阅会员数**；环比贡献 = **上月有效会员数**（整体，正向）+ 本月新增（正向）− 月流失（负向）；**上月有效会员数仅展示整体层贡献，不下钻国家**。
- 下钻列使用 `本月`、`上月`、`2月前` ... `13月前`，环比列仍为 `mom` / `mom%`。

## 检查清单

```text
- [ ] raw_data/{mau,bookings,valid_vip}.csv 已生成或确认可跳过取数
- [ ] output/{YYYYMM}/下钻、贡献度、下钻报告 已创建
- [ ] s1/s2/s3/s5/s4 均成功执行
- [ ] monthly_report_v1.md 存在
- [ ] Phase B：monthly_report_v2.md 符合 memory/归因思路.md
- [ ] Phase D：monthly_report_v2_converted.md 已生成（`python 计算脚本/convert_monthly_v2.py`）；mermaid 树节点含贡献占比
- [ ] 北斗取数为 MONTH + SUM（2026 订阅毛利除外：89060 累积毛利月末差分），日期范围覆盖近 **14** 个完整月
```
