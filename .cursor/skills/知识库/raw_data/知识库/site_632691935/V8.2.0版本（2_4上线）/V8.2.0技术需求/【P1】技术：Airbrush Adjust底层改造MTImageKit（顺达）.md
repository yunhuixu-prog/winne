# 【P1】技术：Airbrush Adjust底层改造MTImageKit（顺达）

**页面ID**: 661761623

**路径**: V8.2.0版本（2_4上线）/V8.2.0技术需求/【P1】技术：Airbrush Adjust底层改造MTImageKit（顺达）

---

#### jira：

#### **技术类需求定义：底层重构，性能优化**

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
1、双端Adjust底层逻辑分离，两套逻辑统一成一套，降低了开发效率
2、iOS端相关遗留bug解决：[https://jira.meitu.com/browse/AIRBRUSH-3305](AIRBRUSH-3305) [https://jira.meitu.com/browse/AIRBRUSH-3286](AIRBRUSH-3286)
3、为了提升一定的效果渲染性能，部分c++算法转gl

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

- **将Adjust双端底层逻辑改造至MTImageKit内**

### 四、影响范围/核对内容

| 确认点 | 具体内容 ||
| 影响范围 | 双端Adjust功能
 ||
| 需要产品验收内容 | 改造后，由于性能提升，AIGC相关效果滑杆可实时渲染，需确认是否采用该优化交互 ||
| 需要效果验收内容 | 双端Adjust效果 ||