# 【P0】技术：升级aigcSDK（立超）

**页面ID**: 710779851

**路径**: V8.15.0版本（8_19上线）/V8.15.0技术需求/【P0】技术：升级aigcSDK（立超）

---

#### jira：

#### **技术类需求定义：底层重构**

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
incomplete
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

### 一.需求描述
**背景：**AirBrush 双端（iOS / Android）当前集成的 AIGC SDK 版本较旧：iOS 线上为 0.6.153，Android 仍停留在最早的 1.0.0.0，期间 SDK 已迭代多个版本。新版修复了一批已知问题，并对进度条数值展示做了调整，升级至最新版本有助于提升任务执行稳定性与用户体验。
**需求描述**
1、双端 AIGC SDK 统一升级至最新版本。Android：[https://platformrd.meitu-int.com/changelog/aigc/android](https://platformrd.meitu-int.com/changelog/aigc/android)，iOS：[https://platformrd.meitu-int.com/changelog/aigc/ios](https://platformrd.meitu-int.com/changelog/aigc/ios)
**注意：**
1、版本跨度大，回归需重点覆盖。iOS 线上为0.6.153，Android 为最早的 1.0.0.0，期间累计升级较多，测试需对各 AI 模块做充分回归。

2、「稍后查看」统一改为停止轮询（不再取消任务）。针对含历史任务的模块（如 AI 风格、画质修复等）：Android 原逻辑点击「稍后查看」会调用 SDK 取消接口、导致任务被取消，本次改为调用「停止轮询」接口、任务保留；iOS 原逻辑为不停止轮询，本次同样改为调用「停止轮询」接口，与 Android 行为对齐。

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
incomplete
提升效率

 | 

1190
incomplete
开发效率

1191
incomplete
调用速度等

1217
incomplete
管理效率

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

### 三、影响范围/核对内容

| 确认点 | 具体内容 ||
| 影响范围 | 

 ||
| 需要产品验收内容 | 无 ||
| 需要效果验收内容 | 无 ||