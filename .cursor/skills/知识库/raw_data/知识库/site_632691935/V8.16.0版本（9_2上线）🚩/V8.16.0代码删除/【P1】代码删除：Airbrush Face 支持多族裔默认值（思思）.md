# 【P1】代码删除：Airbrush Face 支持多族裔默认值（思思）

**页面ID**: 710801254

**路径**: V8.16.0版本（9_2上线）🚩/V8.16.0代码删除/【P1】代码删除：Airbrush Face 支持多族裔默认值（思思）

---

#### JIRA地址：link 

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

1215
complete
效果

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
| 2026.06.30 | Jamie | 创建文档 | 
 ||
| 2026.07.08 | 徐娟 | 增加多人脸情况按照女性参数统一配置描述
除了白/黑/亚/拉丁以外的族裔识别结果都套通用参数（明确描述）
 | 
 ||
| 2026.07.09 | 徐娟 | 点击对应功能后滑杆再切到对应默认值
 | 
 ||
| 2026.07.10 | 徐娟 | 明确不支持多人脸功能的，多人脸情况按照女性参数统一配置 | 
 ||

#### 涉及业务（⚠️是否涉及第三方业务或者其他APP、模块配合，譬如 工具是否涉及商业化、社区等，社区是否涉及商业化、工具等，商业化是否涉及工具、社区等）

| 涉及模块 | 
 ||
| 涉及第三方业务/APP | 
 ||

## 一、需求背景
为什么要做：

- 当前 Face 内的子功能，进入功能时没有提供默认的强度值，需要用户手动进行调整。
- 针对26H1的多族裔数据进行分析时，发现分人种有不同的族裔轮廓：

#### 分人种表现 &middot; 美型意图的族裔轮廓

- 部位优先序一致（jaw > lip > face > eye > nose），轮廓形状明显不同：
- Black 在 Face 进入人数多但满意度最低；
- Asian 主要修 眼+脸型+小头
- Latin 主要调整鼻
- White 偏下颌/唇

- 且在不同部位上，应用强度的喜好差异明确，例如 lip_size

- 基于这些洞察，期望是能在 Face 内子功能支持依照人种、性别，在进入子功能时提供默认值，以提升整体模块的满意度。

文档：
[https://cf.meitu.com/confluence/pages/viewpage.action?pageId=701444624](AB Retouch 26H1 功能数据洞察)
[https://docuhub.meitu-int.com/s/my/jamiekuo-race_strategy_report_new](分人种表现)

**需求定性**

| 

255
incomplete
用户反馈/调研

256
incomplete
公司/产品战略

257
complete
自己灵感/推演

258
incomplete
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
incomplete
基础型：必备，缺失会引起不满

294
complete
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
incomplete
能产生一点的口碑传播

298
incomplete
能产生较好的口碑传播

 ||

## 二、功能目标
预计回收数据时间：8月10日&mdash;&mdash;14号

| 提升指标 | 具体数值 ||
| 

1189
incomplete
用户指标

 | 

299
incomplete
预计可带来新增**万

300
complete
所有功能对应4人种留存均提升3%

1217
complete
黑人人种打勾率提升3%

301
complete
所有功能对应4人种使用频次提升3%

 ||
| 

280
incomplete
收入贡献

 | 

1141
incomplete
高（日均收入5万以上）

1142
incomplete
中（日均收入1-5万）

1143
incomplete
低（日均收入低于1万）

1144
complete
不产生收入或者产生负向收入

 ||

## 三、预估投入工时

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

## 四、原型流程图

## 五、需求描述
1、需求内容

**Face 内子功能支持依照人种、性别，在进入子功能时提供默认值**
a. 进入 Face 时，携带「族裔检测」、「性别检测」字段：

- 根据人脸侦测到的族裔（white / latin / black / asian / mix_blood）对子项下发不同的默认系数
- 根据人脸侦测到的性别（male / female / unknown）对子项下发不同的默认系数
- unknown 时则不叠加性别处理

b. Face 对应子项进入时 照不同人种＋性别 提供默认值：

- 具体子项的映射与对应数值
- 详细数据参考：
- [https://meitu.feishu.cn/wiki/TDCPwI7FFiv2M1kwKItcCvpxnTz#share-NuC0dKfMpoK9lRxgJErcmMTYn5g](https://meitu.feishu.cn/wiki/TDCPwI7FFiv2M1kwKItcCvpxnTz#share-NuC0dKfMpoK9lRxgJErcmMTYn5g)

c. Face 模块支持服务器传参配置，支持联网修改预值参数快速修改，
d. 功能需要埋点记录所有子项的人种、性别、年龄的进入打勾率
2、实验内容

| 组别 | 功能 | 流量 ||
| 对照组（线上） | 线上face模块没有预值参数 | 33% ||
| Test A
（线上）
 | 线上face模块没有预值参数 | 33% ||
| 
 | 除了白/黑/亚/拉丁以外的族裔识别结果都套通用参数
 | 
 ||
| Test B

 | 模块 | 子项 | 白人 | 拉丁 | 黑人 | 亚裔 | 通用
（未识别）
 | 33%

 ||
| Face 脸 | width脸宽 | 女-55
男-30
 | 女-55
男-30
 | 女-55
男-30
 | 女-55
男-30
 | 女-55
男-30
 ||
| Jaw颌

 | double chin双下巴
 | 90 | 80 | 90 | 80 | 80 ||
| jaw line下颌线 | 40 | 40 | 40 | 40 | 40 ||
| jaw angle下颌角 | 45 | 45 | 45 | 45 | 45 ||
| chin下巴 | -30 | -30 | -10 | -30 | -30 ||
| Nose鼻子 | size尺寸 | -50 | -50 | -60 | -50 | -50 ||
| width鼻翼 | -50 | -50 | -60 | -50 | -50 ||
| mouth嘴唇

 | upper上唇 | 55 | 55 | 45 | 55 | 55 ||
| lower下唇 | 40 | 40 | 30 | 40 | 40 ||
| smile笑容 | 30 | 30 | 30 | 30 | 30 ||
| size大小 | 30 | 30 | -10 | 30 | 30 ||
| Eyes眼睛

 | dark circles祛黑眼圈 | 女80
男60
 | 女80
男60
 | 女80
男60
 | 女80
男60
 | 女80
男60
 ||
| size尺寸 | 35 | 35 | 30 | 35 | 35 ||
| stretch眼高 | 35 | 35 | 30 | 35 | 35 ||
| 不支持多人脸功能的，多人脸情况按照女性参数统一配置
 ||
| 实验触发时机 | 升级后首次进入「**Face **」
点击对应功能后滑杆再切到对应默认值
 ||
| 目标用户
 | 所有国家地区（需分国家分新老用户看数据，国家分：美、巴、其他）
 | 
 | 
 | 
 | 
 | 
 | 
 | /
 ||
| 测试周期
 | 实验开启14天后结合数据表现开放实验组流量，如果实验组有收益或无明显数据差异则扩全量
 | 
 | 
 | 
 | 
 | 
 | 
 | /
 ||
| **关注指标**
 ||
| **核心优化指标**
 | P0:打勾/保存/订阅
P1:功能整体的留存率
 | 
 | 
 | 
 | 
 | 
 | 
 | / ||
| **实验预期**
 | 实验组任意P0数据高于或持平对照组，P1数据无明显负向，后台无负反馈
 | 
 | 
 | 
 | 
 | 
 | 
 | / ||

## 六、协议跳转
如有变化需要在这个CF中增减记录：

## 七、翻译
翻译文档link

## 八、埋点需求
1、分人种、性别、年龄记录face模块的进入数据
2、分人种、性别、年龄记录face下所有子项最终打勾数据
3、记录ABC组人群的使用率变化

## 八、服务器配置
需要支持服务器传参配置，支持联网修改预值参数快速修改，