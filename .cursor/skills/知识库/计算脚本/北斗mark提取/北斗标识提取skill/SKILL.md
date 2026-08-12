---
name: 北斗标识提取
description: >-
  提取北斗（Beidou）看板图表中的 marks（标注/标记）数据，按 dashboardId 和 chartId 合并为一个 JSON 文档。
  当用户提到提取/导出/拉取北斗的标注、标记、marks、标志线、注释、批注，或者提到从北斗图表中导出标记数据时，
  只要话题涉及从北斗图表中提取标注信息，都应使用此 skill。
---

# 北斗标识提取 Skill

通过 Connectors API Gateway 调用 Beidou 图表配置接口，从 `知识库地址.csv` 读取看板配置，批量提取 marks（标注/标记线），合并为一个 JSON，按 dashboardId → chartId 分组。

## 数据流

```
输入: 知识库地址.csv（dashboardId + chartId）+ OMNIBUS_ACCESS_TOKEN
  ↓
调用 Beidou Chart Conf API (POST, 按 CSV「网关」列选择 default / oci)
  ↓
从 response.content.configuration.marks 提取标注
  ↓
将 key（毫秒时间戳）转为 yyyyMMdd 日期格式
  ↓
输出 JSON: raw_data/北斗标注/marks_merged.json
```

## 前置依赖

- Python 3.6+
- 环境变量 `OMNIBUS_ACCESS_TOKEN`
- Connectors API Gateway 可用（外网不可达内网服务时需要）

## 配置文件

路径（默认）：

`计算脚本/北斗mark提取/知识库地址.csv`

格式：

```csv
dashboardId,chartId,名称,网关
10015816,89122,DAU,oci
10015816,90629,活跃次留,oci
10015834,89255,DNU,oci
10015834,90267,新增次留,oci
10015810,89046,日均订阅毛利,oci
10015839,89280,新增毛利,oci
10015839,89281,续订毛利,oci
```

说明：

- `dashboardId`、`chartId`：必填，对应北斗看板与图表 ID
- `名称`：可选，仅用于日志与输出备注，便于识别指标
- `网关`：可选，未填时脚本默认 `default`（`beidou.tatstm.com`）
  - `default` / `tatstm` → `beidou.tatstm.com`（PIX 口径）
  - `oci` / `voyager` / `pix` → `beidou-voyager.pix-int.com`（OCI 口径）
- 空行自动跳过
- AirBrush AI 周报 OCI 看板请在 CSV 中显式填 `oci`
- 也可从北斗链接提取 ID：`https://beidou-voyager.pix-int.com/dashboard/10015816?chartId=89122`

## 使用方式

### 默认运行（推荐）

在 **知识库** skill 根目录（`KB_SKILL_ROOT`）执行，读取默认 CSV，输出到 `raw_data/北斗标注/`：

```bash
cd KB_SKILL_ROOT
python 计算脚本/北斗mark提取/北斗标识提取skill/scripts/fetch_marks.py
```

### 指定 CSV 或输出目录

```bash
python 计算脚本/北斗mark提取/北斗标识提取skill/scripts/fetch_marks.py \
  --csv 计算脚本/北斗mark提取/知识库地址.csv \
  --output raw_data/北斗标注
```

### Token

脚本只从环境变量读取，不读本地 token 文件：

```bash
export OMNIBUS_ACCESS_TOKEN="perm:xxx"
python 计算脚本/北斗mark提取/北斗标识提取skill/scripts/fetch_marks.py
```

## 输出格式

`raw_data/北斗标注/marks_merged.json`：

```json
{
  "10015816": {
    "89122": [
      {
        "dashboardId": "10015816",
        "chartId": "89122",
        "name": "DAU",
        "date": "20260612",
        "content": "巴西情人节",
        "userName": "张三",
        "type": "markLine",
        "id": "425a409f-...",
        "createTime": 1774317505554,
        "updateTime": 1774317512852
      }
    ]
  }
}
```

## 工作中的模式

1. **用户要提取 marks** → 确认/更新 `知识库地址.csv`，设置 `OMNIBUS_ACCESS_TOKEN`，运行 `fetch_marks.py`
2. **用户给出北斗链接** → 从 URL 解析 dashboardId、chartId，写入 CSV 后运行
3. **用户只说导出标注** → 按 AI 周报 `fetch_beidou.py` 中的看板 ID 预填 CSV，再运行脚本
4. **新增指标图表** → 在 CSV 追加一行即可，无需改脚本

## 常见问题

- **未读取到 OMNIBUS_ACCESS_TOKEN**: 先 `export OMNIBUS_ACCESS_TOKEN=...`
- **certificate verify failed**: macOS 上旧版脚本用 `urllib` 会无法校验公司网关证书；已改用 `requests`（与 CF 提取工具一致）。若仍失败，确认已安装 `requests`：`pip install requests`
- **504 超时**: 网关或下游超时，重试一次；仍失败则检查网络连接
- **401/403**: token 过期或未授权，重新获取 token
- **HTTP 400 / the chart is not exist**: 通常是「网关」列选错。OCI 看板填 `oci`，PIX 看板填 `default`
- **空 marks**: 该图表没有标注数据，输出空数组
