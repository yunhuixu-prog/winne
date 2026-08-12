# 【P1】技术：云端功能文件压缩及aigc参数走在线配置（立超）

**页面ID**: 707423186

**路径**: V8.14.0版本（8_5上线）/V8.14.0技术需求/【P1】技术：云端功能文件压缩及aigc参数走在线配置（立超）

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

### 一.需求描述
**背景：**
1、端上对图片都有做长边限制，最长边不超过4096，超过的4096的会压缩到4096，但此值是固定在端上的，无法在线灵活调整 
2、一些AI功能，aigc的配置参数，固定在客户端，如果算法变更，需要端上发版。 如： 
**需求描述**
1、[https://airbrush-management-web.pix-int.com/feature-config-config](黑后台功能配置)，增加压缩参数配置、效果参数配置。
2、客户端取服务端下发的压缩参数，按功能获取，如果服务端没有配此功能的压缩参数，则降级取当前客户端本地的配置。
3、客户端请求aigc的参数，改成取服务端下发的。

**需要支持的功能**

| 功能 | aigc参数是否客户端固定 | 长边限制 | 计划版本 ||
| Adjust-Flash
 | 
 | 
 | 
 ||
| Adjust-Deglare | 
 | 
 | 
 ||
| AIRepair
 | 
 | 
 | 
 ||

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

1217
incomplete
管理效率

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

### 三、影响范围/核对内容

| 确认点 | 具体内容 ||
| 影响范围 | 

 ||
| 需要产品验收内容 | 无 ||
| 需要效果验收内容 | 无 ||