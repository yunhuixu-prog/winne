# 【P1】技术：Airbrush双端SDK 接入调试工具（小康）

**页面ID**: 709018149

**路径**: V8.14.0版本（8_5上线）🚩/V8.14.0技术需求/【P1】技术：Airbrush双端SDK 接入调试工具（小康）

---

#### jira：

#### **技术类需求定义：工具支持**

| 模块
 | 

1202
incomplete
翻译需求

 | 

1203
incomplete
隐私整改

 | 

1204
incomplete
UI

 | 

1205
incomplete
特效

 | 

1206
incomplete
AR

 | 

1207
incomplete
素材

 | 

1208
incomplete
前端

 | 

1209
incomplete
服务端

 | 

1210
complete
底层

 | 

1215
incomplete
效果设计师

 | 

1211
complete
iOS

 | 

1212
complete
Android

 | 

1213
complete
测试

 ||

#### 更改记录：

| 更新时间
 | 更改人
 | 更改内容（变更用不同颜色mark）
 | 备注
 ||
| 
 | 
 | 
 | 
 ||
| 
 | 
 | 
 | 
 ||

#### 涉及业务（⚠️是否涉及第三方业务或者其他APP、模块配合，譬如 工具是否涉及商业化、社区等，社区是否涉及商业化、工具等，商业化是否涉及工具、社区等）

| 涉及模块 | 
 ||
| 涉及第三方业务/APP | 
 ||

### 一.需求背景

##### 为什么做该需求（产生的背景、当前存在的问题、效益说明、对产品功能是否有影响）
用例经AI步骤扩写后，操作路径和对象已经非常明确，但当前自动化用例执行主要瓶颈不在"步骤理解"，而在"场景进入"，如：登录态、环境切换、AB 实验、国家语言等前置条件路径长、稳定性差。
SDK 接入调试工具的目标是客户端可以按统一action快速触达目标场景，跳过冗长、不稳定的 UI 前置路径，在扩写步骤执行前或执行中完成环境模拟。

### 二.功能目标（勾选对应指标）

| 提升指标 | 具体数值（其他数值根据实际情况补充） | 上线数据（上线后补充） | 备注 ||
| 

298
incomplete
性能提升

 | 

299
incomplete
减少卡顿

300
incomplete
减少内存等

 | 
 | 
 ||
| 

1189
complete
提升效率

 | 

1190
complete
开发效率

1191
incomplete
调用速度等

 | 
 | 
 ||
| 

280
incomplete
成本节约

 | 

1141
incomplete
20万以上

1142
incomplete
5-20万

1143
incomplete
5万以下

1144
incomplete
不产生收入或者产生负向收入

 | 
 | 
 ||
| 

1192
incomplete
业务指标提升

 | 

1193
incomplete
保存数

1194
incomplete
进入uv...

 | 
 | 
 ||

### 三.需求描述
1.具体修改点/影响范围
2.技术重构需要提供目标框架

## 接入文档：

- 自动化-应用端快捷调试工具及工具列表文档路径： [https://git.meitu.com/aiqa/app-debug-tools/-/blob/master/README.md?ref_type=heads](调试 SDK 接入及测试文档)

- iOS：[https://git.meitu.com/iosmodules/aetherbridge/-/blob/master/README.md?ref_type=heads](AetherBridge 接入文档)

- Android：[https://git.meitu.com/mtgtech/android-components/automated-commands/-/blob/main/docs/integration-guide.md](automated-commands 接入文档)

- 调试命令测试工具：[https://cf.meitu.com/confluence/pages/viewpage.action?pageId=692615895](使用文档)

## 统一协议摘要：
请求统一使用批量命令结构，单指令时 commands 仅包含 1 个元素：

响应需返回整批执行结果和每条命令的结果：

协议要求：

- success=true 表示动作已执行并完成结果校验，不只是"已收到请求"。

- 任一子命令失败时，顶层 success 必须为 false。

- 需要重启后生效的能力，必须返回 requireRestart=true。

- 标准错误码统一使用 OK、INVALID_PARAMS、UNSUPPORTED_ACTION、REJECTED、TIMEOUT、NOT_READY、INTERNAL_ERROR。

## 分版本接入计划

### V1：基础自动化前置能力
目标：优先解决最高频的场景进入问题，让自动化能稳定完成账号VIP态、环境、AB实验、防截图设置。

| 优先级
 | 工具
 | 能力说明
 | 文档路径
 ||
| P0
 | account.setVipStatus
 | 修改当前登录账号的 VIP 状态
 | [https://git.meitu.com/aiqa/app-debug-tools/-/blob/master/account/account.setVipStatus.md](account/account.setVipStatus.md)
 ||
| P0
 | app.setNetworkEnvironment
 | 设置网络环境，如 online、beta、pre、dev
 | [https://git.meitu.com/aiqa/app-debug-tools/-/blob/master/app/app.setNetworkEnvironment.md](app/app.setNetworkEnvironment.md)
 ||
| P0
 | app.setCountry
 | 设置国家或地区
 | [https://git.meitu.com/aiqa/app-debug-tools/-/blob/master/app/app.setCountry.md](app/app.setCountry.md)
 ||
| P0
 | app.setABCodes
 | 设置 AB Code 列表，进入指定实验分组
 | [https://git.meitu.com/aiqa/app-debug-tools/-/blob/master/app/app.setABCodes.md](app/app.setABCodes.md)
 ||
| P0
 | app.setVipScreenshotProtection
 | 设置会员防截图开关，规避截图相关自动化干扰
 | [https://git.meitu.com/aiqa/app-debug-tools/-/blob/master/app/app.setVipScreenshotProtection.md](app/app.setVipScreenshotProtection.md)
 ||

### V2V3：补齐与高阶调试能力
目标：补齐账号、地区语言、主题、广告、审核、Mock、埋点和素材排障能力，提升复杂用例前置状态覆盖率与问题定位效率。

| 优先级
 | 工具
 | 能力说明
 ||
| P0
 | account.login
 | 统一登录能力，支持预置账号、账号密码等登录模式
 ||
| P0
 | account.logout
 | 统一登出能力，支持切换到游客态或未登录态
 ||
| P0
 | app.setLanguage
 | 设置语言
 ||
| P1
 | app.setAdEnabled
 | 设置广告开关
 ||
| P0
 | navigation.openURL
 | 打开 URL / Deep Link，直达目标页面
 ||
| P1
 | app.setUiTheme
 | 设置 UI 主题，如 light、dark、default
 ||
| P1
 | app.setReviewStatus
 | 设置审核状态
 ||
| P1
 | app.getABInfo
 | 查询当前 AB 信息
 ||
| P1
 | mock.setRecordingPolicy
 | 设置请求记录上报策略
 ||
| P1
 | mock.setAutomaticRuleRefreshEnabled
 | 设置规则自动刷新开关
 ||
| P1
 | analytics.switch
 | 控制埋点是否写入本地数据库
 ||
| P1
 | analytics.CRUD
 | 埋点本地库查询与删除
 ||
| P2
 | app.getGid
 | 查询当前 GID
 ||
| P2
 | debug.setLayoutBorder
 | 设置布局边框显示，辅助 UI 排障
 ||

### 四、影响范围/核对内容

| 确认点 | 具体内容 ||
| 影响范围 | 看开发是否有补充
 ||
| 需要产品验收内容 | 无 ||
| 需要效果验收内容 | 无 ||