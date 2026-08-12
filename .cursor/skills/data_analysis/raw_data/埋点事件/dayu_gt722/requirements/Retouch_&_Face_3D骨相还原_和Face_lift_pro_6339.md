| 需求类型 | 事件来源 | 事件类型 | *事件id | *事件名称 | 参数 | 参数名称 | 参数类型 | 参数值类型 | 参数口径 | 参数值 | 参数值名称 | 参数值口径 | *统计口径 | 备注说明 | 事件分组 | 标签 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 新增事件参数值 | 0 | 1 | ai_func_delivery | 请求ai算法 | third_func | 三级功能参数 | 普通参数 | string |  | face |  |  | 请求（是否拦截）的时候上报（缓存不报） |  |  |  |
| 新增事件参数值 | 0 | 1 | ai_func_delivery | 请求ai算法 | material_name |  | 普通参数 | string |  | refine |  | ai retouch上报 | 请求（是否拦截）的时候上报（缓存不报） |  |  |  |
| 新增事件参数值 | 0 | 1 | ai_func_delivery | 请求ai算法 | fourth_func |  | 普通参数 | string |  | sculpt |  | face上报 | 请求（是否拦截）的时候上报（缓存不报） |  |  |  |
| 新增事件参数值 | 0 | 1 | ai_func_delivery | 请求ai算法 | fourth_func |  | 普通参数 | string |  | lift_pro |  | face上报 | 请求（是否拦截）的时候上报（缓存不报） |  |  |  |
| 影响事件 | 0 | 1 | ai_func_delivery | 请求ai算法 | second_func | 二级功能参数 | 普通参数 | string |  | face |  |  | 请求（是否拦截）的时候上报（缓存不报） |  |  |  |
| 影响事件 | 0 | 1 | ai_func_delivery | 请求ai算法 | second_func | 二级功能参数 | 普通参数 | string |  | ai_retouch |  |  | 请求（是否拦截）的时候上报（缓存不报） |  |  |  |
| 新增事件参数值 | 0 | 1 | ai_func_use_result | 使用ai算法请求结果返回 | third_func | 三级功能参数 | 普通参数 | string |  | face |  |  | 使用ai算法请求结果返回时触发 |  |  |  |
| 新增事件参数值 | 0 | 1 | ai_func_use_result | 使用ai算法请求结果返回 | material_name | 素材名称 | 普通参数 | string | Shimmer | refine |  | ai retouch上报 | 使用ai算法请求结果返回时触发 |  |  |  |
| 新增事件参数值 | 0 | 1 | ai_func_use_result | 使用ai算法请求结果返回 | fourth_func |  | 普通参数 | string |  | sculpt |  | face上报 | 使用ai算法请求结果返回时触发 |  |  |  |
| 新增事件参数值 | 0 | 1 | ai_func_use_result | 使用ai算法请求结果返回 | fourth_func |  | 普通参数 | string |  | lift_pro |  | face上报 | 使用ai算法请求结果返回时触发 |  |  |  |
| 影响事件 | 0 | 1 | ai_func_use_result | 使用ai算法请求结果返回 | second_func | 二级功能参数 | 普通参数 | string |  | face |  |  | 使用ai算法请求结果返回时触发 |  |  |  |
| 影响事件 | 0 | 1 | ai_func_use_result | 使用ai算法请求结果返回 | second_func | 二级功能参数 | 普通参数 | string |  | ai_retouch |  |  | 使用ai算法请求结果返回时触发 |  |  |  |
| 新增事件参数值 | 0 | 1 | cloudfilter_per_show | 图片云处理权限弹窗点击 | function | 功能 | 普通参数 | string | relight_beach_day,relight_indigo,relight_soft_glow,relight_sunlit | face_lift_pro |  |  |  |  |  |  |
| 新增事件参数值 | 0 | 1 | cloudfilter_per_show | 图片云处理权限弹窗点击 | function | 功能 | 普通参数 | string | relight_beach_day,relight_indigo,relight_soft_glow,relight_sunlit | face_sculpt |  |  |  |  |  |  |
| 影响事件 | 0 | 1 | cloudfilter_per_show | 图片云处理权限弹窗点击 | function | 功能 | 普通参数 | string | relight_beach_day,relight_indigo,relight_soft_glow,relight_sunlit | ai_retouch |  |  |  |  |  |  |
| 新增事件参数值 | 0 | 1 | cloudfilter_per_show_ok | 图片云处理权限弹窗点击 | function |  | 普通参数 | string | relight_beach_day,relight_indigo,relight_soft_glow,relight_sunlit | face_lift_pro |  |  |  |  |  |  |
| 新增事件参数值 | 0 | 1 | cloudfilter_per_show_ok | 图片云处理权限弹窗点击 | function |  | 普通参数 | string | relight_beach_day,relight_indigo,relight_soft_glow,relight_sunlit | face_sculpt |  |  |  |  |  |  |
| 影响事件 | 0 | 1 | cloudfilter_per_show_ok | 图片云处理权限弹窗点击 | function |  | 普通参数 | string | relight_beach_day,relight_indigo,relight_soft_glow,relight_sunlit | ai_retouch |  |  |  |  |  |  |
| 新增事件参数值 | 0 | 1 | fourth_func_click | 四级功能点击 | fourth_func | 点击的子子功能 | 普通参数 | string |  | sculpt |  |  | 四级功能点击时触发 | fourth_func_exposure也报 |  |  |
| 新增事件参数值 | 0 | 1 | fourth_func_click | 四级功能点击 | fourth_func | 点击的子子功能 | 普通参数 | string |  | lift_pro |  |  | 四级功能点击时触发 | fourth_func_exposure也报 |  |  |
| 影响事件 | 0 | 1 | fourth_func_click | 四级功能点击 | second_func | 二级功能参数 | 普通参数 | string |  | face |  |  | 四级功能点击时触发 | fourth_func_exposure也报 |  |  |
| 新增事件参数 | 0 | 1 | fourth_func_click | 四级功能点击 | from |  | 普通参数 | string |  | mini_icon |  |  | 四级功能点击时触发 | fourth_func_exposure也报 |  |  |
| 新增事件参数值 | 0 | 1 | second_func_save | 二级功能保存 | prf_face_mod |  | 普通参数 | string |  |  |  | chin:xx;lift_pro:xx;width:xx;defined:xx;forehead:xx;cheekbone:xx;doublechin:xx;temple:xx;3d_lift:xx;top:xx;midface:xx;lower_face:xx | 保存edit下的二级功能 | 新增lift pro 和defined滑杆值.（固化逻辑 报最后一个） |  |  |
| 影响事件 | 0 | 1 | second_func_save | 二级功能保存 | second_func |  | 普通参数 | string | plump | face |  |  | 保存edit下的二级功能 | 新增lift pro 和defined滑杆值.（固化逻辑 报最后一个） |  |  |
| 影响事件 | 0 | 1 | second_func_save | 二级功能保存 | second_func |  | 普通参数 | string | plump | ai_retouch |  |  | 保存edit下的二级功能 | 新增lift pro 和defined滑杆值.（固化逻辑 报最后一个） |  |  |
| 新增事件参数值 | 0 | 1 | second_func_use | 二级功能打勾 | prf_face_mod | face各项调整数值 | 普通参数 | string |  |  |  | chin:xx;lift_pro:xx;width:xx;defined:xx;forehead:xx;cheekbone:xx;doublechin:xx;temple:xx;3d_lift:xx;top:xx;midface:xx;lower_face:xx | 应用edit下的二级功能时触发 | 新增lift pro 和defined滑杆值.（固化逻辑 报最后一个） |  |  |
| 影响事件 | 0 | 1 | second_func_use | 二级功能打勾 | second_func | 二级功能参数 | 普通参数 | string | 功能名 | face |  |  | 应用edit下的二级功能时触发 | 新增lift pro 和defined滑杆值.（固化逻辑 报最后一个） |  |  |
| 影响事件 | 0 | 1 | second_func_use | 二级功能打勾 | second_func | 二级功能参数 | 普通参数 | string | 功能名 | ai_retouch |  |  | 应用edit下的二级功能时触发 | 新增lift pro 和defined滑杆值.（固化逻辑 报最后一个） |  |  |
| 影响事件 | 0 | 1 | edit_save | 编辑保存 | mids_material_id | 素材id | 普通参数 | string |  |  |  |  | 结束编辑最终保存时触发 | 确认face 和ai reotuch上报 |  |  |
| 影响事件 | 0 | 1 | edit_save | 编辑保存 | prf_second_func | 二级功能参数 | 普通参数 | string | 多个分割, 一级、二级、三级功能一一对应，若无对应二级功能该位置报 0 |  |  |  | 结束编辑最终保存时触发 | 确认face 和ai reotuch上报 |  |  |
| 影响事件 | 0 | 1 | material_check | 素材打勾 | mids_material_id | 素材id | 普通参数 | string |  |  |  |  | 应用功能时触发 |  |  |  |
| 影响事件 | 0 | 1 | material_check | 素材打勾 | material_type | 素材类型 | 普通参数 | string | hair_dye,hairstyles,hair_enrich(hair_enrich新增),volume,texture(对照组报) | ai_retouch |  |  | 应用功能时触发 |  |  |  |
| 影响事件 | 0 | 1 | material_click | 素材点击 | material_id | 素材id | 普通参数 | string |  |  |  |  | 素材点击时触发 |  |  |  |
| 影响事件 | 0 | 1 | material_click | 素材点击 | material_type | 素材类型 | 普通参数 | string | hair_dye,hairstyles,hair_enrich(hair_enrich新增),volume,texture(对照组报) | ai_retouch |  |  | 素材点击时触发 |  |  |  |
| 影响事件 | 0 | 1 | material_exposure | 素材曝光 | material_id | 素材id | 普通参数 | string |  |  |  |  | 素材曝光时触发 |  |  |  |
| 影响事件 | 0 | 1 | material_exposure | 素材曝光 | material_type | 素材类型 | 普通参数 | string | hair_dye,hairstyles,hair_enrich(hair_enrich新增),volume,texture(对照组报) | ai_retouch |  |  | 素材曝光时触发 |  |  |  |
| 影响事件 | 0 | 1 | w_subscription_click | 订阅页点击订阅按钮 | mids_material_id | 素材id | 普通参数 | string | 发型发色和enrich的素材di |  |  |  | 选中某个plan并点击订阅按钮时上报 |  |  |  |
| 影响事件 | 0 | 1 | w_subscription_click | 订阅页点击订阅按钮 | source_0 | 进入订阅页来源-0 | 普通参数 | string |  | f_ai_retouch |  |  | 选中某个plan并点击订阅按钮时上报 |  |  |  |
| 影响事件 | 0 | 1 | w_subscription_click | 订阅页点击订阅按钮 | source_0 | 进入订阅页来源-0 | 普通参数 | string |  | f_face |  |  | 选中某个plan并点击订阅按钮时上报 |  |  |  |
| 影响事件 | 0 | 1 | w_subscription_click | 订阅页点击订阅按钮 | source_1 | 进入订阅页来源-1 | 普通参数 | string |  | face |  |  | 选中某个plan并点击订阅按钮时上报 |  |  |  |
| 新增事件参数 | 0 | 1 | w_subscription_click | 订阅页点击订阅按钮 | source_2 |  | 普通参数 | string |  | scuplt |  | 仅face上报 | 选中某个plan并点击订阅按钮时上报 |  |  |  |
| 新增事件参数 | 0 | 1 | w_subscription_click | 订阅页点击订阅按钮 | source_2 |  | 普通参数 | string |  | lift_pro |  | 仅face上报 | 选中某个plan并点击订阅按钮时上报 |  |  |  |
| 影响事件 | 0 | 1 | w_subscription_enter | 进入订阅页 | mids_material_id | 素材id | 普通参数 | string | 报发型发色和enrich的素材id |  |  |  | 成功订阅时上报成功付费时上报 |  |  |  |
| 影响事件 | 0 | 1 | w_subscription_enter | 进入订阅页 | source_0 | 进入订阅页来源-0 | 普通参数 | string |  | f_ai_retouch |  |  | 成功订阅时上报成功付费时上报 |  |  |  |
| 影响事件 | 0 | 1 | w_subscription_enter | 进入订阅页 | source_0 | 进入订阅页来源-0 | 普通参数 | string |  | f_face |  |  | 成功订阅时上报成功付费时上报 |  |  |  |
| 影响事件 | 0 | 1 | w_subscription_enter | 进入订阅页 | source_1 | 进入订阅页来源-1 | 普通参数 | string |  | face |  |  | 成功订阅时上报成功付费时上报 |  |  |  |
| 新增事件参数 | 0 | 1 | w_subscription_enter | 进入订阅页 | source_2 |  | 普通参数 | string |  | scuplt |  | 仅face上报 | 成功订阅时上报成功付费时上报 |  |  |  |
| 新增事件参数 | 0 | 1 | w_subscription_enter | 进入订阅页 | source_2 |  | 普通参数 | string |  | lift_pro |  | 仅face上报 | 成功订阅时上报成功付费时上报 |  |  |  |
| 影响事件 | 0 | 1 | w_subscription_success | 订阅成功 | mids_material_id | 素材id | 普通参数 | string |  |  |  |  | 进入订阅页时上报 |  |  |  |
| 影响事件 | 0 | 1 | w_subscription_success | 订阅成功 | source_0 | 进入订阅页来源-0 | 普通参数 | string |  | f_ai_retouch |  |  | 进入订阅页时上报 |  |  |  |
| 影响事件 | 0 | 1 | w_subscription_success | 订阅成功 | source_0 | 进入订阅页来源-0 | 普通参数 | string |  | f_face |  |  | 进入订阅页时上报 |  |  |  |
| 影响事件 | 0 | 1 | w_subscription_success | 订阅成功 | source_1 | 进入订阅页来源-1 | 普通参数 | string |  | face |  |  | 进入订阅页时上报 |  |  |  |
| 新增事件参数 | 0 | 1 | w_subscription_success | 订阅成功 | source_2 |  | 普通参数 | string |  | scuplt |  | 仅face上报 | 进入订阅页时上报 |  |  |  |
| 新增事件参数 | 0 | 1 | w_subscription_success | 订阅成功 | source_2 |  | 普通参数 | string |  | lift_pro |  | 仅face上报 | 进入订阅页时上报 |  |  |  |