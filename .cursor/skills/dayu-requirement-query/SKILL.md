---
name: dayu-requirement-query
description: 从大禹埋点平台(dayu)读取需求文档数据，以结构化表格形式展示埋点需求详情。支持需求检索、埋点数据导出。典型场景：获取特定版本埋点需求-查询美颜安卓V1.0.0的埋点需求、输入需求链接获取具体数据；按条件筛选需求-可过滤需求类型、版本号、需求标题、事件id等
metadata:
  author: 大禹埋点平台
  version: "1.3.0"
---


# 【大禹埋点平台】需求查询及导出

## 权限认证
使用Omnibus的Token，只需一次认证即可使用；（已设置环境变量OMNIBUS_ACCESS_TOKEN可忽略以下步骤）
未设置时：
 - 进入：[Omnibus](https://omnibus.meitu-int.com/users/profile)，新建令牌，复制令牌，并且快捷授权
 - 设置到环境变量
```
vi ~/.zshrc 
# 或 vi ~/.bashrc
export OMNIBUS_ACCESS_TOKEN="your_access_token_here"
# 保存后
source ~/.zshrc
# 或 source ~/.bashrc
```


## 功能概览

### 支持通过需求等分享链接获取指定需求
```
帮我获取埋点平台这个需求文档：https://dayu.tatstm.com/requirement/requirement?id=xxx&appId=xx&platformAgg=APP&fullScreen=true
```

### 支持通过描述方式查找需求
描述中需包含应用信息，可通过版本、平台、需求内容等条件查询。
```
帮我查大禹平台美图秀秀的1.12.7版本的需求;
获取埋点平台美颜相机下"平成大头贴"这个需求;
```

### 需求导出
使用本 skill 查询 Dayu 需求并导出文件（默认输出到 skill 当前目录下的 `output/`；若该目录无写权限会自动降级到 `/tmp/dayu/output`，可通过 `--output-dir` 自定义目录）：

- 单个需求：输出 1 组 `xlsx + md`，文件名按「需求名(+需求id)」生成
- 多个需求：每个需求独立导出 1 组 `xlsx + md`，**每个需求独立一个 md**


## 前置条件

- **服务地址（host）**：脚本内置三套环境，默认使用国内环境；用户若指定海外/OCI 等，再传 `env`（`default` / `starii` / `oci`）或命令行 `--env`。详见 `references/dayu-api.md` 中的「Host 环境」。
- **调用方式**：通过命令行 python3 调用脚本。**脚本路径**：本 skill 目录下的 `scripts/dayu_openapi_gateway.py`（即与 SKILL.md 同级的 `scripts/dayu_openapi_gateway.py`）；**公共入参与各接口入参、命令行示例、Python3 调用示例**见 **references/dayu-api.md**。
- **禁止主动输出使用说明**：正常执行查询时，**不要**向用户输出「使用方式」「OMNIBUS_ACCESS_TOKEN」「python3 ... dayu_openapi_gateway.py」等命令行说明或示例；仅在「网络不可达 / 需用户在本机执行」等降级场景下，才给出可执行命令及 token 配置提示。

## 依赖自动安装与授权提示

- 当执行脚本发现缺少 `requests` 依赖时，将**先自动尝试安装**到本地依赖目录（默认：`~/.agents/skills/.pydeps`，可用 `DAYU_DEPS_DIR` 覆盖），避免全局/用户目录权限问题。
- 若自动安装失败（例如权限不足），脚本会**提示用户授权安装或手动执行安装命令**，并终止本次调用，避免继续走不完整流程。

## 路径使用规范（避免重复拼接）

- 仅使用一种方式定位脚本：**绝对路径** 或 **先 `cd` 再用相对路径**，二选一。
- 若已 `cd` 到 skill 目录（或其子目录），**禁止**再拼接 `.agents/skills/...` 前缀，以免出现重复路径（例如 `.agents/skills/.agents/skills/...`）。

## 硬性规则：Skill 目录锁定（跨 Agent）

- **目录解析顺序固定**：`--skill-root` > `SKILL_DIR` > `CODEX_SKILL_DIR`/`CURSOR_SKILL_DIR`/`CLAUDE_SKILL_DIR`/`GOOGLE_SKILL_DIR` > 脚本 `__file__` 自定位。
- **禁止全局查找**：禁止通过全盘 `find`/`rg` 搜索 skill 目录；目录解析失败时应直接报错，提示补充 `--skill-root` 或 `SKILL_DIR`。
- **执行建议**：调用 `scripts/dayu_openapi_gateway.py` 与 `scripts/dayu_requirement_table_export.py` 时优先显式传 `--skill-root <skill_root_abs_path>`，避免多副本目录误命中。

## 硬性规则：JSON 中间文件管控

- **默认产出 xlsx + Markdown**：默认写入 skill 目录下的 `output/`；若无写权限自动降级到 `/tmp/dayu/output`；支持 `--output-dir` 自定义目录。
- **临时 JSON 仅用于中间处理**：允许临时落盘原始需求 JSON 以完成导出流程，导出后必须立即删除，不得作为最终产物保留（建议使用 `try/finally` 或等价机制确保异常时也清理）。
- **禁止在结果中展示 JSON 文件**：最终回复中的「已生成文件」仅列出 xlsx 与 Markdown，不得出现「原始需求 JSON」。

## 硬性规则：项目未指定时不得执行需求查询

- **项目为必选**。用户**未指定**项目（无 appId ）时：**仅可**调 `dayu_query_project_list` 展示列表并**提示用户选择项目**；**禁止**调用其他接口，**禁止**自行选用默认项目、第一项或任意一项代用户执行查询。

## 硬性规则：环境与项目一致

- **项目列表必须来自目标环境**：查哪个环境就用哪个环境的 `dayu_query_project_list(env=...)`，仅从该列表取appId去调用其他功能，且 `env` 与项目来源一致（default ↔ default，starii ↔ starii，oci ↔ oci）。
- **项目名称入参**：接口中使用到 `appId`、`appName` 参数时，**必须**使用 `dayu_query_project_list` 返回的 `**appId`**、 `**appName**`
- **禁止跨环境混用**：不得用国内（default）项目查海外（starii）或 OCI（oci）数据，也不得用海外/OCI 项目查国内数据。
- **当前环境不可用时**：若目标环境的 `dayu_query_project_list` 或接口报错（404、超时等），**不得**改用其他环境的项目或接口替代；须如实报错并提示用户检查该环境网关或鉴权。

## 硬性规则：鉴权失败不跨环境兜底

- 用户**已指定环境**且该环境返回**鉴权/权限错误**（401、403 等）时：**禁止**改用其他环境重试或返回其他环境的数据；**仅可**如实报错并提示用户检查该环境的 token/权限配置。
- 不得为「凑出结果」而用未指定环境的数据替代用户所请求的环境。

## 接口约束（必须遵守）

参数规范必须对齐以下 schema：

- `dayu_query_project_list`：可选参数 `name`（string）
- `dayu_query_requirements`：必填参数 `queryAppId` + `clientType`；可选参数 `shareLink`、`name`、`versions`、`contentLike`、`requirementTypes`、`priority`、`platforms`、`creator`

禁止自造不在 schema 中的筛选字段。

## 工作流程

### 默认执行策略（强制）

- **命中本 skill 后默认必须导出文件**：除非用户明确说「不要导出文件 / 只看文本结果」，否则不得停在查询摘要。
- **禁止等待式话术**：禁止输出「如果你要我可以继续导出/展开」等把导出变为可选下一步的表述。

1. 解析用户输入  
  支持 Dayu 分享链接、`id+appId`、或需求名关键词、需求内容关键词、需求版本号等过滤。
2. 必要时先查项目/appId  
  使用 `scripts/dayu_openapi_gateway.py` 调 `dayu_query_project_list`。
3. 查询需求明细  
  使用 `scripts/dayu_openapi_gateway.py` 调 `dayu_query_requirements`。
4. 生成文件（默认必做）  
  使用 `scripts/dayu_requirement_table_export.py` 导出 xlsx 与 Markdown，**固定使用 `--input`（临时文件）**，不再在 `--input-json` 与 `--input` 之间做选择。  
  - 执行流程：gateway 结果写入临时 JSON 文件 -> 调用导出脚本 `--input <temp_file>` -> 导出结束后立即删除临时 JSON（成功/失败都要删除），且不对用户展示该临时文件。  
  - Markdown 文件名按需求名生成，md 内容仅包含明细表格。  
  - 若返回多个需求，脚本会按需求拆分并分别导出多个 md。  
  - 默认导出到 skill 同级 `output/` 目录；若该目录无写权限自动降级到 `/tmp/dayu/output`；也可通过 `--output-dir` 指定自定义目录，并在导出结果中明确告知。
5. 产出文件  默认必做）  
  - xlsx（按固定字段顺序导出，明细表头从第 1 行开始，支持 `--mode expanded|merged`；默认 `expanded`）  
  - Markdown（与明细区字段一致，便于文本审阅/复制）

### 完成判定（DoD）

- 回复前必须同时包含：`markdown 文件路径` + `xlsx 文件路径` + `shareLink`（若接口无该字段则明确写「shareLink 为空」）。
- 缺少任一项视为未完成，必须继续执行直到满足。

### 失败处理（必须）

- 导出失败时，必须明确给出：`失败步骤` + `失败原因` + `可执行重试命令/修复建议`。
- 失败场景下禁止只返回查询摘要或需求说明文本。

## 展示模式（xlsx 可选）

- 默认模式：`expanded`  
按 `事件 + 参数 + 参数值` 逐行展开，列值完整填充。
- 可选模式：`merged`（仅 xlsx 生效）  
在 xlsx 中按事件层/参数层进行单元格合并；Markdown 仍保持展开模式（不合并）。

## 字段顺序（固定，xlsx 明细区）

必须按以下顺序输出：

`需求类型、事件来源、事件类型、*事件id、*事件名称、参数、参数名称、参数类型、参数值类型、参数口径、参数值、参数值名称、参数值口径、*统计口径、备注说明、事件分组、标签`

## 脚本说明

- `scripts/dayu_openapi_gateway.py`：gateway 鉴权方式调用 Dayu OpenAPI。
- `scripts/dayu_requirement_table_export.py`：将需求数据展平并导出 xlsx + Markdown（字段顺序以本文件“字段顺序”章节为准）。

## 网络不可达时的降级说明

当**当前执行环境**无法访问 gateway（例如无法解析 `connectors.meitu-int.com`、DNS/内网限制）时：

- **禁止**用其他环境或假数据替代；**仅可**如实说明当前环境无法访问内网 gateway。
- 提示用户在**已接入内网且可解析该域名的本机/终端**执行查询，并把输出 JSON 贴回，由本 skill 继续生成 xlsx + Markdown。
- 给出可执行命令时：
  - **Token**：若用户**已在本机配置** `OMNIBUS_ACCESS_TOKEN`，说明「若你本地已配置 OMNIBUS_ACCESS_TOKEN，可直接执行以下命令（无需再 export）」；否则再提供 `export OMNIBUS_ACCESS_TOKEN="你的token"` 的示例。

## 参考文档

- `references/dayu-api.md`
- `references/table-format-rules.md`

