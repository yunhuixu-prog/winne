| 需求类型 | 事件来源 | 事件类型 | *事件id | *事件名称 | 参数 | 参数名称 | 参数类型 | 参数值类型 | 参数口径 | 参数值 | 参数值名称 | 参数值口径 | *统计口径 | 备注说明 | 事件分组 | 标签 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 影响事件 | 0 | 1 | w_subscription_success | 订阅成功 | SKU |  | 普通参数 | string |  |  |  |  | 进入订阅页时上报 |  |  |  |
| 影响事件 | 0 | 1 | w_subscription_success | 订阅成功 | duration |  | 普通参数 | string |  |  |  |  | 进入订阅页时上报 |  |  |  |
| 影响事件 | 0 | 1 | w_subscription_click | 订阅页点击订阅按钮 | SKU | SKU ID | 普通参数 | string |  |  |  |  | 选中某个plan并点击订阅按钮时上报 |  |  |  |
| 影响事件 | 0 | 1 | w_subscription_click | 订阅页点击订阅按钮 | duration | 订阅周期 | 普通参数 | string |  |  |  |  | 选中某个plan并点击订阅按钮时上报 |  |  |  |
| 影响事件 | 0 | 1 | w_subscription_enter | 进入订阅页 | SKU | SKU ID | 普通参数 | string |  |  |  |  | 成功订阅时上报成功付费时上报 |  |  |  |
| 影响事件 | 0 | 1 | w_subscription_enter | 进入订阅页 | duration | 订阅周期 | 普通参数 | string |  |  |  |  | 成功订阅时上报成功付费时上报 |  |  |  |
| 影响事件 | 0 | 1 | appstore_pay_fail | 付费失败 | prf_fail_reason | 失败原因 | 普通参数 | number |  |  |  |  | 付费失败时上报 |  |  |  |
| 影响事件 | 0 | 1 | appstore_pay_fail | 付费失败 | current_sku | 当前付款的sku | 普通参数 | string |  |  |  |  | 付费失败时上报 |  |  |  |
| 影响事件 | 0 | 1 | question_pop_show | 问卷曝光 | type | 触发类型 | 普通参数 | string |  | month |  | 因为月订阅取消触发 | 问卷曝光时上报 |  |  |  |
| 影响事件 | 0 | 1 | question_pop_show | 问卷曝光 | type | 触发类型 | 普通参数 | string |  | year |  | 因为年订阅取消触发 | 问卷曝光时上报 |  |  |  |
| 影响事件 | 0 | 1 | question_pop_submit | 选择答案后提交 | type | 触发类型 | 普通参数 | string |  | month |  |  | 选择答案后提交时上报 |  |  |  |
| 影响事件 | 0 | 1 | question_pop_submit | 选择答案后提交 | type | 触发类型 | 普通参数 | string |  | year |  |  | 选择答案后提交时上报 |  |  |  |
| 影响事件 | 0 | 1 | question_pop_submit | 选择答案后提交 | content | 选项内容 | 普通参数 | number |  |  |  |  | 选择答案后提交时上报 |  |  |  |
| 影响事件 | 0 | 1 | question_proplan_show | 提交问卷后优惠方案弹窗曝光 | type |  | 普通参数 | string |  | month |  | 因为月订阅取消触发 | 提交问卷后优惠方案弹窗曝光 |  |  |  |
| 影响事件 | 0 | 1 | question_proplan_show | 提交问卷后优惠方案弹窗曝光 | type |  | 普通参数 | string |  | year |  | 因为年订阅取消触发 | 提交问卷后优惠方案弹窗曝光 |  |  |  |
| 影响事件 | 0 | 1 | question_proplan_show | 提交问卷后优惠方案弹窗曝光 | content |  | 普通参数 | string |  | trial_7 |  | 7天试用时间线方案 | 提交问卷后优惠方案弹窗曝光 |  |  |  |
| 影响事件 | 0 | 1 | question_proplan_show | 提交问卷后优惠方案弹窗曝光 | content |  | 普通参数 | string |  | straight |  | 直接优惠方案，关闭问卷时触发 | 提交问卷后优惠方案弹窗曝光 |  |  |  |
| 影响事件 | 0 | 1 | question_proplan_show | 提交问卷后优惠方案弹窗曝光 | content |  | 普通参数 | string |  | question |  | 问卷优惠方案 | 提交问卷后优惠方案弹窗曝光 |  |  |  |
| 影响事件 | 0 | 1 | question_pop_sub_success | 通过问卷触发的优惠订阅成功 | type | 触发类型 | 普通参数 | string |  | month |  |  | 通过问卷触发的优惠，且最终订阅成功。注意原本的订阅成功事件也需要上报 |  |  |  |
| 影响事件 | 0 | 1 | question_pop_sub_success | 通过问卷触发的优惠订阅成功 | type | 触发类型 | 普通参数 | string |  | year |  |  | 通过问卷触发的优惠，且最终订阅成功。注意原本的订阅成功事件也需要上报 |  |  |  |
| 影响事件 | 0 | 1 | question_pop_sub_success | 通过问卷触发的优惠订阅成功 | content | 优惠内容 | 普通参数 | string |  | trial_7 |  |  | 通过问卷触发的优惠，且最终订阅成功。注意原本的订阅成功事件也需要上报 |  |  |  |
| 影响事件 | 0 | 1 | question_pop_sub_success | 通过问卷触发的优惠订阅成功 | content | 优惠内容 | 普通参数 | string |  | straight |  |  | 通过问卷触发的优惠，且最终订阅成功。注意原本的订阅成功事件也需要上报 |  |  |  |
| 影响事件 | 0 | 1 | question_pop_sub_success | 通过问卷触发的优惠订阅成功 | content | 优惠内容 | 普通参数 | string |  | question |  |  | 通过问卷触发的优惠，且最终订阅成功。注意原本的订阅成功事件也需要上报 |  |  |  |
| 影响事件 | 0 | 1 | question_pop_sub_success | 通过问卷触发的优惠订阅成功 | sku | sku id | 普通参数 | string |  |  |  |  | 通过问卷触发的优惠，且最终订阅成功。注意原本的订阅成功事件也需要上报 |  |  |  |
| 影响事件 | 0 | 1 | question_pop_sub_success | 通过问卷触发的优惠订阅成功 | order_id | 订单id | 普通参数 | bool |  |  |  |  | 通过问卷触发的优惠，且最终订阅成功。注意原本的订阅成功事件也需要上报 |  |  |  |
| 影响事件 | 0 | 1 | question_pop_sub_success | 通过问卷触发的优惠订阅成功 | rest_of_time | 距离优惠期多久 | 普通参数 | number | 单位：s |  |  |  | 通过问卷触发的优惠，且最终订阅成功。注意原本的订阅成功事件也需要上报 |  |  |  |
| 新增事件 | 0 | 1 | livex_ai_agent_show | LiveX AI Agent对话弹出 | type |  | 普通参数 | string |  | month |  | 因为月订阅取消触发 | LiveX AI Agent对话弹出时上报 |  |  |  |
| 新增事件 | 0 | 1 | livex_ai_agent_show | LiveX AI Agent对话弹出 | type |  | 普通参数 | string |  | year |  | 因为年订阅取消触发 | LiveX AI Agent对话弹出时上报 |  |  |  |
| 新增事件 | 0 | 1 | livex_ai_agent_sub_click | 点击LiveX推荐的SKU的continue | type |  | 普通参数 | string |  | month |  | 因为月订阅取消触发 | 点击LiveX推荐SKU的continue时上报 |  |  |  |
| 新增事件 | 0 | 1 | livex_ai_agent_sub_click | 点击LiveX推荐的SKU的continue | type |  | 普通参数 | string |  | year |  | 因为年订阅取消触发 | 点击LiveX推荐SKU的continue时上报 |  |  |  |
| 新增事件 | 0 | 1 | livex_ai_agent_sub_click | 点击LiveX推荐的SKU的continue | content | 优惠类型 | 普通参数 | string |  | trial_7 | 7天试用年SKU |  | 点击LiveX推荐SKU的continue时上报 |  |  |  |
| 新增事件 | 0 | 1 | livex_ai_agent_sub_click | 点击LiveX推荐的SKU的continue | content | 优惠类型 | 普通参数 | string |  | promotional | 优惠SKU |  | 点击LiveX推荐SKU的continue时上报 |  |  |  |
| 新增事件 | 0 | 1 | livex_ai_agent_sub_click | 点击LiveX推荐的SKU的continue | sku | sku_id | 普通参数 | string |  |  |  |  | 点击LiveX推荐SKU的continue时上报 |  |  |  |
| 新增事件 | 0 | 1 | livex_ai_agent_sub_success | 通过LiveX推荐的SKU订阅成功 | type |  | 普通参数 | string |  | month |  | 因为月订阅取消触发 | 通过LiveX推荐的SKU订阅成功时上报，注意原本的订阅事件w_subscription_success仍需上报 |  |  |  |
| 新增事件 | 0 | 1 | livex_ai_agent_sub_success | 通过LiveX推荐的SKU订阅成功 | type |  | 普通参数 | string |  | year |  | 因为年订阅取消触发 | 通过LiveX推荐的SKU订阅成功时上报，注意原本的订阅事件w_subscription_success仍需上报 |  |  |  |
| 新增事件 | 0 | 1 | livex_ai_agent_sub_success | 通过LiveX推荐的SKU订阅成功 | content | 优惠类型 | 普通参数 | string |  | trial_7 | 7天试用年SKU |  | 通过LiveX推荐的SKU订阅成功时上报，注意原本的订阅事件w_subscription_success仍需上报 |  |  |  |
| 新增事件 | 0 | 1 | livex_ai_agent_sub_success | 通过LiveX推荐的SKU订阅成功 | content | 优惠类型 | 普通参数 | string |  | promotional | 优惠SKU |  | 通过LiveX推荐的SKU订阅成功时上报，注意原本的订阅事件w_subscription_success仍需上报 |  |  |  |
| 新增事件 | 0 | 1 | livex_ai_agent_sub_success | 通过LiveX推荐的SKU订阅成功 | sku | sku_id | 普通参数 | string |  |  |  |  | 通过LiveX推荐的SKU订阅成功时上报，注意原本的订阅事件w_subscription_success仍需上报 |  |  |  |
| 新增事件 | 0 | 1 | livex_ai_agent_sub_success | 通过LiveX推荐的SKU订阅成功 | order_id | 订单id | 普通参数 | string |  |  |  |  | 通过LiveX推荐的SKU订阅成功时上报，注意原本的订阅事件w_subscription_success仍需上报 |  |  |  |
| 新增事件 | 0 | 1 | livex_ai_agent_sub_fail | 通过LiveX推荐的SKU订阅失败 | type |  | 普通参数 | string |  | month |  | 因为月订阅取消触发 | 通过LiveX推荐的SKU订阅失败时上报 |  |  |  |
| 新增事件 | 0 | 1 | livex_ai_agent_sub_fail | 通过LiveX推荐的SKU订阅失败 | type |  | 普通参数 | string |  | year |  | 因为年订阅取消触发 | 通过LiveX推荐的SKU订阅失败时上报 |  |  |  |
| 新增事件 | 0 | 1 | livex_ai_agent_sub_fail | 通过LiveX推荐的SKU订阅失败 | content | 优惠类型 | 普通参数 | string |  | trial_7 | 7天试用年SKU |  | 通过LiveX推荐的SKU订阅失败时上报 |  |  |  |
| 新增事件 | 0 | 1 | livex_ai_agent_sub_fail | 通过LiveX推荐的SKU订阅失败 | content | 优惠类型 | 普通参数 | string |  | promotional | 优惠SKU |  | 通过LiveX推荐的SKU订阅失败时上报 |  |  |  |
| 新增事件 | 0 | 1 | livex_ai_agent_sub_fail | 通过LiveX推荐的SKU订阅失败 | sku | sku_id | 普通参数 | string |  |  |  |  | 通过LiveX推荐的SKU订阅失败时上报 |  |  |  |
| 新增事件 | 0 | 1 | livex_ai_agent_sub_fail | 通过LiveX推荐的SKU订阅失败 | prf_fail_reason | 失败原因 | 普通参数 | string |  |  |  |  | 通过LiveX推荐的SKU订阅失败时上报 |  |  |  |