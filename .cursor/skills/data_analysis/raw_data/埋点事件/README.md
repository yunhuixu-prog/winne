# 埋点事件

用于 **临时取数（神舟）** 时查找：`event_id`、参数 key（`params['...']`）、参数值。

## 文件一览

| 文件 | 说明 |
|------|------|
| [事件知识_检索.csv](事件知识_检索.csv) | **神舟优先检索**（大禹需求 + 手动版合并） |
| [事件清单（手动版）.csv](事件清单（手动版）.csv) | 人工维护：事件名 / key名 / key值 / 含义 / 备注 |
| [dayu_gt722_事件清单.csv](dayu_gt722_事件清单.csv) | 大禹需求事件汇总 |
| [dayu_gt722_事件参数值清单.csv](dayu_gt722_事件参数值清单.csv) | 大禹需求事件×参数×值 |
| [dayu_gt722/](dayu_gt722/) | 需求 xlsx/md 导出与索引 |
| [事件清单.csv](事件清单.csv) / [事件参数清单.csv](事件参数清单.csv) | 全量事件列表（无参数值） |
| [update_state.json](update_state.json) | 上次同步版本水位 |

## 触发：更新事件埋点

用户说 **「更新事件埋点」** 时执行（见 skill `SKILL.md`）：

1. 读 `update_state.json` 的 `last_synced_version`
2. 从知识库 `site_632691935` 解析 **大于** 水位的版本号
3. 调 **dayu-requirement-query**（Airbrush / OCI）按版本拉需求并更新本目录
4. **必定**把 `事件清单（手动版）.csv` 合并进 `事件知识_检索.csv`

```bash
cd SKILL_ROOT
python3 scripts/update_event_tracking.py          # 增量拉大禹 + 合并手动版
python3 scripts/update_event_tracking.py --manual-only   # 只合并手动版
python3 scripts/update_event_tracking.py --dry-run       # 只看待拉版本
```

当前水位见 `update_state.json`；dry-run 示例：水位 `8.13.5` → 待拉 `8.14.0 / 8.15.0 / 8.16.0`。

## 检索顺序（神舟）

1. `事件知识_检索.csv`（含手动补充）
2. `dayu_gt722_事件参数值清单.csv`
3. 全量 `事件清单.csv` / `事件参数清单.csv`
4. 仍无则问用户；**禁止编造**

## 手动版字段

| 列 | 用途 |
|----|------|
| 事件名 | 对应 `event_id` / 事件名 |
| key名 | `params['key']` |
| key值 | 参数值枚举（可空） |
| 含义 | 口径说明 |
| 备注 | 自由备注 |

## 版本探测注意

大禹 `versions` 对不存在的版本号会返回**全部**需求；脚本用 `0 < total < 全量` 过滤。无效版本仍会推进水位，避免死循环；若需重拉某版本，把 `update_state.json` 的 `last_synced_version` 调低后重跑。
