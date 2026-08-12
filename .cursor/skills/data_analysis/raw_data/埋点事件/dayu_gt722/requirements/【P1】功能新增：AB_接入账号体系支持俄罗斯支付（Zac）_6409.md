| 需求类型 | 事件来源 | 事件类型 | *事件id | *事件名称 | 参数 | 参数名称 | 参数类型 | 参数值类型 | 参数口径 | 参数值 | 参数值名称 | 参数值口径 | *统计口径 | 备注说明 | 事件分组 | 标签 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 新增事件参数值 | 0 | 1 | login_page_show | 登录/注册弹窗曝光 | scene | 弹窗具体场景 | 普通参数 | string | 登录/注册弹窗曝光的具体触发场景 | setting | 设置页 | 从 Settings / Log in 触发登录流程 | 登录/注册弹窗曝光时上报 |  |  |  |
| 新增事件参数值 | 0 | 1 | login_page_show | 登录/注册弹窗曝光 | scene | 弹窗具体场景 | 普通参数 | string | 登录/注册弹窗曝光的具体触发场景 | paywall | Paywall | 从 Paywall / Subscribe 触发登录流程 | 登录/注册弹窗曝光时上报 |  |  |  |
| 新增事件参数值 | 0 | 1 | login_page_success | 登录/注册成功 | login_type | 登录注册方式 | 普通参数 | string | 登录成功所使用的登录方式 | vk | VK | VK 登录成功 | 登录/注册成功时触发 |  |  |  |
| 新增事件参数值 | 0 | 1 | login_page_success | 登录/注册成功 | login_type | 登录注册方式 | 普通参数 | string | 登录成功所使用的登录方式 | email | 邮箱 | 邮箱 OTP 登录成功 | 登录/注册成功时触发 |  |  |  |
| 新增事件参数值 | 0 | 1 | login_page_success | 登录/注册成功 | login_type | 登录注册方式 | 普通参数 | string | 登录成功所使用的登录方式 | apple | Apple | Apple 登录成功 | 登录/注册成功时触发 |  |  |  |
| 新增事件参数值 | 0 | 1 | login_page_success | 登录/注册成功 | login_type | 登录注册方式 | 普通参数 | string | 登录成功所使用的登录方式 | google | Google | Google 登录成功 | 登录/注册成功时触发 |  |  |  |
| 新增事件参数值 | 0 | 1 | login_page_success | 登录/注册成功 | login_type | 登录注册方式 | 普通参数 | string | 登录成功所使用的登录方式 | facebook | Facebook | Facebook 登录成功 | 登录/注册成功时触发 |  |  |  |
| 影响事件 | 0 | 1 | login_page_success | 登录/注册成功 | account_id | 登录方式对应的账号id | 普通参数 | string | 登录成功后生成或绑定的账号ID |  |  |  | 登录/注册成功时触发 |  |  |  |
| 影响事件 | 0 | 1 | login_page_success | 登录/注册成功 | is_register | 是否注册 | 普通参数 | string | 区分新账号创建或已有账号登录 |  |  |  | 登录/注册成功时触发 |  |  |  |
| 新增事件参数值 | 0 | 1 | setting_page_click | 设置页面按钮（开关）点击 | name | 各个按钮名称 | 普通参数 | string |  | account_page |  | 账号管理 | 设置页面按钮（开关）点击时上报 |  |  |  |
| 影响事件 | 0 | 1 | w_subscription_click | 订阅页点击订阅按钮 | trace_info |  | 普通参数 | string |  |  |  |  | 选中某个plan并点击订阅按钮时上报 | 俄罗斯订阅相关事件参数(order_id等所有)均确认上报 |  |  |
| 影响事件 | 0 | 1 | w_subscription_enter | 进入订阅页 | trace_info |  | 普通参数 | string |  |  |  |  | 成功订阅时上报成功付费时上报 | 俄罗斯订阅相关事件参数(order_id等所有)均确认上报 |  |  |
| 影响事件 | 0 | 1 | w_subscription_success | 订阅成功 | trace_info | trace_info | 普通参数 | string |  |  |  |  | 进入订阅页时上报 | 俄罗斯订阅相关事件参数(order_id等所有)均确认上报 |  |  |
| 影响事件 | 0 | 1 | appstore_pay_fail | 付费失败 | trace_info |  | 普通参数 | string |  |  |  |  | 付费失败时上报 | 俄罗斯订阅相关事件参数(order_id等所有)均确认上报 |  |  |
| 新增事件 | 0 | 1 | login_page_fail | 登录失败 | source | 登录来源 | 普通参数 | string | 触发登录的入口来源 | paywall |  |  | 用户邮箱登录或三方登录失败时触发 |  |  |  |
| 新增事件 | 0 | 1 | login_page_fail | 登录失败 | source | 登录来源 | 普通参数 | string | 触发登录的入口来源 | setting |  |  | 用户邮箱登录或三方登录失败时触发 |  |  |  |
| 新增事件 | 0 | 1 | login_page_fail | 登录失败 | fail_reason | 失败原因 | 普通参数 | string | 登录失败原因（第三方） |  |  |  | 用户邮箱登录或三方登录失败时触发 |  |  |  |
| 新增事件 | 0 | 1 | account_logout_success | 退出登录成功 | account_id | 账号ID | 普通参数 | string | 退出登录的账号ID |  |  |  | 用户确认退出登录且退出成功时触发 |  |  |  |
| 新增事件 | 0 | 1 | connected_account_success | 第三方账号连接成功 | connect_type | 连接方式 | 普通参数 | string | 成功连接的平台类型 | vk | VK | VK 连接成功 | 第三方账号成功绑定到当前 Airbrush account_id 时触发 |  |  |  |
| 新增事件 | 0 | 1 | connected_account_success | 第三方账号连接成功 | connect_type | 连接方式 | 普通参数 | string | 成功连接的平台类型 | apple | Apple | Apple 连接成功 | 第三方账号成功绑定到当前 Airbrush account_id 时触发 |  |  |  |
| 新增事件 | 0 | 1 | connected_account_success | 第三方账号连接成功 | connect_type | 连接方式 | 普通参数 | string | 成功连接的平台类型 | google | Google | Google 连接成功 | 第三方账号成功绑定到当前 Airbrush account_id 时触发 |  |  |  |
| 新增事件 | 0 | 1 | connected_account_success | 第三方账号连接成功 | connect_type | 连接方式 | 普通参数 | string | 成功连接的平台类型 | facebook | Facebook | Facebook 连接成功 | 第三方账号成功绑定到当前 Airbrush account_id 时触发 |  |  |  |
| 新增事件 | 0 | 1 | connected_account_success | 第三方账号连接成功 | connect_type | 连接方式 | 普通参数 | string | 成功连接的平台类型 | email | 邮箱 | 邮箱连接成功 | 第三方账号成功绑定到当前 Airbrush account_id 时触发 |  |  |  |
| 新增事件 | 0 | 1 | connected_account_success | 第三方账号连接成功 | account_id | 账号ID | 普通参数 | string | 当前登录账号ID |  |  |  | 第三方账号成功绑定到当前 Airbrush account_id 时触发 |  |  |  |
| 新增事件 | 0 | 1 | connected_account_fail | 第三方账号连接失败 | connect_type | 连接方式 | 普通参数 | string | 连接失败的平台类型 | vk | VK | VK 连接失败 | 第三方账号绑定当前 Airbrush account_id 失败时触发 |  |  |  |
| 新增事件 | 0 | 1 | connected_account_fail | 第三方账号连接失败 | connect_type | 连接方式 | 普通参数 | string | 连接失败的平台类型 | apple | Apple | Apple 连接失败 | 第三方账号绑定当前 Airbrush account_id 失败时触发 |  |  |  |
| 新增事件 | 0 | 1 | connected_account_fail | 第三方账号连接失败 | connect_type | 连接方式 | 普通参数 | string | 连接失败的平台类型 | google | Google | Google 连接失败 | 第三方账号绑定当前 Airbrush account_id 失败时触发 |  |  |  |
| 新增事件 | 0 | 1 | connected_account_fail | 第三方账号连接失败 | connect_type | 连接方式 | 普通参数 | string | 连接失败的平台类型 | facebook | Facebook | Facebook 连接失败 | 第三方账号绑定当前 Airbrush account_id 失败时触发 |  |  |  |
| 新增事件 | 0 | 1 | connected_account_fail | 第三方账号连接失败 | connect_type | 连接方式 | 普通参数 | string | 连接失败的平台类型 | email | 邮箱 | 邮箱连接失败 | 第三方账号绑定当前 Airbrush account_id 失败时触发 |  |  |  |
| 新增事件 | 0 | 1 | connected_account_fail | 第三方账号连接失败 | fail_reason | 失败原因 | 普通参数 | string | 连接失败原因 |  |  |  | 第三方账号绑定当前 Airbrush account_id 失败时触发 |  |  |  |