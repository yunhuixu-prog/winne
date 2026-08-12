| 需求类型 | 事件来源 | 事件类型 | *事件id | *事件名称 | 参数 | 参数名称 | 参数类型 | 参数值类型 | 参数口径 | 参数值 | 参数值名称 | 参数值口径 | *统计口径 | 备注说明 | 事件分组 | 标签 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 影响事件 | 0 | 1 | second_func_use | 二级功能打勾 | second_func | 二级功能参数 | 普通参数 | string | makeup | body |  |  | 应用edit下的二级功能时触发 |  |  |  |
| 影响事件 | 0 | 1 | second_func_use | 二级功能打勾 | is_effect | 是否有应用任一效果 | 普通参数 | string |  |  |  |  | 应用edit下的二级功能时触发 |  |  |  |
| 新增事件参数 | 0 | 1 | second_func_use | 二级功能打勾 | by_waist |  | 普通参数 | string | 用啥报啥，都用逗号隔开 | waist |  |  | 应用edit下的二级功能时触发 |  |  |  |
| 新增事件参数 | 0 | 1 | second_func_use | 二级功能打勾 | by_waist |  | 普通参数 | string | 用啥报啥，都用逗号隔开 | hourglass |  |  | 应用edit下的二级功能时触发 |  |  |  |
| 影响事件 | 0 | 1 | fourth_func_enter |  | second_func |  | 普通参数 | string |  | body |  |  |  |  |  |  |
| 新增事件参数 | 0 | 1 | fourth_func_enter |  | third_func |  | 普通参数 | string |  | waist |  |  |  |  |  |  |
| 新增事件参数 | 0 | 1 | fourth_func_enter |  | fourth_func |  | 普通参数 | string |  | waist |  |  |  |  |  |  |
| 新增事件参数 | 0 | 1 | fourth_func_enter |  | fourth_func |  | 普通参数 | string |  | hourglass |  |  |  |  |  |  |
| 影响事件 | 0 | 1 | second_func_save | 二级功能保存 | second_func |  | 普通参数 | string |  | body |  |  | 保存edit下的二级功能 |  |  |  |
| 新增事件参数 | 0 | 1 | second_func_save | 二级功能保存 | waist |  | 普通参数 | string | 两次打勾不去重复 | waist |  |  | 保存edit下的二级功能 |  |  |  |
| 新增事件参数 | 0 | 1 | second_func_save | 二级功能保存 | waist |  | 普通参数 | string | 两次打勾不去重复 | hourglass |  |  | 保存edit下的二级功能 |  |  |  |
| 影响事件 | 0 | 1 | ai_func_use_result | 使用ai算法请求结果返回 | second_func | 二级功能参数 | 普通参数 | string |  | body |  |  | 使用ai算法请求结果返回时触发 |  |  |  |
| 影响事件 | 0 | 1 | ai_func_use_result | 使用ai算法请求结果返回 | first_func | 一级功能参数 | 普通参数 | string |  | retouch |  |  | 使用ai算法请求结果返回时触发 |  |  |  |
| 影响事件 | 0 | 1 | ai_func_use_result | 使用ai算法请求结果返回 | third_func | 三级功能参数 | 普通参数 | string |  | waist |  |  | 使用ai算法请求结果返回时触发 |  |  |  |
| 影响事件 | 0 | 1 | ai_func_use_result | 使用ai算法请求结果返回 | time | 应用时长 | 普通参数 | number |  |  |  |  | 使用ai算法请求结果返回时触发 |  |  |  |
| 影响事件 | 0 | 1 | ai_func_use_result | 使用ai算法请求结果返回 | is_success | 应用效果(图片处理)是否成功 | 普通参数 | number |  |  |  |  | 使用ai算法请求结果返回时触发 |  |  |  |
| 新增事件参数值 | 0 | 1 | ai_func_use_result | 使用ai算法请求结果返回 | fourth_func |  | 普通参数 | string |  | hourglass |  |  | 使用ai算法请求结果返回时触发 |  |  |  |
| 影响事件 | 0 | 1 | ai_func_delivery | 请求ai算法 | second_func | 二级功能参数 | 普通参数 | string |  | body |  |  | 请求（是否拦截）的时候上报（缓存不报） |  |  |  |
| 影响事件 | 0 | 1 | ai_func_delivery | 请求ai算法 | third_func | 三级功能参数 | 普通参数 | string |  | waist |  |  | 请求（是否拦截）的时候上报（缓存不报） |  |  |  |
| 新增事件参数 | 0 | 1 | ai_func_delivery | 请求ai算法 | fourth_func |  | 普通参数 | string |  | hourglass |  |  | 请求（是否拦截）的时候上报（缓存不报） |  |  |  |
| 影响事件 | 0 | 1 | edit_save | 编辑保存 | prf_second_func | 二级功能参数 | 普通参数 | string |  | body |  |  | 结束编辑最终保存时触发 |  |  |  |
| 影响事件 | 0 | 1 | edit_save | 编辑保存 | prf_third_func | 三级功能参数 | 普通参数 | string | 只到waist |  |  |  | 结束编辑最终保存时触发 |  |  |  |
| 影响事件 | 0 | 1 | w_subscription_enter | 进入订阅页 | source_0 | 进入订阅页来源-0 | 普通参数 | string |  | f_body |  |  | 成功订阅时上报成功付费时上报 |  |  |  |
| 新增事件参数值 | 0 | 1 | w_subscription_enter | 进入订阅页 | source_1 | 进入订阅页来源-1 | 普通参数 | string |  | f_hourglass |  |  | 成功订阅时上报成功付费时上报 |  |  |  |
| 新增事件参数值 | 0 | 1 | w_subscription_enter | 进入订阅页 | source_1 | 进入订阅页来源-1 | 普通参数 | string |  | f_waist |  | waist下waist，背景保护+wais订阅 | 成功订阅时上报成功付费时上报 |  |  |  |
| 影响事件 | 0 | 1 | w_subscription_success | 订阅成功 | source_0 | 进入订阅页来源-0 | 普通参数 | string |  | f_body |  |  | 进入订阅页时上报 |  |  |  |
| 新增事件参数值 | 0 | 1 | w_subscription_success | 订阅成功 | source_1 | 进入订阅页来源-1 | 普通参数 | string |  | f_ hourglass |  |  | 进入订阅页时上报 |  |  |  |
| 新增事件参数值 | 0 | 1 | w_subscription_success | 订阅成功 | source_1 | 进入订阅页来源-1 | 普通参数 | string |  | f_waist |  | waist下waist，背景保护+wais订阅 | 进入订阅页时上报 |  |  |  |
| 影响事件 | 0 | 1 | popup_show | popup弹窗出现 | pop_id | 弹窗id | 普通参数 | string |  |  |  |  | popup弹窗出现时触发(不包括评分弹窗) |  |  |  |
| 影响事件 | 0 | 1 | popup_show | popup弹窗出现 | pop_name | 弹窗name | 普通参数 | string |  | no_free_delivery_popup |  |  | popup弹窗出现时触发(不包括评分弹窗) |  |  |  |
| 影响事件 | 0 | 1 | popup_show | popup弹窗出现 | first_func | 一级功能参数 | 普通参数 | string |  | retouch |  |  | popup弹窗出现时触发(不包括评分弹窗) |  |  |  |
| 影响事件 | 0 | 1 | popup_show | popup弹窗出现 | second_func | 二级功能参数 | 普通参数 | string |  | body |  |  | popup弹窗出现时触发(不包括评分弹窗) |  |  |  |
| 新增事件参数 | 0 | 1 | popup_show | popup弹窗出现 | fourth_func |  | 普通参数 | string |  | hourglass |  |  | popup弹窗出现时触发(不包括评分弹窗) |  |  |  |
| 新增事件参数 | 0 | 1 | popup_show | popup弹窗出现 | fourth_func |  | 普通参数 | string |  | breast_plus |  |  | popup弹窗出现时触发(不包括评分弹窗) |  |  |  |
| 新增事件参数值 | 0 | 1 | popup_show | popup弹窗出现 | third_func | 三级功能参数 | 普通参数 | string |  | waist |  |  | popup弹窗出现时触发(不包括评分弹窗) |  |  |  |
| 新增事件参数值 | 0 | 1 | popup_show | popup弹窗出现 | third_func | 三级功能参数 | 普通参数 | string |  | breast |  |  | popup弹窗出现时触发(不包括评分弹窗) |  |  |  |
| 影响事件 | 0 | 1 | popup_click | 点击popup弹窗confirm  button | second_func | 二级功能参数 | 普通参数 | string |  | body |  |  | 点击popup弹窗confirm  button触发 (不包括评分弹窗) |  |  |  |
| 影响事件 | 0 | 1 | popup_click | 点击popup弹窗confirm  button | pop_id | 弹窗id | 普通参数 | string |  |  |  |  | 点击popup弹窗confirm  button触发 (不包括评分弹窗) |  |  |  |
| 影响事件 | 0 | 1 | popup_click | 点击popup弹窗confirm  button | pop_name | 弹窗name | 普通参数 | string |  |  |  |  | 点击popup弹窗confirm  button触发 (不包括评分弹窗) |  |  |  |
| 新增事件参数 | 0 | 1 | popup_click | 点击popup弹窗confirm  button | fourth_func |  | 普通参数 | string |  | hourglass |  |  | 点击popup弹窗confirm  button触发 (不包括评分弹窗) |  |  |  |
| 新增事件参数 | 0 | 1 | popup_click | 点击popup弹窗confirm  button | fourth_func |  | 普通参数 | string |  | breast_plus |  |  | 点击popup弹窗confirm  button触发 (不包括评分弹窗) |  |  |  |
| 新增事件参数值 | 0 | 1 | popup_click | 点击popup弹窗confirm  button | third_func | 三级功能参数 | 普通参数 | string |  | waist |  |  | 点击popup弹窗confirm  button触发 (不包括评分弹窗) |  |  |  |
| 新增事件参数值 | 0 | 1 | popup_click | 点击popup弹窗confirm  button | third_func | 三级功能参数 | 普通参数 | string |  | breast |  |  | 点击popup弹窗confirm  button触发 (不包括评分弹窗) |  |  |  |
| 新增事件参数值 | 0 | 1 | w_subscription_click | 订阅页点击订阅按钮 | source_1 | 进入订阅页来源-1 | 普通参数 | string |  | f_ hourglass |  |  | 选中某个plan并点击订阅按钮时上报 |  |  |  |
| 新增事件参数值 | 0 | 1 | w_subscription_click | 订阅页点击订阅按钮 | source_1 | 进入订阅页来源-1 | 普通参数 | string |  | f_waist |  | waist下waist，背景保护+wais订阅 | 选中某个plan并点击订阅按钮时上报 |  |  |  |
| 新增事件参数值 | 0 | 1 | cloudfilter_per_show_ok | 图片云处理权限弹窗点击 | function |  | 普通参数 | string | relight_beach_day,relight_indigo,relight_soft_glow,relight_sunlit | hourglass |  |  |  |  |  |  |
| 新增事件参数值 | 0 | 1 | cloudfilter_per_show | 图片云处理权限弹窗点击 | function | 功能 | 普通参数 | string | relight_beach_day,relight_indigo,relight_soft_glow,relight_sunlit | hourglass |  |  |  |  |  |  |