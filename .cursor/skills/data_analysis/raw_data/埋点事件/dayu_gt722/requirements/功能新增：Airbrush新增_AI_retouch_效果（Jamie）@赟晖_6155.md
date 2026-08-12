| 需求类型 | 事件来源 | 事件类型 | *事件id | *事件名称 | 参数 | 参数名称 | 参数类型 | 参数值类型 | 参数口径 | 参数值 | 参数值名称 | 参数值口径 | *统计口径 | 备注说明 | 事件分组 | 标签 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 影响事件 | 0 | 1 | second_func_use | 二级功能打勾 | first_func | 一级功能参数 | 普通参数 | string |  | retouch |  |  | 应用edit下的二级功能时触发 |  |  |  |
| 影响事件 | 0 | 1 | second_func_use | 二级功能打勾 | second_func | 二级功能参数 | 普通参数 | string |  | ai_retouch |  |  | 应用edit下的二级功能时触发 |  |  |  |
| 影响事件 | 0 | 1 | second_func_use | 二级功能打勾 | is_effect | 是否有应用任一效果 | 普通参数 | string |  |  |  |  | 应用edit下的二级功能时触发 |  |  |  |
| 新增事件参数值 | 0 | 1 | second_func_use | 二级功能打勾 | material_name | 素材名称 | 普通参数 | string |  | chiselled |  |  | 应用edit下的二级功能时触发 |  |  |  |
| 新增事件参数值 | 0 | 1 | second_func_use | 二级功能打勾 | material_name | 素材名称 | 普通参数 | string |  | glowy |  |  | 应用edit下的二级功能时触发 |  |  |  |
| 新增事件参数 | 0 | 1 | second_func_use | 二级功能打勾 | by_value | 滑杆值 | 普通参数 | string |  | 0～100 |  |  | 应用edit下的二级功能时触发 |  |  |  |
| 影响事件 | 0 | 1 | second_func_save | 二级功能保存 | first_func |  | 普通参数 | string |  | retouch |  |  | 保存edit下的二级功能 |  |  |  |
| 影响事件 | 0 | 1 | second_func_save | 二级功能保存 | second_func |  | 普通参数 | string |  | ai_retouch |  |  | 保存edit下的二级功能 |  |  |  |
| 新增事件参数值 | 0 | 1 | second_func_save | 二级功能保存 | material_name | 素材名称 | 普通参数 | string |  | chiselled |  |  | 保存edit下的二级功能 |  |  |  |
| 新增事件参数值 | 0 | 1 | second_func_save | 二级功能保存 | material_name | 素材名称 | 普通参数 | string |  | glowy |  |  | 保存edit下的二级功能 |  |  |  |
| 影响事件 | 0 | 1 | ai_func_use_result | 使用ai算法请求结果返回 | first_func | 一级功能参数 | 普通参数 | string |  | retouch |  |  | 使用ai算法请求结果返回时触发 |  |  |  |
| 影响事件 | 0 | 1 | ai_func_use_result | 使用ai算法请求结果返回 | second_func | 二级功能参数 | 普通参数 | string |  | ai_retouch |  |  | 使用ai算法请求结果返回时触发 |  |  |  |
| 影响事件 | 0 | 1 | ai_func_use_result | 使用ai算法请求结果返回 | is_success | 应用效果(图片处理)是否成功 | 普通参数 | number |  |  |  |  | 使用ai算法请求结果返回时触发 |  |  |  |
| 影响事件 | 0 | 1 | ai_func_use_result | 使用ai算法请求结果返回 | time | 应用时长 | 普通参数 | number |  |  |  |  | 使用ai算法请求结果返回时触发 |  |  |  |
| 新增事件参数值 | 0 | 1 | ai_func_use_result | 使用ai算法请求结果返回 | material_name | 素材名称 | 普通参数 | string |  | chiselled |  |  | 使用ai算法请求结果返回时触发 |  |  |  |
| 新增事件参数值 | 0 | 1 | ai_func_use_result | 使用ai算法请求结果返回 | material_name | 素材名称 | 普通参数 | string |  | glowy |  |  | 使用ai算法请求结果返回时触发 |  |  |  |
| 影响事件 | 0 | 1 | ai_func_delivery | 请求ai算法 | first_func | 一级功能参数 | 普通参数 | string |  | retouch |  |  | 请求（是否拦截）的时候上报（缓存不报） |  |  |  |
| 新增事件参数值 | 0 | 1 | ai_func_delivery | 请求ai算法 | second_func | 二级功能参数 | 普通参数 | string |  | ai_retouch |  |  | 请求（是否拦截）的时候上报（缓存不报） |  |  |  |
| 新增事件参数 | 0 | 1 | ai_func_delivery | 请求ai算法 | material_name |  | 普通参数 | string |  | chiselled |  |  | 请求（是否拦截）的时候上报（缓存不报） |  |  |  |
| 新增事件参数 | 0 | 1 | ai_func_delivery | 请求ai算法 | material_name |  | 普通参数 | string |  | glowy |  |  | 请求（是否拦截）的时候上报（缓存不报） |  |  |  |
| 影响事件 | 0 | 1 | material_exposure | 素材曝光 | module | 模块 | 普通参数 | string |  | edit |  |  | 素材曝光时触发 |  |  |  |
| 影响事件 | 0 | 1 | material_exposure | 素材曝光 | material_type | 素材类型 | 普通参数 | string |  | ai_retouch |  |  | 素材曝光时触发 |  |  |  |
| 影响事件 | 0 | 1 | material_exposure | 素材曝光 | material_id | 素材id | 普通参数 | string |  |  |  |  | 素材曝光时触发 |  |  |  |
| 影响事件 | 0 | 1 | material_exposure | 素材曝光 | category_id | 分类id | 普通参数 | string |  |  |  |  | 素材曝光时触发 |  |  |  |
| 影响事件 | 0 | 1 | material_click | 素材点击 | module | 模块 | 普通参数 | string |  | edit |  |  | 素材点击时触发 |  |  |  |
| 影响事件 | 0 | 1 | material_click | 素材点击 | material_type | 素材类型 | 普通参数 | string |  | ai_retouch |  |  | 素材点击时触发 |  |  |  |
| 影响事件 | 0 | 1 | material_click | 素材点击 | material_id | 素材id | 普通参数 | string |  |  |  |  | 素材点击时触发 |  |  |  |
| 影响事件 | 0 | 1 | material_click | 素材点击 | category_id | 分类id | 普通参数 | string |  |  |  |  | 素材点击时触发 |  |  |  |
| 影响事件 | 0 | 1 | material_check | 素材打勾 | module | 模块 | 普通参数 | string |  | edit |  |  | 应用功能时触发 |  |  |  |
| 影响事件 | 0 | 1 | material_check | 素材打勾 | material_type | 素材类型 | 普通参数 | string |  | ai_retouch |  |  | 应用功能时触发 |  |  |  |
| 影响事件 | 0 | 1 | material_check | 素材打勾 | mids_material_id | 素材id | 普通参数 | string |  |  |  |  | 应用功能时触发 |  |  |  |
| 影响事件 | 0 | 1 | material_check | 素材打勾 | mids_category_id | 分类id | 普通参数 | string |  |  |  |  | 应用功能时触发 |  |  |  |
| 影响事件 | 0 | 1 | w_subscription_success | 订阅成功 | source_module | 进入订阅页来源模块 | 普通参数 | string | p_edit | p_edit |  |  | 进入订阅页时上报 |  |  |  |
| 影响事件 | 0 | 1 | w_subscription_success | 订阅成功 | source_0 | 进入订阅页来源-0 | 普通参数 | string | f_plump | f_ai_retouch |  |  | 进入订阅页时上报 |  |  |  |
| 影响事件 | 0 | 1 | w_subscription_success | 订阅成功 | mids_material_id | 素材id | 普通参数 | string |  |  |  |  | 进入订阅页时上报 |  |  |  |
| 影响事件 | 0 | 1 | w_subscription_success | 订阅成功 | mids_category_id | 分类id | 普通参数 | string |  |  |  |  | 进入订阅页时上报 |  |  |  |
| 影响事件 | 0 | 1 | w_subscription_click | 订阅页点击订阅按钮 | source_module | 进入订阅页来源模块 | 普通参数 | string |  | p_edit |  |  | 选中某个plan并点击订阅按钮时上报 |  |  |  |
| 影响事件 | 0 | 1 | w_subscription_click | 订阅页点击订阅按钮 | source_0 | 进入订阅页来源-0 | 普通参数 | string |  | f_ai_retouch |  |  | 选中某个plan并点击订阅按钮时上报 |  |  |  |
| 影响事件 | 0 | 1 | w_subscription_click | 订阅页点击订阅按钮 | mids_material_id | 素材id | 普通参数 | string |  |  |  |  | 选中某个plan并点击订阅按钮时上报 |  |  |  |
| 影响事件 | 0 | 1 | w_subscription_click | 订阅页点击订阅按钮 | mids_category_id | 分类id | 普通参数 | string |  |  |  |  | 选中某个plan并点击订阅按钮时上报 |  |  |  |
| 影响事件 | 0 | 1 | w_subscription_enter | 进入订阅页 | source_module | 进入订阅页来源模块 | 普通参数 | string |  | p_edit |  |  | 成功订阅时上报成功付费时上报 |  |  |  |
| 影响事件 | 0 | 1 | w_subscription_enter | 进入订阅页 | source_0 | 进入订阅页来源-0 | 普通参数 | string |  | f_ai_retouch |  |  | 成功订阅时上报成功付费时上报 |  |  |  |
| 影响事件 | 0 | 1 | w_subscription_enter | 进入订阅页 | mids_material_id | 素材id | 普通参数 | string |  |  |  |  | 成功订阅时上报成功付费时上报 |  |  |  |
| 影响事件 | 0 | 1 | w_subscription_enter | 进入订阅页 | mids_category_id | 分类id | 普通参数 | string |  |  |  |  | 成功订阅时上报成功付费时上报 |  |  |  |
| 影响事件 | 0 | 1 | popup_show | popup弹窗出现 | pop_id | 弹窗id | 普通参数 | string |  |  |  |  | popup弹窗出现时触发(不包括评分弹窗) |  |  |  |
| 影响事件 | 0 | 1 | popup_show | popup弹窗出现 | pop_name | 弹窗name | 普通参数 | string |  | no_free_delivery_popup |  |  | popup弹窗出现时触发(不包括评分弹窗) |  |  |  |
| 影响事件 | 0 | 1 | popup_show | popup弹窗出现 | page_name | 弹窗出现的页面名称 | 普通参数 | string |  | edit |  |  | popup弹窗出现时触发(不包括评分弹窗) |  |  |  |
| 影响事件 | 0 | 1 | popup_show | popup弹窗出现 | first_func | 一级功能参数 | 普通参数 | string |  | retouch |  |  | popup弹窗出现时触发(不包括评分弹窗) |  |  |  |
| 新增事件参数值 | 0 | 1 | popup_show | popup弹窗出现 | second_func | 二级功能参数 | 普通参数 | string |  | ai_retouch |  |  | popup弹窗出现时触发(不包括评分弹窗) |  |  |  |
| 影响事件 | 0 | 1 | popup_click | 点击popup弹窗confirm  button | pop_id | 弹窗id | 普通参数 | string |  |  |  |  | 点击popup弹窗confirm  button触发 (不包括评分弹窗) |  |  |  |
| 影响事件 | 0 | 1 | popup_click | 点击popup弹窗confirm  button | pop_name | 弹窗name | 普通参数 | string |  | no_free_delivery_popup |  |  | 点击popup弹窗confirm  button触发 (不包括评分弹窗) |  |  |  |
| 影响事件 | 0 | 1 | popup_click | 点击popup弹窗confirm  button | page_name | 弹窗出现的页面名称 | 普通参数 | string |  | edit |  |  | 点击popup弹窗confirm  button触发 (不包括评分弹窗) |  |  |  |
| 影响事件 | 0 | 1 | popup_click | 点击popup弹窗confirm  button | first_func | 一级功能参数 | 普通参数 | string |  | retouch |  |  | 点击popup弹窗confirm  button触发 (不包括评分弹窗) |  |  |  |
| 新增事件参数值 | 0 | 1 | popup_click | 点击popup弹窗confirm  button | second_func | 二级功能参数 | 普通参数 | string |  | ai_retouch |  |  | 点击popup弹窗confirm  button触发 (不包括评分弹窗) |  |  |  |