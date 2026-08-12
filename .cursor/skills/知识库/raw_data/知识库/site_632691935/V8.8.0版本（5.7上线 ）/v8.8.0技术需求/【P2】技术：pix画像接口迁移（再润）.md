# 【P2】技术：pix画像接口迁移（再润）

**页面ID**: 685224671

**路径**: V8.8.0版本（5.7上线 ）/v8.8.0技术需求/【P2】技术：pix画像接口迁移（再润）

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
出于大数据成本,架构,数据基建基本已在集团oci神舟完成。先需要将客户端使用的大数据接口下线。

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
complete
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
下线功能列表：
1. 消息中心，接口/openapi/v1/public/getMessageHistory。
2. 画像群组，接口/openapi/v1/public/getUserGroups。
3.限免策略，新用户判断。接口/openapi/v1/bigtable/beautyplus-bc0ed/px-da-bigtable/722-dwd_hzp_campaign_airbrush_gid_first_show_time。看是否能迁移到集团画像/大数据的新老用户接口。
接口文档：
集团接口：
oci：
测试：[https://test-gid-gdi-external.pixocial.com/info/sdk/query](https://test-gid-gdi-external.pixocial.com/info/sdk/query)
正式：[https://gid-gdi-external.pixocial.com/info/sdk/query](https://gid-gdi-external.pixocial.com/info/sdk/query)

参考：

### 四、影响范围/核对内容

| 确认点 | 具体内容 ||
| 影响范围 | ABPixADManager.isNewUser 影响编辑页首存广告、编辑页 premium 功能激励广告、订阅页激励广告、编辑页挽留广告，以及相关埋点与诊断信息。
 ||
| 需要产品验收内容 | 重点验收新用户/老用户在编辑页、订阅页、退出编辑页等场景下的广告分流与页面表现是否符合预期。
 ||
| 需要效果验收内容 | 重点核对埋点、诊断信息以及冷启动时序场景下广告行为是否与最终 isNewUser 状态一致。
 ||

**测试用例表**

| 用例ID | 测试场景 | 前置条件 | 操作步骤 | 预期结果 ||
| TC-01 | 新用户首次进入编辑页 | 新安装，当天首次启动，isNewUser = true，未订阅 | 进入编辑页 | 页面正常进入；埋点 user_type = new ||
| TC-02 | 新用户首次保存前触发首存广告 | 新用户，未保存过图片，首存广告配置开启 | 进入编辑页后执行保存 | 出现"首次保存广告/看广告解锁"相关弹窗 ||
| TC-03 | 新用户完成首存奖励后状态变化 | 新用户，已出现首存广告 | 点击看广告并成功获得奖励 | 奖励发放成功；功能刷新；首存奖励状态被记录 ||
| TC-04 | 新用户完成一次保存后不重复首存广告 | 新用户，已经完成过首次保存流程 | 再次进入编辑页并保存 | 不再重复走首次保存广告链路 ||
| TC-05 | 老用户进入编辑页 | 老用户，isNewUser = false，未订阅 | 进入编辑页 | 页面正常进入；埋点 user_type = old ||
| TC-06 | 老用户保存图片时不触发首存广告 | 老用户，首存广告配置开启 | 进入编辑页后执行保存 | 不出现新用户首次保存广告 ||
| TC-07 | 新用户使用 premium 功能 | 新用户，未订阅，功能支持广告解锁 | 进入 Highlighter/Bokeh/AIRetouch 功能 | 不走编辑器内普通激励广告解锁链路 ||
| TC-08 | 老用户使用 premium 功能 | 老用户，未订阅，功能支持广告解锁，广告配置开启 | 进入 Highlighter/Bokeh/AIRetouch 功能 | 按配置可展示普通激励广告解锁逻辑 ||
| TC-09 | 新用户订阅页激励广告展示 | 新用户，未订阅，满足广告配置 | 进入订阅页对应 premium 功能场景 | 可按配置展示订阅页激励广告 ||
| TC-10 | 老用户订阅页激励广告展示 | 老用户，未订阅，满足广告配置 | 进入订阅页对应 premium 功能场景 | 不因 isNewUser 条件展示该类新用户激励广告 ||
| TC-11 | 新用户退出编辑页 | 新用户，已编辑过内容 | 退出编辑页 | 不展示挽留广告 ||
| TC-12 | 老用户退出编辑页 | 老用户，已编辑过内容，命中配置和实验条件 | 退出编辑页 | 可展示挽留广告 ||
| TC-13 | 新用户编辑页进入埋点校验 | 新用户 | 进入编辑页，抓埋点 | user_type = new，is_retention_rewarded = 0 ||
| TC-14 | 老用户编辑页进入埋点校验 | 老用户，命中挽留实验 | 进入编辑页，抓埋点 | user_type = old，is_retention_rewarded 按实验结果校验 ||
| TC-15 | 诊断页新用户状态展示 | 新用户或老用户任一环境 | 打开广告诊断/日志相关页面 | "是否是新用户"展示与实际用户状态一致 ||
| TC-16 | 冷启动时序校验 | 新安装或可控制 gid 返回时序的环境 | 冷启动后快速进入编辑页，观察 gid 回填前后表现 | 不出现明显错误分流；页面广告表现与最终 isNewUser 状态一致 ||
| TC-17 | 隐私同意后首次状态计算 | 首次安装，未同意隐私 | 同意隐私后立即进入相关广告场景 | checkIsNewUser 生效，广告分流符合预期 ||
| TC-18 | gid 创建时间异步回填后状态修正 | 可模拟 gid 创建时间异步返回 | 启动后先进入编辑页，再等待 gid 回填 | 若新老用户状态修正，后续广告逻辑与修正后状态一致 ||

**建议重点回归**
1. 新用户首次保存链路
2. 新用户 premium 功能入口
3. 老用户 premium 功能入口
4. 新用户/老用户退出编辑页
5. 订阅页激励广告差异
6. 冷启动快速进入编辑页的时序问题
7. 埋点与页面表现是否一致
**补充说明**
isNewUser 当前不是单纯"账号新用户"，而是"广告口径的新用户，当天有效"。测试数据准备时，建议明确控制以下条件：
1. 安装/首启日期
2. gid 创建日期
3. 是否订阅
4. 广告配置和实验开关