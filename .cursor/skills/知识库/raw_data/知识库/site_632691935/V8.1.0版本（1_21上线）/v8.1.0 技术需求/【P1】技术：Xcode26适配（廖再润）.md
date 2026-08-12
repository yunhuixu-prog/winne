# 【P1】技术：Xcode26适配（廖再润）

**页面ID**: 658401337

**路径**: V8.1.0版本（1_21上线）/v8.1.0 技术需求/【P1】技术：Xcode26适配（廖再润）

---

# 一、环境
macOS：15.6
Xcode：26.1.1、26.0、26.2
开发分支：feature/tjq/xcode26

外部参考文章：
[https://juejin.cn/column/7513818640602071090](https://juejin.cn/column/7513818640602071090)
[https://juejin.cn/post/7514562953383821346](https://juejin.cn/post/7514562953383821346)
[https://github.com/ktiays/GlassExplorer](https://github.com/ktiays/GlassExplorer)
内部参考文章：

# 二、适配工作

## 1、ALAssetsLibrary Swift库废弃

### （1）错误截图

### （2）原因
ALAssetsLibrary在iOS26后被废弃，无法在Swift文件中被引用（OC中目前不受影响）
Airbrush中目前存在古老的ALAssetsLibrary类扩展，这个文件在umbrella文件中被引用，导致会进入PIXABBase的Swift编译，从而报错。ABImageBeautyHelper中虽然import了该类扩展，但没有实际引用。

### （3）解决方案
移除该ALAssetsLibrary类扩展。

## 2、-ld_classic编译标志废弃

### （1）错误截图

### （2）原因
-ld_classic编译标志已被废弃
从"旧版链接器"切换到了"新链接器"，而新链接器有多项 **自动体积优化能力**。（参考自官方文档和Wink适配文档：）

| 优化能力 | 默认链接器 | -ld_classic（旧链接器） ||
| **Dead Code Stripping（无引用代码剔除）** | ✔ 完整支持 | ❌ 限制多、效果差 ||
| **LTO（Link Time Optimization）** | ✔ 支持 | ❌ 不支持 ||
| **Swift / ObjC Merge & De-dup** | ✔ 优化强 | ❌ 基本没有 ||
| **更好的段压缩（__TEXT,__DATA）** | ✔ | ❌ ||
| **符号去重（ICF &ndash; Identical Code Folding）** | ✔ | ❌ ||

### （3）解决方案
参考链接：[https://stackoverflow.com/questions/79766437/xcode26-compile-time-error-ld-assertion-failed](https://stackoverflow.com/questions/79766437/xcode26-compile-time-error-ld-assertion-failed)

移除项目中该标志

## 3、PIXABServiceBridge报错

### （1）错误截图

### （2）解决方案
这里提示找不到PIXABServiceBridge，且不受SWIFT_ENABLE_EXPLICIT_MODULES字段控制，只能移除。
import PIXABServiceBridge只在以下两个文件中找到，删除掉。

## 4、PIXImageEditBridge报错

### （1）错误截图
类似上面PIXABServiceBridge的情况，提示找不到PIXABImageEditBridge

### （2）原因
新版本新增了SWIFT_ENABLE_EXPLICIT_MODULES字段，启用该字段后，可以获得以下优化（参考自官方文档和Wink适配文档：）：

- 加快编译（显著减少 module loading）

- 减少不必要的模块依赖扫描

- 降低编译器内存占用与崩溃几率

- 强化依赖边界（必须显式 import）

- 避免隐式依赖污染

- 提升 CI / DevOps 构建效率

Airbrush实测开启后似乎编译速度无明显区别。

### （3）解决方案
如果关闭该字段，可以直接解决这个报错，但是不能享受到新编译优化加成。所以采用开启该字段，修改相关报错的方式。
首先先将代码中所有使用到import PIXABImageEditBridge的代码移除，然后将剩下找不到定义的类加入到PIXImageEdit.h文件中即可。

最根本的方式，是要底层库将对应的头文件添加到库的umbrella文件中，已经跟底层库同事反馈。

## 5、AdjustSigSdk编译报错

### （1）错误截图

### （2）解决方案
[https://github.com/adjust/adjust_signature_sdk/releases](https://github.com/adjust/adjust_signature_sdk/releases)
升级到v3.61.0

## 6、Release环境下PIXABVideoEdit编译报错

### （1）错误截图

### （2）原因
根据log定位到是这个地方init出现了问题。Swift6.2在Release的模式下，SIL发生了崩溃

### （3）解决方案
修改subItems的赋值方式，不进行多次赋值，而是借用局部变量

## 7、Xcode26.0 Release环境下PIXImageEdit编译报错

### （1）错误截图
大体同第六点相似，是在某些代码编译报错

### （2）原因
怀疑是Xcode26的bug，因为仅在这个版本出现，16.1和26.1.1都没出现。
具体是圈中代码无法编译器无法推断出类型。

### （3）解决方案
在后面加上as关键字

## 8、UI

### （1）错误截图
Tabbar：

UISwitch：

TableView圆角：

NavigationBar返回按钮（目前似乎只有Debug菜单使用到了）：

### （2）原因
iOS26苹果推广玻璃效果UI

### （3）解决方案
考虑到目前版本更新UI时间不够，先采用苹果提供的字段恢复成之前的UI

注意：这个字段苹果会在下个Xcode大版本放弃支持。已经拉群同产品设计告知

## 9、其他
列举一些在其他文档中有提到，但是适配过程中暂时没遇到的问题。方便后面遇到对应问题查阅。

### （1）相机异常
使用iPhone17 Pro Max测试，目前没遇到

### （2）模型无法下载
Airbrush目前模型内置，暂时无这个问题，后面模型放云端可能会有这个问题。参考，需要升级库。

### （3）本地 Release / Distribution 运行应用
参考，需要增加&quot;-Wl,-no_compact_unwind&quot;参数

# 三、升级前后对比

在Xcode26和Xcode16的Release和Debug环境均已编译通过。Xcode26采用的是Xcode26.0版本，Xcode16采用的是Xcode16.2版本。
Xcode16测试环境：[https://omnibus.meitu-int.com/apps/airbrush:ios/build/9526](https://omnibus.meitu-int.com/apps/airbrush:ios/build/9526)
Xcode16正式环境：[https://omnibus.meitu-int.com/apps/airbrush:ios/build/9527](https://omnibus.meitu-int.com/apps/airbrush:ios/build/9527)
Xcode16 App Store：[https://omnibus.meitu-int.com/apps/airbrush:ios/build/9528](https://omnibus.meitu-int.com/apps/airbrush:ios/build/9528)
Xcode26测试环境：[https://omnibus.meitu-int.com/apps/airbrush:ios/build/9529](https://omnibus.meitu-int.com/apps/airbrush:ios/build/9529)
Xcode26正式环境：[https://omnibus.meitu-int.com/apps/airbrush:ios/build/9532](https://omnibus.meitu-int.com/apps/airbrush:ios/build/9532)
Xcode26 App Store：[https://omnibus.meitu-int.com/apps/airbrush:ios/build/9531](https://omnibus.meitu-int.com/apps/airbrush:ios/build/9531)

## 1、包体积

### （1）测试环境

Xcode26打出来的测试环境开发包大概比Xcode16打出来的小0.6M左右

### （2）正式环境

Xcode26打出来的正式环境开发包大概比Xcode16打出来的小2.5M左右

### （3）App Store

Xcode26打出来的App Store正式包包大概比Xcode16打出来的小4.4M左右

## 2、编译时间
本地编译时，两者时间接近，无明显变化。

# 四、其他
2026.01.08合并最新代码及Xcode26.2编译测试通过

# 五、测试范围
1、UI（需要看下iOS26系统是否正常，最好也看下非iOS26系统）
2、相机（需要看下iPhone17系列是否正常，最好也看下其他机型）
3、编辑器基础功能（无法明确哪些功能一定要测）