# 20250918【AB】新用户onboarding订阅页优化实验&未订阅用户升级订阅页优化实验

**页面ID**: 616745613

---

# 一、背景
1、需求文档： [https://pixocial.feishu.cn/docx/PBPudRyeNoVRrcxQRkJcLcFwnXg](AirBrush新用户onboarding订阅页优化) [https://pixocial.feishu.cn/docx/UuMzdls9AopNfkxdoM6c01D5nCc](AirBrush未订阅用户升级订阅页优化)
需求内容：新用户onboarding订阅页及老用户升级订阅页优化

| 实验 | 版本 | 内容 | 图片展示 | 实验流量 ||
| 新用户onboarding订阅页优化 | 对照组 | 线上Onboarding订阅页

 | 
 | 50% ||
| 实验组 | Onboarding订阅页：
1.精简权益文案，由4条优化为3条，并突出权益关键词
2.订阅按钮突出关键信息：7天试用
3.上新/热门功能推荐
4.年价格/其他细节信息重新进行页面布局优化
 | 
 | 50% ||
| 老用户升级订阅页优化 | 对照组 | 线上老用户升级订阅页

 | 
 | 50% ||
| 实验组 | 老用户升级订阅页替换为onboarding订阅页方案
 | 
 | 50% ||

实验周期8/22 - 老用户升级订阅页优化实验9.16已停止，新用户onboarding于9.19日周五全量实验组
2、分析周期8/22-9/10
实验链接：
1）新用户onboarding订阅页优化实验
iOS：[https://data.int.pixocial.com/meepo/experiment/5374/result/status](https://data.int.pixocial.com/meepo/experiment/5374/result/status)
Android：[https://data.int.pixocial.com/meepo/experiment/5375/result/status](https://data.int.pixocial.com/meepo/experiment/5375/result/status)
2）老用户升级订阅页优化实验
iOS：[https://data.int.pixocial.com/meepo/experiment/5376/result/status](https://data.int.pixocial.com/meepo/experiment/5376/result/status)
Android：[https://data.int.pixocial.com/meepo/experiment/5377/result/status](https://data.int.pixocial.com/meepo/experiment/5377/result/status)

# 二、主要结论
新用户onboarding优化实验：onboarding订阅页优化带动更多用户订阅点击进而带动订阅成功人数显著上涨，订阅付费人数、订阅收入不显著上涨（经估算日均上涨$780）；但订阅人数上涨导致广告展示次数下降，广告收入显著下降（经估算日均仅下降$10）；其他活跃&保存指标无显著影响。建议**全量实验组**
经估算：**订阅收入上涨 0.64k美金/天，日均订阅收入涨幅 0.35%，预计带来全年收入上涨 23.39w美金**

| 结论 | 预估365天收入增量 | 预估365天新增收入增量 | 预估365天续费收入增量 ||
| iOS | $187,321 | $247,732 | $-60,411 ||
| Android | $46,610 | $43,273 | $3,337 ||
| All | $233,931 | $291,005 | $-57,074 ||

老用户升级订阅页优化实验：由于升级订阅页的页面变化较大，原先同时展示年月sku，现在仅展示年sku，极大削减了月订阅，也未能促进年订阅，导致升级订阅页点击人数下降，进而订阅人数、订阅付费人数、订阅收入均显著下降；其他活跃&保存&广告指标无显著影响。建议**关闭实验组**

# 三、数据详情

#### 1、P0指标（APP活跃度&保存&收入）

- 新用户onboarding优化实验：订阅人数显著上涨，订阅付费人数、订阅收入不显著上涨（经估算日均上涨$780）；广告收入显著下降，主要由于订阅人数上涨导致广告展示次数下降（经估算日均仅下降$10）；其他活跃&保存指标无显著影响
- 老用户升级订阅页优化实验：订阅人数、订阅付费人数、订阅收入均显著下降；其他活跃&保存&广告指标无显著影响

#### **2、P1指标（订阅指标拆解）**

- 新用户onboarding优化实验：onboarding订阅页优化带动更多用户订阅点击，进而带动订阅付费收入上涨
- 老用户升级订阅页优化实验：由于升级订阅页的页面变化较大，原先同时展示年月sku，现在仅展示年sku，极大削减了月订阅，也未能促进年订阅，导致升级订阅页点击人数下降，进而订阅付费人数、收入下降

# 一、背景
1、需求文档： [https://pixocial.feishu.cn/docx/PBPudRyeNoVRrcxQRkJcLcFwnXg](AirBrush新用户onboarding订阅页优化) [https://pixocial.feishu.cn/docx/UuMzdls9AopNfkxdoM6c01D5nCc](AirBrush未订阅用户升级订阅页优化)
需求内容：新用户onboarding订阅页及老用户升级订阅页优化

| 实验 | 版本 | 内容 | 图片展示 | 实验流量 ||
| 新用户onboarding订阅页优化 | 对照组 | 线上Onboarding订阅页

 | 
 | 50% ||
| 实验组 | Onboarding订阅页：
1.精简权益文案，由4条优化为3条，并突出权益关键词
2.订阅按钮突出关键信息：7天试用
3.上新/热门功能推荐
4.年价格/其他细节信息重新进行页面布局优化
 | 
 | 50% ||
| 老用户升级订阅页优化 | 对照组 | 线上老用户升级订阅页

 | 
 | 50% ||
| 实验组 | 老用户升级订阅页替换为onboarding订阅页方案
 | 
 | 50% ||

实验周期8/22 - 老用户升级订阅页优化实验9.16已停止，新用户onboarding于9.19日周五全量实验组
2、分析周期8/22-9/10
实验链接：
1）新用户onboarding订阅页优化实验
iOS：[https://data.int.pixocial.com/meepo/experiment/5374/result/status](https://data.int.pixocial.com/meepo/experiment/5374/result/status)
Android：[https://data.int.pixocial.com/meepo/experiment/5375/result/status](https://data.int.pixocial.com/meepo/experiment/5375/result/status)
2）老用户升级订阅页优化实验
iOS：[https://data.int.pixocial.com/meepo/experiment/5376/result/status](https://data.int.pixocial.com/meepo/experiment/5376/result/status)
Android：[https://data.int.pixocial.com/meepo/experiment/5377/result/status](https://data.int.pixocial.com/meepo/experiment/5377/result/status)

# 二、主要结论
新用户onboarding优化实验：onboarding订阅页优化带动更多用户订阅点击进而带动订阅成功人数显著上涨，订阅付费人数、订阅收入不显著上涨（经估算日均上涨$780）；但订阅人数上涨导致广告展示次数下降，广告收入显著下降（经估算日均仅下降$10）；其他活跃&保存指标无显著影响。建议**全量实验组**
老用户升级订阅页优化实验：由于升级订阅页的页面变化较大，原先同时展示年月sku，现在仅展示年sku，极大削减了月订阅，也未能促进年订阅，导致升级订阅页点击人数下降，进而订阅人数、订阅付费人数、订阅收入均显著下降；其他活跃&保存&广告指标无显著影响。建议**关闭实验组**

# 三、数据详情

#### 1、P0指标（APP活跃度&保存&收入）

- 新用户onboarding优化实验：订阅人数显著上涨，订阅付费人数、订阅收入不显著上涨（经估算日均上涨$780）；广告收入显著下降，主要由于订阅人数上涨导致广告展示次数下降（经估算日均仅下降$10）；其他活跃&保存指标无显著影响
- 老用户升级订阅页优化实验：订阅人数、订阅付费人数、订阅收入均显著下降；其他活跃&保存&广告指标无显著影响

#### **2、P1指标（订阅指标拆解）**

- 新用户onboarding优化实验：onboarding订阅页优化带动更多用户订阅点击，进而带动订阅付费收入上涨
- 老用户升级订阅页优化实验：由于升级订阅页的页面变化较大，原先同时展示年月sku，现在仅展示年sku，极大削减了月订阅，也未能促进年订阅，导致升级订阅页点击人数下降，进而订阅付费人数、收入下降