# 【P2】技术：Airbrush EyeBrighten底层改造MTImageKit（顺达）

**页面ID**: 710780885

**路径**: V8.15.0版本（8_19上线）/V8.15.0技术需求/【P2】技术：Airbrush EyeBrighten底层改造MTImageKit（顺达）

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
1、底层技术改造优化，减少内存占用，提升版本稳定性和用户体验，为画质提升奠定基础

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

- **底层重构，将EyeBrighten双端逻辑改造至MTImageKit内**
- **提升笔刷涂抹速度，优化用户体验**

### 四、影响范围/核对内容

| 确认点 | 具体内容 ||
| 影响范围 | 

 ||
| 需要产品验收内容 | 交互不变，可以不需要产品验收，简单过下功能即可 ||
| 需要效果验收内容 | 效果处理由客户端迁移至ImageKit，双端均需要效果核对
 ||