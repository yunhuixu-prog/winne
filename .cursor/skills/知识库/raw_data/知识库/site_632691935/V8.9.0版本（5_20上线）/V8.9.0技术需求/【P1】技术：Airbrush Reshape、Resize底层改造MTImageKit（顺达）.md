# 【P1】技术：Airbrush Reshape、Resize底层改造MTImageKit（顺达）

**页面ID**: 686624486

**路径**: V8.9.0版本（5_20上线）/V8.9.0技术需求/【P1】技术：Airbrush Reshape、Resize底层改造MTImageKit（顺达）

---

#### jira：

#### **技术类需求定义：底层重构**

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
incomplete
前端

 | 

1209
incomplete
服务端

 | 

1210
complete
底层

 | 

1215
complete
效果设计师

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
1、底层技术改造优化，Reshape、Resize功能改造，减少双端上层的重复工作量
2、提升功能整体的性能、减少内存占用，为画质优化提供基础

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
complete
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

- **底层重构，将Reshape & Resize双端逻辑改造至MTImageKit内**

### 四、影响范围/核对内容

| 确认点 | 具体内容 ||
| 影响范围 | Reshape、Resize功能内效果
 ||
| 需要产品验收内容 | 交互与线上一致，主要是效果验收 ||
| 需要效果验收内容 | Reshape、Resize效果验收 ||