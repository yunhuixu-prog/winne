# 【P1】AB 实验：Airbrush Face 子项算法优化（Jamie）底层先行

**页面ID**: 649363214

**路径**: V8.0.0版本（1_7上线）/v8.0.0 底层先行/【P1】AB 实验：Airbrush Face 子项算法优化（Jamie）底层先行

---

#### JIRA地址：link

服务端：

| 模块 | 

1181
incomplete
**翻译**

 | 

1182
incomplete
**隐私整改**

 | 

1183
incomplete
 **UI**

 | 

1184
incomplete
**特效**

 | 

1185
incomplete
**AR**

 | 

1186
incomplete
**素材**

 | 

1187
incomplete
 **前端**

 | 

1188
incomplete
**服务端**

 | 

1194
complete
设计

 | 

1189
complete
**底层**

 | 

1190
complete
**iOS**

 | 

1191
complete
 **Android**

 | 

1192
complete
**测试**

 ||

# 前置项

| 前置项
 | 负责人 | 预计完成时间 | 状态
 | 备注（进展） ||
| 
 | 
 | 
 | 
 | 
 ||

**需求变更记录表**

| 更新时间
 | 更新内容
 | 变更发起人
 ||
| 2025/10/14 | 输出需求 | 刘晓 ||

# 一、需求背景
**face 模块当前状态**

- face 模块部分功能算法陈旧，集团已有算法更新可供采购。

- face 模块存在部分功能分辨率下降问题，需要设计师核对后，对效果进行优化
- face 模块为用户高频使用功能，订阅收入全编辑器第二

 效果设计师核对文档：

- [https://cf.meitu.com/confluence/pages/viewpage.action?pageId=626299065](https://cf.meitu.com/confluence/pages/viewpage.action?pageId=626299065)
- 以下功能存在效果差、分辨率不佳情况

需求定性**

| 

255
incomplete
用户反馈/调研

256
incomplete
公司/产品战略

257
incomplete
自己灵感/推演

258
complete
竞品跟进

259
incomplete
运营推广

260
incomplete
技术研发

261
incomplete
老板提的

262
incomplete
我党提的

263
incomplete
用户合规

 | 

265
complete
基础优化

266
incomplete
人有我有（参考x产品）

267
incomplete
人有我优（参考x产品）

268
incomplete
美图独创

 | 

269
complete
全体适用

270
incomplete
小白用户

271
incomplete
中端用户

272
incomplete
高端用户

 | 

273
complete
高频

274
incomplete
中频

275
incomplete
低频但刚需

276
incomplete
低频非刚需

 | 

283
complete
不提升复杂度

284
incomplete
化繁为简

285
incomplete
略微提升复杂度

286
incomplete
大大提升复杂度

 | 

293
complete
基础型：必备，缺失会引起不满

294
incomplete
期望型：做越多，用户越满意

295
incomplete
惊喜型：缺失不会引起不满，一但具备会显著提升满意度

296
incomplete
不关心型：无论是否具备，用户都不关心，可做可不做

297
incomplete
负向型：具备了会引起不满

 | 

287
incomplete
不产生口碑传播

288
complete
能产生一点的口碑传播

298
incomplete
能产生较好的口碑传播

 ||

# 二、功能数据目标（勾选对应指标）

| **用户指标**
 | **保存率**
 ||
| 

280
incomplete
收入指标（如有）

 | 

1141
incomplete
20万以上

1142
complete
5-20万

1143
incomplete
5万以下

1144
incomplete
不产生收入或者产生负向收入

 ||

# 三、预估投入工时

| 职能 | 设计 | 前端 | 服务端 | 中间架构 | iOS | android | 测试 | 总 ||
| owner | 
 | 
 | 
 | 
 | 
 | 
 | 
 | 
 ||
| 工时/人天 | 
 | 
 | 
 | 
 | 
 | 
 | 
 ||

# 四、需求原型

# 五 、需求描述

| xxxx算法接口 | 
 ||
| demo地址 | 
 ||
| 算法对接人 | 杨树铭 ||
| 效果设计师 | 孔宇琴 ||

| 功能描述 ||
| Face模块子功能算法更新**
**需更新功能（21 项）**

- 面部
- 脸宽、颧骨、面部提拉、颅顶

- 下颌
- 下巴、双下巴、下颌角

- 眼睛
- 尺寸、上下位置、眼距、眼宽、倾斜

- 嘴巴
- 笑容、大小、高度、上唇、下唇、唇宽

- 眉毛
- 间距眉形、长短、眉峰

 ||
| **Face模块清晰度优化**

- 设计师根据表格标注，对分辨率不佳的太功能参数进行调整⬇️
- 

 ||
| 本次需求 **不涉及 **订阅限免策略调整 ||

# 六、协议跳转

# 无

# 七、翻译
无

# 九、埋点需求

##### AB 实验

| 组别 | 对照组A | 对照组B | 实验组 ||
| 内容 | 线上版本 | 线上版本 | face 子功能更新算法 ||
| 流量 | 33% | 33% | 33% ||
| 实验周期 | 2 周 ||
| 对比数据 | face 模块、及优化功能 的打勾率、订阅情况 ||