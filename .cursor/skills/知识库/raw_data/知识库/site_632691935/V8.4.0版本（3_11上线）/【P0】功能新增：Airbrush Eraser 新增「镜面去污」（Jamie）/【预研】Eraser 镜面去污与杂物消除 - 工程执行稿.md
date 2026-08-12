# 【预研】Eraser 镜面去污与杂物消除 - 工程执行稿

**页面ID**: 671742327

**路径**: V8.4.0版本（3_11上线）/【P0】功能新增：Airbrush Eraser 新增「镜面去污」（Jamie）/【预研】Eraser 镜面去污与杂物消除 - 工程执行稿

---

# 【P0】Airbrush Eraser 镜面去污 / 杂物消除 &mdash; 工程执行稿（预研）
**需求来源**：[https://cf.meitu.com/confluence/pages/viewpage.action?pageId=669675708](CF 669675708) &middot; JIRA AIRBRUSH-4523
**预研说明**：本次预研基于代码库直接探索完成（PIXImageEdit 未初始化 OpenSpec，未调用 openspec-explore；已对 Eraser 组件、云请求、限免、埋点、路由做文件/函数级锚点梳理）。

## 管理摘要（1 屏版）

| 项 | 内容 ||
| **结论** | 可做。Mirror Stains 已在工程内大部分接入，以补齐与验收为主；Objects 需新增一条完整链路。 ||
| **范围** | 本次覆盖：Mirror Stains 协议/限免/埋点/交互对齐；Objects 从 0 到 1 接入。明确不覆盖：算法侧接口实现、海外同步策略配置。 ||
| **计划** | 建议 2 迭代：迭代 1 以 Mirror Stains 收尾 + 路由/协议登记；迭代 2 Objects 接入与联调。 ||
| **风险** | 限免策略二（消除模块共用次数）需与订阅/服务端配置一致；Objects 算法接口需确认入参与返回格式。 ||
| **门禁** | 上线前 Mirror/Objects 均走限免校验且埋点齐全；Eraser-Mirror 协议已在 AB 路由文档登记。 ||
| **回滚** | 功能由 Eraser 入口与 EraserTaskType 控制；可通过配置或分支关闭 Mirror/Objects 入口。 ||

## TL;DR

- **Mirror Stains（镜面去污）**：UI、云任务、loading、再次执行确认、new 角标、部分埋点与限免枚举已存在；**缺口**：路由 plist 中「Eraser - Mirror」协议条目、限免策略二与弹窗/不可保存等与产品说明的对齐、首次 tooltips/云弹窗需按需求核对。
- **Objects（杂物消除）**：需求与算法接口已明确，工程侧**尚未**接入；需新增 EraserEffectType.objects、EraserTaskType.sundries、云请求、限免枚举、UI 顺序、埋点与路由。

## 范围定义（In Scope / Out of Scope）

| In Scope | Out of Scope ||
| Mirror Stains 协议登记、限免/弹窗/交互与 CF 一致、埋点补齐 | 算法接口实现、海外环境同步 ||
| Objects 完整接入（UI、云请求、限免、埋点、路由） | 订阅服务端策略配置（由订阅同学补充） ||
| 功能顺序与 CF 一致：AI Eraser &rarr; Spot Remover &rarr; Passerby &rarr; Mirror Stains [&rarr; Objects] | 翻译与多语言资源（按现有流程） ||

## 现状对照（现状 vs 目标）

| 需求点 | 当前现状 | 目标 ||
| Eraser 内展示 Mirror Stains、Objects | 仅有 Mirror Stains 入口；无 Objects | 两功能均展示，顺序为 &hellip;、Mirror Stains、Objects，new 角标点击后消失 ||
| Mirror Stains 一键投递 | 已实现：点击即投递，loading 组件三，再次点击弹确认 | 保持，核对标题/按钮案与 CF ||
| 首次使用云弹窗 / tooltips | 需核对是否已接云弹窗与 tooltips | 与线上逻辑一致 ||
| 限免：策略二，消除模块共用 | 枚举 eraserMirror 已有；需确认 FreeUses 策略 key | 限免使用后提示剩余次数；用尽后不可请求、展示兜底图；不可保存、无「分享解锁」 ||
| 协议跳转 Eraser - Mirror | 代码支持 type=mirror；plist 无独立协议 key | 在 AB 路由协议 CF 与 plist 中登记 Eraser - Mirror ||
| Objects 能力 | 无 | 接入 /v1/img_sundries_seg_async，交互与 Mirror 类似 ||

## 执行清单（仅本次范围）

### Mirror Stains 收尾与登记

- **路由 / 协议**：在 ABBeautyCenterDeeplinkInfo.plist 中新增 Eraser-Mirror 协议条目；在 CF「0. AB路由协议」中登记「Eraser - Mirror」。
- **限免与弹窗**：确认 Mirror 使用「消除模块共用」策略二；限免用尽不可请求、展示兜底图；不可保存、无「分享解锁」。
- **交互与提示**：核对首次使用云弹窗、tooltips、再次执行确认弹窗文案与 CF 一致。
- **埋点**：确认 EditorEvent.Func.Eraser 中 Mirror 相关 key 在进入/成功/失败/再次执行等节点已上报；成本埋点已接。

### Objects 从 0 到 1

- **类型与云请求**：新增 EraserEffectType.objects、EraserTaskType.sundries；EraserCloudViewModel 的 EffectCtx 增加 task /v1/img_sundries_seg_async；createTask 支持新 type。
- **UI 与顺序**：makeSelectView 的 dataSource 追加 Objects；EraserUtils 增加 objectsNewFlagKey；resolveRouteParamsIfNeeded 支持 type=objects。
- **限免与订阅**：PIXABService 新增 eraserObjects 枚举与 SubscriptionEvent_Source1_*；限免与 Mirror 一致。
- **埋点与路由**：EditorEvent.Func.Eraser 增加 Objects 相关 key；plist 与 CF 路由协议登记 Eraser - Objects。

## 代码骨架与文件锚点
**文件**：PIXImageEdit/Classes/Features/Components/Eraser/EraserComponent.swift &mdash; 扩展 EraserEffectType、makeSelectView dataSource、resolveRouteParamsIfNeeded 的 type 映射。
**文件**：EraserCloudViewModel.swift &mdash; EraserTaskType 增加 sundries；EffectCtx.task / aigcParams 增加对应分支。
**文件**：PIXABService PXLSubscriptionConfigUtil.swift、ABSubscriptionEvent.h &mdash; 为 Objects 增加 eraserObjects 及 SubscriptionEvent_Source1_*。
**文件**：EditorEvent.swift、EraserComponent.swift &mdash; Mirror 已接；Objects 分支中调用相同埋点模式。

## 验收矩阵（紧凑表）

| 输入/前置 | 期望结果 | 失败排查 ||
| 进入 Eraser，默认 AI Eraser，滑杆 50 | 选中 AI Eraser，滑杆居中 | 查 setupData()、onceTokenForDefaultSelect、slider 初始值 ||
| 点击 Mirror Stains，首次 | 投递、loading 组件三、云弹窗、结果图后对比/撤销高亮 | 查 performMirrorStainsEntry、showLoadingIndicator、限免校验 ||
| 已有 Mirror 结果图时再次点击 Mirror | 弹「已有效果，确认是否再次执行」；确认后用当前图画布投递 | 查 eraserType == .mirrorStains 分支、确认弹窗文案 ||
| 限免用尽后点 Mirror/Objects | 不请求、展示兜底图；不可保存 | 查 FreeUses 校验、ABIAPManager 与 Eraser 限免分支 ||
| Deeplink type=mirror | 进入 Eraser 并选中 Mirror Stains 且触发 performMirrorStainsEntry | 查 resolveRouteParamsIfNeeded、itemType=4、routeParams ||
| plist 中 f_eraser_mirror | 打开编辑页并进入 Eraser + Mirror | 查 EditorRouter、ABBeautyCenterDeeplinkInfo ||
| Objects 接入后点击 Objects | 投递 /v1/img_sundries_seg_async，结果图展示与限免/埋点与 Mirror 一致 | 查 EraserTaskType.sundries、createTask、埋点 key ||

## 风险门禁与回滚

- **限免策略与服务端不一致**：与订阅同学确认策略二 key 及「消除模块共用」在服务端与客户端一致后再上线。
- **Objects 接口格式变更**：与算法对接人确认 /v1/img_sundries_seg_async 入参/返回格式后再实现。
- **回滚**：通过 Eraser 入口 dataSource 移除 Objects/Mirror 项或通过配置关闭对应 type。

## 发布观察项

- Mirror / Objects 的 ai_func_use_result、adjust_count、成本埋点是否按预期上报。
- 限免用尽后兜底图与不可保存是否在所有入口一致。

## 待确认项

- Objects 交互：与 Mirror 完全一致「点击即投递」还是需选区/画笔。
- 路由协议命名：f_eraser_mirror / f_eraser_objects 是否与美颜中心统一命名规范一致。
- 翻译：CF 七、翻译表中 Mirror Stains &rarr; 镜面污渍已给；Objects 中英文案待补充。

## 预研执行留痕

- **openspec-explore**：未调用（PIXImageEdit 未初始化 OpenSpec）。
- **探索方式**：代码库直接阅读与 grep 锚点（EraserComponent、EraserCloudViewModel、EraserUtils、EditorEvent、PXLSubscriptionConfigUtil、ABBeautyCenterDeeplinkInfo、EditorRouter）。
- **需求文档**：已通过 Gateway API 读取 CF pageId 669675708 全文。