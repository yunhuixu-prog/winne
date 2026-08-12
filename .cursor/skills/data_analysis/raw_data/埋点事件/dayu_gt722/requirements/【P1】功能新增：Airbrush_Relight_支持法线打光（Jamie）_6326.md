| 需求类型 | 事件来源 | 事件类型 | *事件id | *事件名称 | 参数 | 参数名称 | 参数类型 | 参数值类型 | 参数口径 | 参数值 | 参数值名称 | 参数值口径 | *统计口径 | 备注说明 | 事件分组 | 标签 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 影响事件 | 0 | 1 | ai_func_delivery | 请求ai算法 | first_func | 一级功能参数 | 普通参数 | string |  | edit |  |  | 请求（是否拦截）的时候上报（缓存不报） |  |  |  |
| 影响事件 | 0 | 1 | ai_func_delivery | 请求ai算法 | second_func | 二级功能参数 | 普通参数 | string |  | relight |  |  | 请求（是否拦截）的时候上报（缓存不报） |  |  |  |
| 影响事件 | 0 | 1 | ai_func_delivery | 请求ai算法 | third_func | 三级功能参数 | 普通参数 | string | 具体素材名 |  |  |  | 请求（是否拦截）的时候上报（缓存不报） |  |  |  |
| 影响事件 | 0 | 1 | ai_func_use_result | 使用ai算法请求结果返回 | first_func | 一级功能参数 | 普通参数 | string |  | edit |  |  | 使用ai算法请求结果返回时触发 |  |  |  |
| 影响事件 | 0 | 1 | ai_func_use_result | 使用ai算法请求结果返回 | second_func | 二级功能参数 | 普通参数 | string |  | relight |  |  | 使用ai算法请求结果返回时触发 |  |  |  |
| 影响事件 | 0 | 1 | ai_func_use_result | 使用ai算法请求结果返回 | third_func | 三级功能参数 | 普通参数 | string | 具体素材名 |  |  |  | 使用ai算法请求结果返回时触发 |  |  |  |
| 影响事件 | 0 | 1 | ai_func_use_result | 使用ai算法请求结果返回 | time | 应用时长 | 普通参数 | number |  |  |  |  | 使用ai算法请求结果返回时触发 |  |  |  |
| 影响事件 | 0 | 1 | ai_func_use_result | 使用ai算法请求结果返回 | is_success | 应用效果(图片处理)是否成功 | 普通参数 | number |  |  |  |  | 使用ai算法请求结果返回时触发 |  |  |  |
| 影响事件 | 0 | 1 | second_func_enter | 点击二级功能页面 | first_func | 一级功能参数 | 普通参数 | string |  | edit |  |  | 点击二级功能页面时上报 |  |  |  |
| 影响事件 | 0 | 1 | second_func_enter | 点击二级功能页面 | second_func | 二级功能参数 | 普通参数 | string |  | relight |  |  | 点击二级功能页面时上报 |  |  |  |
| 影响事件 | 0 | 1 | second_func_save | 二级功能保存 | first_func |  | 普通参数 | string |  | edit |  |  | 保存edit下的二级功能 |  |  |  |
| 影响事件 | 0 | 1 | second_func_save | 二级功能保存 | second_func |  | 普通参数 | string |  | relight |  |  | 保存edit下的二级功能 |  |  |  |
| 影响事件 | 0 | 1 | second_func_save | 二级功能保存 | presets_selection | 应用的预设 | 普通参数 | string | 上报打勾的素材名称 |  |  |  | 保存edit下的二级功能 |  |  |  |
| 新增事件参数 | 0 | 1 | second_func_save | 二级功能保存 | direction_value |  | 普通参数 | string | brightness:xx;saturation:xx |  |  |  | 保存edit下的二级功能 |  |  |  |
| 新增事件参数 | 0 | 1 | second_func_save | 二级功能保存 | natural_value |  | 普通参数 | string | brightness:xx;hue:xx |  |  |  | 保存edit下的二级功能 |  |  |  |
| 新增事件参数 | 0 | 1 | second_func_save | 二级功能保存 | ambient_value |  | 普通参数 | string | brightness:xx,xx;hue:xx,xx |  |  |  | 保存edit下的二级功能 |  |  |  |
| 影响事件 | 0 | 1 | second_func_use | 二级功能打勾 | first_func | 一级功能参数 | 普通参数 | string |  | edit |  |  | 应用edit下的二级功能时触发 |  |  |  |
| 影响事件 | 0 | 1 | second_func_use | 二级功能打勾 | second_func | 二级功能参数 | 普通参数 | string | 功能名 | relight |  |  | 应用edit下的二级功能时触发 |  |  |  |
| 影响事件 | 0 | 1 | second_func_use | 二级功能打勾 | presets_selection | 应用的预设（由于功能交互原因，只需要报一个值） | 普通参数 | string | 上报打勾的素材名称 |  |  |  | 应用edit下的二级功能时触发 |  |  |  |
| 新增事件参数 | 0 | 1 | second_func_use | 二级功能打勾 | direction_value |  | 普通参数 | string | brightness:xx;saturation:xx |  |  |  | 应用edit下的二级功能时触发 |  |  |  |
| 新增事件参数 | 0 | 1 | second_func_use | 二级功能打勾 | natural_value |  | 普通参数 | string | brightness:xx;hue:xx |  |  |  | 应用edit下的二级功能时触发 |  |  |  |
| 新增事件参数 | 0 | 1 | second_func_use | 二级功能打勾 | ambient_value |  | 普通参数 | string | brightness:xx,xx;hue:xx,xx |  |  |  | 应用edit下的二级功能时触发 |  |  |  |
| 影响事件 | 0 | 1 | third_func_enter | 点击三级功能页面 | first_func | 一级功能参数 | 普通参数 | string |  | edit |  |  | 点击三级功能页面时上报 |  |  |  |
| 影响事件 | 0 | 1 | third_func_enter | 点击三级功能页面 | second_func | 二级功能参数 | 普通参数 | string |  | relight |  |  | 点击三级功能页面时上报 |  |  |  |
| 影响事件 | 0 | 1 | third_func_enter | 点击三级功能页面 | third_func | 三级功能参数 | 普通参数 | string | aesthetic下上报具体素材名 |  |  |  | 点击三级功能页面时上报 |  |  |  |
| 新增事件参数值 | 0 | 1 | third_func_enter | 点击三级功能页面 | third_func | 三级功能参数 | 普通参数 | string | manual下上报功能名 | manual_direction |  | manual下的direction | 点击三级功能页面时上报 |  |  |  |
| 新增事件参数值 | 0 | 1 | third_func_enter | 点击三级功能页面 | third_func | 三级功能参数 | 普通参数 | string | manual下上报功能名 | manual_nature |  | manual下的nature | 点击三级功能页面时上报 |  |  |  |
| 新增事件参数值 | 0 | 1 | third_func_enter | 点击三级功能页面 | third_func | 三级功能参数 | 普通参数 | string | manual下上报功能名 | manual_ambient |  | manual下的ambient | 点击三级功能页面时上报 |  |  |  |
| 影响事件 | 0 | 1 | w_subscription_click | 订阅页点击订阅按钮 | source_module | 进入订阅页来源模块 | 普通参数 | string |  | p_edit |  |  | 选中某个plan并点击订阅按钮时上报 |  |  |  |
| 影响事件 | 0 | 1 | w_subscription_click | 订阅页点击订阅按钮 | source_0 | 进入订阅页来源-0 | 普通参数 | string |  | f_relight |  |  | 选中某个plan并点击订阅按钮时上报 |  |  |  |
| 影响事件 | 0 | 1 | w_subscription_click | 订阅页点击订阅按钮 | source_1 | 进入订阅页来源-1 | 普通参数 | string | 上报具体素材名 |  |  |  | 选中某个plan并点击订阅按钮时上报 |  |  |  |
| 影响事件 | 0 | 1 | w_subscription_enter | 进入订阅页 | source_module | 进入订阅页来源模块 | 普通参数 | string |  | p_edit |  |  | 成功订阅时上报成功付费时上报 |  |  |  |
| 影响事件 | 0 | 1 | w_subscription_enter | 进入订阅页 | source_0 | 进入订阅页来源-0 | 普通参数 | string |  | f_relight |  |  | 成功订阅时上报成功付费时上报 |  |  |  |
| 影响事件 | 0 | 1 | w_subscription_enter | 进入订阅页 | source_1 | 进入订阅页来源-1 | 普通参数 | string | 上报具体素材名 |  |  |  | 成功订阅时上报成功付费时上报 |  |  |  |
| 影响事件 | 0 | 1 | w_subscription_success | 订阅成功 | source_module | 进入订阅页来源模块 | 普通参数 | string |  | p_edit |  |  | 进入订阅页时上报 |  |  |  |
| 影响事件 | 0 | 1 | w_subscription_success | 订阅成功 | source_0 | 进入订阅页来源-0 | 普通参数 | string |  | f_relight |  |  | 进入订阅页时上报 |  |  |  |
| 影响事件 | 0 | 1 | w_subscription_success | 订阅成功 | source_1 | 进入订阅页来源-1 | 普通参数 | string | 上报具体素材名 |  |  |  | 进入订阅页时上报 |  |  |  |