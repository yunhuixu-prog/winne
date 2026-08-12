| 需求类型 | 事件来源 | 事件类型 | *事件id | *事件名称 | 参数 | 参数名称 | 参数类型 | 参数值类型 | 参数口径 | 参数值 | 参数值名称 | 参数值口径 | *统计口径 | 备注说明 | 事件分组 | 标签 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 新增事件 | 0 | 1 | button_click | 按钮点击 | name |  | 普通参数 | string |  | more |  |  | enhance按钮点击上报 |  |  |  |
| 新增事件 | 0 | 1 | button_click | 按钮点击 | name |  | 普通参数 | string |  | original |  |  | enhance按钮点击上报 |  |  |  |
| 新增事件 | 0 | 1 | button_click | 按钮点击 | name |  | 普通参数 | string |  | ultra_hd |  |  | enhance按钮点击上报 |  |  |  |
| 新增事件 | 0 | 1 | button_click | 按钮点击 | name |  | 普通参数 | string |  | portrait |  |  | enhance按钮点击上报 |  |  |  |
| 影响事件 | 0 | 1 | popup_show | popup弹窗出现 | pop_name | 弹窗name | 普通参数 | string |  | no_free_delivery_popup |  |  | popup弹窗出现时触发(不包括评分弹窗) |  |  |  |
| 新增事件参数值 | 0 | 1 | popup_show | popup弹窗出现 | first_func | 一级功能参数 | 普通参数 | string |  | enhance |  |  | popup弹窗出现时触发(不包括评分弹窗) |  |  |  |
| 影响事件 | 0 | 1 | popup_click | 点击popup弹窗confirm  button | pop_name | 弹窗name | 普通参数 | string |  | no_free_delivery_popup |  |  | 点击popup弹窗confirm  button触发 (不包括评分弹窗) |  |  |  |
| 新增事件参数值 | 0 | 1 | popup_click | 点击popup弹窗confirm  button | first_func | 一级功能参数 | 普通参数 | string |  | enhance |  |  | 点击popup弹窗confirm  button触发 (不包括评分弹窗) |  |  |  |
| 影响事件 | 0 | 1 | w_subscription_click | 订阅页点击订阅按钮 | source_module | 进入订阅页来源模块 | 普通参数 | string |  | p_edit |  |  | 选中某个plan并点击订阅按钮时上报 |  |  |  |
| 新增事件参数值 | 0 | 1 | w_subscription_click | 订阅页点击订阅按钮 | source_0 | 进入订阅页来源-0 | 普通参数 | string |  | f_enhance |  |  | 选中某个plan并点击订阅按钮时上报 |  |  |  |
| 影响事件 | 0 | 1 | w_subscription_success | 订阅成功 | source_module | 进入订阅页来源模块 | 普通参数 | string |  | p_edit |  |  | 进入订阅页时上报 |  |  |  |
| 新增事件参数值 | 0 | 1 | w_subscription_success | 订阅成功 | source_0 | 进入订阅页来源-0 | 普通参数 | string |  | f_enhance |  |  | 进入订阅页时上报 |  |  |  |
| 影响事件 | 0 | 1 | w_subscription_enter | 进入订阅页 | source_module | 进入订阅页来源模块 | 普通参数 | string |  | p_edit |  |  | 成功订阅时上报成功付费时上报 |  |  |  |
| 新增事件参数值 | 0 | 1 | w_subscription_enter | 进入订阅页 | source_0 | 进入订阅页来源-0 | 普通参数 | string |  | f_enhance |  |  | 成功订阅时上报成功付费时上报 |  |  |  |
| 新增事件参数值 | 0 | 1 | cloudfilter_per_show_ok | 图片云处理权限弹窗点击 | function |  | 普通参数 | string | relight_beach_day,relight_indigo,relight_soft_glow,relight_sunlit | enhance |  |  |  |  |  |  |
| 新增事件参数值 | 0 | 1 | cloudfilter_per_show | 图片云处理权限弹窗点击 | function | 功能 | 普通参数 | string | relight_beach_day,relight_indigo,relight_soft_glow,relight_sunlit | enhance |  |  |  |  |  |  |
| 新增事件参数值 | 0 | 1 | ai_func_use_result | 使用ai算法请求结果返回 | first_func | 一级功能参数 | 普通参数 | string |  | enhance |  |  | 使用ai算法请求结果返回时触发 |  |  |  |
| 新增事件参数 | 0 | 1 | edit_save | 编辑保存 | enhance_quality | 照片质量 | 普通参数 | string | 都有用英文逗号隔开 | original |  |  | 结束编辑最终保存时触发 |  |  |  |
| 新增事件参数 | 0 | 1 | edit_save | 编辑保存 | enhance_quality | 照片质量 | 普通参数 | string | 都有用英文逗号隔开 | ultra_hd |  |  | 结束编辑最终保存时触发 |  |  |  |
| 新增事件参数 | 0 | 1 | edit_save | 编辑保存 | enhance_quality | 照片质量 | 普通参数 | string | 都有用英文逗号隔开 | portrait |  |  | 结束编辑最终保存时触发 |  |  |  |
| 新增事件参数 | 0 | 1 | edit_save | 编辑保存 | type |  | 普通参数 | string | save_original按钮保存报再type，正常保存流程不报该参数 | save_original |  |  | 结束编辑最终保存时触发 |  |  |  |