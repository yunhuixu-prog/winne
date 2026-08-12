| 需求类型 | 事件来源 | 事件类型 | *事件id | *事件名称 | 参数 | 参数名称 | 参数类型 | 参数值类型 | 参数口径 | 参数值 | 参数值名称 | 参数值口径 | *统计口径 | 备注说明 | 事件分组 | 标签 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 新增事件参数 | 0 | 1 | button_click | 按钮点击 | pic_num |  | 普通参数 | string | 图片张数 |  |  |  |  |  |  |  |
| 新增事件参数值 | 0 | 1 | button_click | 按钮点击 | name |  | 普通参数 | string |  | satrt |  | start按钮 |  |  |  |  |
| 新增事件参数值 | 0 | 1 | button_click | 按钮点击 | name |  | 普通参数 | string |  | batch |  | batch按钮 |  |  |  |  |
| 新增事件参数值 | 0 | 1 | button_click | 按钮点击 | name |  | 普通参数 | string |  | change_pic |  | 换图 |  |  |  |  |
| 新增事件参数 | 0 | 1 | second_func_save | 二级功能保存 | is_batch |  | 普通参数 | string | history报（编辑器里不报is batch） | 0 |  | 非批量产生 | 保存edit下的二级功能 | 埋点确认； second_func_use is_batch不报了 |  |  |
| 新增事件参数 | 0 | 1 | second_func_save | 二级功能保存 | is_batch |  | 普通参数 | string | history报（编辑器里不报is batch） | 1 |  | 批量产生 | 保存edit下的二级功能 | 埋点确认； second_func_use is_batch不报了 |  |  |
| 新增事件参数 | 0 | 1 | second_func_save | 二级功能保存 | is_batch |  | 普通参数 | string | history报（编辑器里不报is batch） | 2 |  | 批量&非批量 | 保存edit下的二级功能 | 埋点确认； second_func_use is_batch不报了 |  |  |
| 影响事件 | 0 | 1 | second_func_save | 二级功能保存 | second_func |  | 普通参数 | string | plump | ai_repair |  |  | 保存edit下的二级功能 | 埋点确认； second_func_use is_batch不报了 |  |  |
| 新增事件参数 | 0 | 1 | second_func_use | 二级功能打勾 | is_batch |  | 普通参数 | string | history报（编辑器里不报is batch） | 0 |  | 非批量产生 | 应用edit下的二级功能时触发 | 埋点确认； second_func_use is_batch不报了 |  |  |
| 新增事件参数 | 0 | 1 | second_func_use | 二级功能打勾 | is_batch |  | 普通参数 | string | history报（编辑器里不报is batch） | 1 |  | 批量产生 | 应用edit下的二级功能时触发 | 埋点确认； second_func_use is_batch不报了 |  |  |
| 新增事件参数 | 0 | 1 | second_func_use | 二级功能打勾 | is_batch |  | 普通参数 | string | history报（编辑器里不报is batch） | 2 |  | 批量&非批量 | 应用edit下的二级功能时触发 | 埋点确认； second_func_use is_batch不报了 |  |  |
| 影响事件 | 0 | 1 | second_func_use | 二级功能打勾 | second_func | 二级功能参数 | 普通参数 | string | 功能名 | ai_repair |  |  | 应用edit下的二级功能时触发 | 埋点确认； second_func_use is_batch不报了 |  |  |
| 影响事件 | 0 | 1 | ai_func_delivery | 请求ai算法 | second_func | 二级功能参数 | 普通参数 | string |  | ai_repair |  |  | 请求（是否拦截）的时候上报（缓存不报） |  |  |  |
| 影响事件 | 0 | 1 | ai_func_use_result | 使用ai算法请求结果返回 | second_func | 二级功能参数 | 普通参数 | string |  | ai_repair |  |  | 使用ai算法请求结果返回时触发 |  |  |  |