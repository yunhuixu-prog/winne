# 【P1】技术：图片编辑器内runSync调用全面改造治理 -- 仅Android（paolo）

**页面ID**: 687585127

**路径**: V8.7.0版本（4_22上线 延至4_24）/v8.7.0技术需求/【P1】技术：图片编辑器内runSync调用全面改造治理 -- 仅Android（paolo）

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
1、随着接入image kit功能越来越多，图片编辑器内原 canUndo canRedo hasDoEffect 同步方法，在调用切换mtik实现后，都是最终走到runSync同步等待GL结果逻辑，导致主线程卡顿anr很多

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

- 全面排查改造接入功能runSync使用方式 ，彻底消除功能内主线程对runSync调用

- 在测试包中，开启监控编辑器内主线程runSync调用，触发崩溃，**强制**开发时注意

### 当前已接入ImageKit（MTIK）功能表

| 序号 | 产品能力 / 入口 | 使用的 MTIK 滤镜 | 主要接入类（挂链 / 业务） ||
| 1
 | 美型（面部重塑等，FaceFragment）
 | MTIKFaceReshapeFilter
 | FaceIMIKProcessor（FaceImageKitPresenter 内创建）
 ||
| 2
 | 质感大片 / 一键美颜类（BeautyMagicFragment）
 | MTIKMagicFilter
 | BMImageKitPresenter
 ||
| 3
 | 滤镜（NewFilterFragment、旧版 EditFilterFragment）
 | MTIKRealtimeFilter
 | EditFilterMTIKProcessor + EditFilterMTIKViewModel / MTIKManagerPool
 ||
| 4
 | 文字（TextFragmentV2 等）
 | MTIKTextFilter（可多实例）
 | TextEffectProcessor + EditTextViewModel
 ||
| 5
 | 裁剪 / 旋转 / 透视 / 编辑（CropFragment 等）
 | MTIKABEditFilter
 | AdjustEffectProcessor
 ||
| 6
 | AI 扩图（AIExpandFragment 等）
 | MTIKABEditFilter
 | AIExpandEffectProcessor
 ||
| 7
 | 调整（含局部涂抹，AdjustFragment）
 | MTIKAdjustFilter
 | AdjustMTIKEffectProcessor
 ||
| 8
 | 身体塑形（瘦腰、丰胸、多部位等）
 | MTIKRCBodyShapeFilter
 | BodyVBEffectProcessor &rarr; BodyFragmentVB / BodyFragmentVC、WaistFragment、BreastFragmentVB、BreastFineTuneFragmentVB 等共用
 ||
| 9
 | 增高 / 拉伸（StretchFragment）
 | MTIKRCBodyShapeFilter（独立实例）
 | HeightenEffectProcessor
 ||
| 10
 | 美肤 AB（实验 A/B）
 | MTIKSmoothSkinABFilter
 | BaseImageKitFragment：SmoothFragmentA、SmoothFragmentB + SmoothViewModel
 ||
| 11
 | 立体 / 苹果肌丰满
 | MTIKCheekFilter
 | BaseImageKitFragment：PlumpFragment
 ||
| 12
 | 橡皮擦（ImageKit 版）
 | MTIKEraserFilter
 | BaseImageKitFragment：EraserMtikFragment
 ||
| 13
 | AI 替换
 | MTIKAIReplaceFilter
 | PixEngineAIReplaceEffectProcessor &rarr; EditAIReplaceFragment
 ||
| 14
 | AI 精修
 | MTIKAIRetouchFilter
 | AIRetouchV2EffectProcessor &rarr; AIRetouchV2Fragment / AIRetouchV2ViewModel
 ||
| 15
 | AI 纹身（贴纸 + 文字素材）
 | MTIKStickerFilter、MTIKTextFilter
 | AiTattooViewModel（addFilter）&rarr; AITattooFragment、子页 AiTattooStickerAdjustFragment / AiTattooTextAdjustFragment
 ||

### 改造梳理表（非 BaseImageKitFragment）

| 功能/场景 | 涉及类 / 滤镜 | 调用的 MTIK API | 主线程风险说明 ||
| 裁剪 / 旋转 / 透视 / AI 扩图
 | CropFragment &rarr; AdjustEffectProcessor &rarr; MTIKABEditFilter
 | hasDoEffect()
 | mEditorViewModel.mCurrentEffectCallback 内直接调 
mAdjustEffectProcessor.hasEffect()；
hasEffect() 覆写等均在主线程读效果
 ||
| 增高（拉伸）保存前判断
 | StretchFragment &rarr; HeightenEffectProcessor &rarr; MTIKRCBodyShapeFilter
 | canUndo()
 | ok() 里同步 if (!mHeightenProcessor.canUndo())（对比条另有 canUndoMtikFilter 走 IO，与此处无关）
 ||
| 丰胸微调 / 与身体塑形共用的 BodyVBEffectProcessor
 | BreastFineTuneFragmentVB、BodyFragmentVB、NewBodyViewModel 等 &rarr; MTIKRCBodyShapeFilter
 | canUndo() / canRedo() / hasDoEffect()
 | BreastFineTuneFragmentVB 未实现 canUndoMtikFilter，对比条无参 updateState() 会回退到同步 canUndo()；BodyFragmentVB 等处 viewModel.hasEffect() 会进 hasDoEffect()（主线程赋值 oriStateEvent 等）
 ||
| AI 替换
 | EditAIReplaceFragment &rarr; PixEngineAIReplaceEffectProcessor &rarr; MTIKAIReplaceFilter
 | canUndo() / canRedo()
 | aiReplaceCanUndo() / aiReplaceCanRedo() 为同步封装；Fragment.canUndo()/canRedo() 覆写直接调上述方法
 ||
| AI 精修
 | AIRetouchV2ViewModel &rarr; AIRetouchV2EffectProcessor &rarr; MTIKAIRetouchFilter
 | canUndo() / canRedo() / hasDoEffect()（经 hasEffect()）
 | 对比条经 AIRetouchV2Fragment.canUndoMtikFilter 已在 IO；若业务直接调 ViewModel 的同步 canUndo() 等仍为主线程
 ||
| 调整（含局部涂抹栈）
 | AdjustFragment + AdjustViewModel &rarr; AdjustMTIKEffectProcessor &rarr; MTIKAdjustFilter
 | canUndoSmear() / canRedoSmear() 等（非 hasDoEffect，同属 MTIK 撤销栈查询）
 | canUndo()/canRedo() 在 hasEffect() 为真时会调 viewModel.canUndo()；对比条走 canUndoMtikFilter 时整段包在 IO，其它主线程同步调 Fragment.canUndo() 仍会命中 MTIK
 ||

### 四、影响范围/核对内容

| 确认点 | 具体内容 ||
| 影响范围 | 如上梳理表中，功能逻辑正常
 ||
| 需要产品验收内容 | 不影响交互，无 ||
| 需要效果验收内容 | 不影响效果，无 ||