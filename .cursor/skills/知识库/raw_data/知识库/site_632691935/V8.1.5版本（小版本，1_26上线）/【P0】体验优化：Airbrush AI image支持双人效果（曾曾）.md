# 【P0】体验优化：Airbrush AI image支持双人效果（曾曾）

**页面ID**: 654095361

**路径**: V8.1.5版本（小版本，1_26上线）/【P0】体验优化：Airbrush AI image支持双人效果（曾曾）

---

#### JIRA地址：

| 模块
 | 

1202
complete
翻译需求

 | 

1203
incomplete
隐私整改

 | 

1204
complete
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
complete
前端

 | 

1209
complete
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
| 2025.1.12 | 曾曾 | 创建文档 | 
 ||

#### 涉及业务（⚠️是否涉及第三方业务或者其他APP、模块配合，譬如 工具是否涉及商业化、社区等，社区是否涉及商业化、工具等，商业化是否涉及工具、社区等）

| 涉及模块 | 
 ||
| 涉及第三方业务/APP | ||

## 一、需求背景

- 目前 AB 的 AI Image 能力仅支持单人效果，尚未覆盖双人及多人合影场景。但在欧美用户的使用心智中，合影是高度情感化且高频的拍摄与分享场景，尤其在圣诞节、情人节等重要节日，社媒中合影内容占比显著提升。单人 AI Image 已无法覆盖用户核心分享需求，需补齐双人合影能力。

- 从数据看，秀秀的 AI 合照功能曾在意大利、法国率先爆火，并迅速扩散至欧洲其他地区，热点持续近一个月（10.1&ndash;10.27），累计带来约 350 万新增用户、320 万订阅收入，并在欧洲 17 个地区登顶 App Store 总榜（其中意大利连续 11 天、法国 6 天、德国 4 天），35 个国家位列分类榜第 1，充分验证了双人 AI 合影在欧美市场的强需求与商业价值。

- 情人节双人效果list：[https://doc.weixin.qq.com/doc/w3_AdUAnwaPAHACNGMH1DDeOTyCe1yXy?scode=ACIAJAeGAAg1vn9RFhAdUAnwaPAHA](https://doc.weixin.qq.com/doc/w3_AdUAnwaPAHACNGMH1DDeOTyCe1yXy?scode=ACIAJAeGAAg1vn9RFhAdUAnwaPAHA)

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
incomplete
基础优化

266
complete
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
incomplete
期望型：做越多，用户越满意

295
complete
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

## 二、功能目标

| 

1189
incomplete
用户指标

 | 

299
incomplete
保存率

 | 
 | 
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

 | 
 | 
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
****

## 五、需求描述

| 原型图 | 功能详情说明 ||
| 
 | **入口**

- 首页-AI image-双人效果
- 编辑器-AI image-双人效果

**交互流程**

- **从编辑器进入**

- 用户选择单张图，进入AI image
- 选择双人效果，弹出下拉弹窗
- 标题「Upload photos of two people」上传两人照片
- 副标题「Please upload clear frontal photo」请上传高清正面照片
- 2个图片框，默认将用户当前的底图作为选中图
- 进入的底图不符合图片要求则置空，并弹出Toast「Photo fails two-person group shot check. Re-upload required」3s渐隐消失

- 底图不符合要求时，用户需要重新上传两张图，点击「+」可进入相册页，进入上传图片流程，进入图片检测：
- 图片要求
- 单人：超过单人脸则弹出toast「Please upload a solo photo」请上传单人照片
- 有全脸和完整五官：不符合则弹出toast「Please upload a photo with a complete face」请上传完整人脸照片

- 上传成功后，点击换图可切换图片
- 最低需要两张图，否则「Generate Now」置灰不可点击，满足两张后，「Generate Now」高亮可点击

- 点击「❌」可关闭当前下拉弹窗，返回当前AI image功能页
- 再次点击双人效果，则依然弹出双人照片弹窗（默认用户上次选择的照片），点击换图icon可替换图片
- 在当前AI image面板中时，始终记忆用户选择的双人照片，退出AI image面板后则不记忆（置空）

- 点击「Generate Now」后，进入loading页面

- 点击「Check later」停留当前AI image页面
- 点击「Cancel」则取消生成，停留在当前AI image功能页面

 ||
| 
 | 
- **从首页进入**

- 用户从首页/效果集合页，进入AI image，选择双人效果
- 进入上传照片页面，未满足两张图则「Generate Now」置灰不可点击，满足两张后，「Generate Now」高亮可点击
- 图片要求
- 单人：超过单人脸则弹出toast「Please upload a solo photo」请上传单人照片
- 有全脸和完整五官：不符合则弹出toast「Please upload a photo with a complete face」请上传完整人脸照片

- 点击「Generate Now」后，进入loading页面，底图为上传完的图片页面
- 点击「Cheek later」返回AI image首页
- 点击「Cancel」则停留在当前上传图片页面

- **其他逻辑：**均Follow当前AI image逻辑，含黄图/摄政检测，订阅/网络等情况

 ||

3、订阅限免策略
不涉及，follow功能订阅策略

## 六、协议跳转
/

## 七、翻译

| 英文 | 中文 ||
| Upload photos of two people | 上传2张人脸照片 ||
| Please upload a clear frontal photo | 请上传正脸清晰的照片 ||
| Please upload a solo photo
 | 请上传单人照片 ||
| Please upload photo with complete face | 请上传完整人脸照片 ||
| Photo fails two-person group shot check. Re-upload required | 当前图片不符合双人合影要求，请重新上传 ||

## 八、埋点需求

| 埋点 | 指标 ||
| 双人写真曝光/点击/打勾/保存/订阅/取消 | pv/uv ||
| 双人效果的上传--生成--保存全链路的使用情况 | pv/uv ||