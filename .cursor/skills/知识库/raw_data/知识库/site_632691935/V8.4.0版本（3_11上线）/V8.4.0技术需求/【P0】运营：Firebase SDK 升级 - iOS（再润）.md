# 【P0】运营：Firebase SDK 升级 - iOS（再润）

**页面ID**: 671725417

**路径**: V8.4.0版本（3_11上线）/V8.4.0技术需求/【P0】运营：Firebase SDK 升级 - iOS（再润）

---

#### jira：

#### **技术类需求定义：技术组件升级**

| 
### 模块
 | 

245
incomplete

### UI

 | 

246
incomplete

### 特效

 | 

1203
incomplete

### AR

 | 

254
incomplete

### 素材

 | 

247
incomplete

### 前端

 | 

248
incomplete

### 服务端

 | 

249
incomplete

### 底层

 | 

250
complete

### iOS

 | 

251
complete

### Android

 | 

252
incomplete

### 测试

 ||

#### 涉及功能（必选）：

| 
### 功能
 | 

1204
incomplete

### 人像美容

 | 

1205
incomplete

### 图片美化

 | 

1206
incomplete

### 相机

 | 

1207
incomplete

### 拼图

 | 

1208
incomplete

### 视频剪辑

 | 

1209
incomplete

### 视频美容

 | 

1210
incomplete

### 垂类

 | 

1211
incomplete

### 订阅

 | 

1212
incomplete

### 社区

 | 

1213
incomplete

### 商业化

 | 

1214
complete

### 全局

 | 

1215
incomplete

### 其他

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

#### 涉及业务（⚠️是否涉及第三方业务或者其他APP、模块配合，譬如 工具是否涉及商业化、社区等，社区是否涉及商业化、工具等，商业化是否涉及工具、社区等）

| 涉及模块 | 
 ||
| 涉及第三方业务/APP | 
 ||

### 一.需求背景
运营在Google广告渠道这边我们需要投放iOS，目前现在需要Firebase的SDK版本至少在11.14.0以上。

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

1225
incomplete
维护效率

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
将Firebase的SDK版本升级到11.14.0以上。
Firebase依赖GoogleUtilitiesy也可能需要升级。
具体问题可以联系 @王子昊 

### 四、影响范围/核对内容

| 确认点 | 具体内容 ||
| 影响范围 | 无 ||
| 需要产品验收内容 | 无 ||
| 需要效果验收内容 | 无 ||

**Firebase 升级回归测试点（P0）**

- Analytics-事件上报
步骤：启动 App，进入首页/编辑页，触发核心埋点事件。
预期：Firebase DebugView 实时看到事件，事件名和参数完整。

- Messaging-推送到达（前台）
步骤：App 前台发送测试推送。
预期：消息可接收，展示逻辑符合预期，无崩溃。

- Messaging-推送到达（后台/杀进程）
步骤：App 在后台和杀进程状态分别发送推送。
预期：系统通知可达，点击后正确跳转。

- RemoteConfig-fetch+activate 成功
步骤：服务端修改配置后启动 App 拉取。
预期：配置能拉到并生效，关键业务开关正确变化。

- 稳定性
步骤：连续冷启动 10 次并混合触发上面场景。
预期：无初始化报错、无崩溃、无明显性能劣化。

**阻塞标准**

- 事件不上报或参数错乱。
- FCM token 获取失败或推送不可达。
- RemoteConfig 拉取失败且未正确降级，影响主流程。