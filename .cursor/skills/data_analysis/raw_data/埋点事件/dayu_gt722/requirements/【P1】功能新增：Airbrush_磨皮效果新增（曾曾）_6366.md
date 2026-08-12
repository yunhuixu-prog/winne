| 需求类型 | 事件来源 | 事件类型 | *事件id | *事件名称 | 参数 | 参数名称 | 参数类型 | 参数值类型 | 参数口径 | 参数值 | 参数值名称 | 参数值口径 | *统计口径 | 备注说明 | 事件分组 | 标签 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 新增事件参数值 | 0 | 1 | edit_save | 编辑保存 | prf_first_func | 一级功能参数 | 普通参数 | string | 多个分割, 一级、二级、三级功能一一对应 | retouch | Retouch | 保存时使用Retouch一级功能 | 结束编辑最终保存时触发 |  |  |  |
| 新增事件参数值 | 0 | 1 | edit_save | 编辑保存 | prf_second_func | 二级功能参数 | 普通参数 | string | 多个分割, 一级、二级、三级功能一一对应，若无对应二级功能该位置报 0 | skin | Skin | 保存时使用Skin二级功能 | 结束编辑最终保存时触发 |  |  |  |
| 新增事件参数值 | 0 | 1 | edit_save | 编辑保存 | prf_third_func | 三级功能参数 | 普通参数 | string | 只到waist | smooth | Smooth | 保存时使用Smooth磨皮功能 | 结束编辑最终保存时触发 |  |  |  |
| 新增事件参数值 | 0 | 1 | button_click | 按钮点击 | name |  | 普通参数 | string |  | nature |  |  | 按钮点击上报 |  |  |  |
| 新增事件参数值 | 0 | 1 | button_click | 按钮点击 | name |  | 普通参数 | string |  | classic |  |  | 按钮点击上报 |  |  |  |
| 新增事件参数值 | 0 | 1 | w_subscription_click | 订阅页点击订阅按钮 | source_0 | 进入订阅页来源-0 | 普通参数 | string |  | f_smooth |  |  | 选中某个plan并点击订阅按钮时上报 |  |  |  |
| 影响事件 | 0 | 1 | w_subscription_click | 订阅页点击订阅按钮 | source_module | 进入订阅页来源模块 | 普通参数 | string |  | p_edit |  |  | 选中某个plan并点击订阅按钮时上报 |  |  |  |
| 新增事件参数值 | 0 | 1 | w_subscription_enter | 进入订阅页 | source_0 | 进入订阅页来源-0 | 普通参数 | string |  | f_smooth |  |  | 成功订阅时上报成功付费时上报 |  |  |  |
| 影响事件 | 0 | 1 | w_subscription_enter | 进入订阅页 | source_module | 进入订阅页来源模块 | 普通参数 | string |  | p_edit |  |  | 成功订阅时上报成功付费时上报 |  |  |  |
| 新增事件参数值 | 0 | 1 | w_subscription_success | 订阅成功 | source_0 | 进入订阅页来源-0 | 普通参数 | string |  | f_smooth |  |  | 进入订阅页时上报 |  |  |  |
| 影响事件 | 0 | 1 | w_subscription_success | 订阅成功 | source_module | 进入订阅页来源模块 | 普通参数 | string |  | p_edit |  |  | 进入订阅页时上报 |  |  |  |
| 新增事件参数 | 0 | 1 | third_func_use | 三级功能使用 | classic_mod |  | 普通参数 | string | 滑杆调整数值 |  |  |  | 三级功能使用时触发 |  |  |  |
| 新增事件参数 | 0 | 1 | third_func_use | 三级功能使用 | nature_mod |  | 普通参数 | string | nature滑杆调整数值 |  |  |  | 三级功能使用时触发 |  |  |  |
| 新增事件参数 | 0 | 1 | third_func_save | 三级功能保存 | smooth_mode |  | 普通参数 | string | smooth保存情况 | classic |  |  | 三级功能保存时上报 |  |  |  |
| 新增事件参数 | 0 | 1 | third_func_save | 三级功能保存 | smooth_mode |  | 普通参数 | string | smooth保存情况 | nature |  |  | 三级功能保存时上报 |  |  |  |