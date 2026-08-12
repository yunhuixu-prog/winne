# OpenAPI 接口文档

## Host 环境

| 环境 | 说明 | Base URL |
| --- | --- | --- |
| 默认 / 国内 | 默认环境 | ${MEITU_CONNECTORS_BASE_URL:-https://connectors.meitu-int.com}/gateway/bd-gateway.meitustat.com/forward/dayu |
| 海外 / starii | 海外 / starii | ${MEITU_CONNECTORS_BASE_URL:-https://connectors.meitu-int.com}/gateway/bd-gateway.meitustat.com/forward/dayu-starii |
| oci / pixocial / pix | OCI / Pixocial / Pix | ${MEITU_CONNECTORS_BASE_URL:-https://connectors.meitu-int.com}/gateway/bd-gateway.meitustat.com/forward/dayu-oci |


## 统一响应格式

| 字段 | 类型 | 说明 |
| --- | --- | --- |
| code | number | 状态码，0 表示成功 |
| message | string | 状态信息 |
| response | object/array | 业务数据 |

## 接口

### 1. 获取需求列表

**POST** `/requirements`

说明：查询需求列表。`queryAppId` 与 `clientType` 为必填项。

**请求头**

`Content-Type: application/json`

**请求体字段**

| 字段 | 类型 | 必填 | 说明 |
| --- | --- | --- | --- |
| queryAppId | number | 是 | 应用 ID，通过项目列表 tool 获取 |
| clientType | string | 是 | 终端类型：APP、WEB、PC |
| shareLink | string | 否 | 需求分享链接（如 `.../requirement?id=6964&appId=45&platformAgg=APP`），用于提取需求 ID |
| platforms | array<string> | 否 | 平台名称列表：iOS、Android、Harmony、iPad、Windows、Web、Mac、Linux、抖音、微信、支付宝、HarmonyPC |
| contentLike | string | 否 | 需求内容关键词搜索（如事件 id） |
| name | string | 否 | 需求名称模糊匹配 |
| versions | string | 否 | 版本号匹配（如 `12.5.0` 或 `LIVE埋点条恒V1`） |
| creator | string | 否 | 创建人 |
| requirementTypes | array<number> | 否 | 需求类型：1新增事件, 2删除事件, 3新增事件参数, 4删除事件参数, 5新增事件参数值, 6删除事件参数值, 7影响事件 |
| priority | string | 否 | 优先级：p0/p1/p2 |
| pageNum | number | 否 | 页码，默认 1 |
| pageSize | number | 否 | 每页数量，默认 20 |

**逻辑说明**

- 若传入 `shareLink`，优先使用分享链接中的 `id` 作为查询条件，其他过滤条件不生效。

**响应字段（response）**

`response` 为 `McpRequirementListResponse`：

| 字段 | 类型 | 说明 |
| --- | --- | --- |
| total | number | 总数 |
| pageSize | number | 每页数量 |
| pageNum | number | 页码 |
| requirements | array<object> | 需求列表 |

`requirements` 元素结构（`McpRequirementItem`）：

| 字段 | 类型 | 说明 |
| --- | --- | --- |
| id | number | 需求 ID |
| name | string | 需求名称 |
| background | string | 需求背景 |
| priority | string | 优先级 |
| link | string | cf链接 |
| shareLink | string | 需求分享链接 |
| platforms | array<number> | 平台 ID 列表 |
| platformVersions | array<object> | 平台版本列表 |
| events | array<object> | 事件列表 |

`productCf` 元素结构（`RequirementDetailTemplateInfo`）：

| 字段 | 类型 | 说明 |
| --- | --- | --- |
| field | string | 字段 |
| fieldName | string | 字段名称 |
| value | string | 值 |
| fieldType | number | 字段类型 |

`platformVersions` 元素结构（`RequirementPlatformVersion`）：

| 字段 | 类型 | 说明 |
| --- | --- | --- |
| platform | number | 平台 ID |
| versionId | number | 版本 ID |

`events` 元素结构（`McpEventItem`）：

| 字段 | 类型 | 说明 |
| --- | --- | --- |
| event | string | 事件 ID |
| eventName | string | 事件名称 |
| eventSource | number | 事件来源 |
| eventType | number | 事件类型 |
| info | string | 统计口径 |
| requirementTypes | array<object> | 需求类型列表 |

`requirementTypes` 元素结构（`McpEventRequirementTypeItem`）：

| 字段 | 类型 | 说明 |
| --- | --- | --- |
| requirementType | number | 需求类型 |
| requirementTypeName | string | 需求类型名称 |
| remark | string | 备注 |
| params | array<object> | 参数列表 |

`params` 元素结构（`McpParamItem`）：

| 字段 | 类型 | 说明 |
| --- | --- | --- |
| param | string | 参数名 |
| paramName | string | 参数中文名 |
| paramType | number | 参数类型 |
| valueType | number | 参数值类型 |
| info | string | 参数说明 |
| values | array<object> | 参数值列表 |

`values` 元素结构（`McpParamValueItem`）：

| 字段 | 类型 | 说明 |
| --- | --- | --- |
| val | string | 参数值 |
| valName | string | 参数值名称 |
| info | string | 参数值说明 |

**请求示例**

```json
{
  "queryAppId": 45,
  "clientType": "APP",
  "pageNum": 1,
  "pageSize": 20
}
```

### 2. 获取应用列表

**GET** `/project_list`

说明：根据应用名称模糊搜索应用列表，返回 `appId` 及应用名称。

**查询参数**

| 字段 | 类型 | 必填 | 说明 |
| --- | --- | --- | --- |
| name | string | 否 | 应用名称关键词，不传则返回全部 |

**响应字段（response）**

`response` 为 `McpAppItem` 列表：

| 字段 | 类型 | 说明 |
| --- | --- | --- |
| appId | number | 应用 ID |
| appName | string | 应用名称 |
| appNameEn | string | 应用英文名 |
