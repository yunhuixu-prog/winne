| 需求类型 | 事件来源 | 事件类型 | *事件id | *事件名称 | 参数 | 参数名称 | 参数类型 | 参数值类型 | 参数口径 | 参数值 | 参数值名称 | 参数值口径 | *统计口径 | 备注说明 | 事件分组 | 标签 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 影响事件 | 0 | 1 | second_func_use | 二级功能打勾 | first_func | 一级功能参数 | 普通参数 | string |  | edit |  |  | 应用edit下的二级功能时触发 |  |  |  |
| 影响事件 | 0 | 1 | second_func_use | 二级功能打勾 | second_func | 二级功能参数 | 普通参数 | string |  | adjust |  |  | 应用edit下的二级功能时触发 |  |  |  |
| 影响事件 | 0 | 1 | second_func_use | 二级功能打勾 | is_effect | 是否有应用任一效果 | 普通参数 | string |  | 0 |  |  | 应用edit下的二级功能时触发 |  |  |  |
| 影响事件 | 0 | 1 | second_func_use | 二级功能打勾 | is_effect | 是否有应用任一效果 | 普通参数 | string |  | 1 |  |  | 应用edit下的二级功能时触发 |  |  |  |
| 影响事件 | 0 | 1 | second_func_save | 二级功能保存 | first_func |  | 普通参数 | string |  | edit |  |  | 保存edit下的二级功能 |  |  |  |
| 影响事件 | 0 | 1 | second_func_save | 二级功能保存 | second_func |  | 普通参数 | string |  | adjust |  |  | 保存edit下的二级功能 |  |  |  |
| 影响事件 | 0 | 1 | second_func_save | 二级功能保存 | ai_auto | ai auto 使用结果情况 | 普通参数 | string |  |  |  |  | 保存edit下的二级功能 |  |  |  |
| 影响事件 | 0 | 1 | second_func_save | 二级功能保存 | adjust_selection | 应用的预设 | 普通参数 | string | 逗号分隔 |  |  |  | 保存edit下的二级功能 |  |  |  |
| 影响事件 | 0 | 1 | second_func_save | 二级功能保存 | flash | flash使用情况 | 普通参数 | string |  |  |  |  | 保存edit下的二级功能 |  |  |  |
| 影响事件 | 0 | 1 | second_func_save | 二级功能保存 | deglare | deglare使用情况 | 普通参数 | string |  |  |  |  | 保存edit下的二级功能 |  |  |  |
| 影响事件 | 0 | 1 | third_func_enter | 点击三级功能页面 | first_func | 一级功能参数 | 普通参数 | string |  | edit |  |  | 点击三级功能页面时上报 |  |  |  |
| 影响事件 | 0 | 1 | third_func_enter | 点击三级功能页面 | second_func | 二级功能参数 | 普通参数 | string |  | adjust |  |  | 点击三级功能页面时上报 |  |  |  |
| 影响事件 | 0 | 1 | third_func_enter | 点击三级功能页面 | third_func | 三级功能参数 | 普通参数 | string | auto是点一次报一次(因为每次点击auto应用状态有变化) |  |  |  | 点击三级功能页面时上报 |  |  |  |
| 影响事件 | 0 | 1 | third_func_enter | 点击三级功能页面 | third_func_order |  | 普通参数 | string |  |  |  |  | 点击三级功能页面时上报 |  |  |  |