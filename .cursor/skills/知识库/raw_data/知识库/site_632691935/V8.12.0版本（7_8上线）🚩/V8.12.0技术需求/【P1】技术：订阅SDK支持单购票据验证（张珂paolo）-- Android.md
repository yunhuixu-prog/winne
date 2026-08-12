# 【P1】技术：订阅SDK支持单购票据验证（张珂paolo）-- Android

**页面ID**: 701445641

**路径**: V8.12.0版本（7_8上线）🚩/V8.12.0技术需求/【P1】技术：订阅SDK支持单购票据验证（张珂paolo）-- Android

---

#### jira：

#### **技术类需求定义：**

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

1215
incomplete
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
incomplete
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

- 安卓订阅SDK不支持单购票据验证，导致Pix部分接口无法下线，当前能力在业务层实现。
- 订阅还有依赖旧aw sdk做权益判断，考虑移除

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

- 单购也迁移到订阅中台，以便统一状态判断、下线旧服务，需要 ⁠pix_migrate/google_play/receipt_check⁠ 接口支持单购校验
- 中台已补齐Google支付SDK的单购票据校验能力
- 接入中台单购票据验证能力，并移除旧AW SDK

### 四、影响范围/核对内容

| 确认点 | 具体内容 ||
| 影响范围 | 单购商品权益校验
 ||
| 需要产品验收内容 | 无 ||
| 需要效果验收内容 | 无 ||