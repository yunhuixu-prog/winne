# v2 格式转换（Phase D）

将 `weekly_report_v2.md` 转为平台规范版 `weekly_report_v2_converted.md`。

## 规范来源

Sibling skill **[md_convert](../../md_convert/SKILL.md)**：

| 文件 | 作用 |
|------|------|
| `md_convert/format_require.md` | 硬性格式规范 |
| `md_convert/target.md` | 目标版式样例 |
| `md_convert/convert/convert_weekly_report_v2.py` | v2 专用转换实现 |

## 脚本入口

```bash
cd SKILL_ROOT

# 指定输出目录（须已有 weekly_report_v2.md）
python 计算脚本/convert_weekly_v2.py -o output/0622～0628

# v3 终审版转换
python 计算脚本/convert_weekly_v2.py -o output/0622～0628 --v3

# 或显式指定输入/输出
python 计算脚本/convert_weekly_v2.py -o output/0622～0628 \
  -i weekly_report_v3.md --out weekly_report_v3_converted.md

# 或依赖 ZHOUBAO_OUTPUT_DIR
export ZHOUBAO_OUTPUT_DIR=output/0622～0628
python 计算脚本/convert_weekly_v2.py
```

## Agent 执行（Phase B 之后）

1. 确认 `{OUT}/weekly_report_v2.md` 已按 `memory/归因思路.md` 写完
2. 运行 `python 计算脚本/convert_weekly_v2.py -o {OUT}`
3. 抽查产出：十对标识符、`现象：` 前缀、mermaid 树节点含**贡献占比**（如 `巴西 86.47%`，从 ASCII 树 `（86.47%）` / `（占比XX%）` 提取）、知识库字段（**事件** / 出处 / 命中原因 / **事件描述** / **关联度：强|中|弱**，禁止一律强）

## 产出

| 命令 | 产出 |
|------|------|
| 默认 / 无 `--v3` | `{OUT}/weekly_report_v2_converted.md` |
| `--v3` | `{OUT}/weekly_report_v3_converted.md` |

均**不覆盖**对应源文件（v2 / v3）。

## 与 v3 的关系

- **converted** 面向下游平台排版
- **完整流水线默认**：Phase D（v2 converted）→ Phase C（v3 终审）→ Phase E（`--v3` → `weekly_report_v3_converted.md`）
- 仅 v3 converted：`python 计算脚本/convert_weekly_v2.py -o {OUT} --v3`
