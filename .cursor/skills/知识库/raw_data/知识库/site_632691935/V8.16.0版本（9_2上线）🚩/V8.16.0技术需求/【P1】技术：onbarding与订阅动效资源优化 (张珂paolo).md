# 【P1】技术：onbarding与订阅动效资源优化 (张珂paolo)

**页面ID**: 710802796

**路径**: V8.16.0版本（9_2上线）🚩/V8.16.0技术需求/【P1】技术：onbarding与订阅动效资源优化 (张珂paolo)

---

#### jira：

#### **技术类需求定义：依赖升级**

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
视频

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
1、Onboarding 页面内置了 7 种语言（EN/ES/TR/FR/RU/PT/DE）的视频文件，包体占用较大
2、订阅页兜底展示pag文件较大，进行设计侧压缩输出，降低文件大小

### 二.功能目标（勾选对应指标）

| 提升指标 | 具体数值（其他数值根据实际情况补充） | 上线数据（上线后补充） | 备注 ||
| 

298
complete
性能提升

 | 

299
incomplete
减少卡顿

300
complete
减少内存

1219
complete
减少包体等

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

- 将多语言视频改为单个带可编辑文字图层的 PAG 文件，文字由各语言在 App 内独立配置

- 将较大pag进行压缩处理，降低文件大小

**预期收益**：从 7 份视频减为 1 份 PAG，降低包体；新增语言只需配置文字

### 四、影响范围/核对内容
**后续具体项会补充：**

| 确认点 | 具体内容 ||
| 影响范围 | onboarding页面、订阅页面 动效展示
 ||
| 需要产品验收内容 | 无 ||
| 需要效果验收内容 | 无
 ||