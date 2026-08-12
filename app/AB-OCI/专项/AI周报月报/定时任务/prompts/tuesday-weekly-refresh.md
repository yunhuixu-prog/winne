# 周二定时任务 · 刷新上周周报（含周日次留）

**调度**：每周二 10:30（Asia/Shanghai）  
**说明**：补全上周日留存数据后，**全量覆盖**周一初版周报。

---

## 必读 Skill

`.cursor/skills/周报生成/SKILL.md` — **默认完整流水线**

**跳过**知识库更新（除非 marks/CF 有紧急变更）。

---

## Step 1 · Phase A（强制重取数）

`cwd = .cursor/skills/周报生成/`

```bash
python3 run_weekly_report.py --recent
```

- 周期与周一相同：**最近一个已结束的完整自然周**
- 输出目录：`app/AB-OCI/专项/AI周报月报/AI周报/{MMDD～MMDD}/`
- **覆盖**该目录下已有 v1/v2/v3 及下钻产物

---

## Step 2 · Phase B～E（全量重跑）

与周一相同，但须：

1. 重新 QUERY `知识库/wiki/`（无需重跑 fetch，除非周一后有大事件）
2. **重点核对**：
   - 整体 / 分渠道 **活跃次留**、**新增次留**（含分析周 **周日** 列）
   - 下钻报告中 wk 末列与北斗一致
3. Phase C 终审：删除周一版「待周二刷新」类占位表述
4. 生成 `weekly_report_v3.md` + `weekly_report_v3_converted.md` 为**最终可交付版**

---

## 交付检查

- [ ] 次留指标与看板 wk（含周日）一致
- [ ] v3 / v3_converted 已覆盖周一版本
- [ ] `审核报告.md` 记录相对周一版的主要修正点（若有）
