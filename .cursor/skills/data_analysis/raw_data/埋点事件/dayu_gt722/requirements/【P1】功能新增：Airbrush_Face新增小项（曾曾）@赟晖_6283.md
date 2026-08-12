| 需求类型 | 事件来源 | 事件类型 | *事件id | *事件名称 | 参数 | 参数名称 | 参数类型 | 参数值类型 | 参数口径 | 参数值 | 参数值名称 | 参数值口径 | *统计口径 | 备注说明 | 事件分组 | 标签 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 影响事件 | 0 | 1 | second_func_use | 二级功能打勾 | first_func | 一级功能参数 | 普通参数 | string |  | retouch |  |  | 应用edit下的二级功能时触发 |  |  |  |
| 影响事件 | 0 | 1 | second_func_use | 二级功能打勾 | second_func | 二级功能参数 | 普通参数 | string | makeup | face |  |  | 应用edit下的二级功能时触发 |  |  |  |
| 影响事件 | 0 | 1 | second_func_use | 二级功能打勾 | is_effect | 是否有应用任一效果 | 普通参数 | string |  |  |  |  | 应用edit下的二级功能时触发 |  |  |  |
| 影响事件 | 0 | 1 | second_func_use | 二级功能打勾 | prf_nose_mod | nose各项调整数值 | 普通参数 | string | size:xx;length:xx;width:xx;bridge:xx;tip:xx;root:xx |  |  |  | 应用edit下的二级功能时触发 |  |  |  |
| 影响事件 | 0 | 1 | second_func_use | 二级功能打勾 | prf_jaw_mod | jaw各项调整数值 | 普通参数 | string | chin:xx;double_chin:xx;jaw:xx;jaw_line:xx;length:xx;jaw_shape:xx;double_chin_pro:xx |  |  |  | 应用edit下的二级功能时触发 |  |  |  |
| 影响事件 | 0 | 1 | second_func_use | 二级功能打勾 | is_background_protect | 背景保护开关是否打开 | 普通参数 | string |  |  |  |  | 应用edit下的二级功能时触发 |  |  |  |
| 影响事件 | 0 | 1 | second_func_use | 二级功能打勾 | is_adjust_background_protect | 是否开打开过背景保护的开关 | 普通参数 | string |  |  |  |  | 应用edit下的二级功能时触发 |  |  |  |
| 影响事件 | 0 | 1 | second_func_use | 二级功能打勾 | single_side_used | 是否使用单侧调节 | 普通参数 | string |  |  |  |  | 应用edit下的二级功能时触发 |  |  |  |
| 影响事件 | 0 | 1 | second_func_save | 二级功能保存 | first_func |  | 普通参数 | string |  | retouch |  |  | 保存edit下的二级功能 |  |  |  |
| 影响事件 | 0 | 1 | second_func_save | 二级功能保存 | second_func |  | 普通参数 | string |  | face |  |  | 保存edit下的二级功能 |  |  |  |
| 影响事件 | 0 | 1 | second_func_save | 二级功能保存 | prf_nose_mod |  | 普通参数 | string | size:xx;length:xx;width:xx;bridge:xx;tip:xx;root:xx |  |  |  | 保存edit下的二级功能 |  |  |  |
| 影响事件 | 0 | 1 | second_func_save | 二级功能保存 | prf_jaw_mod |  | 普通参数 | string | chin:xx;double_chin:xx;jaw:xx;jaw_line:xx;length:xx;jaw_shape:xx;double_chin_pro:xx |  |  |  | 保存edit下的二级功能 |  |  |  |
| 影响事件 | 0 | 1 | second_func_save | 二级功能保存 | is_background_protect | 背景保护开关是否打开 | 普通参数 | string |  |  |  |  | 保存edit下的二级功能 |  |  |  |
| 影响事件 | 0 | 1 | second_func_save | 二级功能保存 | is_adjust_background_protect |  | 普通参数 | string |  |  |  |  | 保存edit下的二级功能 |  |  |  |
| 影响事件 | 0 | 1 | second_func_save | 二级功能保存 | single_side_used |  | 普通参数 | string |  |  |  |  | 保存edit下的二级功能 |  |  |  |
| 影响事件 | 0 | 1 | edit_save | 编辑保存 | prf_first_func | 一级功能参数 | 普通参数 | string | 多个分割, 一级、二级、三级功能一一对应 | retouch |  |  | 结束编辑最终保存时触发 |  |  |  |
| 影响事件 | 0 | 1 | edit_save | 编辑保存 | prf_second_func | 二级功能参数 | 普通参数 | string | 多个分割, 一级、二级、三级功能一一对应，若无对应二级功能该位置报 0 | face |  |  | 结束编辑最终保存时触发 |  |  |  |
| 影响事件 | 0 | 1 | edit_save | 编辑保存 | prf_third_func | 三级功能参数 | 普通参数 | string | 只到waist | nose |  |  | 结束编辑最终保存时触发 |  |  |  |
| 影响事件 | 0 | 1 | edit_save | 编辑保存 | prf_third_func | 三级功能参数 | 普通参数 | string | 只到waist | jaw |  |  | 结束编辑最终保存时触发 |  |  |  |
| 影响事件 | 0 | 1 | third_func_enter | 点击三级功能页面 | first_func | 一级功能参数 | 普通参数 | string |  | retouch |  |  | 点击三级功能页面时上报 |  |  |  |
| 影响事件 | 0 | 1 | third_func_enter | 点击三级功能页面 | second_func | 二级功能参数 | 普通参数 | string |  | face |  |  | 点击三级功能页面时上报 |  |  |  |
| 影响事件 | 0 | 1 | third_func_enter | 点击三级功能页面 | third_func | 三级功能参数 | 普通参数 | string | auto是点一次报一次(因为每次点击auto应用状态有变化) | nose |  |  | 点击三级功能页面时上报 |  |  |  |
| 影响事件 | 0 | 1 | third_func_enter | 点击三级功能页面 | third_func | 三级功能参数 | 普通参数 | string | auto是点一次报一次(因为每次点击auto应用状态有变化) | jaw |  |  | 点击三级功能页面时上报 |  |  |  |
| 影响事件 | 0 | 1 | ai_func_use_result | 使用ai算法请求结果返回 | first_func | 一级功能参数 | 普通参数 | string |  | retouch |  |  | 使用ai算法请求结果返回时触发 |  |  |  |
| 影响事件 | 0 | 1 | ai_func_use_result | 使用ai算法请求结果返回 | second_func | 二级功能参数 | 普通参数 | string |  | face |  |  | 使用ai算法请求结果返回时触发 |  |  |  |
| 影响事件 | 0 | 1 | ai_func_use_result | 使用ai算法请求结果返回 | third_func | 三级功能参数 | 普通参数 | string |  | background_protect |  |  | 使用ai算法请求结果返回时触发 |  |  |  |
| 影响事件 | 0 | 1 | ai_func_use_result | 使用ai算法请求结果返回 | is_success | 应用效果(图片处理)是否成功 | 普通参数 | number |  |  |  |  | 使用ai算法请求结果返回时触发 |  |  |  |
| 影响事件 | 0 | 1 | ai_func_use_result | 使用ai算法请求结果返回 | time | 应用时长 | 普通参数 | number |  |  |  |  | 使用ai算法请求结果返回时触发 |  |  |  |
| 新增事件参数值 | 0 | 1 | ai_func_use_result | 使用ai算法请求结果返回 | third_func | 三级功能参数 | 普通参数 | string |  | double_chin_pro |  |  | 使用ai算法请求结果返回时触发 |  |  |  |
| 影响事件 | 0 | 1 | fourth_func_click | 四级功能点击 | first_func | 一级功能参数 | 普通参数 | string |  | retouch |  |  | 四级功能点击时触发 |  |  |  |
| 影响事件 | 0 | 1 | fourth_func_click | 四级功能点击 | second_func | 二级功能参数 | 普通参数 | string |  | face |  |  | 四级功能点击时触发 |  |  |  |
| 影响事件 | 0 | 1 | fourth_func_click | 四级功能点击 | third_func | 点击的子功能 | 普通参数 | string |  | nose |  |  | 四级功能点击时触发 |  |  |  |
| 影响事件 | 0 | 1 | fourth_func_click | 四级功能点击 | third_func | 点击的子功能 | 普通参数 | string |  | jaw |  |  | 四级功能点击时触发 |  |  |  |
| 新增事件参数值 | 0 | 1 | fourth_func_click | 四级功能点击 | fourth_func | 点击的子子功能 | 普通参数 | string |  | root |  | nose上报 | 四级功能点击时触发 |  |  |  |
| 新增事件参数值 | 0 | 1 | fourth_func_click | 四级功能点击 | fourth_func | 点击的子子功能 | 普通参数 | string |  | double_chin_pro |  | jaw上报 | 四级功能点击时触发 |  |  |  |
| 影响事件 | 0 | 1 | w_subscription_click | 订阅页点击订阅按钮 | source_module | 进入订阅页来源模块 | 普通参数 | string |  | p_edit |  |  | 选中某个plan并点击订阅按钮时上报 |  |  |  |
| 影响事件 | 0 | 1 | w_subscription_click | 订阅页点击订阅按钮 | source_0 | 进入订阅页来源-0 | 普通参数 | string |  | f_face |  |  | 选中某个plan并点击订阅按钮时上报 |  |  |  |
| 影响事件 | 0 | 1 | w_subscription_click | 订阅页点击订阅按钮 | source_1 | 进入订阅页来源-1 | 普通参数 | string | beach_day,indigo,soft_glow,sunlit | jaw |  |  | 选中某个plan并点击订阅按钮时上报 |  |  |  |
| 影响事件 | 0 | 1 | w_subscription_enter | 进入订阅页 | source_module | 进入订阅页来源模块 | 普通参数 | string |  | p_edit |  |  | 成功订阅时上报成功付费时上报 |  |  |  |
| 影响事件 | 0 | 1 | w_subscription_enter | 进入订阅页 | source_0 | 进入订阅页来源-0 | 普通参数 | string |  | f_face |  |  | 成功订阅时上报成功付费时上报 |  |  |  |
| 影响事件 | 0 | 1 | w_subscription_enter | 进入订阅页 | source_1 | 进入订阅页来源-1 | 普通参数 | string |  | jaw |  |  | 成功订阅时上报成功付费时上报 |  |  |  |
| 影响事件 | 0 | 1 | w_subscription_success | 订阅成功 | source_module | 进入订阅页来源模块 | 普通参数 | string |  | p_edit |  |  | 进入订阅页时上报 |  |  |  |
| 影响事件 | 0 | 1 | w_subscription_success | 订阅成功 | source_0 | 进入订阅页来源-0 | 普通参数 | string |  | f_face |  |  | 进入订阅页时上报 |  |  |  |
| 影响事件 | 0 | 1 | w_subscription_success | 订阅成功 | source_1 | 进入订阅页来源-1 | 普通参数 | string |  | jaw |  |  | 进入订阅页时上报 |  |  |  |
| 影响事件 | 0 | 1 | cloudfilter_per_show | 图片云处理权限弹窗点击 | port |  | 普通参数 | string |  | app |  |  |  |  |  |  |
| 新增事件参数值 | 0 | 1 | cloudfilter_per_show | 图片云处理权限弹窗点击 | function | 功能 | 普通参数 | string |  | face_ double_chin_pro |  |  |  |  |  |  |
| 影响事件 | 0 | 1 | cloudfilter_per_show_ok | 图片云处理权限弹窗点击 | port |  | 普通参数 | string |  | app |  |  |  |  |  |  |
| 影响事件 | 0 | 1 | cloudfilter_per_show_ok | 图片云处理权限弹窗点击 | type |  | 普通参数 | string |  | cancel |  |  |  |  |  |  |
| 影响事件 | 0 | 1 | cloudfilter_per_show_ok | 图片云处理权限弹窗点击 | type |  | 普通参数 | string |  | agree |  |  |  |  |  |  |
| 影响事件 | 0 | 1 | cloudfilter_per_show_ok | 图片云处理权限弹窗点击 | version |  | 普通参数 | string | 用户同意隐私协议版本号 |  |  |  |  |  |  |  |
| 新增事件参数值 | 0 | 1 | cloudfilter_per_show_ok | 图片云处理权限弹窗点击 | function |  | 普通参数 | string |  | face_ double_chin_pro |  |  |  |  |  |  |