# 【P1】AB 实验：Airbrush Face 算法模糊优化（Jamie）

**页面ID**: 662838058

**路径**: V8.2.0版本（2_4上线）/【P1】AB 实验：Airbrush Face 算法模糊优化（Jamie）

---

#### JIRA地址：

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
| 2026/01/19 | 输出需求 | 刘晓 ||

# 一、需求背景
**face 模块当前状态**

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

| xxxx算法接口 | ||
| demo地址 | ||
| 算法对接人 | 林顺达 ||
| 效果设计师 | 孔宇琴 ||

**1、需求描述**
**Face模块清晰度优化**

- 设计师根据表格标注，对分辨率不佳的太功能参数进行调整⬇️
- 

- 涉及功能
- 头
- **垂直、水平 **

- 面部
- **脸宽、颧骨**

- 下颌
- **下巴**

- 眼睛
- **眼高、尺寸、眼距、倾斜**

**2、实验规划**
针对 face模块算法替换 做如下AAB实验：

- 对照组：维持线上算法不变。
- 实验组：

- **接入为重塑优化底层算法**
- 原交互、生成数量、订阅逻辑维持不变。

- 涉及的9项子功能都要进行替换
- Magic内也同样替换 (相机内不用)

**AAB实验信息：**

| 实验触发时机 | **进入face****功能时、点击magic功能时（同个gid要同一个实验组）**
 ||
| 线上A | 维持线上算法不变 ||
| 对照组AA | 维持线上算法不变
 ||
| 实验组B | **替换为 重塑优化底层算法**
 ||
| 实验观察指标 | P0: 打勾率、保存、用户留存
 ||
| 流量控制 | 全区，对照组AA、实验组B 各 33% 流量 ||
| 测试周期 | 14天（看結果決定是否延長） ||

# 六、协议跳转

# 无

# 七、翻译
无

# 九、埋点需求