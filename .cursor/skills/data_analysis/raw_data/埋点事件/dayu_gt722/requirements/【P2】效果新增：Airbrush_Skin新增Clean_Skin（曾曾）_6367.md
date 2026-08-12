| 需求类型 | 事件来源 | 事件类型 | *事件id | *事件名称 | 参数 | 参数名称 | 参数类型 | 参数值类型 | 参数口径 | 参数值 | 参数值名称 | 参数值口径 | *统计口径 | 备注说明 | 事件分组 | 标签 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 新增事件参数值 | 0 | 1 | third_func_save | 三级功能保存 | third_func |  | 普通参数 | string |  | clean_skin | Clean Skin | 点击的三级功能为Clean Skin | 三级功能保存时上报 |  |  |  |
| 影响事件 | 0 | 1 | third_func_save | 三级功能保存 | first_func |  | 普通参数 | string |  | retouch |  |  | 三级功能保存时上报 |  |  |  |
| 影响事件 | 0 | 1 | third_func_save | 三级功能保存 | second_func |  | 普通参数 | string |  | skin |  |  | 三级功能保存时上报 |  |  |  |
| 新增事件参数值 | 0 | 1 | third_func_enter | 点击三级功能页面 | third_func | 三级功能参数 | 普通参数 | string | auto是点一次报一次(因为每次点击auto应用状态有变化) | clean_skin | Clean Skin | 点击的三级功能为Clean Skin | 点击三级功能页面时上报 |  |  |  |
| 影响事件 | 0 | 1 | third_func_enter | 点击三级功能页面 | first_func | 一级功能参数 | 普通参数 | string |  | retouch |  |  | 点击三级功能页面时上报 |  |  |  |
| 影响事件 | 0 | 1 | third_func_enter | 点击三级功能页面 | second_func | 二级功能参数 | 普通参数 | string |  | skin |  |  | 点击三级功能页面时上报 |  |  |  |
| 新增事件参数值 | 0 | 1 | third_func_use | 三级功能使用 | third_func | 三级功能参数 | 普通参数 | string |  | clean_skin | Clean Skin | 点击的三级功能为Clean Skin | 三级功能使用时触发 |  |  |  |
| 影响事件 | 0 | 1 | third_func_use | 三级功能使用 | first_func | 一级功能参数 | 普通参数 | string |  | retouch |  |  | 三级功能使用时触发 |  |  |  |
| 影响事件 | 0 | 1 | third_func_use | 三级功能使用 | second_func | 二级功能参数 | 普通参数 | string |  | skin |  |  | 三级功能使用时触发 |  |  |  |
| 新增事件参数值 | 0 | 1 | third_func_exposure | 三级功能曝光 | third_func |  | 普通参数 | string | 子功能英文名 | clean_skin | Clean Skin | 点击的三级功能为Clean Skin | 三级功能曝光时上报 |  |  |  |
| 影响事件 | 0 | 1 | third_func_exposure | 三级功能曝光 | first_func |  | 普通参数 | string |  | retouch |  |  | 三级功能曝光时上报 |  |  |  |
| 影响事件 | 0 | 1 | third_func_exposure | 三级功能曝光 | second_func |  | 普通参数 | string |  | skin |  |  | 三级功能曝光时上报 |  |  |  |
| 新增事件参数值 | 0 | 1 | w_subscription_enter | 进入订阅页 | source_0 | 进入订阅页来源-0 | 普通参数 | string |  | f_clean_skin | Clean Skin | 从Clean Skin功能触发进入订阅页 | 成功订阅时上报成功付费时上报 |  |  |  |
| 影响事件 | 0 | 1 | w_subscription_enter | 进入订阅页 | source_module | 进入订阅页来源模块 | 普通参数 | string |  | p_edit |  |  | 成功订阅时上报成功付费时上报 |  |  |  |
| 新增事件参数值 | 0 | 1 | w_subscription_click | 订阅页点击订阅按钮 | source_0 | 进入订阅页来源-0 | 普通参数 | string |  | f_clean_skin | Clean Skin | 从Clean Skin功能触发进入订阅页 | 选中某个plan并点击订阅按钮时上报 |  |  |  |
| 影响事件 | 0 | 1 | w_subscription_click | 订阅页点击订阅按钮 | source_module | 进入订阅页来源模块 | 普通参数 | string |  | p_edit |  |  | 选中某个plan并点击订阅按钮时上报 |  |  |  |
| 新增事件参数值 | 0 | 1 | w_subscription_success | 订阅成功 | source_0 | 进入订阅页来源-0 | 普通参数 | string |  | f_clean_skin | Clean Skin | 从Clean Skin功能触发进入订阅页 | 进入订阅页时上报 |  |  |  |
| 影响事件 | 0 | 1 | w_subscription_success | 订阅成功 | source_module | 进入订阅页来源模块 | 普通参数 | string |  | p_edit |  |  | 进入订阅页时上报 |  |  |  |