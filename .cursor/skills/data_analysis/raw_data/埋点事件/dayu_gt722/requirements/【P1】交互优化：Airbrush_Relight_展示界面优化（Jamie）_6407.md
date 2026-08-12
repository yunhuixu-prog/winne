| 需求类型 | 事件来源 | 事件类型 | *事件id | *事件名称 | 参数 | 参数名称 | 参数类型 | 参数值类型 | 参数口径 | 参数值 | 参数值名称 | 参数值口径 | *统计口径 | 备注说明 | 事件分组 | 标签 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 新增事件参数 | 0 | 1 | material_exposure | 素材曝光 | panel_state | 面板状态 | 普通参数 | string | 区分Relight素材曝光发生在收起态或拓展态 | collapsed | 收起态 | Relight单行收起面板下的素材曝光 | 素材曝光时触发 |  |  |  |
| 新增事件参数 | 0 | 1 | material_exposure | 素材曝光 | panel_state | 面板状态 | 普通参数 | string | 区分Relight素材曝光发生在收起态或拓展态 | expanded | 拓展态 | Relight多行拓展面板下的素材曝光 | 素材曝光时触发 |  |  |  |
| 影响事件 | 0 | 1 | material_exposure | 素材曝光 | category_id | 分类id | 普通参数 | string |  |  |  |  | 素材曝光时触发 |  |  |  |
| 新增事件参数值 | 0 | 1 | material_exposure | 素材曝光 | material_type | 素材类型 | 普通参数 | string |  | relight |  |  | 素材曝光时触发 |  |  |  |
| 新增事件参数值 | 0 | 1 | material_exposure | 素材曝光 | material_id | 素材id | 普通参数 | string |  |  |  |  | 素材曝光时触发 |  |  |  |
| 新增事件参数 | 0 | 1 | material_click | 素材点击 | panel_state |  | 普通参数 | string |  | collapsed |  |  | 素材点击时触发 |  |  |  |
| 新增事件参数 | 0 | 1 | material_click | 素材点击 | panel_state |  | 普通参数 | string |  | expanded |  |  | 素材点击时触发 |  |  |  |
| 新增事件参数值 | 0 | 1 | material_click | 素材点击 | material_type | 素材类型 | 普通参数 | string |  | relight |  |  | 素材点击时触发 |  |  |  |
| 新增事件参数值 | 0 | 1 | material_click | 素材点击 | material_id | 素材id | 普通参数 | string |  |  |  |  | 素材点击时触发 |  |  |  |
| 新增事件参数 | 0 | 1 | material_check | 素材打勾 | panel_state |  | 普通参数 | string |  | collapsed |  |  | 应用功能时触发 |  |  |  |
| 新增事件参数 | 0 | 1 | material_check | 素材打勾 | panel_state |  | 普通参数 | string |  | expanded |  |  | 应用功能时触发 |  |  |  |
| 影响事件 | 0 | 1 | material_check | 素材打勾 | mids_category_id | 分类id | 普通参数 | string |  |  |  |  | 应用功能时触发 |  |  |  |
| 新增事件参数值 | 0 | 1 | material_check | 素材打勾 | material_type | 素材类型 | 普通参数 | string |  | relight |  |  | 应用功能时触发 |  |  |  |
| 新增事件参数值 | 0 | 1 | material_check | 素材打勾 | mids_material_id | 素材id | 普通参数 | string |  |  |  |  | 应用功能时触发 |  |  |  |
| 影响事件 | 0 | 1 | w_subscription_click | 订阅页点击订阅按钮 | mids_category_id | 分类id | 普通参数 | string | 发型发色和enrich的分类di |  |  |  | 选中某个plan并点击订阅按钮时上报 |  |  |  |
| 影响事件 | 0 | 1 | w_subscription_click | 订阅页点击订阅按钮 | mids_material_id | 素材id | 普通参数 | string | 发型发色和enrich的素材di |  |  |  | 选中某个plan并点击订阅按钮时上报 |  |  |  |
| 影响事件 | 0 | 1 | w_subscription_click | 订阅页点击订阅按钮 | source_0 | 进入订阅页来源-0 | 普通参数 | string |  | f_relight |  |  | 选中某个plan并点击订阅按钮时上报 |  |  |  |
| 影响事件 | 0 | 1 | w_subscription_success | 订阅成功 | mids_category_id | 分类id | 普通参数 | string |  |  |  |  | 进入订阅页时上报 |  |  |  |
| 影响事件 | 0 | 1 | w_subscription_success | 订阅成功 | mids_material_id | 素材id | 普通参数 | string |  |  |  |  | 进入订阅页时上报 |  |  |  |
| 影响事件 | 0 | 1 | w_subscription_success | 订阅成功 | source_0 | 进入订阅页来源-0 | 普通参数 | string |  | f_relight |  |  | 进入订阅页时上报 |  |  |  |
| 新增事件参数值 | 0 | 1 | button_click | 按钮点击 | name |  | 普通参数 | string |  | all |  |  | 按钮点击上报 |  |  |  |
| 新增事件参数值 | 0 | 1 | button_click | 按钮点击 | name |  | 普通参数 | string |  | collapse |  |  | 按钮点击上报 |  |  |  |
| 新增事件参数值 | 0 | 1 | button_click | 按钮点击 | name |  | 普通参数 | string |  | none |  |  | 按钮点击上报 |  |  |  |