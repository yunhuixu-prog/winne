# 20251024【AB】Hair 默认Tab变更实验分析

**页面ID**: 630771325

---

## 一、背景
1、实验需求：

| 版本 | 内容 | 实验流量 ||
| 对照组 | - 目前线上的方案，默认进入Hairstyles并不记忆
 | 33% ||
| 实验组A | - 默认进入时选中 Color tab，并按照用户的勾选记录进行记忆，下次进入时自动默认到上次打勾的选项；
 | 33% ||
| 实验组B | - 默认进入时始终选中 Color tab，不根据用户勾选记录进行记忆。 | 33% ||

实验周期：9/19～10/19
产品决策：全量实验组A
2、数据分析周期：

- 9/22～10/19

实验链接：

- Android：[https://data.int.pixocial.com/meepo/experiment/5400/result/status](https://data.int.pixocial.com/meepo/experiment/5400/result/status)
- iOS： [https://data.int.pixocial.com/meepo/experiment/5401/result/target](https://data.int.pixocial.com/meepo/experiment/5401/result/target)

## 二、主要结论
Android端指标均不显著，iOS除整体ARPU实验组显著外均不显著；实验组A和B 双端无显著负向表现，可根据业务需求全量

## 三、数据详情

### 3.1 主要指标
**Android端** 各项指标（留存、收入、行为）与对照组差异均不显著，默认进入 Color tab 的改动未对用户行为产生明显影响；
**iOS端** 在实验组A、B中 **整体收入ARPU显著提升**（A组+9.22%，B组+6.82%），其余指标变化不显著，该改动未影响用户留存或使用行为。
iOS实验组整体ARPU显著提升，但Hair收入未显著变化

- 显著性来源于样本波动或其他收入来源（非Hair），而不是功能逻辑带来的实际效果；整体收入的显著提升可能是**统计学意义上的波动**，而非真实业务改善

- 进入「Color」后，用户更有可能继续使用编辑器其他功能，带动收入增长

****

### 3.2 Top10订阅收入来源&Hair订阅来源

- 实验组A和B存在发型收入向发色转移，但是整体实验组的Hair收入对比对照组来说不显著
- Top10的收入来源中，过半来源有正向变化

*f_hairdye为发色

### 3.3 Hair子功能进入与保存
由于对照组默认选中 Hairstyles，实验组A和B默认选中 Color，进入有从 Hairstyles 转移到Color，同时由于入口流量的变化，Color 保存上涨（Android涨幅30～34%，iOS涨幅21%），Hairstyles 保存下降（双端降幅36%～38%）