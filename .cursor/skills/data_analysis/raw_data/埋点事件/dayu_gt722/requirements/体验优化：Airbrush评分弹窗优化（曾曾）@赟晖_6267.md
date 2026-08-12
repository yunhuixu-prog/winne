| 需求类型 | 事件来源 | 事件类型 | *事件id | *事件名称 | 参数 | 参数名称 | 参数类型 | 参数值类型 | 参数口径 | 参数值 | 参数值名称 | 参数值口径 | *统计口径 | 备注说明 | 事件分组 | 标签 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 新增事件参数 | 0 | 1 | score_popup_click | 提交评分弹窗分数 | button_type | 点击按钮 | 普通参数 | string | 点击评分弹窗时上报 | yes | 点击「Yes, go and rate」 |  | 点击评分弹窗触发 |  |  |  |
| 新增事件参数 | 0 | 1 | score_popup_click | 提交评分弹窗分数 | button_type | 点击按钮 | 普通参数 | string | 点击评分弹窗时上报 | no | 点击「No, I'm not satisfied」 |  | 点击评分弹窗触发 |  |  |  |
| 新增事件参数 | 0 | 1 | score_popup_click | 提交评分弹窗分数 | content | 具体不满意configid | 普通参数 | string | 点击「No, I'm not satisfied」后触发弹窗点击confirm时上报，选择多个用逗号隔开 |  |  |  | 点击评分弹窗触发 |  |  |  |
| 新增事件参数 | 0 | 1 | score_popup_click | 提交评分弹窗分数 | content_other | 具体不满意-other的自定义内容 | 普通参数 | string | 点击「No, I'm not satisfied」后触发弹窗提交自定义内容时上报 |  |  |  | 点击评分弹窗触发 |  |  |  |
| 影响事件 | 0 | 1 | score_popup_show | 评分弹窗出现 |  |  |  |  |  |  |  |  | 评分弹窗出现时触发 |  |  |  |