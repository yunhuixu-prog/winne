# 【P1】代码删除：Airbrush Magic子项参数优化（思思）

**页面ID**: 710801232

**路径**: V8.16.0版本（9_2上线）🚩/V8.16.0代码删除/【P1】代码删除：Airbrush Magic子项参数优化（思思）

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
| 2026.06.30 | 徐娟 | 创建文档 | 
 ||
| 2026.07.07 | 徐娟 | 和设计（小孔）确认实验参数
1、Smooth磨皮（支持男女检测，男性磨皮参数为10）
2、大眼功能不开启
3、增加c组实验项
4、白牙强度0.5改为0.6
 | 
 ||
| 2026.07.08 | 徐娟 | 瘦脸底层值填写方式修正
磨皮底层系数备注
 | 
 ||

#### 涉及业务（⚠️是否涉及第三方业务或者其他APP、模块配合，譬如 工具是否涉及商业化、社区等，社区是否涉及商业化、工具等，商业化是否涉及工具、社区等）

| 涉及模块 | 
 ||
| 涉及第三方业务/APP | 
 ||

## 一、需求背景
Magic 与 Skin 中的差别为全脸应用相同强度，需要检视目前多个效果应用的打勾组成，排查功能默认值。
调整Magic模块下的6个子项中用户打勾率低的参数进行AB实验，提升 Magic 模块的用户打勾率

参数修改注意点：
Smooth 磨皮和 Acne 祛痘在 Magic 和 Skin 入口里都很强，说明不是单纯被 Magic 分流，而是用户本身就有稳定需求&mdash;&mdash;既能被一键满足，也有明确的手动需求。
自动应用的子项会有打勾数据但没有进入数据（当前仅用户手动进入会记录），需要补上才能完整看 Magic 的内部转化。

**需求定性**

| 

255
complete
用户反馈/调研

256
incomplete
公司/产品战略

257
incomplete
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
incomplete
全体适用

270
complete
小白用户

271
complete
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
incomplete
不提升复杂度

284
complete
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
complete
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
incomplete
留存提升**%

1215
complete
Whiten牙齿美白打勾率提升3%

301
complete
Enlarge大 眼、Slim瘦脸使用频次提升3%

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

## 六、需求描述

| **组别 ** | **功能** | 底层参数 | ui显示参数 | 流量 ||
| 对照组（线上）

 | Smooth磨皮
Acne祛痘
Dark Circles祛黑眼圈
Whiten牙齿美白
Brighten亮眼
Tint唇色
 | 0.6
0
1.5
0.8
0.5
0.2
 | 60
开
开
开
开
开
 | 33%
 ||
| Test A（线上） | Smooth磨皮
Acne祛痘
Dark Circles祛黑眼圈
Whiten牙齿美白
Brighten亮眼
Tint唇色
 | 0.6
0
1.5
0.8
0.5
0.2
 | 60
开
开
开
开
开
 | 33% ||
| Test B | Smooth磨皮（支持男女检测，男性磨皮参数为10）
Acne祛痘
Dark Circles祛黑眼圈
Whiten牙齿美白
Brighten亮眼
Tint唇色
 | 0.6
0
1.5
0.6
0.5
0.2
 | 60
开
开
开
开
开
 | 33% ||
| Test C | Smooth磨皮（支持男女检测，男性磨皮参数为10）
Acne祛痘
Dark Circles祛黑眼圈
Whiten牙齿美白
Brighten亮眼
Tint唇色
Slim瘦脸
 | 0.6
0
1.5
0.6
0.5
0.2
1
 | 60
开
开
开
开
开
开
 | 33% ||
| 补充注意:
磨皮应用到底层，有用了系数0.7,即滑竿拖动到100，映射到底层参数最大才0.7，对于这里UI显示为60的，底层参数其实才0.42
 ||
| 实验触发时机
 | 升级后首次进入「Magic」
 | 
 | 
 | / ||
| 目标用户
 | 所有国家地区（需分国家分新老用户看数据，国家分：美、巴、其他）
 | 
 | 
 | /
 ||
| 测试周期
 | 实验开启14天后结合数据表现开放实验组流量，如果实验组有收益或无明显数据差异则扩全量
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
 | / ||
| **实验预期**
 | 实验组任意P0数据高于或持平对照组，P1数据无明显负向，后台无负反馈
 | 
 | 
 | / ||

## 七.协议跳转

## 八.AB code

## 九.AB结论

## 十.埋点需求
1、分人种、性别、年龄记录Magic模块的进入数据
2、分人种、性别、年龄记录Magic下所有子项最终打勾数据
3、记录ABC三组人群的使用率变化

## 十一.翻译需求

## 十二.TPM信息

| 能力类型 | 

22
complete
业务自研

 | 

26
incomplete
外采转自研

 | 

23
incomplete
接入

 | 

25
incomplete
外采

 ||
| **TPM项目名称
(可附上jira链接)** | 无 ||
| 业务侧的功能入口 | 无 ||
| **从哪个业务接入（接入的需填写）** | 无 ||

| 功能名称 | 算法对接人 | 接口文档 ||
| 
 | 
 | 
 ||
| 
 | 
 | 
 ||

### 十一.UI
Figma链接：