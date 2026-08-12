# 【P1】技术：客户端遗留效果接入SDK（大宝）

**页面ID**: 691201533

**路径**: V8.12.0版本（7_8上线）🚩/V8.12.0上期遗留需求/【P1】技术：客户端遗留效果接入SDK（大宝）

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
complete
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
目前所有AI效果，都需要推进接入SDK，不再使用PIX的effects以及客户端不再直连算法，统一链路以及基建，方便管理

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
提升体验

 | 

1217
complete
使用体验及管理

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
以下残留的效果，需要改造接入SDK:

- 双端-漂发：[https://api.lab.pixocial.com/v1/hair_fade](https://api.lab.pixocial.com/v1/hair_fade) （token_type:haircoloring; task: [https://api.lab.pixocial.com/v1/hair_fade](/v1/hair_fade); task_type: mtlab）
- 双端-GlowUp 
- 分割：https://[http://image-tools.pixocial.com](image-tools.pixocial.com/api/v1/image/inst-skin-hair-seg)（token_type:glow_up; task: [https://insight-mtlab.meitu-int.com/document/editor?id=697&type=preview](/v1/inst_skin_hair_seg_async); task_type: mtlab）
- 去晒痕：https://[http://image-tools.pixocial.com](image-tools.pixocial.com/api/v1/image/tanline) (token_type:glow_up; task: [https://insight-mtlab.meitu-int.com/document/editor?id=752&type=preview](/v1/aitanline_async); task_type: mtlab)
- 身体光泽：https://[http://image-tools.pixocial.com](image-tools.pixocial.com/api/v1/image/body-glowing) (token_type:glow_up; task: [https://insight-mtlab.meitu-int.com/document/editor?id=738&type=preview](/v1/ai_body_glowing_async;) task_type: mtlab

- 双端-智能抠图（背景保护前置）:https://[http://v2.lab.pixocial.com](v2.lab.pixocial.com/v1/saliency-object-detection) (token_type:glow_up; task: /v1/saliency-object-detection (); task_type: mtlab)

3. Effects 服务端渲染（证件照/微笑、风格头像、发色）

- 域名：配置在duffle
- /v1/beauty_smile、/v2/animeface、/v1/hair_fade

 （token_type:portrait_preset; task: /v1/beauty_smile; task_type: mtlab）
 （token_type:portrait_preset; task: /v2/animeface; task_type: mtlab）
 （token_type:portrait_preset; task:/v1/hair_fade; task_type: mtlab）

参数说明：
inst-skin-hair-seg:
原始请求
{
 &quot;parameter&quot;: {
 &quot;instMask&quot;: {
 &quot;instMaskOutType&quot;: 0,
 &quot;instMaskBoxes&quot;: 0,
 &quot;instMaskBG&quot;: 0
 },
 &quot;skinMask&quot;: {
 &quot;skinMaskOutType&quot;: 0,
 &quot;skinMaskOutMode&quot;: 0
 },
 &quot;multiMask&quot;: {
 &quot;multiMaskOutMode&quot;: 0,
 &quot;multiMaskOutType&quot;: 1,
 &quot;multiMaskOutClass&quot;: &quot;0,1,1,0,0,1,0,0,0&quot;
 }
 },
 &quot;input&quot;: &quot;[https://object.pixocial.com//aibiz//B8F406B8-34BD-4C6A-98B3-6B03CDC449E7_1781246349207.jpeg](https:\/\/object.pixocial.com\/aibiz\/B8F406B8-34BD-4C6A-98B3-6B03CDC449E7_1781246349207.jpeg)&quot;
}

算法请求

{
 &quot;parameter&quot;: {
 &quot;rsp_media_type&quot;: &quot;url&quot;,
 &quot;ClothMask&quot;: {
 &quot;ClothMask_OutMode&quot;: 0,
 &quot;ClothMask_OutType&quot;: 0
 },
 &quot;InstMask&quot;: {
 &quot;InstMask_BG&quot;: 0,
 &quot;InstMask_Boxes&quot;: 0,
 &quot;InstMask_OutType&quot;: 0
 },
 &quot;MultiMask&quot;: {
 &quot;MultiMask_OutClass&quot;: &quot;0,1,1,0,0,1,0,0,0&quot;,
 &quot;MultiMask_OutMode&quot;: 0,
 &quot;MultiMask_OutType&quot;: 1
 },
 &quot;SkinMask&quot;: {
 &quot;SkinMask_OutMode&quot;: 0,
 &quot;SkinMask_OutType&quot;: 0
 },
 &quot;MultiBgMask&quot;: {
 &quot;MultiBgMask_OutClass&quot;: &quot;&quot;,
 &quot;MultiBgMask_OutMode&quot;: 0,
 &quot;MultiBgMask_OutType&quot;: 0
 }
 },
 &quot;media_info_list&quot;: [
 {
 &quot;media_data&quot;: &quot;[https://object.pixocial.com/aibiz/B8F406B8-34BD-4C6A-98B3-6B03CDC449E7_1781246349207.jpeg](https://object.pixocial.com/aibiz/B8F406B8-34BD-4C6A-98B3-6B03CDC449E7_1781246349207.jpeg)&quot;,
 &quot;media_profiles&quot;: {
 &quot;media_data_type&quot;: &quot;url&quot;
 }
 }
 ]
}

映射规则：

| MediaDataDescribe 值
 | 对应输出字段
 ||
| extraInstMaskData | output.InstMaskOutput ||
| extraMultiMaskData0 / allpeople_mask | output.MultiMaskOutput.WholePerson ||
| extraMultiMaskData1 / skinall_mask | output.MultiMaskOutput.AllSkin ||
| extraMultiMaskData2 / hair_mask | output.MultiMaskOutput.Hair ||
| extraMultiMaskData3 / skinbody_mask | output.MultiMaskOutput.BodySkin ||
| extraMultiMaskData4 / skinneck_mask | output.MultiMaskOutput.Neck ||
| extraMultiMaskData5 / cloth_mask | output.MultiMaskOutput.Clothes ||
| extraMultiMaskData6 / face_mask | output.MultiMaskOutput.Face ||
| extraMultiMaskData7 / faceskin_mask | output.MultiMaskOutput.FaceSkin ||
| extraMultiMaskData8 / accessory_mask | output.MultiMaskOutput.Accessories ||
| extraMultiMaskData9 / skinnormal_mask | output.SkinMaskOutput ||

[http://image-tools.pixocial.com](/api/v1/image/tanline)
原始请求参数
{
 &quot;input&quot;: &quot;[https://object.pixocial.com//aibiz//C1A82EEB-BEC2-4418-8AA4-FBE5D47F1954_1781246302742.jpeg](https:\/\/object.pixocial.com\/aibiz\/C1A82EEB-BEC2-4418-8AA4-FBE5D47F1954_1781246302742.jpeg)&quot;
}

算法请求参数
{
 &quot;parameter&quot;: {
 &quot;rsp_media_type&quot;: &quot;url&quot;
 },
 &quot;media_info_list&quot;: [
 {
 &quot;media_data&quot;: &quot;[https://object.pixocial.com/aibiz/C1A82EEB-BEC2-4418-8AA4-FBE5D47F1954_1781246302742.jpeg](https://object.pixocial.com/aibiz/C1A82EEB-BEC2-4418-8AA4-FBE5D47F1954_1781246302742.jpeg)&quot;,
 &quot;media_profiles&quot;: {
 &quot;media_data_type&quot;: &quot;url&quot;
 }
 }
 ]
}

[http://image-tools.pixocial.com](api/v1/image/body-glowing)
原始请求参数
{
 &quot;input&quot;: &quot;[https://object.pixocial.com/aibiz/e24cd6bd108642428649c595c3554464_1781246763685.jpg](https://object.pixocial.com/aibiz/e24cd6bd108642428649c595c3554464_1781246763685.jpg)&quot;,
 &quot;outputDir&quot;: &quot;&quot;,
 &quot;parameter&quot;: {
 &quot;glowingAlpha&quot;: 1,
 &quot;glowingType&quot;: 1
 }
}

算法请求参数
{
 &quot;parameter&quot;: {
 &quot;rsp_media_type&quot;: &quot;url&quot;,
 &quot;glowing_alpha&quot;: 1,
 &quot;glowing_type&quot;: 1
 },
 &quot;media_info_list&quot;: [
 {
 &quot;media_data&quot;: &quot;[https://object.pixocial.com/aibiz/e24cd6bd108642428649c595c3554464_1781246763685.jpg](https://object.pixocial.com/aibiz/e24cd6bd108642428649c595c3554464_1781246763685.jpg)&quot;,
 &quot;media_profiles&quot;: {
 &quot;media_data_type&quot;: &quot;url&quot;
 }
 }
 ]
}

### 四、影响范围/核对内容

| 确认点 | 具体内容 ||
| 影响范围 | 漂发
 ||
| 需要产品验收内容 | 无 ||
| 需要效果验收内容 | 无 ||