| 需求类型 | 事件来源 | 事件类型 | *事件id | *事件名称 | 参数 | 参数名称 | 参数类型 | 参数值类型 | 参数口径 | 参数值 | 参数值名称 | 参数值口径 | *统计口径 | 备注说明 | 事件分组 | 标签 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 影响事件 | 0 | 1 | popup_show | popup弹窗出现 | page_name | 弹窗出现的页面名称 | 普通参数 | string |  | sub | 订阅页 |  | popup弹窗出现时触发(不包括评分弹窗) |  |  |  |
| 新增事件参数值 | 0 | 1 | popup_show | popup弹窗出现 | pop_name | 弹窗name | 普通参数 | string |  | google_confirm | Google Play确认支付弹窗 |  | popup弹窗出现时触发(不包括评分弹窗) |  |  |  |
| 影响事件 | 0 | 1 | popup_click | 点击popup弹窗confirm  button | page_name | 弹窗出现的页面名称 | 普通参数 | string |  | sub | 订阅页 |  | 点击popup弹窗confirm  button触发 (不包括评分弹窗) | 点击「refresh status」时上报 |  |  |
| 新增事件参数值 | 0 | 1 | popup_click | 点击popup弹窗confirm  button | pop_name | 弹窗name | 普通参数 | string |  | google_confirm | Google Play确认支付弹窗 |  | 点击popup弹窗confirm  button触发 (不包括评分弹窗) | 点击「refresh status」时上报 |  |  |
| 新增事件参数值 | 0 | 1 | restore_purchase_click | 用户点击恢复购买 | type | 触发位置 | 普通参数 | string |  | google_confirm | Google Play确认支付弹窗 |  | 用户点击恢复购买时触发 |  |  |  |
| 新增事件参数值 | 0 | 1 | restore_purchase_success | 用户成功恢复购买 | type | 触发位置 | 普通参数 | string |  | google_confirm | Google Play确认支付弹窗 |  | 用户成功恢复购买时触发 |  |  |  |