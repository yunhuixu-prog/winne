| 需求类型 | 事件来源 | 事件类型 | *事件id | *事件名称 | 参数 | 参数名称 | 参数类型 | 参数值类型 | 参数口径 | 参数值 | 参数值名称 | 参数值口径 | *统计口径 | 备注说明 | 事件分组 | 标签 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 影响事件 | 0 | 1 | second_func_use | 二级功能打勾 | second_func | 二级功能参数 | 普通参数 | string | 功能名 | ai_retouch |  |  | 应用edit下的二级功能时触发 |  |  |  |
| 影响事件 | 0 | 1 | second_func_use | 二级功能打勾 | by_value | 滑杆值 | 普通参数 | string |  |  |  |  | 应用edit下的二级功能时触发 |  |  |  |
| 新增事件参数值 | 0 | 1 | second_func_use | 二级功能打勾 | material_name | 素材名称 | 普通参数 | string |  | dewy |  |  | 应用edit下的二级功能时触发 |  |  |  |
| 新增事件参数值 | 0 | 1 | second_func_use | 二级功能打勾 | material_name | 素材名称 | 普通参数 | string |  | defined |  |  | 应用edit下的二级功能时触发 |  |  |  |
| 影响事件 | 0 | 1 | second_func_save | 二级功能保存 | second_func |  | 普通参数 | string | 功能名 | ai_retouch |  |  | 保存edit下的二级功能 |  |  |  |
| 新增事件参数值 | 0 | 1 | second_func_save | 二级功能保存 | material_name | 素材名称 | 普通参数 | string |  | dewy |  |  | 保存edit下的二级功能 |  |  |  |
| 新增事件参数值 | 0 | 1 | second_func_save | 二级功能保存 | material_name | 素材名称 | 普通参数 | string |  | defined |  |  | 保存edit下的二级功能 |  |  |  |
| 影响事件 | 0 | 1 | ai_func_delivery | 请求ai算法 | second_func | 二级功能参数 | 普通参数 | string |  | ai_retouch |  |  | 请求（是否拦截）的时候上报（缓存不报） |  |  |  |
| 新增事件参数值 | 0 | 1 | ai_func_delivery | 请求ai算法 | material_name |  | 普通参数 | string |  | dewy |  |  | 请求（是否拦截）的时候上报（缓存不报） |  |  |  |
| 新增事件参数值 | 0 | 1 | ai_func_delivery | 请求ai算法 | material_name |  | 普通参数 | string |  | defined |  |  | 请求（是否拦截）的时候上报（缓存不报） |  |  |  |
| 影响事件 | 0 | 1 | ai_func_use_result | 使用ai算法请求结果返回 | second_func | 二级功能参数 | 普通参数 | string | 之前second func上报子功能，现在统一上报eraser，third func上报子功能 | ai_retouch |  |  | 使用ai算法请求结果返回时触发 |  |  |  |
| 新增事件参数值 | 0 | 1 | ai_func_use_result | 使用ai算法请求结果返回 | material_name | 素材名称 | 普通参数 | string |  | dewy |  |  | 使用ai算法请求结果返回时触发 |  |  |  |
| 新增事件参数值 | 0 | 1 | ai_func_use_result | 使用ai算法请求结果返回 | material_name | 素材名称 | 普通参数 | string |  | defined |  |  | 使用ai算法请求结果返回时触发 |  |  |  |
| 影响事件 | 0 | 1 | material_exposure | 素材曝光 | material_id | 素材id | 普通参数 | string |  |  |  |  | 素材曝光时触发 |  |  |  |
| 影响事件 | 0 | 1 | material_exposure | 素材曝光 | category_id | 分类id | 普通参数 | string |  |  |  |  | 素材曝光时触发 |  |  |  |
| 影响事件 | 0 | 1 | material_exposure | 素材曝光 | material_type | 素材类型 | 普通参数 | string | hair_dye,hairstyles,hair_enrich(hair_enrich新增),volume,texture(对照组报) | ai_retouch |  |  | 素材曝光时触发 |  |  |  |
| 影响事件 | 0 | 1 | material_exposure | 素材曝光 | module | 模块 | 普通参数 | string | edit | edit |  |  | 素材曝光时触发 |  |  |  |
| 影响事件 | 0 | 1 | material_click | 素材点击 | material_id | 素材id | 普通参数 | string |  |  |  |  | 素材点击时触发 |  |  |  |
| 影响事件 | 0 | 1 | material_click | 素材点击 | category_id | 分类id | 普通参数 | string |  |  |  |  | 素材点击时触发 |  |  |  |
| 影响事件 | 0 | 1 | material_click | 素材点击 | material_type | 素材类型 | 普通参数 | string | hair_dye,hairstyles,hair_enrich(hair_enrich新增),volume,texture(对照组报) | ai_retouch |  |  | 素材点击时触发 |  |  |  |
| 影响事件 | 0 | 1 | material_click | 素材点击 | module | 模块 | 普通参数 | string | edit | edit |  |  | 素材点击时触发 |  |  |  |
| 影响事件 | 0 | 1 | material_check | 素材打勾 | mids_material_id | 素材id | 普通参数 | string |  |  |  |  | 应用功能时触发 |  |  |  |
| 影响事件 | 0 | 1 | material_check | 素材打勾 | mids_category_id | 分类id | 普通参数 | string |  |  |  |  | 应用功能时触发 |  |  |  |
| 影响事件 | 0 | 1 | material_check | 素材打勾 | material_type | 素材类型 | 普通参数 | string | hair_dye,hairstyles,hair_enrich(hair_enrich新增),volume,texture(对照组报) | ai_retouch |  |  | 应用功能时触发 |  |  |  |
| 影响事件 | 0 | 1 | material_check | 素材打勾 | module | 模块 | 普通参数 | string | edit | edit |  |  | 应用功能时触发 |  |  |  |
| 影响事件 | 0 | 1 | w_subscription_enter | 进入订阅页 | source_0 | 进入订阅页来源-0 | 普通参数 | string |  | f_ai_retouch |  |  | 成功订阅时上报成功付费时上报 |  |  |  |
| 影响事件 | 0 | 1 | w_subscription_enter | 进入订阅页 | mids_material_id | 素材id | 普通参数 | string | 报发型发色和enrich的素材id |  |  |  | 成功订阅时上报成功付费时上报 |  |  |  |
| 影响事件 | 0 | 1 | w_subscription_enter | 进入订阅页 | mids_category_id | 分类id | 普通参数 | string | 报发型发色和enrich的分类id |  |  |  | 成功订阅时上报成功付费时上报 |  |  |  |
| 影响事件 | 0 | 1 | w_subscription_enter | 进入订阅页 | source_module | 进入订阅页来源模块 | 普通参数 | string |  | p_edit |  |  | 成功订阅时上报成功付费时上报 |  |  |  |
| 影响事件 | 0 | 1 | w_subscription_click | 订阅页点击订阅按钮 | source_0 | 进入订阅页来源-0 | 普通参数 | string |  | f_ai_retouch |  |  | 选中某个plan并点击订阅按钮时上报 |  |  |  |
| 影响事件 | 0 | 1 | w_subscription_click | 订阅页点击订阅按钮 | mids_material_id | 素材id | 普通参数 | string | 发型发色和enrich的素材di |  |  |  | 选中某个plan并点击订阅按钮时上报 |  |  |  |
| 影响事件 | 0 | 1 | w_subscription_click | 订阅页点击订阅按钮 | mids_category_id | 分类id | 普通参数 | string | 发型发色和enrich的分类di |  |  |  | 选中某个plan并点击订阅按钮时上报 |  |  |  |
| 影响事件 | 0 | 1 | w_subscription_click | 订阅页点击订阅按钮 | source_module | 进入订阅页来源模块 | 普通参数 | string |  | p_edit |  |  | 选中某个plan并点击订阅按钮时上报 |  |  |  |
| 影响事件 | 0 | 1 | w_subscription_success | 订阅成功 | source_0 | 进入订阅页来源-0 | 普通参数 | string |  | f_ai_retouch |  |  | 进入订阅页时上报 |  |  |  |
| 影响事件 | 0 | 1 | w_subscription_success | 订阅成功 | mids_material_id | 素材id | 普通参数 | string |  |  |  |  | 进入订阅页时上报 |  |  |  |
| 影响事件 | 0 | 1 | w_subscription_success | 订阅成功 | mids_category_id | 分类id | 普通参数 | string |  |  |  |  | 进入订阅页时上报 |  |  |  |
| 影响事件 | 0 | 1 | w_subscription_success | 订阅成功 | source_module | 进入订阅页来源模块 | 普通参数 | string |  | p_edit |  |  | 进入订阅页时上报 |  |  |  |