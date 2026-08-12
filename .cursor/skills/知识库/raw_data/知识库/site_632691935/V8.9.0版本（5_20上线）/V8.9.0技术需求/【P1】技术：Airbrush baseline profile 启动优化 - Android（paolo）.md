# 【P1】技术：Airbrush baseline profile 启动优化 - Android（paolo）

**页面ID**: 689986290

**路径**: V8.9.0版本（5_20上线）/V8.9.0技术需求/【P1】技术：Airbrush baseline profile 启动优化 - Android（paolo）

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
1、为优化应用启动速度，降低启动anr发生率，接入 omnibus Baseline Profile 启动优化。

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

- ****引入****profileinstaller，ci平台生成 baseline profile
- ****
- 升级 支持 bundle 和apk 同时 ci构建
- 移除无用的firebase anr和crash监控，目前已迁至灵问监控。

**验证：**
普通安装包：
1. 下载 apk 包 
2. 第一次安装 apk 包，点击同意隐私协议
adb install xxx.apk
3. 第二次安装 apk 包 (模拟覆盖安装)
adb install xxx.apk
4. 启动 app ，查看 application 耗时
------------------------
安装优化包：
1. 下载 apk 包 
2. 第一次安装 apk 包，点击同意隐私协议
adb install xxx.apk
3. 第二次安装 apk 包, 使用 install-dm 模拟谷歌 baseline 安装逻辑.
1) 下载 dm 文件
 1. "扩展资源" 对话框中下载 dm.zip
 2. 解压 dm.zip
 3. **不同Android系统版本使用不同的 dm 文件：**
 31+ : 0/[http://base.dm/](base.dm)
 28 ~ 30 : 1/[http://base.dm/](base.dm)
2) **改名 xxx.apk 为 base.apk, 需要与 [http://base.dm/](base.dm) 文件同名**
adb install-multiple base.apk [http://base.dm/](base.dm)
3) 确认是否达到 install-dm 
 执行指令：
 adb shell pm dump com.magicv.airbrush | grep -C 10 &quot;Dexopt state&quot; 
 得到结果，判断 reason 是否是 install-dm, 并且 base.odex 大于 普通安装包的 大小
 [com.magicv.airbrush]
 path: /data/app/com.magicv.airbrush-vJtm3Q_LK-wZJGaxNKXGLg==/base.apk
 arm64: [status=speed-profile] [reason=install-dm]
 odex file size: base.art: 2988Kb base.odex: 10903Kb base.vdex: 49208Kb 

### 四、影响范围/核对内容

| 确认点 | 具体内容 ||
| 影响范围 | 启动速度，验证profile应用成功，本地测试实际优化数据
 ||
| 需要产品验收内容 | 无 ||
| 需要效果验收内容 | 无 ||