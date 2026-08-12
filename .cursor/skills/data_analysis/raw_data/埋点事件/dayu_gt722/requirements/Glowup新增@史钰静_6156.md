| 需求类型 | 事件来源 | 事件类型 | *事件id | *事件名称 | 参数 | 参数名称 | 参数类型 | 参数值类型 | 参数口径 | 参数值 | 参数值名称 | 参数值口径 | *统计口径 | 备注说明 | 事件分组 | 标签 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 影响事件 | 0 | 1 | second_func_enter | 点击二级功能页面 | second_func | 二级功能参数 | 普通参数 | string | glowup |  |  |  | 点击二级功能页面时上报 |  |  |  |
| 影响事件 | 0 | 1 | second_func_enter | 点击二级功能页面 | from | 进入功能来源 | 普通参数 | string | mini_icon |  |  |  | 点击二级功能页面时上报 |  |  |  |
| 影响事件 | 0 | 1 | second_func_use | 二级功能打勾 | second_func | 二级功能参数 | 普通参数 | string | glowup |  |  |  | 应用edit下的二级功能时触发 |  |  |  |
| 影响事件 | 0 | 1 | second_func_use | 二级功能打勾 | material_name | 素材名称 | 普通参数 | string | Shimmer |  |  |  | 应用edit下的二级功能时触发 |  |  |  |
| 影响事件 | 0 | 1 | second_func_use | 二级功能打勾 | value | 应用的滑杆值 | 普通参数 | string | 各个维度滑竿值(整数)，用分号隔开。例如： intensity:xx;size:xx;tan line:xx |  |  |  | 应用edit下的二级功能时触发 |  |  |  |
| 影响事件 | 0 | 1 | third_func_enter | 点击三级功能页面 | third_func | 三级功能参数 | 普通参数 | string | Shimmer |  |  |  | 点击三级功能页面时上报 |  |  |  |
| 影响事件 | 0 | 1 | third_func_enter | 点击三级功能页面 | second_func | 二级功能参数 | 普通参数 | string | glowup |  |  |  | 点击三级功能页面时上报 |  |  |  |
| 影响事件 | 0 | 1 | second_func_save | 二级功能保存 | second_func |  | 普通参数 | string | glowup |  |  |  | 保存edit下的二级功能 |  |  |  |
| 影响事件 | 0 | 1 | second_func_save | 二级功能保存 | material_name | 素材名称 | 普通参数 | string | Shimmer |  |  |  | 保存edit下的二级功能 |  |  |  |
| 影响事件 | 0 | 1 | ai_func_use_result | 使用ai算法请求结果返回 | material_name | 素材名称 | 普通参数 | string | Shimmer |  |  |  | 使用ai算法请求结果返回时触发 |  |  |  |
| 影响事件 | 0 | 1 | edit_save | 编辑保存 | prf_second_func | 二级功能参数 | 普通参数 | string | glowup |  |  |  | 结束编辑最终保存时触发 |  |  |  |
| 影响事件 | 0 | 1 | w_subscription_enter | 进入订阅页 | source_0 | 进入订阅页来源-0 | 普通参数 | string | f_glowup |  |  |  | 成功订阅时上报成功付费时上报 |  |  |  |
| 影响事件 | 0 | 1 | w_subscription_enter | 进入订阅页 | source_1 | 进入订阅页来源-1 | 普通参数 | string | Shimmer |  |  |  | 成功订阅时上报成功付费时上报 |  |  |  |
| 影响事件 | 0 | 1 | w_subscription_click | 订阅页点击订阅按钮 | source_0 | 进入订阅页来源-0 | 普通参数 | string | f_glowup |  |  |  | 选中某个plan并点击订阅按钮时上报 |  |  |  |
| 影响事件 | 0 | 1 | w_subscription_click | 订阅页点击订阅按钮 | source_1 | 进入订阅页来源-1 | 普通参数 | string | Shimmer |  |  |  | 选中某个plan并点击订阅按钮时上报 |  |  |  |
| 影响事件 | 0 | 1 | w_subscription_success | 订阅成功 | source_0 | 进入订阅页来源-0 | 普通参数 | string | f_glowup |  |  |  | 订阅页成功时上报 |  |  |  |
| 影响事件 | 0 | 1 | w_subscription_success | 订阅成功 | source_1 | 进入订阅页来源-1 | 普通参数 | string | Shimmer |  |  |  | 订阅页成功时上报 |  |  |  |
| 影响事件 | 0 | 1 | second_func_exposure | 二级功能曝光 | second_func |  | 普通参数 | string | glowup |  |  |  | 功能icon曝光 |  |  |  |
| 新增事件参数 | 0 | 1 | third_func_exposure | 三级功能曝光 | first_func |  | 普通参数 | string |  | retouch |  |  |  |  |  |  |
| 新增事件参数 | 0 | 1 | third_func_exposure | 三级功能曝光 | second_func |  | 普通参数 | string |  | glowup |  |  |  |  |  |  |
| 新增事件参数 | 0 | 1 | third_func_exposure | 三级功能曝光 | third_func |  | 普通参数 | string | 子功能英文名 |  |  | Flawless、Matte、Soft Glow、Body Glow、Natural Tan、Tanned、Shimmer |  |  |  |  |