| 需求类型 | 事件来源 | 事件类型 | *事件id | *事件名称 | 参数 | 参数名称 | 参数类型 | 参数值类型 | 参数口径 | 参数值 | 参数值名称 | 参数值口径 | *统计口径 | 备注说明 | 事件分组 | 标签 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 影响事件 | 0 | 1 | second_func_enter | 点击二级功能页面 | first_func | 一级功能参数 | 普通参数 | string |  | edit |  |  | 点击二级功能页面时上报 |  |  |  |
| 影响事件 | 0 | 1 | second_func_enter | 点击二级功能页面 | second_func | 二级功能参数 | 普通参数 | string |  | relight |  |  | 点击二级功能页面时上报 |  |  |  |
| 影响事件 | 0 | 1 | second_func_enter | 点击二级功能页面 | from | 进入功能来源 | 普通参数 | string | mini_icon | mini_icon |  |  | 点击二级功能页面时上报 |  |  |  |
| 影响事件 | 0 | 1 | third_func_enter | 点击三级功能页面 | first_func | 一级功能参数 | 普通参数 | string |  | edit |  |  | 点击三级功能页面时上报 |  |  |  |
| 影响事件 | 0 | 1 | third_func_enter | 点击三级功能页面 | second_func | 二级功能参数 | 普通参数 | string |  | relight |  |  | 点击三级功能页面时上报 |  |  |  |
| 新增事件参数值 | 0 | 1 | third_func_enter | 点击三级功能页面 | third_func | 三级功能参数 | 普通参数 | string | beach_day,indigo,soft_glow,sunlit |  |  |  | 点击三级功能页面时上报 |  |  |  |
| 新增事件参数 | 0 | 1 | third_func_enter | 点击三级功能页面 | from |  | 普通参数 | string |  | mini_icon |  |  | 点击三级功能页面时上报 |  |  |  |
| 影响事件 | 0 | 1 | second_func_use | 二级功能打勾 | first_func | 一级功能参数 | 普通参数 | string |  | edit |  |  | 应用edit下的二级功能时触发 |  |  |  |
| 影响事件 | 0 | 1 | second_func_use | 二级功能打勾 | second_func | 二级功能参数 | 普通参数 | string |  | relight |  |  | 应用edit下的二级功能时触发 |  |  |  |
| 新增事件参数值 | 0 | 1 | second_func_use | 二级功能打勾 | presets_selection | 应用的预设（由于功能交互原因，只需要报一个值） | 普通参数 | string | beach_day,indigo,soft_glow,sunlit |  |  |  | 应用edit下的二级功能时触发 |  |  |  |
| 影响事件 | 0 | 1 | second_func_save | 二级功能保存 | first_func |  | 普通参数 | string |  | edit |  |  | 保存edit下的二级功能 |  |  |  |
| 影响事件 | 0 | 1 | second_func_save | 二级功能保存 | second_func |  | 普通参数 | string | plump | relight |  |  | 保存edit下的二级功能 |  |  |  |
| 新增事件参数值 | 0 | 1 | second_func_save | 二级功能保存 | presets_selection | 应用的预设 | 普通参数 | string | beach_day,indigo,soft_glow,sunlit |  |  |  | 保存edit下的二级功能 |  |  |  |
| 影响事件 | 0 | 1 | edit_save | 编辑保存 | prf_first_func | 一级功能参数 | 普通参数 | string | edit | retouch,retouch,retouch,edit,filters,hair,retouch |  |  | 结束编辑最终保存时触发 |  |  |  |
| 影响事件 | 0 | 1 | edit_save | 编辑保存 | prf_second_func | 二级功能参数 | 普通参数 | string | relight |  |  |  | 结束编辑最终保存时触发 |  |  |  |
| 影响事件 | 0 | 1 | w_subscription_enter | 进入订阅页 | source_0 | 进入订阅页来源-0 | 普通参数 | string | f_relight |  |  |  | 成功订阅时上报成功付费时上报 |  |  |  |
| 影响事件 | 0 | 1 | w_subscription_enter | 进入订阅页 | source_1 | 进入订阅页来源-1 | 普通参数 | string | beach_day,indigo,soft_glow,sunlit |  |  |  | 成功订阅时上报成功付费时上报 |  |  |  |
| 影响事件 | 0 | 1 | w_subscription_click | 订阅页点击订阅按钮 | source_0 | 进入订阅页来源-0 | 普通参数 | string | f_relight |  |  |  | 选中某个plan并点击订阅按钮时上报 |  |  |  |
| 影响事件 | 0 | 1 | w_subscription_click | 订阅页点击订阅按钮 | source_1 | 进入订阅页来源-1 | 普通参数 | string | beach_day,indigo,soft_glow,sunlit |  |  |  | 选中某个plan并点击订阅按钮时上报 |  |  |  |
| 影响事件 | 0 | 1 | w_subscription_success | 订阅成功 | source_0 | 进入订阅页来源-0 | 普通参数 | string | f_relight |  |  |  | 进入订阅页时上报 |  |  |  |
| 影响事件 | 0 | 1 | w_subscription_success | 订阅成功 | source_1 | 进入订阅页来源-1 | 普通参数 | string | beach_day,indigo,soft_glow,sunlit |  |  |  | 进入订阅页时上报 |  |  |  |
| 影响事件 | 0 | 1 | ai_func_use_result | 使用ai算法请求结果返回 | first_func | 一级功能参数 | 普通参数 | string |  | edit |  |  | 使用ai算法请求结果返回时触发 |  |  |  |
| 影响事件 | 0 | 1 | ai_func_use_result | 使用ai算法请求结果返回 | is_success | 应用效果(图片处理)是否成功 | 普通参数 | number |  |  |  |  | 使用ai算法请求结果返回时触发 |  |  |  |
| 影响事件 | 0 | 1 | ai_func_use_result | 使用ai算法请求结果返回 | time | 应用时长 | 普通参数 | number |  |  |  |  | 使用ai算法请求结果返回时触发 |  |  |  |
| 影响事件 | 0 | 1 | ai_func_use_result | 使用ai算法请求结果返回 | second_func | 二级功能参数 | 普通参数 | string |  | relight |  |  | 使用ai算法请求结果返回时触发 |  |  |  |
| 新增事件参数值 | 0 | 1 | ai_func_use_result | 使用ai算法请求结果返回 | third_func | 三级功能参数 | 普通参数 | string | beach_day,indigo,soft_glow,sunlit |  |  |  | 使用ai算法请求结果返回时触发 |  |  |  |
| 影响事件 | 0 | 1 | ai_func_delivery | 请求ai算法 | second_func | 二级功能参数 | 普通参数 | string |  | relight |  |  | 请求（是否拦截）的时候上报（缓存不报） |  |  |  |
| 影响事件 | 0 | 1 | popup_show | popup弹窗出现 | first_func | 一级功能参数 | 普通参数 | string |  | retouch |  |  | popup弹窗出现时触发(不包括评分弹窗) |  |  |  |
| 新增事件参数值 | 0 | 1 | popup_show | popup弹窗出现 | second_func | 二级功能参数 | 普通参数 | string |  | relight |  |  | popup弹窗出现时触发(不包括评分弹窗) |  |  |  |
| 新增事件参数值 | 0 | 1 | popup_show | popup弹窗出现 | pop_name | 弹窗name | 普通参数 | string |  |  |  |  | popup弹窗出现时触发(不包括评分弹窗) |  |  |  |
| 影响事件 | 0 | 1 | popup_click | 点击popup弹窗confirm  button | first_func | 一级功能参数 | 普通参数 | string |  | retouch |  |  | 点击popup弹窗confirm  button触发 (不包括评分弹窗) |  |  |  |
| 影响事件 | 0 | 1 | popup_click | 点击popup弹窗confirm  button | pop_name | 弹窗name | 普通参数 | string |  |  |  |  | 点击popup弹窗confirm  button触发 (不包括评分弹窗) |  |  |  |
| 新增事件参数值 | 0 | 1 | popup_click | 点击popup弹窗confirm  button | second_func | 二级功能参数 | 普通参数 | string |  | relight |  |  | 点击popup弹窗confirm  button触发 (不包括评分弹窗) |  |  |  |
| 新增事件参数值 | 0 | 1 | cloudfilter_per_show | 图片云处理权限弹窗点击 | function | 功能 | 普通参数 | string | relight_beach_day,relight_indigo,relight_soft_glow,relight_sunlit |  |  |  |  |  |  |  |
| 新增事件参数值 | 0 | 1 | cloudfilter_per_show_ok | 图片云处理权限弹窗点击 | function |  | 普通参数 | string | relight_beach_day,relight_indigo,relight_soft_glow,relight_sunlit |  |  |  |  |  |  |  |