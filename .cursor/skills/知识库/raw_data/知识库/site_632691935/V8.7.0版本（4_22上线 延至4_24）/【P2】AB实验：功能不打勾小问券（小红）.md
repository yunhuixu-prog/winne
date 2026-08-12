# 【P2】AB实验：功能不打勾小问券（小红）

**页面ID**: 675231528

**路径**: V8.7.0版本（4_22上线 延至4_24）/【P2】AB实验：功能不打勾小问券（小红）

---

#### JIRA地址：

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
complete
服务端

 | 

1210
complete
底层

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

#### 前置项

| 模块
 | 负责人|到期时间
 | 进度
 | 备注
 ||
| 
 | 
 | 
 | 
 ||

#### 更改记录：

| 更新时间
 | 更改人
 | 更改内容（变更用不同颜色mark）
 | 备注
 ||
| 2026-03-11 | 小红 | 创建文档 | 
 ||

#### 涉及业务（⚠️是否涉及第三方业务或者其他APP、模块配合，譬如 工具是否涉及商业化、社区等，社区是否涉及商业化、工具等，商业化是否涉及工具、社区等）

| 涉及模块 | 
 ||
| 涉及第三方业务/APP | 
 ||

## 一、需求背景
目前端内进行功能升级后，部分功能会出现打勾率低的情况。先前只能基于跑图分析，但并不是用户当下真实的情况。因此希望新增小问券，期望收集真实反馈、为后续的迭代提供指导。
分为两期进行：
一期：Plumping

**需求定性**

| 

1445
complete
用户反馈/调研

1446
incomplete
公司/产品战略

1447
incomplete
自己灵感/推演

1448
incomplete
竞品跟进

1449
incomplete
运营推广

1450
incomplete
技术研发

1451
incomplete
老板提的

1452
incomplete
我党提的

1453
incomplete
用户合规

 | 

1454
complete
基础优化

1455
incomplete
人有我有（参考x产品）

1456
incomplete
人有我优（参考x产品）

1457
incomplete
美图独创

 | 

1458
complete
全体适用

1459
incomplete
小白用户

1460
incomplete
中端用户

1461
incomplete
高端用户

 | 

1462
incomplete
高频

1463
complete
中频

1464
incomplete
低频但刚需

1465
incomplete
低频非刚需

 | 

1466
incomplete
不提升复杂度

1467
incomplete
化繁为简

1468
complete
略微提升复杂度

1469
incomplete
大大提升复杂度

 | 

1470
complete
基础型：必备，缺失会引起不满

1471
incomplete
期望型：做越多，用户越满意

1472
incomplete
惊喜型：缺失不会引起不满，一但具备会显著提升满意度

1473
incomplete
不关心型：无论是否具备，用户都不关心，可做可不做

1474
incomplete
负向型：具备了会引起不满

 | 

1475
incomplete
不产生口碑传播

1476
complete
能产生一点的口碑传播

1477
incomplete
能产生较好的口碑传播

 ||

**功能数据目标（勾选对应指标）**

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
incomplete
5-20万

1143
incomplete
5万以下

1144
incomplete
不产生收入或者产生负向收入

 ||

## 二、预估投入工时

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

## 三、原型流程图

## 四、需求描述

| xxxx算法接口 | 
 ||
| demo地址 | 
 ||
| 算法对接人 | 
 ||
| 效果设计师 | 
 ||

| 原型图 | 详情说明 ||
| 
 | **场景1：**编辑器内横幅
**功能范围：**

- 一期：Plumping
- 二期：Relight、Body、Hair

**触发条件**：
用户进入功能，（累计）**第二次打叉**时触发。
**展示形式**
第二次打岔后，回到上级页面，在tab bar上浮现小问券横幅。
**按钮**

- let us know：点击按钮跳转表单收集问券。
- 关闭按钮：点击后关闭横幅。

**关闭逻辑**：

- 点击关闭按钮则关闭
- 点击任意区域则自动关闭

**触达次数**

- 生命周期每个功能展示两次： 第二次不点击问券、第三次触发时则不显示横幅

 ||
| 
 | 待确认：
问券内容
 ||

实验设置

| 项目 | 说明 ||
| 实验触发时机 | 进入plumping功能 ||
| 实验停止方式 | 根据结果决定是关闭问券、还是长期进行问券。 ||
| 实验组说明
 | 对照组 | 当前线上状态 50% ||
| 实验组 | plumping小问券 50%
 ||
| 实验观察指标 | P0: 保存和用户留存
 ||
| 测试周期 | 14天（看结果决定是否延长）
 ||
| 目标用户 | 全体用户
 ||
| 实验预期 | 保存、留存 不负向 ||

## 五、订阅相关
无

## 六、协议跳转

| 

 | 问券链接
 ||
| EN
 | [https://tally.so/r/J900rR](https://tally.so/r/J900rR) ||
| PT
 | [https://tally.so/r/Zjzb7v](https://tally.so/r/Zjzb7v) ||
| ES
 | [https://tally.so/r/ja9y04](https://tally.so/r/ja9y04) ||
| FR
 | [https://tally.so/r/Y5zPpv](https://tally.so/r/Y5zPpv) ||
| DE
 | [https://tally.so/r/xXNrvd](https://tally.so/r/xXNrvd) ||
| RU
 | [https://tally.so/r/GxB6YO](https://tally.so/r/GxB6YO) ||
| TR
 | [https://tally.so/r/q4ELzg](https://tally.so/r/q4ELzg) ||
| AR
 | [https://tally.so/r/VL1GqM](https://tally.so/r/VL1GqM) ||

## 七、翻译

| 
 | EN ||
| Title | How was this feature? ||
| btn | Share with us ||
| 
 | Feedback ||

## 八、埋点需求

| 横幅 | 曝光/点击 ||