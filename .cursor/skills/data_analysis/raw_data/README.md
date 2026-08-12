# raw_data

本 skill 自用的取数知识源（相对 `SKILL_ROOT/raw_data/`）。临时取数优先读这里，不再默认去 `app/AB-OCI/说明/` 找看板映射。

| 目录 | 用途 | 消费流程 |
|------|------|----------|
| [看板说明/](看板说明/) | 北斗看板 `dashboardId` / `chartId` / 网关 / 筛选 | 临时取数（看板） |
| [订阅归因层级/](订阅归因层级/) | L1～L4 订阅来源层级 mapping + 北斗筛选项 | 查功能/子功能订阅人数 |
| [埋点事件/](埋点事件/) | 事件名、`params` key；写 `sdk_odz_source_data` 等事件 SQL | 临时取数（神舟） |

同步约定：`看板说明/看板.csv` 可从 `app/AB-OCI/说明/看板.csv` 复制更新。订阅分级权威表导出为 `订阅归因层级/官方分级mapping.csv`。埋点见 `埋点事件/`；说「更新事件埋点」跑 `scripts/update_event_tracking.py`。
