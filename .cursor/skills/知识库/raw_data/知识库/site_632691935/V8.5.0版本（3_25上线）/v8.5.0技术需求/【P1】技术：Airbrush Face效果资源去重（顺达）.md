# 【P1】技术：Airbrush Face效果资源去重（顺达）

**页面ID**: 675222564

**路径**: V8.5.0版本（3_25上线）/v8.5.0技术需求/【P1】技术：Airbrush Face效果资源去重（顺达）

---

#### jira：

#### **技术类需求定义：包体积优化**

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
complete

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
complete

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
incomplete

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

##### 为什么做该需求（产生的背景、当前存在的问题、效益说明、对产品功能是否有影响）
1、改造需求后，相关资源的新增导致包体增加
2、通过当前端侧已内置资源与Face所需资源进行去重，减少重复的内置资源，减少包体

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
1.具体修改点/影响范围
2.技术重构需要提供目标框架

- **iOS / Android上层进行Face资源去重/复用 减少APP的包体积**

### 四、影响范围/核对内容

| 确认点 | 具体内容 ||
| 影响范围 | 相关资源复用修改功能，开发后续给到
 ||
| 需要产品验收内容 | 无 ||
| 需要效果验收内容 | 无，测试过相关影响范围内功能效果是否正常即可 ||