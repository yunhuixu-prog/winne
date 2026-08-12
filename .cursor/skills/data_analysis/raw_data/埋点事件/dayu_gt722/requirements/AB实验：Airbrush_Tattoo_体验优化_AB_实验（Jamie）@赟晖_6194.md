| 需求类型 | 事件来源 | 事件类型 | *事件id | *事件名称 | 参数 | 参数名称 | 参数类型 | 参数值类型 | 参数口径 | 参数值 | 参数值名称 | 参数值口径 | *统计口径 | 备注说明 | 事件分组 | 标签 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 影响事件 | 0 | 1 | second_func_enter | 点击二级功能页面 | first_func | 一级功能参数 | 普通参数 | string |  | retouch |  |  | 点击二级功能页面时上报 |  |  |  |
| 影响事件 | 0 | 1 | second_func_enter | 点击二级功能页面 | second_func | 二级功能参数 | 普通参数 | string |  | ai_tattoo |  |  | 点击二级功能页面时上报 |  |  |  |
| 影响事件 | 0 | 1 | material_exposure | 素材曝光 | material_type | 素材类型 | 普通参数 | string | hair_dye,hairstyles,hair_enrich(hair_enrich新增),volume,texture(对照组报) | ai_tattoo |  |  | 素材曝光时触发 |  |  |  |
| 影响事件 | 0 | 1 | material_exposure | 素材曝光 | module | 模块 | 普通参数 | string | edit | edit |  |  | 素材曝光时触发 |  |  |  |
| 影响事件 | 0 | 1 | material_exposure | 素材曝光 | material_id | 素材id | 普通参数 | string |  |  |  |  | 素材曝光时触发 |  |  |  |
| 影响事件 | 0 | 1 | material_exposure | 素材曝光 | category_id | 分类id | 普通参数 | string |  |  |  |  | 素材曝光时触发 |  |  |  |
| 影响事件 | 0 | 1 | material_click | 素材点击 | material_type | 素材类型 | 普通参数 | string | hair_dye,hairstyles,hair_enrich(hair_enrich新增),volume,texture(对照组报) | ai_tattoo |  |  | 素材点击时触发 |  |  |  |
| 影响事件 | 0 | 1 | material_click | 素材点击 | module | 模块 | 普通参数 | string | edit | edit |  |  | 素材点击时触发 |  |  |  |
| 影响事件 | 0 | 1 | material_click | 素材点击 | material_id | 素材id | 普通参数 | string |  |  |  |  | 素材点击时触发 |  |  |  |
| 影响事件 | 0 | 1 | material_click | 素材点击 | category_id | 分类id | 普通参数 | string |  |  |  |  | 素材点击时触发 |  |  |  |
| 影响事件 | 0 | 1 | material_check | 素材打勾 | module | 模块 | 普通参数 | string |  | edit |  |  | 应用功能时触发 |  |  |  |
| 影响事件 | 0 | 1 | material_check | 素材打勾 | material_type | 素材类型 | 普通参数 | string |  | ai_tattoo |  |  | 应用功能时触发 |  |  |  |
| 影响事件 | 0 | 1 | material_check | 素材打勾 | mids_material_id | 素材id | 普通参数 | string |  |  |  |  | 应用功能时触发 |  |  |  |
| 影响事件 | 0 | 1 | material_check | 素材打勾 | mids_category_id | 分类id | 普通参数 | string |  |  |  |  | 应用功能时触发 |  |  |  |
| 影响事件 | 0 | 1 | ai_func_delivery | 请求ai算法 | first_func | 一级功能参数 | 普通参数 | string |  | retouch |  |  | 请求（是否拦截）的时候上报（缓存不报） | 有素材选中且未应用，点击「应用效果弹窗」的「应用」等同于apply按钮，也需要上报 |  |  |
| 影响事件 | 0 | 1 | ai_func_delivery | 请求ai算法 | second_func | 二级功能参数 | 普通参数 | string |  | ai_tattoo |  |  | 请求（是否拦截）的时候上报（缓存不报） | 有素材选中且未应用，点击「应用效果弹窗」的「应用」等同于apply按钮，也需要上报 |  |  |
| 影响事件 | 0 | 1 | ai_func_delivery | 请求ai算法 | material_id | 素材id | 普通参数 | string |  |  |  |  | 请求（是否拦截）的时候上报（缓存不报） | 有素材选中且未应用，点击「应用效果弹窗」的「应用」等同于apply按钮，也需要上报 |  |  |
| 影响事件 | 0 | 1 | ai_func_delivery | 请求ai算法 | category_id | 素材分类id | 普通参数 | number |  |  |  |  | 请求（是否拦截）的时候上报（缓存不报） | 有素材选中且未应用，点击「应用效果弹窗」的「应用」等同于apply按钮，也需要上报 |  |  |
| 影响事件 | 0 | 1 | ai_func_use_result | 使用ai算法请求结果返回 | first_func | 一级功能参数 | 普通参数 | string |  | retouch |  |  | 使用ai算法请求结果返回时触发 | 有素材选中且未应用，点击「应用效果弹窗」的「应用」等同于apply按钮，也需要上报 |  |  |
| 影响事件 | 0 | 1 | ai_func_use_result | 使用ai算法请求结果返回 | second_func | 二级功能参数 | 普通参数 | string |  | ai_tattoo |  |  | 使用ai算法请求结果返回时触发 | 有素材选中且未应用，点击「应用效果弹窗」的「应用」等同于apply按钮，也需要上报 |  |  |
| 影响事件 | 0 | 1 | ai_func_use_result | 使用ai算法请求结果返回 | is_success | 应用效果(图片处理)是否成功 | 普通参数 | number |  |  |  |  | 使用ai算法请求结果返回时触发 | 有素材选中且未应用，点击「应用效果弹窗」的「应用」等同于apply按钮，也需要上报 |  |  |
| 影响事件 | 0 | 1 | ai_func_use_result | 使用ai算法请求结果返回 | time | 应用时长 | 普通参数 | number |  |  |  |  | 使用ai算法请求结果返回时触发 | 有素材选中且未应用，点击「应用效果弹窗」的「应用」等同于apply按钮，也需要上报 |  |  |
| 影响事件 | 0 | 1 | ai_func_use_result | 使用ai算法请求结果返回 | material_id | 素材id | 普通参数 | string |  |  |  |  | 使用ai算法请求结果返回时触发 | 有素材选中且未应用，点击「应用效果弹窗」的「应用」等同于apply按钮，也需要上报 |  |  |
| 影响事件 | 0 | 1 | ai_func_use_result | 使用ai算法请求结果返回 | category_id | 分类id | 普通参数 | string |  |  |  |  | 使用ai算法请求结果返回时触发 | 有素材选中且未应用，点击「应用效果弹窗」的「应用」等同于apply按钮，也需要上报 |  |  |
| 影响事件 | 0 | 1 | second_func_use | 二级功能打勾 | first_func | 一级功能参数 | 普通参数 | string |  | retouch |  |  | 应用edit下的二级功能时触发 | 未应用素材点击打勾弹出「应用效果弹窗」时不上报 |  |  |
| 影响事件 | 0 | 1 | second_func_use | 二级功能打勾 | second_func | 二级功能参数 | 普通参数 | string |  | ai_tattoo |  |  | 应用edit下的二级功能时触发 | 未应用素材点击打勾弹出「应用效果弹窗」时不上报 |  |  |
| 影响事件 | 0 | 1 | second_func_use | 二级功能打勾 | is_effect | 是否有应用任一效果 | 普通参数 | string |  |  |  |  | 应用edit下的二级功能时触发 | 未应用素材点击打勾弹出「应用效果弹窗」时不上报 |  |  |
| 影响事件 | 0 | 1 | edit_save | 编辑保存 | prf_first_func | 一级功能参数 | 普通参数 | string |  | retouch |  |  | 结束编辑最终保存时触发 |  |  |  |
| 影响事件 | 0 | 1 | edit_save | 编辑保存 | prf_second_func | 二级功能参数 | 普通参数 | string |  | ai_tattoo |  |  | 结束编辑最终保存时触发 |  |  |  |
| 影响事件 | 0 | 1 | edit_save | 编辑保存 | mids_category_id | 分类id | 普通参数 | string |  |  |  |  | 结束编辑最终保存时触发 |  |  |  |
| 影响事件 | 0 | 1 | edit_save | 编辑保存 | mids_material_id | 素材id | 普通参数 | string |  |  |  |  | 结束编辑最终保存时触发 |  |  |  |
| 影响事件 | 0 | 1 | edit_save | 编辑保存 | unlock_func | 通过广告解锁付费功能保存的 | 普通参数 | string | ai_tattoo |  |  |  | 结束编辑最终保存时触发 |  |  |  |
| 影响事件 | 0 | 1 | w_subscription_success | 订阅成功 | source_module | 进入订阅页来源模块 | 普通参数 | string |  | p_edit |  |  | 订阅成功时候上报 |  |  |  |
| 影响事件 | 0 | 1 | w_subscription_success | 订阅成功 | source_0 | 进入订阅页来源-0 | 普通参数 | string | f_relight | f_ai_tattoo |  |  | 订阅成功时候上报 |  |  |  |
| 影响事件 | 0 | 1 | w_subscription_success | 订阅成功 | mids_material_id | 素材id | 普通参数 | string |  |  |  |  | 订阅成功时候上报 |  |  |  |
| 影响事件 | 0 | 1 | w_subscription_success | 订阅成功 | mids_category_id | 分类id | 普通参数 | string |  |  |  |  | 订阅成功时候上报 |  |  |  |
| 影响事件 | 0 | 1 | w_subscription_click | 订阅页点击订阅按钮 | source_module | 进入订阅页来源模块 | 普通参数 | string | p_edit | p_edit |  |  | 选中某个plan并点击订阅按钮时上报 |  |  |  |
| 影响事件 | 0 | 1 | w_subscription_click | 订阅页点击订阅按钮 | source_0 | 进入订阅页来源-0 | 普通参数 | string |  | f_ai_tattoo |  |  | 选中某个plan并点击订阅按钮时上报 |  |  |  |
| 影响事件 | 0 | 1 | w_subscription_click | 订阅页点击订阅按钮 | mids_material_id | 素材id | 普通参数 | string | 发型发色和enrich的素材di |  |  |  | 选中某个plan并点击订阅按钮时上报 |  |  |  |
| 影响事件 | 0 | 1 | w_subscription_click | 订阅页点击订阅按钮 | mids_category_id | 分类id | 普通参数 | string | 发型发色和enrich的分类di |  |  |  | 选中某个plan并点击订阅按钮时上报 |  |  |  |
| 影响事件 | 0 | 1 | w_subscription_enter | 进入订阅页 | source_module | 进入订阅页来源模块 | 普通参数 | string | p_edit | p_edit |  |  | 成功订阅时上报成功付费时上报 |  |  |  |
| 影响事件 | 0 | 1 | w_subscription_enter | 进入订阅页 | source_0 | 进入订阅页来源-0 | 普通参数 | string |  | f_ai_tattoo |  |  | 成功订阅时上报成功付费时上报 |  |  |  |
| 影响事件 | 0 | 1 | w_subscription_enter | 进入订阅页 | mids_material_id | 素材id | 普通参数 | string | 报发型发色和enrich的素材id |  |  |  | 成功订阅时上报成功付费时上报 |  |  |  |
| 影响事件 | 0 | 1 | w_subscription_enter | 进入订阅页 | mids_category_id | 分类id | 普通参数 | string | 报发型发色和enrich的分类id |  |  |  | 成功订阅时上报成功付费时上报 |  |  |  |
| 影响事件 | 0 | 1 | popup_show | popup弹窗出现 | pop_id | 弹窗id | 普通参数 | string |  |  |  |  | popup弹窗出现时触发(不包括评分弹窗) |  |  |  |
| 影响事件 | 0 | 1 | popup_show | popup弹窗出现 | page_name | 弹窗出现的页面名称 | 普通参数 | string |  | edit |  |  | popup弹窗出现时触发(不包括评分弹窗) |  |  |  |
| 新增事件参数值 | 0 | 1 | popup_show | popup弹窗出现 | pop_name | 弹窗name | 普通参数 | string |  | ai_tatto_apply_remind |  |  | popup弹窗出现时触发(不包括评分弹窗) |  |  |  |
| 影响事件 | 0 | 1 | popup_click | 点击popup弹窗confirm  button | pop_id | 弹窗id | 普通参数 | string |  |  |  |  | 点击popup弹窗confirm  button触发 (不包括评分弹窗) |  |  |  |
| 影响事件 | 0 | 1 | popup_click | 点击popup弹窗confirm  button | page_name | 弹窗出现的页面名称 | 普通参数 | string |  | edit |  |  | 点击popup弹窗confirm  button触发 (不包括评分弹窗) |  |  |  |
| 新增事件参数值 | 0 | 1 | popup_click | 点击popup弹窗confirm  button | pop_name | 弹窗name | 普通参数 | string |  | ai_tatto_apply_remind |  | 点击「应用」时上报 | 点击popup弹窗confirm  button触发 (不包括评分弹窗) |  |  |  |