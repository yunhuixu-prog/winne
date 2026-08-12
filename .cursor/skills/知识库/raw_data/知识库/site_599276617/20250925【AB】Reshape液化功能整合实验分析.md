# 20250925【AB】Reshape液化功能整合实验分析

**页面ID**: 619433149

---

## 一、背景
1、实验需求：resize移动到Reshape下作为子功能

| 版本 | 内容 | 实验流量 ||
| 对照组 | - 线上版本 | 50% ||
| 实验组 | - resize移动到Reshape下作为子功能
- 弹窗提示resize移动 | 50% ||

实验周期：9.9 - 9.30
2、数据分析周期：2025.9.9 - 2025.9.22
实验链接：

- Android：[https://data.int.pixocial.com/meepo/experiment/5393/result/status](https://data.int.pixocial.com/meepo/experiment/5393/result/status)
- iOS：[https://data.int.pixocial.com/meepo/experiment/5392/result/status](https://data.int.pixocial.com/meepo/experiment/5392/result/status)

## 二、主要结论
整体活跃、订阅和保存渗透率指标稳定，但是对于修改功能（resize）**入口可见性下降，**对双端（Resize&Reshape VS 实验组Reshape）订阅指标和Enter to Save转化率有负向影响，不建议全量

- **对照组Resize&Reshape VS 实验组Reshape情况**

- 进入渗透率下降：

- Android：28.49% &rarr; 28.03%（-1.63%）；iOS：37.19% &rarr; 36.74%（-1.23%） 入口合并后，整体进入 reshape 的用户比例略有下降，功能可发现性确实受到了一点影响。(实验组Reshape进入渗透率低于对照组代表实验组没有"承接住" resize转移的流量，（可能是路径更深，用户不愿意点了）)

- 保存渗透率下降：

- Android：20.35% &rarr; 19.89%（-2.25%）；iOS：28.04% &rarr; 27.60%（-1.55%） 保存的用户比例也随之下降，和"入口更深"一致。

- Enter to Save 转化率双端显著下降：
- Android 71.41% &rarr; 70.96%（-0.63%），iOS 75.37% &rarr; 75.13%（-0.32%）

- 订阅成功渗透率：
- Android：0.07% &rarr; 0.08%（+5.98%），上升；iOS：0.31% &rarr; 0.29%（-6.79%），显著下降。 

- 订阅转付费渗透率：
- Android：0.055% &rarr; 0.057% （+2.51%），稳定；iOS：0.21% &rarr; 0.19%（-8.41%）显著下降。

- 订阅ARPU
- Android：+$0.005 &rarr; $0.006（+18.29%）；iOS：$0.055 &rarr; $0.051（-7.18%） Android表现偏正向，iOS 偏负向

- 对照组Resize VS 实验组resize功能

- resize由于功能入口变深，实验组进入渗透率和保存渗透率下降(-33% ~ -15%)，enter to save转化率双端均有上升（10% ～ 18%）
- 留下来的用户更有"明确需求"（不是随便点进来的），所以保存的成功率更高，实验组的 Resize 功能"更精准，但更小众"

## 三、数据详情

### 1、整体
**对用户路径的影响有限**：将 resize 合并到 Reshape 没有导致用户保存率下降，也没让用户活跃留存、订阅转化有负面冲击。

### 2、对照组Reshape+Resize VS 实验组Reshape(resize)功能
对照组是reshape和resize,实验组是reshape,resize在rehape内部
**入口可见性下降**对双端有负向影响

#### 功能使用情况

- 进入渗透率下降：

- Android：28.49% &rarr; 28.03%（-1.63%）；iOS：37.19% &rarr; 36.74%（-1.23%） 入口合并后，整体进入 reshape 的用户比例略有下降，功能可发现性确实受到了一点影响。

- 保存渗透率下降：

- Android：20.35% &rarr; 19.89%（-2.25%）；iOS：28.04% &rarr; 27.60%（-1.55%） 保存的用户比例也随之下降，和"入口更深"一致。

- Enter to Save 转化率显著下降： Android 71.41% &rarr; 70.96%（-0.63%），iOS 75.37% &rarr; 75.13%（-0.32%）

- **人均保存次数**：略有增加（Android +1.5%，iOS +0.43%），留下来的用户用得比较深入。

#### 订阅相关

- 订阅成功渗透率：

- Android：0.07% &rarr; 0.08%（+5.98%），上升；iOS：0.31% &rarr; 0.29%（-6.79%），显著下降。 

- 转付费渗透率：

- Android：+2.51%（几乎没动）；iOS：-8.41%（显著下降）。

- 功能 ARPU：

- Android：+$0.005 &rarr; $0.006（+18.29%）；iOS：$0.055 &rarr; $0.051（-7.18%） Android表现偏正向，iOS 偏负向

#### 分新老

- iOS端显著负向的订阅指标和Enter to Save转化率新老表现一致，实验组均下降

### 3、对照组Resize VS 实验组resize功能

- resize由于功能入口变深，实验组进入渗透率和保存渗透率下降，enter to save转化率双端均有上升
- 留下来的用户更有"明确需求"（不是随便点进来的），所以保存的成功率更高，实验组的 Resize 功能"更精准，但更小众"