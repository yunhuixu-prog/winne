# Edit 排序优化 AB 实验需求复盘

**页面ID**: 709006187

**路径**: V8.6.0版本（4_8上线）/V8.6.0需求复盘/Edit 排序优化 AB 实验需求复盘

---

## **一、需求背景**
**需求来源：**[https://cf.meitu.com/confluence/pages/viewpage.action?pageId=673240798](【P1】AB实验：Airbrush Edit 排序优化 AB 实验（Jamie）)
**版本：**V8.6.0（4/8上线）
**背景：**
当前编辑器内 edit 模块的功能排序，主要依据历史版本的功能布局进行展示，但随着新 AI 功能的持续优化调整，各功能的用户满意度与进入结构已发生变化。从用户使用反馈及功能数据表现来看，部分 AI 功能在用户满意度与转化表现上具备较好的潜力，但由于当前排序位置靠后，整体曝光量不足，未能充分发挥其价值。
以 AI Repair 为例：用户对 AI Repair 的使用满意度处于第二梯队，但由于当前排序位置较后，功能曝光量相对较低，导致整体使用量未能达到预期水平。为验证功能排序调整是否能够提升高潜力功能的使用率与转化表现，本次实验对 edit 模块内部分功能顺序进行优化。

#### **实验调整内容**
**AAB实验信息：**

| 实验触发时机 | **进入 edit 时** ||
| 对照组 | 维持线上排序不变 ||
| 实验组B | **AI Repair 前移、与 AI Expand 位置交换**：Adjust、Crop、Eraser、Relight、AI Repair、Bokeh、Blur、AI Expand、AI Replace、Stamp、Prism ||
| 实验组BB | **5~9 位顺序重排幅度更大**：Adjust、Crop、Eraser、Relight、AI Repair、Blur、Bokeh、AI Replace、AI Expand、Stamp、Prism ||
| 共同调整 | 对照、实验组都做：移除 AI Expand 的 New 角标 ||
| 实验观察指标 | 模块的进入、打勾率、使用、订阅情况 ||
| 流量控制 | 对照组、实验组B、实验组BB 各 25% 流量 ||
| 测试周期 | 2 周（实际 4/7~4/27） ||

## **二、数据表现和分析**
**🔴结论：**

- **实验组B**：AI Repair 进入、打勾、保存、订阅渗透率均有可信的 10%~24% 上涨；AI Expand 对应指标有可信下跌，但整体功能订阅成功渗透率有可信提升；其余关注的核心指标无可信变化。
- **实验组BB**：edit Tab 下功能的保存渗透率可信下降 0.61%（25.08% 降至 24.92%）。

实验链接：[https://qiming-voyager.pixocial.com/experiment/11332/result/status](https://qiming-voyager.pixocial.com/experiment/11332/result/status)（4/7~4/27）

## **三、原因分析**

- **排序位置对功能曝光的作用得到验证**：AI Repair 前移后，进入、打勾、保存、订阅全链路可信上涨，验证了需求假设&mdash;&mdash;满意度处第二梯队的功能，此前确实因排序靠后被压制了曝光，位置前移即可释放其价值。
- **排序调整本质是曝光的再分配**：AI Repair 上涨的同时 AI Expand 对应下跌，位置交换是此消彼长的零和调整；但整体功能订阅成功渗透率有可信提升，说明把满意度与转化更高的功能往前放，总量上是正收益。
- **大幅重排有打乱用户习惯的风险**：实验组BB 重排幅度更大（Blur/Bokeh 互换、AI Expand 进一步后移），edit Tab 下功能保存渗透率反而可信下降 0.61%，推测打乱用户既有使用习惯的成本超过了曝光优化的收益，排序调整宜小步进行、逐次验证。

## **四、后续计划**

- 已全量「实验组B」方案。
- 删除实验代码：[https://cf.meitu.com/confluence/pages/viewpage.action?pageId=692609719](【P2】代码刪除：Airbrush Edit 排序优化 AAB 实验（Jamie）)。
- 后续排序优化沿用「小幅调整 + 数据验证」的节奏，可依据功能满意度与转化数据，继续将高潜力、排序靠后的功能作为下一批调整候选。