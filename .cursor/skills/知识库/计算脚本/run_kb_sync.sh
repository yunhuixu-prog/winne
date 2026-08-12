#!/usr/bin/env bash
# 知识库「更新知识库」：拉 marks + CF → check → INGEST → write-baseline
# 用法：bash run_kb_sync.sh
# 需环境变量 OMNIBUS_ACCESS_TOKEN；任一步失败则 exit 1（不写 baseline）
set -euo pipefail

KB_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$KB_ROOT"

echo "==> [1/4] 拉取北斗 marks"
python3 计算脚本/北斗mark提取/北斗标识提取skill/scripts/fetch_marks.py

echo "==> [2/4] 拉取 Confluence"
python3 计算脚本/提取cf/提取cf文档.py

echo "==> [3/4] 检查待 ingest"
python3 计算脚本/check_wiki_updates.py || true

echo "==> [4/4] 请在 Agent 中完成 wiki INGEST 后执行："
echo "    python3 计算脚本/check_wiki_updates.py --write-baseline"
echo ""
echo "说明：INGEST 需 Agent 按 karpathy-wiki 写入 wiki/；本脚本仅自动化 raw 拉取。"
