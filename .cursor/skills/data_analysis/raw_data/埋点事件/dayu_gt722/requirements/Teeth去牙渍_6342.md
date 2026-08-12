| 需求类型 | 事件来源 | 事件类型 | *事件id | *事件名称 | 参数 | 参数名称 | 参数类型 | 参数值类型 | 参数口径 | 参数值 | 参数值名称 | 参数值口径 | *统计口径 | 备注说明 | 事件分组 | 标签 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 新增事件参数值 | 0 | 1 | edit_save | 编辑保存 | prf_third_func | 三级功能参数 | 普通参数 | string | 只到waist | stains |  |  | 结束编辑最终保存时触发 |  |  |  |
| 影响事件 | 0 | 1 | edit_save | 编辑保存 | prf_second_func | 二级功能参数 | 普通参数 | string | 多个分割, 一级、二级、三级功能一一对应，若无对应二级功能该位置报 0 | teeth |  |  | 结束编辑最终保存时触发 |  |  |  |
| 新增事件参数值 | 0 | 1 | second_func_save | 二级功能保存 | second_func |  | 普通参数 | string | plump | teeth |  |  | 保存edit下的二级功能 |  |  |  |
| 新增事件参数 | 0 | 1 | second_func_save | 二级功能保存 | teeth_selection |  | 普通参数 | string |  | align |  |  | 保存edit下的二级功能 |  |  |  |
| 新增事件参数 | 0 | 1 | second_func_save | 二级功能保存 | teeth_selection |  | 普通参数 | string |  | whiten |  |  | 保存edit下的二级功能 |  |  |  |
| 新增事件参数 | 0 | 1 | second_func_save | 二级功能保存 | teeth_selection |  | 普通参数 | string |  | stains |  |  | 保存edit下的二级功能 |  |  |  |
| 新增事件参数值 | 0 | 1 | second_func_use | 二级功能打勾 | second_func | 二级功能参数 | 普通参数 | string | 功能名 | teeth |  |  | 应用edit下的二级功能时触发 |  |  |  |
| 新增事件参数 | 0 | 1 | second_func_use | 二级功能打勾 | teeth_selection |  | 普通参数 | string |  | align |  |  | 应用edit下的二级功能时触发 |  |  |  |
| 新增事件参数 | 0 | 1 | second_func_use | 二级功能打勾 | teeth_selection |  | 普通参数 | string |  | whiten |  |  | 应用edit下的二级功能时触发 |  |  |  |
| 新增事件参数 | 0 | 1 | second_func_use | 二级功能打勾 | teeth_selection |  | 普通参数 | string |  | stains |  |  | 应用edit下的二级功能时触发 |  |  |  |
| 新增事件参数值 | 0 | 1 | third_func_enter | 点击三级功能页面 | third_func | 三级功能参数 | 普通参数 | string | auto是点一次报一次(因为每次点击auto应用状态有变化) | stains |  |  | 点击三级功能页面时上报 |  |  |  |
| 影响事件 | 0 | 1 | third_func_enter | 点击三级功能页面 | second_func | 二级功能参数 | 普通参数 | string |  | teeth |  |  | 点击三级功能页面时上报 |  |  |  |
| 影响事件 | 0 | 1 | third_func_enter | 点击三级功能页面 | third_func | 三级功能参数 | 普通参数 | string | auto是点一次报一次(因为每次点击auto应用状态有变化) | whiten |  |  | 点击三级功能页面时上报 |  |  |  |
| 影响事件 | 0 | 1 | third_func_enter | 点击三级功能页面 | third_func | 三级功能参数 | 普通参数 | string | auto是点一次报一次(因为每次点击auto应用状态有变化) | align |  |  | 点击三级功能页面时上报 |  |  |  |
| 新增事件参数值 | 0 | 1 | third_func_exposure | 三级功能曝光 | third_func |  | 普通参数 | string | 子功能英文名 | stains |  |  | 三级功能曝光时上报 |  |  |  |
| 影响事件 | 0 | 1 | third_func_exposure | 三级功能曝光 | second_func |  | 普通参数 | string |  | teeth |  |  | 三级功能曝光时上报 |  |  |  |
| 影响事件 | 0 | 1 | third_func_exposure | 三级功能曝光 | third_func |  | 普通参数 | string | 子功能英文名 | whiten |  |  | 三级功能曝光时上报 |  |  |  |
| 影响事件 | 0 | 1 | third_func_exposure | 三级功能曝光 | third_func |  | 普通参数 | string | 子功能英文名 | align |  |  | 三级功能曝光时上报 |  |  |  |
| 新增事件参数值 | 0 | 1 | third_func_save | 三级功能保存 | third_func |  | 普通参数 | string |  | stains |  |  | 三级功能保存时上报 |  |  |  |
| 影响事件 | 0 | 1 | third_func_save | 三级功能保存 | second_func |  | 普通参数 | string |  | teeth |  |  | 三级功能保存时上报 |  |  |  |
| 影响事件 | 0 | 1 | third_func_save | 三级功能保存 | third_func |  | 普通参数 | string |  | whiten |  |  | 三级功能保存时上报 |  |  |  |
| 影响事件 | 0 | 1 | third_func_save | 三级功能保存 | third_func |  | 普通参数 | string |  | align |  |  | 三级功能保存时上报 |  |  |  |
| 新增事件参数值 | 0 | 1 | third_func_use | 三级功能使用 | third_func | 三级功能参数 | 普通参数 | string |  | stains |  |  | 三级功能使用时触发 |  |  |  |
| 影响事件 | 0 | 1 | third_func_use | 三级功能使用 | second_func | 二级功能参数 | 普通参数 | string |  | teeth |  |  | 三级功能使用时触发 |  |  |  |
| 影响事件 | 0 | 1 | third_func_use | 三级功能使用 | third_func | 三级功能参数 | 普通参数 | string |  | whiten |  |  | 三级功能使用时触发 |  |  |  |
| 影响事件 | 0 | 1 | third_func_use | 三级功能使用 | third_func | 三级功能参数 | 普通参数 | string |  | align |  |  | 三级功能使用时触发 |  |  |  |
| 新增事件参数值 | 0 | 1 | w_subscription_click | 订阅页点击订阅按钮 | source_0 | 进入订阅页来源-0 | 普通参数 | string |  | f_teeth |  |  | 选中某个plan并点击订阅按钮时上报 |  |  |  |
| 新增事件参数值 | 0 | 1 | w_subscription_click | 订阅页点击订阅按钮 | source_1 | 进入订阅页来源-1 | 普通参数 | string |  | stains |  |  | 选中某个plan并点击订阅按钮时上报 |  |  |  |
| 新增事件参数值 | 0 | 1 | w_subscription_enter | 进入订阅页 | source_0 | 进入订阅页来源-0 | 普通参数 | string |  | f_teeth |  |  | 成功订阅时上报成功付费时上报 |  |  |  |
| 新增事件参数值 | 0 | 1 | w_subscription_enter | 进入订阅页 | source_1 | 进入订阅页来源-1 | 普通参数 | string |  | stains |  |  | 成功订阅时上报成功付费时上报 |  |  |  |
| 新增事件参数值 | 0 | 1 | w_subscription_success | 订阅成功 | source_0 | 进入订阅页来源-0 | 普通参数 | string |  | f_teeth |  |  | 进入订阅页时上报 |  |  |  |
| 新增事件参数值 | 0 | 1 | w_subscription_success | 订阅成功 | source_1 | 进入订阅页来源-1 | 普通参数 | string |  | stains |  |  | 进入订阅页时上报 |  |  |  |