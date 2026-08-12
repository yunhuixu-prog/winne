| 需求类型 | 事件来源 | 事件类型 | *事件id | *事件名称 | 参数 | 参数名称 | 参数类型 | 参数值类型 | 参数口径 | 参数值 | 参数值名称 | 参数值口径 | *统计口径 | 备注说明 | 事件分组 | 标签 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 影响事件 | 0 | 1 | w_subscription_enter | 进入订阅页 | source_module | 进入订阅页来源模块 | 普通参数 | string |  | p_ads |  | 通过「去广告」订阅 | 成功订阅时上报成功付费时上报 | 实验对照组均要改，之前ios用acne去广告解锁上报source_module=p_edit，改为p_ads |  |  |
| 影响事件 | 0 | 1 | w_subscription_enter | 进入订阅页 | source_module | 进入订阅页来源模块 | 普通参数 | string |  | p_edit |  | 通过「免费次数已用完，打勾第X次需要订阅」订阅 | 成功订阅时上报成功付费时上报 | 实验对照组均要改，之前ios用acne去广告解锁上报source_module=p_edit，改为p_ads |  |  |
| 影响事件 | 0 | 1 | w_subscription_enter | 进入订阅页 | source_0 | 进入订阅页来源-0 | 普通参数 | string |  | f_acne |  |  | 成功订阅时上报成功付费时上报 | 实验对照组均要改，之前ios用acne去广告解锁上报source_module=p_edit，改为p_ads |  |  |
| 新增事件参数值 | 0 | 1 | w_subscription_enter | 进入订阅页 | source_1 |  | 普通参数 | string | 通过「去广告」订阅不上报该key | three |  | 打勾第三次触发订阅，即实验组A的触发场景 | 成功订阅时上报成功付费时上报 | 实验对照组均要改，之前ios用acne去广告解锁上报source_module=p_edit，改为p_ads |  |  |
| 新增事件参数值 | 0 | 1 | w_subscription_enter | 进入订阅页 | source_1 |  | 普通参数 | string | 通过「去广告」订阅不上报该key | four |  | 打勾第四次触发订阅，即实验组B的触发场景 | 成功订阅时上报成功付费时上报 | 实验对照组均要改，之前ios用acne去广告解锁上报source_module=p_edit，改为p_ads |  |  |
| 影响事件 | 0 | 1 | w_subscription_click | 订阅页点击订阅按钮 | source_module | 进入订阅页来源模块 | 普通参数 | string |  | p_ads |  | 通过「去广告」订阅 | 选中某个plan并点击订阅按钮时上报 | 实验对照组均要改，之前ios用acne去广告解锁上报source_module=p_edit，改为p_ads |  |  |
| 影响事件 | 0 | 1 | w_subscription_click | 订阅页点击订阅按钮 | source_module | 进入订阅页来源模块 | 普通参数 | string |  | p_edit |  | 通过「免费次数已用完，打勾第X次需要订阅」订阅 | 选中某个plan并点击订阅按钮时上报 | 实验对照组均要改，之前ios用acne去广告解锁上报source_module=p_edit，改为p_ads |  |  |
| 影响事件 | 0 | 1 | w_subscription_click | 订阅页点击订阅按钮 | source_0 | 进入订阅页来源-0 | 普通参数 | string |  | f_acne |  |  | 选中某个plan并点击订阅按钮时上报 | 实验对照组均要改，之前ios用acne去广告解锁上报source_module=p_edit，改为p_ads |  |  |
| 新增事件参数值 | 0 | 1 | w_subscription_click | 订阅页点击订阅按钮 | source_1 | 进入订阅页来源-1 | 普通参数 | string |  | three |  | 打勾第三次触发订阅 | 选中某个plan并点击订阅按钮时上报 | 实验对照组均要改，之前ios用acne去广告解锁上报source_module=p_edit，改为p_ads |  |  |
| 新增事件参数值 | 0 | 1 | w_subscription_click | 订阅页点击订阅按钮 | source_1 | 进入订阅页来源-1 | 普通参数 | string |  | four |  | 打勾第四次触发订阅 | 选中某个plan并点击订阅按钮时上报 | 实验对照组均要改，之前ios用acne去广告解锁上报source_module=p_edit，改为p_ads |  |  |
| 影响事件 | 0 | 1 | w_subscription_success | 订阅成功 | source_module | 进入订阅页来源模块 | 普通参数 | string |  | p_ads |  | 通过「去广告」订阅 | 进入订阅页时上报 | 实验对照组均要改，之前ios用acne去广告解锁上报source_module=p_edit，改为p_ads |  |  |
| 影响事件 | 0 | 1 | w_subscription_success | 订阅成功 | source_module | 进入订阅页来源模块 | 普通参数 | string |  | p_edit |  | 通过「免费次数已用完，打勾第X次需要订阅」订阅 | 进入订阅页时上报 | 实验对照组均要改，之前ios用acne去广告解锁上报source_module=p_edit，改为p_ads |  |  |
| 影响事件 | 0 | 1 | w_subscription_success | 订阅成功 | source_0 | 进入订阅页来源-0 | 普通参数 | string |  | f_acne |  |  | 进入订阅页时上报 | 实验对照组均要改，之前ios用acne去广告解锁上报source_module=p_edit，改为p_ads |  |  |
| 新增事件参数值 | 0 | 1 | w_subscription_success | 订阅成功 | source_1 | 进入订阅页来源-1 | 普通参数 | string |  | three |  | 打勾第三次触发订阅 | 进入订阅页时上报 | 实验对照组均要改，之前ios用acne去广告解锁上报source_module=p_edit，改为p_ads |  |  |
| 新增事件参数值 | 0 | 1 | w_subscription_success | 订阅成功 | source_1 | 进入订阅页来源-1 | 普通参数 | string |  | four |  | 打勾第四次触发订阅 | 进入订阅页时上报 | 实验对照组均要改，之前ios用acne去广告解锁上报source_module=p_edit，改为p_ads |  |  |
| 影响事件 | 0 | 1 | third_func_exposure | 三级功能曝光 | first_func |  | 普通参数 | string |  | retouch |  |  | 三级功能曝光时上报 |  |  |  |
| 影响事件 | 0 | 1 | third_func_exposure | 三级功能曝光 | second_func |  | 普通参数 | string |  | skin |  |  | 三级功能曝光时上报 |  |  |  |
| 影响事件 | 0 | 1 | third_func_exposure | 三级功能曝光 | third_func |  | 普通参数 | string | 子功能英文名 | acne |  |  | 三级功能曝光时上报 |  |  |  |
| 影响事件 | 0 | 1 | third_func_enter | 点击三级功能页面 | first_func | 一级功能参数 | 普通参数 | string |  | retouch |  |  | 点击三级功能页面时上报 |  |  |  |
| 影响事件 | 0 | 1 | third_func_enter | 点击三级功能页面 | second_func | 二级功能参数 | 普通参数 | string |  | skin |  |  | 点击三级功能页面时上报 |  |  |  |
| 影响事件 | 0 | 1 | third_func_enter | 点击三级功能页面 | third_func | 三级功能参数 | 普通参数 | string |  | acne |  |  | 点击三级功能页面时上报 |  |  |  |
| 影响事件 | 0 | 1 | third_func_use | 三级功能使用 | first_func | 一级功能参数 | 普通参数 | string |  | retouch |  |  | 三级功能使用时触发 |  |  |  |
| 影响事件 | 0 | 1 | third_func_use | 三级功能使用 | second_func | 二级功能参数 | 普通参数 | string |  | skin |  |  | 三级功能使用时触发 |  |  |  |
| 影响事件 | 0 | 1 | third_func_use | 三级功能使用 | third_func | 三级功能参数 | 普通参数 | string |  | acne |  |  | 三级功能使用时触发 |  |  |  |
| 影响事件 | 0 | 1 | third_func_use | 三级功能使用 | is_effect | 是否有应用任一效果 | 普通参数 | string |  | 1 |  |  | 三级功能使用时触发 |  |  |  |
| 影响事件 | 0 | 1 | third_func_use | 三级功能使用 | is_effect | 是否有应用任一效果 | 普通参数 | string |  | 0 |  |  | 三级功能使用时触发 |  |  |  |
| 影响事件 | 0 | 1 | third_func_use | 三级功能使用 | mode |  | 普通参数 | string |  | both |  |  | 三级功能使用时触发 |  |  |  |
| 影响事件 | 0 | 1 | third_func_use | 三级功能使用 | mode |  | 普通参数 | string |  | manual |  |  | 三级功能使用时触发 |  |  |  |
| 影响事件 | 0 | 1 | third_func_use | 三级功能使用 | mode |  | 普通参数 | string |  | auto |  |  | 三级功能使用时触发 |  |  |  |
| 影响事件 | 0 | 1 | third_func_save | 三级功能保存 | first_func |  | 普通参数 | string |  | retouch |  |  | 三级功能保存时上报 |  |  |  |
| 影响事件 | 0 | 1 | third_func_save | 三级功能保存 | second_func |  | 普通参数 | string |  | skin |  |  | 三级功能保存时上报 |  |  |  |
| 影响事件 | 0 | 1 | third_func_save | 三级功能保存 | third_func |  | 普通参数 | string |  | acne |  |  | 三级功能保存时上报 |  |  |  |
| 影响事件 | 0 | 1 | third_func_save | 三级功能保存 | mode |  | 普通参数 | string |  |  |  |  | 三级功能保存时上报 |  |  |  |