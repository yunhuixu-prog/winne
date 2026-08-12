# 【P0】技术：升级aigcSDK（立超）

**页面ID**: 710779851

**路径**: V8.15.0版本（8_19上线）🚩/V8.15.0技术需求/【P0】技术：升级aigcSDK（立超）

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
**背景：**双端aigcSDK的版本比较低，新版有优化一些已知问题及调整进度条数值，升级新版对用户体验上会好一些
**需求描述**
1、双端升级aigc sdk ，升级到最新版本。安卓：[https://platformrd.meitu-int.com/changelog/aigc/android](https://platformrd.meitu-int.com/changelog/aigc/android)，iOS：[https://platformrd.meitu-int.com/changelog/aigc/ios](https://platformrd.meitu-int.com/changelog/aigc/ios)
2、安卓模块：对于AI风格模块，点击稍后查看，退出页面后会调用SDK取消接口，任务也会取消，本次要改成调用停止轮询接口（Ai Repair 在8.13.5版本有修复，本期确认下没问题就好） &mdash; 2026-08-07 
3、开启平滑进度，体验一下效果，安卓文档：[https://meitu.feishu.cn/wiki/GUIjwr0f5ivfxUkQUEgchoI2nKg](https://meitu.feishu.cn/wiki/GUIjwr0f5ivfxUkQUEgchoI2nKg)，iOS文档：最新版本会自动开启平滑进度 细节与浩文对接 （如果双端轮询阶段有特殊处理过平滑进度，保持就好，但像美妆模块，进度很粗糙，可以用SDK的平滑进度 2026-08-07 ） 

**注意：**
1、iOS线上应该是0.6.153 版本，安卓看着是最最早的版本（1.0.0.0），期间升级比较多，测试需要多测一些AI模块。

2、对于有历史任务的（AI风格/画质修复等模块），之前安卓点击稍后查看，会调用SDK取消接口，任务也会取消，本次要改成调用停止轮询接口或者改成和iOS一样继续轮询获取结果；iOS之前处理是不停止轮询，本次也要改成调用停止轮询的接口。 2026-08-07 
3、开启平滑进度，体验一下效果，安卓文档：[https://meitu.feishu.cn/wiki/GUIjwr0f5ivfxUkQUEgchoI2nKg](https://meitu.feishu.cn/wiki/GUIjwr0f5ivfxUkQUEgchoI2nKg)，iOS文档：最新版本会自动开启平滑进度 细节与浩文对接 2026-08-07 

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