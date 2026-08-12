---
name: biweekly-data-sop
description: Biweekly (双周会) data SOP for AirBrush/PIX/OCI. Use when user mentions 双周会/biweekly, SOP, 北斗/Beidou取数, DAU/DNU/留存/订阅毛利, dashboard_id/chart_id, 核心国家, 异常检测（全国家）, 或需要按规则生成双周/周度指标与对比。
---

# 双周会数据同步 SOP（Skill 入口）

本 skill 将 `.cursor/skills/biweekly-data-sop/biweekly-data-sop.md` 作为**权威流程文档**。

## 使用方式（Agent 操作指引）

1. **先读取 SOP 全文**
   - 文件：`./biweekly-data-sop.md`
2. **确认口径与环境**
   - 用户规模（DAU/DNU/留存）：PIX 口径（通常 `default` 环境，`beidou.tatstm.com`）
   - 收入（订阅毛利）：OCI 口径（通常 `oci` 环境，`beidou-voyager.pix-int.com`）
3. **按 SOP 的表格配置执行取数**
   - 直接使用 SOP 中列出的 `dashboard_id / chart_id / filters` 组合
   - 强制遵守 SOP 中“已踩坑规则”（如 DAU 的“自然/渠道投放”不要多选导致均值错误）
4. **需要双周/周度对比时**
   - 按 SOP 的“时间窗口规则”确定周一~周日、近 N 周滚动等口径
   - 若要做“本双周 vs 上双周”并按差值 TopN，可复用项目内另一个 skill：
     - `.cursor/skills/beidou-biweek-compare/`

## 参考文档

- 权威 SOP：`biweekly-data-sop.md`

