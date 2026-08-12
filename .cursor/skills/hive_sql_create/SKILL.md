---
name: hive_sql_create
description: >-
  编写 AirBrush OCI 的 Presto / Hive SQL。表口径以 app/AB-OCI/口径、app/AB-OCI/说明 为准；
  不参考表名以 dataintegration-265403、airbrush-1324 开头的 BigQuery 旧代码。
  TRIGGER: 生成XXX的sql、写一段 hive/presto sql、按口径生成 SQL、补 SQL。
  在神舟跑数出现新报错时，须把报错与规避写法追加到本 skill 的注意事项。
---

# hive_sql_create

为 AirBrush OCI（Hive / Presto）编写可在神舟执行的 SQL。

## 何时使用

用户说「生成 XXX 的 sql」「写一段 hive/presto sql」「按口径生成 SQL」等时，必须先读本 skill，再写 SQL。

## 工作流

1. **读口径**：优先读 `app/AB-OCI/口径/`、`app/AB-OCI/说明/` 中与需求相关的 `.sql`；同主题可再参考 `app/AB-OCI/看板/`、`app/AB-OCI/实验/` 里已有 OCI 脚本。
2. **排除旧口径**：若文件/表名以 `dataintegration-265403`、`airbrush-1324` 开头，或明显 BigQuery 语法（`` `project.dataset.table` ``、`EXTRACT`、`user_pseudo_id` 等），**禁止参考**。
3. **选引擎**：默认按 Presto 可跑来写；注释里注明「不行切换 hive」。大查询、超时、复杂窗口/UDF 优先 Hive on Spark。
4. **写 SQL**：遵守下方「常量表过滤」与「神舟注意事项」。
5. **神舟跑数后**：若出现**新报错**，把「错误信息 + 规避写法」追加到 [神舟注意事项.md](神舟注意事项.md)；已有条目不重复堆砌。

## 常量表过滤（AirBrush）

| 场景 | 表 | 必带条件 |
|------|-----|----------|
| 日活 | `stat_sdk.sdk_odz_active` | `date_p BETWEEN ...`；`app_key_p IN ('C851ED7164B6DF0F','7F7023B6CEC7CDED')`；`os_p IS NOT NULL` |
| 新用户 | `stat_sdk.sdk_odz_new_device_info` | 同上 app_key / date_p / os_p |
| 国家维表 | `stat_sdk.dim_rna_ip_location` | `level='1' AND date_p IS NOT NULL`；`id`→`name` |
| 订单 | `stat_vip.paid_oda_all_order_summary` | `app_id_p IN (7329803307041000000)`；`product_sub_line='AirBrush'`；`is_subscribe='订阅'` |
| 埋点 | `stat_sdk.sdk_odz_source_data` | 同上 app_key + `date_p`；事件用 `event_id` / `params['...']` |
| 订阅归因明细 | `stat_ab.filing_onz_sub_source_event_detail`（或 `_level`） | `date_p BETWEEN ...` |

用户 id：活跃侧常用 `final_id`，订单/归因侧常用 `gid`（对齐时 `a.final_id = o.gid`）。

## 语法偏好

- 分区日期：`yyyyMMdd` 整型/`bigint`，`BETWEEN ${start_time} AND ${end_time}`。
- 日期运算：优先参考 `app/AB-OCI/口径/presto语法.sql`（`unix_timestamp` / `from_unixtime` / `date_format` / `meitu_datediff`）。
- 一行变多行：`LATERAL VIEW explode(...)` / `LATERAL VIEW stack(...)`（偏 Hive）。
- 参数风格：与周边脚本一致，用 `${start_time}` / `${end_time}` / `${start_date}` 等。
- 不要默认使用 `WITH`（见神舟注意事项）；优先嵌套子查询。

## 输出要求

- 只输出可执行 SQL（或用户指定的文件路径写入）。
- 口径有歧义时，先指出依据文件（`口径/xxx.sql` 或 `说明/xxx.sql`），再写代码。
- 不编造表名/字段；口径文件没有的，先问用户或搜索 `app/AB-OCI` 内 OCI 脚本。

## 详细参考

- 表字段与示例：见 `app/AB-OCI/说明/`、`app/AB-OCI/口径/`
- 神舟踩坑清单（须维护）：[神舟注意事项.md](神舟注意事项.md)
