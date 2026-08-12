| 需求类型 | 事件来源 | 事件类型 | *事件id | *事件名称 | 参数 | 参数名称 | 参数类型 | 参数值类型 | 参数口径 | 参数值 | 参数值名称 | 参数值口径 | *统计口径 | 备注说明 | 事件分组 | 标签 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 影响事件 | 0 | 1 | second_func_enter | 点击二级功能页面 | first_func | 一级功能参数 | 普通参数 | string |  | edit |  |  | 点击二级功能页面时上报 |  |  |  |
| 影响事件 | 0 | 1 | second_func_enter | 点击二级功能页面 | second_func | 二级功能参数 | 普通参数 | string |  | ai_replace |  |  | 点击二级功能页面时上报 |  |  |  |
| 影响事件 | 0 | 1 | second_func_use | 二级功能打勾 | first_func | 一级功能参数 | 普通参数 | string |  | edit |  |  | 应用edit下的二级功能时触发 | 仅在结果页选择效果图打勾时上报 |  |  |
| 影响事件 | 0 | 1 | second_func_use | 二级功能打勾 | second_func | 二级功能参数 | 普通参数 | string | makeup | ai_replace |  |  | 应用edit下的二级功能时触发 | 仅在结果页选择效果图打勾时上报 |  |  |
| 影响事件 | 0 | 1 | second_func_use | 二级功能打勾 | is_effect | 是否有应用任一效果 | 普通参数 | string |  | 0 |  |  | 应用edit下的二级功能时触发 | 仅在结果页选择效果图打勾时上报 |  |  |
| 影响事件 | 0 | 1 | second_func_use | 二级功能打勾 | is_effect | 是否有应用任一效果 | 普通参数 | string |  | 1 |  |  | 应用edit下的二级功能时触发 | 仅在结果页选择效果图打勾时上报 |  |  |
| 影响事件 | 0 | 1 | second_func_use | 二级功能打勾 | prf_text | 用户输入的文本内容 | 普通参数 | string | pumpkin,skull,spooky，等其他用户输入的内容 |  |  |  | 应用edit下的二级功能时触发 | 仅在结果页选择效果图打勾时上报 |  |  |
| 影响事件 | 0 | 1 | second_func_use | 二级功能打勾 | is_recomend_text |  | 普通参数 | string |  | 0 |  | 手动输入词 | 应用edit下的二级功能时触发 | 仅在结果页选择效果图打勾时上报 |  |  |
| 影响事件 | 0 | 1 | second_func_use | 二级功能打勾 | is_recomend_text |  | 普通参数 | string |  | 1 |  | 使用推荐词 | 应用edit下的二级功能时触发 | 仅在结果页选择效果图打勾时上报 |  |  |
| 新增事件参数 | 0 | 1 | second_func_use | 二级功能打勾 | auto_icon | 用户选取的主体 | 普通参数 | string | 若使用多个上报多个，逗号隔开 | manual |  | 手动选取 | 应用edit下的二级功能时触发 | 仅在结果页选择效果图打勾时上报 |  |  |
| 新增事件参数 | 0 | 1 | second_func_use | 二级功能打勾 | auto_icon | 用户选取的主体 | 普通参数 | string | 若使用多个上报多个，逗号隔开 | background |  | 背景选区 | 应用edit下的二级功能时触发 | 仅在结果页选择效果图打勾时上报 |  |  |
| 新增事件参数 | 0 | 1 | second_func_use | 二级功能打勾 | auto_icon | 用户选取的主体 | 普通参数 | string | 若使用多个上报多个，逗号隔开 | subject |  | 人物主体选区 | 应用edit下的二级功能时触发 | 仅在结果页选择效果图打勾时上报 |  |  |
| 新增事件参数 | 0 | 1 | second_func_use | 二级功能打勾 | auto_icon | 用户选取的主体 | 普通参数 | string | 若使用多个上报多个，逗号隔开 | clothes |  | 衣物选区 | 应用edit下的二级功能时触发 | 仅在结果页选择效果图打勾时上报 |  |  |
| 新增事件参数 | 0 | 1 | second_func_use | 二级功能打勾 | auto_icon | 用户选取的主体 | 普通参数 | string | 若使用多个上报多个，逗号隔开 | hair |  | 头发选区 | 应用edit下的二级功能时触发 | 仅在结果页选择效果图打勾时上报 |  |  |
| 新增事件参数 | 0 | 1 | second_func_use | 二级功能打勾 | auto_icon | 用户选取的主体 | 普通参数 | string | 若使用多个上报多个，逗号隔开 | bag |  | 包包选区 | 应用edit下的二级功能时触发 | 仅在结果页选择效果图打勾时上报 |  |  |
| 新增事件参数 | 0 | 1 | second_func_use | 二级功能打勾 | auto_icon | 用户选取的主体 | 普通参数 | string | 若使用多个上报多个，逗号隔开 | muscle |  | 肌肉选区 | 应用edit下的二级功能时触发 | 仅在结果页选择效果图打勾时上报 |  |  |
| 影响事件 | 0 | 1 | second_func_save | 二级功能保存 | first_func |  | 普通参数 | string |  | edit |  |  | 保存edit下的二级功能 |  |  |  |
| 影响事件 | 0 | 1 | second_func_save | 二级功能保存 | second_func |  | 普通参数 | string | plump | ai_replace |  |  | 保存edit下的二级功能 |  |  |  |
| 影响事件 | 0 | 1 | second_func_save | 二级功能保存 | prf_text |  | 普通参数 | string |  |  |  |  | 保存edit下的二级功能 |  |  |  |
| 新增事件参数 | 0 | 1 | second_func_save | 二级功能保存 | auto_icon | 用户选取的主体 | 普通参数 | string | 若使用多个上报多个，逗号隔开 | manual |  | 手动选取 | 保存edit下的二级功能 |  |  |  |
| 新增事件参数 | 0 | 1 | second_func_save | 二级功能保存 | auto_icon | 用户选取的主体 | 普通参数 | string | 若使用多个上报多个，逗号隔开 | background |  | 背景选区 | 保存edit下的二级功能 |  |  |  |
| 新增事件参数 | 0 | 1 | second_func_save | 二级功能保存 | auto_icon | 用户选取的主体 | 普通参数 | string | 若使用多个上报多个，逗号隔开 | subject |  | 人物主体选区 | 保存edit下的二级功能 |  |  |  |
| 新增事件参数 | 0 | 1 | second_func_save | 二级功能保存 | auto_icon | 用户选取的主体 | 普通参数 | string | 若使用多个上报多个，逗号隔开 | clothes |  | 衣物选区 | 保存edit下的二级功能 |  |  |  |
| 新增事件参数 | 0 | 1 | second_func_save | 二级功能保存 | auto_icon | 用户选取的主体 | 普通参数 | string | 若使用多个上报多个，逗号隔开 | hair |  | 头发选区 | 保存edit下的二级功能 |  |  |  |
| 新增事件参数 | 0 | 1 | second_func_save | 二级功能保存 | auto_icon | 用户选取的主体 | 普通参数 | string | 若使用多个上报多个，逗号隔开 | bag |  | 包包选区 | 保存edit下的二级功能 |  |  |  |
| 新增事件参数 | 0 | 1 | second_func_save | 二级功能保存 | auto_icon | 用户选取的主体 | 普通参数 | string | 若使用多个上报多个，逗号隔开 | muscle |  | 肌肉选区 | 保存edit下的二级功能 |  |  |  |
| 新增事件参数 | 0 | 1 | second_func_save | 二级功能保存 | is_recomend_text |  | 普通参数 | string |  | 0 |  | 手动输入词 | 保存edit下的二级功能 |  |  |  |
| 新增事件参数 | 0 | 1 | second_func_save | 二级功能保存 | is_recomend_text |  | 普通参数 | string |  | 1 |  | 使用推荐词 | 保存edit下的二级功能 |  |  |  |
| 影响事件 | 0 | 1 | label_click | ai replace 功能label点击 | label_id |  | 普通参数 | string | pumpkin,skull,spooky的标签ID |  |  |  | ai replace 功能label点击时上报 |  |  |  |
| 影响事件 | 0 | 1 | ai_func_use_result | 使用ai算法请求结果返回 | first_func | 一级功能参数 | 普通参数 | string |  | edit |  |  | 使用ai算法请求结果返回时触发 |  |  |  |
| 影响事件 | 0 | 1 | ai_func_use_result | 使用ai算法请求结果返回 | second_func | 二级功能参数 | 普通参数 | string |  | ai_replace |  |  | 使用ai算法请求结果返回时触发 |  |  |  |
| 影响事件 | 0 | 1 | ai_func_use_result | 使用ai算法请求结果返回 | is_success | 应用效果(图片处理)是否成功 | 普通参数 | number |  |  |  |  | 使用ai算法请求结果返回时触发 |  |  |  |
| 影响事件 | 0 | 1 | ai_func_use_result | 使用ai算法请求结果返回 | time | 应用时长 | 普通参数 | number |  |  |  |  | 使用ai算法请求结果返回时触发 |  |  |  |
| 影响事件 | 0 | 1 | ai_func_use_result | 使用ai算法请求结果返回 | is_generate_again | 是否通过generate again请求结果 | 普通参数 | number | 是否通过generate again请求结果 | 1 |  |  | 使用ai算法请求结果返回时触发 |  |  |  |
| 影响事件 | 0 | 1 | ai_func_use_result | 使用ai算法请求结果返回 | is_generate_again | 是否通过generate again请求结果 | 普通参数 | number | 是否通过generate again请求结果 | 0 |  |  | 使用ai算法请求结果返回时触发 |  |  |  |
| 影响事件 | 0 | 1 | ai_func_use_result | 使用ai算法请求结果返回 | pic_num | 返回的图片张数 | 普通参数 | string |  |  |  |  | 使用ai算法请求结果返回时触发 |  |  |  |
| 影响事件 | 0 | 1 | ai_func_delivery | 请求ai算法 | first_func | 一级功能参数 | 普通参数 | string |  | edit |  |  | 请求（是否拦截）的时候上报（缓存不报） |  |  |  |
| 影响事件 | 0 | 1 | ai_func_delivery | 请求ai算法 | second_func | 二级功能参数 | 普通参数 | string |  | ai_replace |  |  | 请求（是否拦截）的时候上报（缓存不报） |  |  |  |
| 影响事件 | 0 | 1 | w_subscription_success | 订阅成功 | source_module | 进入订阅页来源模块 | 普通参数 | string |  | p_edit |  |  | 进入订阅页时上报 |  |  |  |
| 影响事件 | 0 | 1 | w_subscription_success | 订阅成功 | source_0 | 进入订阅页来源-0 | 普通参数 | string |  | f_ai_replace |  |  | 进入订阅页时上报 |  |  |  |
| 影响事件 | 0 | 1 | w_subscription_click | 订阅页点击订阅按钮 | source_module | 进入订阅页来源模块 | 普通参数 | string |  | p_edit |  |  | 选中某个plan并点击订阅按钮时上报 |  |  |  |
| 影响事件 | 0 | 1 | w_subscription_click | 订阅页点击订阅按钮 | source_0 | 进入订阅页来源-0 | 普通参数 | string |  | f_ai_replace |  |  | 选中某个plan并点击订阅按钮时上报 |  |  |  |
| 影响事件 | 0 | 1 | w_subscription_enter | 进入订阅页 | source_module | 进入订阅页来源模块 | 普通参数 | string |  | p_edit |  |  | 成功订阅时上报成功付费时上报 |  |  |  |
| 影响事件 | 0 | 1 | w_subscription_enter | 进入订阅页 | source_0 | 进入订阅页来源-0 | 普通参数 | string |  | f_ai_replace |  |  | 成功订阅时上报成功付费时上报 |  |  |  |
| 影响事件 | 0 | 1 | cloudfilter_per_show | 图片云处理权限弹窗点击 | port |  | 普通参数 | string |  | app |  |  |  |  |  |  |
| 新增事件参数值 | 0 | 1 | cloudfilter_per_show | 图片云处理权限弹窗点击 | function | 功能 | 普通参数 | string |  | ai_replace |  |  |  |  |  |  |
| 影响事件 | 0 | 1 | cloudfilter_per_show_ok | 图片云处理权限弹窗点击 | port |  | 普通参数 | string |  | app |  |  |  |  |  |  |
| 影响事件 | 0 | 1 | cloudfilter_per_show_ok | 图片云处理权限弹窗点击 | type |  | 普通参数 | string |  | cancel |  |  |  |  |  |  |
| 影响事件 | 0 | 1 | cloudfilter_per_show_ok | 图片云处理权限弹窗点击 | type |  | 普通参数 | string |  | agree |  |  |  |  |  |  |
| 新增事件参数值 | 0 | 1 | cloudfilter_per_show_ok | 图片云处理权限弹窗点击 | function |  | 普通参数 | string |  | ai_replace |  |  |  |  |  |  |
| 新增事件 | 0 | 1 | icon_click | ai replace点击选区icon | icon |  | 普通参数 | string |  | background |  |  | ai replace点击选区icon |  |  |  |
| 新增事件 | 0 | 1 | icon_click | ai replace点击选区icon | icon |  | 普通参数 | string |  | subject |  |  | ai replace点击选区icon |  |  |  |
| 新增事件 | 0 | 1 | icon_click | ai replace点击选区icon | icon |  | 普通参数 | string |  | clothes |  |  | ai replace点击选区icon |  |  |  |
| 新增事件 | 0 | 1 | icon_click | ai replace点击选区icon | icon |  | 普通参数 | string |  | hair |  |  | ai replace点击选区icon |  |  |  |
| 新增事件 | 0 | 1 | icon_click | ai replace点击选区icon | icon |  | 普通参数 | string |  | bag |  |  | ai replace点击选区icon |  |  |  |
| 新增事件 | 0 | 1 | icon_click | ai replace点击选区icon | icon |  | 普通参数 | string |  | muscle |  |  | ai replace点击选区icon |  |  |  |
| 新增事件 | 0 | 1 | icon_click | ai replace点击选区icon | function |  | 普通参数 | string |  | ai_replace |  |  | ai replace点击选区icon |  |  |  |