# v2 格式转换（Phase D）

将 `monthly_report_v2.md` 转为平台规范版 `monthly_report_v2_converted.md`。

## 规范来源

Sibling skill **[md_convert](../../md_convert/SKILL.md)**：

| 文件 | 作用 |
|------|------|
| `md_convert/format_require.md` | 硬性格式规范 |
| `md_convert/target.md` | 目标版式样例 |
| `md_convert/convert/convert_monthly_report_v2.py` | v2 月报专用转换实现 |

## 脚本入口

```bash
cd SKILL_ROOT

# 指定输出目录（须已有 monthly_report_v2.md）
python 计算脚本/convert_monthly_v2.py -o output/202605

# 或依赖 YUEBAO_OUTPUT_DIR
export YUEBAO_OUTPUT_DIR=output/202605
python 计算脚本/convert_monthly_v2.py
```

## Agent 执行（Phase B 之后）

1. 确认 `{OUT}/monthly_report_v2.md` 已按 `memory/归因思路.md` 写完
2. 运行 `python 计算脚本/convert_monthly_v2.py -o {OUT}`
3. 抽查产出：十对标识符、`现象：` 前缀、mermaid 树节点含**贡献占比**（如 `老用户 22.23%`，从 ASCII 树 `（22.23%）` / `（占比XX%）` 提取）、知识库三字段（出处/命中原因/事件描述）
4. **业务举措抽查（强制）**：`## 业务举措` 下路径 A、路径 B **均为 Markdown 表格**（路径 A 列：上线日期 / 需求概述 / 数据表现 / 是否入选）；convert 对业务举措节**原文保留**，不得改回 `> -` 列举

## 产出

`{OUT}/monthly_report_v2_converted.md` — **不覆盖** v2 源文件。
