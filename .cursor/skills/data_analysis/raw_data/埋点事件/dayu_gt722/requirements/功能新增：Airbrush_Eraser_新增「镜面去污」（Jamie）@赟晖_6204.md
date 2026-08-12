| 需求类型 | 事件来源 | 事件类型 | *事件id | *事件名称 | 参数 | 参数名称 | 参数类型 | 参数值类型 | 参数口径 | 参数值 | 参数值名称 | 参数值口径 | *统计口径 | 备注说明 | 事件分组 | 标签 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 影响事件 | 0 | 1 | second_func_use | 二级功能打勾 | first_func | 一级功能参数 | 普通参数 | string |  | edit |  |  | 应用edit下的二级功能时触发 |  |  |  |
| 影响事件 | 0 | 1 | second_func_use | 二级功能打勾 | second_func | 二级功能参数 | 普通参数 | string |  | eraser |  |  | 应用edit下的二级功能时触发 |  |  |  |
| 影响事件 | 0 | 1 | second_func_use | 二级功能打勾 | is_ai_eraser | AI Eraser使用情况 | 普通参数 | string |  |  |  |  | 应用edit下的二级功能时触发 |  |  |  |
| 影响事件 | 0 | 1 | second_func_use | 二级功能打勾 | is_passersby | Passersby使用情况 | 普通参数 | string |  |  |  |  | 应用edit下的二级功能时触发 |  |  |  |
| 影响事件 | 0 | 1 | second_func_use | 二级功能打勾 | is_spot_remover | Spot Remover使用情况 | 普通参数 | string |  |  |  |  | 应用edit下的二级功能时触发 |  |  |  |
| 影响事件 | 0 | 1 | second_func_use | 二级功能打勾 | adjust_count | 涂抹次数 | 普通参数 | string | ai_bru:xx;ai_era:xx;spot:xx;pass_bru:xx;pass_era:xx;mirror:xx |  |  |  | 应用edit下的二级功能时触发 |  |  |  |
| 新增事件参数 | 0 | 1 | second_func_use | 二级功能打勾 | is_mirror_stains |  | 普通参数 | string |  | 0 |  | 未使用 | 应用edit下的二级功能时触发 |  |  |  |
| 新增事件参数 | 0 | 1 | second_func_use | 二级功能打勾 | is_mirror_stains |  | 普通参数 | string |  | 1 |  | 已使用 | 应用edit下的二级功能时触发 |  |  |  |
| 影响事件 | 0 | 1 | second_func_save | 二级功能保存 | first_func |  | 普通参数 | string |  | edit |  |  | 保存edit下的二级功能 |  |  |  |
| 影响事件 | 0 | 1 | second_func_save | 二级功能保存 | second_func |  | 普通参数 | string |  | eraser |  |  | 保存edit下的二级功能 |  |  |  |
| 影响事件 | 0 | 1 | second_func_save | 二级功能保存 | is_ai_eraser | AI Eraser使用情况 | 普通参数 | string |  |  |  |  | 保存edit下的二级功能 |  |  |  |
| 影响事件 | 0 | 1 | second_func_save | 二级功能保存 | is_passersby | Passersby使用情况 | 普通参数 | string |  |  |  |  | 保存edit下的二级功能 |  |  |  |
| 影响事件 | 0 | 1 | second_func_save | 二级功能保存 | is_spot_remover | Spot Remover使用情况 | 普通参数 | string |  |  |  |  | 保存edit下的二级功能 |  |  |  |
| 新增事件参数 | 0 | 1 | second_func_save | 二级功能保存 | is_mirror_stains |  | 普通参数 | string |  | 0 |  | 未使用 | 保存edit下的二级功能 |  |  |  |
| 新增事件参数 | 0 | 1 | second_func_save | 二级功能保存 | is_mirror_stains |  | 普通参数 | string |  | 1 |  | 已使用 | 保存edit下的二级功能 |  |  |  |
| 影响事件 | 0 | 1 | ai_func_use_result | 使用ai算法请求结果返回 | first_func | 一级功能参数 | 普通参数 | string |  | edit |  |  | 使用ai算法请求结果返回时触发 |  |  |  |
| 影响事件 | 0 | 1 | ai_func_use_result | 使用ai算法请求结果返回 | second_func | 二级功能参数 | 普通参数 | string |  | ai_eraser |  |  | 使用ai算法请求结果返回时触发 |  |  |  |
| 影响事件 | 0 | 1 | ai_func_use_result | 使用ai算法请求结果返回 | second_func | 二级功能参数 | 普通参数 | string |  | passersby |  |  | 使用ai算法请求结果返回时触发 |  |  |  |
| 影响事件 | 0 | 1 | ai_func_use_result | 使用ai算法请求结果返回 | second_func | 二级功能参数 | 普通参数 | string |  | identify_passersby |  |  | 使用ai算法请求结果返回时触发 |  |  |  |
| 影响事件 | 0 | 1 | ai_func_use_result | 使用ai算法请求结果返回 | is_success | 应用效果(图片处理)是否成功 | 普通参数 | number |  |  |  |  | 使用ai算法请求结果返回时触发 |  |  |  |
| 影响事件 | 0 | 1 | ai_func_use_result | 使用ai算法请求结果返回 | time | 应用时长 | 普通参数 | number |  |  |  |  | 使用ai算法请求结果返回时触发 |  |  |  |
| 新增事件参数值 | 0 | 1 | ai_func_use_result | 使用ai算法请求结果返回 | second_func | 二级功能参数 | 普通参数 | string |  | mirror_stains |  |  | 使用ai算法请求结果返回时触发 |  |  |  |
| 影响事件 | 0 | 1 | ai_func_delivery | 请求ai算法 | first_func | 一级功能参数 | 普通参数 | string |  | edit |  |  | 请求（是否拦截）的时候上报（缓存不报） |  |  |  |
| 新增事件参数值 | 0 | 1 | ai_func_delivery | 请求ai算法 | second_func | 二级功能参数 | 普通参数 | string |  | mirror_stains |  |  | 请求（是否拦截）的时候上报（缓存不报） |  |  |  |
| 影响事件 | 0 | 1 | cloudfilter_per_show | 图片云处理权限弹窗点击 | port |  | 普通参数 | string |  | app |  |  |  |  |  |  |
| 新增事件参数值 | 0 | 1 | cloudfilter_per_show | 图片云处理权限弹窗点击 | function | 功能 | 普通参数 | string |  | eraser_mirror_stains |  |  |  |  |  |  |
| 影响事件 | 0 | 1 | cloudfilter_per_show_ok | 图片云处理权限弹窗点击 | port |  | 普通参数 | string |  | app |  |  |  |  |  |  |
| 影响事件 | 0 | 1 | cloudfilter_per_show_ok | 图片云处理权限弹窗点击 | type |  | 普通参数 | string |  | cancel |  |  |  |  |  |  |
| 影响事件 | 0 | 1 | cloudfilter_per_show_ok | 图片云处理权限弹窗点击 | type |  | 普通参数 | string |  | agree |  |  |  |  |  |  |
| 新增事件参数值 | 0 | 1 | cloudfilter_per_show_ok | 图片云处理权限弹窗点击 | function |  | 普通参数 | string |  | eraser_mirror_stains |  |  |  |  |  |  |
| 影响事件 | 0 | 1 | popup_show | popup弹窗出现 | pop_id | 弹窗id | 普通参数 | string |  |  |  |  | popup弹窗出现时触发(不包括评分弹窗) |  |  |  |
| 影响事件 | 0 | 1 | popup_show | popup弹窗出现 | page_name | 弹窗出现的页面名称 | 普通参数 | string |  | edit |  |  | popup弹窗出现时触发(不包括评分弹窗) |  |  |  |
| 新增事件参数值 | 0 | 1 | popup_show | popup弹窗出现 | pop_name | 弹窗name | 普通参数 | string |  | eraser_mirror_run_again |  | 再次点击mirror stains弹出「确认再次执行弹窗」 | popup弹窗出现时触发(不包括评分弹窗) |  |  |  |
| 影响事件 | 0 | 1 | popup_click | 点击popup弹窗confirm  button | pop_id | 弹窗id | 普通参数 | string |  |  |  |  | 点击popup弹窗confirm  button触发 (不包括评分弹窗) |  |  |  |
| 影响事件 | 0 | 1 | popup_click | 点击popup弹窗confirm  button | page_name | 弹窗出现的页面名称 | 普通参数 | string |  | edit |  |  | 点击popup弹窗confirm  button触发 (不包括评分弹窗) |  |  |  |
| 新增事件参数值 | 0 | 1 | popup_click | 点击popup弹窗confirm  button | pop_name | 弹窗name | 普通参数 | string |  | eraser_mirror_run_again |  | 再次点击mirror stains弹出「确认再次执行弹窗」 | 点击popup弹窗confirm  button触发 (不包括评分弹窗) |  |  |  |
| 影响事件 | 0 | 1 | w_subscription_enter | 进入订阅页 | source_module | 进入订阅页来源模块 | 普通参数 | string |  | p_edit |  |  | 成功订阅时上报成功付费时上报 |  |  |  |
| 影响事件 | 0 | 1 | w_subscription_enter | 进入订阅页 | source_0 | 进入订阅页来源-0 | 普通参数 | string |  | f_eraser |  |  | 成功订阅时上报成功付费时上报 |  |  |  |
| 影响事件 | 0 | 1 | w_subscription_enter | 进入订阅页 | source_1 | 进入订阅页来源-1 | 普通参数 | string |  | ai |  |  | 成功订阅时上报成功付费时上报 |  |  |  |
| 影响事件 | 0 | 1 | w_subscription_enter | 进入订阅页 | source_1 | 进入订阅页来源-1 | 普通参数 | string |  | classic |  |  | 成功订阅时上报成功付费时上报 |  |  |  |
| 影响事件 | 0 | 1 | w_subscription_enter | 进入订阅页 | source_1 | 进入订阅页来源-1 | 普通参数 | string |  | passersby |  |  | 成功订阅时上报成功付费时上报 |  |  |  |
| 新增事件参数值 | 0 | 1 | w_subscription_enter | 进入订阅页 | source_1 | 进入订阅页来源-1 | 普通参数 | string |  | mirror |  |  | 成功订阅时上报成功付费时上报 |  |  |  |
| 影响事件 | 0 | 1 | w_subscription_click | 订阅页点击订阅按钮 | source_module | 进入订阅页来源模块 | 普通参数 | string |  | p_edit |  |  | 选中某个plan并点击订阅按钮时上报 |  |  |  |
| 影响事件 | 0 | 1 | w_subscription_click | 订阅页点击订阅按钮 | source_0 | 进入订阅页来源-0 | 普通参数 | string |  | f_eraser |  |  | 选中某个plan并点击订阅按钮时上报 |  |  |  |
| 影响事件 | 0 | 1 | w_subscription_click | 订阅页点击订阅按钮 | source_1 | 进入订阅页来源-1 | 普通参数 | string | beach_day,indigo,soft_glow,sunlit | ai |  |  | 选中某个plan并点击订阅按钮时上报 |  |  |  |
| 影响事件 | 0 | 1 | w_subscription_click | 订阅页点击订阅按钮 | source_1 | 进入订阅页来源-1 | 普通参数 | string | beach_day,indigo,soft_glow,sunlit | classic |  |  | 选中某个plan并点击订阅按钮时上报 |  |  |  |
| 影响事件 | 0 | 1 | w_subscription_click | 订阅页点击订阅按钮 | source_1 | 进入订阅页来源-1 | 普通参数 | string | beach_day,indigo,soft_glow,sunlit | passersby |  |  | 选中某个plan并点击订阅按钮时上报 |  |  |  |
| 新增事件参数值 | 0 | 1 | w_subscription_click | 订阅页点击订阅按钮 | source_1 | 进入订阅页来源-1 | 普通参数 | string | beach_day,indigo,soft_glow,sunlit | mirror |  |  | 选中某个plan并点击订阅按钮时上报 |  |  |  |
| 影响事件 | 0 | 1 | w_subscription_success | 订阅成功 | source_module | 进入订阅页来源模块 | 普通参数 | string |  | p_edit |  |  | 进入订阅页时上报 |  |  |  |
| 影响事件 | 0 | 1 | w_subscription_success | 订阅成功 | source_0 | 进入订阅页来源-0 | 普通参数 | string |  | f_eraser |  |  | 进入订阅页时上报 |  |  |  |
| 影响事件 | 0 | 1 | w_subscription_success | 订阅成功 | source_1 | 进入订阅页来源-1 | 普通参数 | string |  | ai |  |  | 进入订阅页时上报 |  |  |  |
| 影响事件 | 0 | 1 | w_subscription_success | 订阅成功 | source_1 | 进入订阅页来源-1 | 普通参数 | string |  | classic |  |  | 进入订阅页时上报 |  |  |  |
| 影响事件 | 0 | 1 | w_subscription_success | 订阅成功 | source_1 | 进入订阅页来源-1 | 普通参数 | string |  | passersby |  |  | 进入订阅页时上报 |  |  |  |
| 新增事件参数值 | 0 | 1 | w_subscription_success | 订阅成功 | source_1 | 进入订阅页来源-1 | 普通参数 | string |  | mirror |  |  | 进入订阅页时上报 |  |  |  |