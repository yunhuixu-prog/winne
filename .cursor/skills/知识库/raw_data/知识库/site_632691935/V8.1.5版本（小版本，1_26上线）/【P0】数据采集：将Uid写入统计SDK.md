# 【P0】数据采集：将Uid写入统计SDK

**页面ID**: 662843023

**路径**: V8.1.5版本（小版本，1_26上线）/【P0】数据采集：将Uid写入统计SDK

---

背景：目前AirBrush已经接入大账号，用户登录后统计SDK事件没有上报uid，无法对uid维度数据进行统计分析
需求：

- 应用每次启动/用户登录成功后，将uid写入到统计SDK中，作为系统参数上报
- 设置详情见：
- [https://cf.meitu.com/confluence/pages/viewpage.action?pageId=179666494#iOS%E7%BB%9F%E8%AE%A1SDK%E6%8E%A5%E5%85%A5%E6%B5%81%E7%A8%8B-%E8%AE%BE%E7%BD%AEUID](iOS - 统计SDK接入流程#设置UID) 对接人：黄贵阳
- [https://cf.meitu.com/confluence/pages/viewpage.action?pageId=186946291](Android-统计SDK接入指南) 对接人：黄卓寅