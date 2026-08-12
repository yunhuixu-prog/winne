# 订阅归因层级

查询北斗「订阅链路来源」多级看板时，先对照本目录确定 **选哪层看板、筛选项填什么**。

## 官方 mapping（权威）

| 文件 | 说明 |
|------|------|
| [官方分级mapping.csv](官方分级mapping.csv) | **权威**：埋点 `source_*` → 看板 `first/second/third/fourth_source` |
| [官方分级mapping.xlsx](官方分级mapping.xlsx) | 同源 xlsx 备份（来自 Downloads/mapping.xlsx） |

列含义：

| 列 | 含义 |
|----|------|
| `source_module` / `source_0` / `source_1` | 埋点字段 |
| `first_source` | 看板「分类」(L1) |
| `second_source` | 看板「二级归因」(L2) |
| `third_source` | 看板「三级归因」(L3) |
| `fourth_source` | 看板「四级分类」(L4) |
| `comment` | 备注 |

来源 Sheet：https://docs.google.com/spreadsheets/d/1Q1gdgKdbcfLm55cgcA-weHgGfUvGSZz5Zj0BOBSoOhE/edit?pli=1&gid=0#gid=0  

更新方式：重新导出 xlsx → 覆盖本目录两文件（或只覆盖 csv）。

## 看板层级

| 文件 | 说明 |
|------|------|
| [看板层级对照.csv](看板层级对照.csv) | L1～L4 的 `dashboardId`、筛选项、常用 chartId |
| [常用路径示例.csv](常用路径示例.csv) | 常见功能路径（含 Eraser，已按官方表校正） |
| [北斗筛选项_*.csv](北斗筛选项_一级分类.csv) | OCI linkage 选项快照（辅助校验看板选项是否存在） |

| 层级 | dashboardId | 筛选项 | 用途 |
|------|-------------|--------|------|
| L1 | 10015758 | 分类 = `first_source` | Edit / Else / Video / … |
| L2 | 10015759 | + 二级归因 = `second_source` | 如 Edit-Retouch、Edit-Edit |
| L3 | 10015763 | + 三级归因 = `third_source` | 如 Edit-Edit—Eraser |
| L4 | 10015764 | + 四级分类 = `fourth_source` | Eraser 子功能：AI / Classic / Passersby / … |

## 查法（示例：Eraser 子功能订阅人数）

官方表（`p_edit` + `f_eraser`）：

- L1 `分类` = **Edit**
- L2 `二级归因` = **Edit**
- L3 `三级归因` = **Eraser**
- L4 `四级分类` = 子项（AI / Classic / Passersby / Mirror Stains / Object / Text），或选「整体」看分布

指标：优先「订阅成功人数」；付费看「订阅成功付费人数」。近 7 天付费可能偏低（链路回填）。

路径不确定时：先在 `官方分级mapping.csv` 按功能名 / `source_0` 检索，再填筛选；仍不清则问用户。
