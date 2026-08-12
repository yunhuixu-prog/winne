| 需求类型 | 事件来源 | 事件类型 | *事件id | *事件名称 | 参数 | 参数名称 | 参数类型 | 参数值类型 | 参数口径 | 参数值 | 参数值名称 | 参数值口径 | *统计口径 | 备注说明 | 事件分组 | 标签 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 影响事件 | 0 | 1 | second_func_enter | 点击二级功能页面 | first_func | 一级功能参数 | 普通参数 | string |  | edit |  |  | 点击二级功能页面时上报 |  |  |  |
| 影响事件 | 0 | 1 | second_func_enter | 点击二级功能页面 | second_func | 二级功能参数 | 普通参数 | string |  | ai_repair |  |  | 点击二级功能页面时上报 |  |  |  |
| 影响事件 | 0 | 1 | ai_func_use_result | 使用ai算法请求结果返回 | first_func | 一级功能参数 | 普通参数 | string |  | edit |  |  | 使用ai算法请求结果返回时触发 |  |  |  |
| 影响事件 | 0 | 1 | ai_func_use_result | 使用ai算法请求结果返回 | second_func | 二级功能参数 | 普通参数 | string |  | ai_repair |  |  | 使用ai算法请求结果返回时触发 |  |  |  |
| 影响事件 | 0 | 1 | ai_func_use_result | 使用ai算法请求结果返回 | time | 应用时长 | 普通参数 | number |  |  |  |  | 使用ai算法请求结果返回时触发 |  |  |  |
| 影响事件 | 0 | 1 | ai_func_use_result | 使用ai算法请求结果返回 | is_success | 应用效果(图片处理)是否成功 | 普通参数 | number |  |  |  |  | 使用ai算法请求结果返回时触发 |  |  |  |
| 新增事件参数值 | 0 | 1 | ai_func_use_result | 使用ai算法请求结果返回 | func | 功能 | 普通参数 | string |  | uhd |  |  | 使用ai算法请求结果返回时触发 |  |  |  |
| 新增事件参数值 | 0 | 1 | ai_func_use_result | 使用ai算法请求结果返回 | func | 功能 | 普通参数 | string |  | portrait |  |  | 使用ai算法请求结果返回时触发 |  |  |  |
| 新增事件参数值 | 0 | 1 | ai_func_use_result | 使用ai算法请求结果返回 | func | 功能 | 普通参数 | string |  | denoise |  |  | 使用ai算法请求结果返回时触发 |  |  |  |
| 新增事件参数值 | 0 | 1 | ai_func_use_result | 使用ai算法请求结果返回 | func | 功能 | 普通参数 | string |  | colorize |  |  | 使用ai算法请求结果返回时触发 |  |  |  |
| 影响事件 | 0 | 1 | ai_func_delivery | 请求ai算法 | first_func | 一级功能参数 | 普通参数 | string |  | edit |  |  | 请求（是否拦截）的时候上报（缓存不报） |  |  |  |
| 新增事件参数值 | 0 | 1 | ai_func_delivery | 请求ai算法 | second_func | 二级功能参数 | 普通参数 | string |  | ai_repair |  |  | 请求（是否拦截）的时候上报（缓存不报） |  |  |  |
| 新增事件参数 | 0 | 1 | ai_func_delivery | 请求ai算法 | func | 功能 | 普通参数 | string |  | uhd |  |  | 请求（是否拦截）的时候上报（缓存不报） |  |  |  |
| 新增事件参数 | 0 | 1 | ai_func_delivery | 请求ai算法 | func | 功能 | 普通参数 | string |  | portrait |  |  | 请求（是否拦截）的时候上报（缓存不报） |  |  |  |
| 新增事件参数 | 0 | 1 | ai_func_delivery | 请求ai算法 | func | 功能 | 普通参数 | string |  | denoise |  |  | 请求（是否拦截）的时候上报（缓存不报） |  |  |  |
| 新增事件参数 | 0 | 1 | ai_func_delivery | 请求ai算法 | func | 功能 | 普通参数 | string |  | colorize |  |  | 请求（是否拦截）的时候上报（缓存不报） |  |  |  |
| 影响事件 | 0 | 1 | second_func_use | 二级功能打勾 | first_func | 一级功能参数 | 普通参数 | string |  | edit |  |  | 应用edit下的二级功能时触发 |  |  |  |
| 影响事件 | 0 | 1 | second_func_use | 二级功能打勾 | second_func | 二级功能参数 | 普通参数 | string | makeup | ai_repair |  |  | 应用edit下的二级功能时触发 |  |  |  |
| 影响事件 | 0 | 1 | second_func_use | 二级功能打勾 | is_effect | 是否有应用任一效果 | 普通参数 | string |  |  |  |  | 应用edit下的二级功能时触发 |  |  |  |
| 新增事件参数值 | 0 | 1 | second_func_use | 二级功能打勾 | func | 功能 | 普通参数 | string | 使用了多个用逗号隔开 | uhd |  |  | 应用edit下的二级功能时触发 |  |  |  |
| 新增事件参数值 | 0 | 1 | second_func_use | 二级功能打勾 | func | 功能 | 普通参数 | string | 使用了多个用逗号隔开 | portrait |  |  | 应用edit下的二级功能时触发 |  |  |  |
| 新增事件参数值 | 0 | 1 | second_func_use | 二级功能打勾 | func | 功能 | 普通参数 | string | 使用了多个用逗号隔开 | denoise |  |  | 应用edit下的二级功能时触发 |  |  |  |
| 新增事件参数值 | 0 | 1 | second_func_use | 二级功能打勾 | func | 功能 | 普通参数 | string | 使用了多个用逗号隔开 | colorize |  |  | 应用edit下的二级功能时触发 |  |  |  |
| 影响事件 | 0 | 1 | w_subscription_click | 订阅页点击订阅按钮 | source_module | 进入订阅页来源模块 | 普通参数 | string |  | p_edit |  |  | 选中某个plan并点击订阅按钮时上报 |  |  |  |
| 影响事件 | 0 | 1 | w_subscription_click | 订阅页点击订阅按钮 | source_0 | 进入订阅页来源-0 | 普通参数 | string |  | f_ai_repair |  |  | 选中某个plan并点击订阅按钮时上报 |  |  |  |
| 影响事件 | 0 | 1 | w_subscription_success | 订阅成功 | source_module | 进入订阅页来源模块 | 普通参数 | string |  | p_edit |  |  | 进入订阅页时上报 |  |  |  |
| 影响事件 | 0 | 1 | w_subscription_success | 订阅成功 | source_0 | 进入订阅页来源-0 | 普通参数 | string |  | f_ai_repair |  |  | 进入订阅页时上报 |  |  |  |
| 影响事件 | 0 | 1 | w_subscription_enter | 进入订阅页 | source_module | 进入订阅页来源模块 | 普通参数 | string |  | p_edit |  |  | 成功订阅时上报成功付费时上报 |  |  |  |
| 影响事件 | 0 | 1 | w_subscription_enter | 进入订阅页 | source_0 | 进入订阅页来源-0 | 普通参数 | string |  | f_ai_repair |  |  | 成功订阅时上报成功付费时上报 |  |  |  |