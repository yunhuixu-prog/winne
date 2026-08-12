# 【P1】技术：Airbrush GlowUp底层改造MTImageKit-底层先行-长线（顺达）

**页面ID**: 667321690

**路径**: V8.3.0版本（2_26上线）/V8.3.0 底层先行/【P1】技术：Airbrush GlowUp底层改造MTImageKit-底层先行-长线（顺达）

---

#### jira：

#### **技术类需求定义：底层重构**

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
complete

### 底层

 | 

250
incomplete

### iOS

 | 

251
incomplete

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
1、底层技术改造优化，逻辑下层，减少后续双端上层的开发工作量
2、AIGC相关效果下沉底层请求，效果处理流程更加连贯，减少内存峰值，耗时

### 二.功能目标（勾选对应指标）

| 提升指标 | 具体数值（其他数值根据实际情况补充） | 上线数据（上线后补充） | 备注 ||
| 

298
complete
性能提升

 | 

299
complete
减少卡顿

300
incomplete
减少内存等

 | 
 | 
 ||
| 

1189
complete
提升效率

 | 

1190
complete
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

- **底层先行，将双端逻辑改造至MTImageKit内**

### 四、影响范围/核对内容
底层先行，暂不需要产品验收/效果核对

| 确认点 | 具体内容 ||
| 影响范围 | 无
 ||
| 需要产品验收内容 | 无 ||
| 需要效果验收内容 | 无 ||