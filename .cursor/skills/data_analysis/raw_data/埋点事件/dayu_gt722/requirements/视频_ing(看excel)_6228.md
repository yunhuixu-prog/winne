| 需求类型 | 事件来源 | 事件类型 | *事件id | *事件名称 | 参数 | 参数名称 | 参数类型 | 参数值类型 | 参数口径 | 参数值 | 参数值名称 | 参数值口径 | *统计口径 | 备注说明 | 事件分组 | 标签 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 新增事件 | 0 | 1 | sp_enter | 进入组件 | enter_from | 进入视频编辑器来源 | 普通参数 | string | video(首页视频主编辑器人像入口);dl(dl进入视频相册);video_edit(视频编辑左上角进入视频相册) ,tvideo(首页tool模块video入口进入视频相册),shortcuts（Explore模块）; album_out(首页外漏相册进入),首页全部相册按钮进入 album_all，AIGC，album_add,album_center,system_album |  |  |  | 进入组件 |  |  |  |
| 新增事件 | 0 | 1 | sp_enter | 进入组件 | first_source | 进入编辑页的一级来源 | 普通参数 | string | video |  |  |  | 进入组件 |  |  |  |
| 新增事件 | 0 | 1 | sp_enter | 进入组件 | second_source | 进入编辑页的二级来源 | 普通参数 | string | 所有视频相册有进入视频编辑页的二级来源 ios: recents；favorites；selfies；portrait；live photos；screenshot；其他都为others android: recents；其他都为others |  |  |  | 进入组件 |  |  |  |
| 新增事件 | 0 | 1 | sp_content_import | 导入 |  |  |  |  |  |  |  |  | 导入 |  |  |  |
| 新增事件 | 0 | 1 | sp_homesave | 保存 | icon_name | 取scheme中的功能名 | 普通参数 | string |  | picture_quality | 画质修复 |  | 保存（仅记录是否使用功能，不记录子项） |  |  |  |
| 新增事件 | 0 | 1 | sp_homesave | 保存 | icon_name | 取scheme中的功能名 | 普通参数 | string |  | body | 身材美型 |  | 保存（仅记录是否使用功能，不记录子项） |  |  |  |
| 新增事件 | 0 | 1 | sp_picture_quality_click | 视频_画质修复入口点击 | target_type | 档位 | 普通参数 | string |  | ultra_hd |  |  | 视频_画质修复入口点击 |  |  |  |
| 新增事件 | 0 | 1 | sp_picture_quality_click | 视频_画质修复入口点击 | target_type | 档位 | 普通参数 | string |  | portrait |  |  | 视频_画质修复入口点击 |  |  |  |
| 新增事件 | 0 | 1 | sp_picture_quality_click | 视频_画质修复入口点击 | icon_name | 功能名称 | 普通参数 | string |  | picture_quality |  |  | 视频_画质修复入口点击 |  |  |  |
| 新增事件 | 0 | 1 | sp_picture_quality_yes | 视频_画质修复打勾 | tab_name | 选中tab | 普通参数 | string |  | classic | 画质修复/经典模式 |  | 视频_画质修复打勾 |  |  |  |
| 新增事件 | 0 | 1 | sp_picture_quality_yes | 视频_画质修复打勾 | tab_name | 选中tab | 普通参数 | string |  | ai | AI修复 |  | 视频_画质修复打勾 |  |  |  |
| 新增事件 | 0 | 1 | sp_quality_apply_save | 画质修复_应用效果保存 | portrait_level | 人像程度调节滑杆值 | 普通参数 | string |  |  |  |  | 画质修复_应用效果保存 |  |  |  |
| 新增事件 | 0 | 1 | sp_quality_apply_save | 画质修复_应用效果保存 | slide_range | UI上显示的程度滑杆值 | 普通参数 | string |  |  |  |  | 画质修复_应用效果保存 |  |  |  |
| 新增事件 | 0 | 1 | sp_body | 视频_身材美型进入 |  |  |  |  |  |  |  |  | 视频_身材美型进入 |  |  |  |
| 新增事件 | 0 | 1 | sp_bodybeauty_auto_click | 视频_身材美型一键美型点击 |  |  |  |  |  |  |  |  | 视频_身材美型一键美型点击 |  |  |  |
| 新增事件 | 0 | 1 | sp_bodybeauty_apply | 身材美型保存 |  |  |  |  |  |  |  |  | 身材美型保存 |  |  |  |
| 新增事件 | 0 | 1 | sp_bodybeauty_tab_click | 视频_身材美型子项选择 | subfunction | 子项功能 | 普通参数 | string |  | swan_neck | 天鹅颈 |  | 视频_身材美型子项选择 |  |  |  |
| 新增事件 | 0 | 1 | sp_bodybeauty_tab_click | 视频_身材美型子项选择 | subfunction | 子项功能 | 普通参数 | string |  | angular_shoulder | 直角肩 |  | 视频_身材美型子项选择 |  |  |  |
| 新增事件 | 0 | 1 | sp_bodybeauty_tab_click | 视频_身材美型子项选择 | subfunction | 子项功能 | 普通参数 | string |  | firm_breast_pro | 3d丰胸pro |  | 视频_身材美型子项选择 |  |  |  |
| 新增事件 | 0 | 1 | sp_bodybeauty_tab_click | 视频_身材美型子项选择 | subfunction | 子项功能 | 普通参数 | string |  | body | 瘦身 |  | 视频_身材美型子项选择 |  |  |  |
| 新增事件 | 0 | 1 | sp_bodybeauty_tab_click | 视频_身材美型子项选择 | subfunction | 子项功能 | 普通参数 | string |  | neck_thickness | 脖子粗细 |  | 视频_身材美型子项选择 |  |  |  |
| 新增事件 | 0 | 1 | sp_bodybeauty_tab_click | 视频_身材美型子项选择 | subfunction | 子项功能 | 普通参数 | string |  | leg | 长腿 |  | 视频_身材美型子项选择 |  |  |  |
| 新增事件 | 0 | 1 | sp_bodybeauty_tab_click | 视频_身材美型子项选择 | subfunction | 子项功能 | 普通参数 | string |  | head | 小头 |  | 视频_身材美型子项选择 |  |  |  |
| 新增事件 | 0 | 1 | sp_bodybeauty_tab_click | 视频_身材美型子项选择 | subfunction | 子项功能 | 普通参数 | string |  | haunch | 美胯 |  | 视频_身材美型子项选择 |  |  |  |
| 新增事件 | 0 | 1 | sp_bodybeauty_tab_click | 视频_身材美型子项选择 | subfunction | 子项功能 | 普通参数 | string |  | thinleg | 瘦腿 |  | 视频_身材美型子项选择 |  |  |  |
| 新增事件 | 0 | 1 | sp_bodybeauty_tab_click | 视频_身材美型子项选择 | subfunction | 子项功能 | 普通参数 | string |  | neck_length | 脖子长短 |  | 视频_身材美型子项选择 |  |  |  |
| 新增事件 | 0 | 1 | sp_bodybeauty_tab_click | 视频_身材美型子项选择 | subfunction | 子项功能 | 普通参数 | string |  | waist | 瘦腰 |  | 视频_身材美型子项选择 |  |  |  |
| 新增事件 | 0 | 1 | sp_bodybeauty_tab_click | 视频_身材美型子项选择 | subfunction | 子项功能 | 普通参数 | string |  | breast_enhancement | 丰胸 |  | 视频_身材美型子项选择 |  |  |  |
| 新增事件 | 0 | 1 | sp_bodybeauty_tab_click | 视频_身材美型子项选择 | subfunction | 子项功能 | 普通参数 | string |  | shoulder | 瘦肩膀 |  | 视频_身材美型子项选择 |  |  |  |
| 新增事件 | 0 | 1 | sp_bodybeauty_tab_click | 视频_身材美型子项选择 | subfunction | 子项功能 | 普通参数 | string |  | arm | 瘦手臂 |  | 视频_身材美型子项选择 |  |  |  |
| 新增事件 | 0 | 1 | sp_bodybeauty_yes | 身材美型打勾 | swan_neck |  | 普通参数 | string | 滑杆值左右先左后右，整理报两个一样的值 |  |  |  | 身材美型打勾 |  |  |  |
| 新增事件 | 0 | 1 | sp_bodybeauty_yes | 身材美型打勾 | angular_shoulder |  | 普通参数 | string |  |  |  |  | 身材美型打勾 |  |  |  |
| 新增事件 | 0 | 1 | sp_bodybeauty_yes | 身材美型打勾 | firm_breast_pro |  | 普通参数 | string |  |  |  |  | 身材美型打勾 |  |  |  |
| 新增事件 | 0 | 1 | sp_bodybeauty_yes | 身材美型打勾 | body |  | 普通参数 | string |  |  |  |  | 身材美型打勾 |  |  |  |
| 新增事件 | 0 | 1 | sp_bodybeauty_yes | 身材美型打勾 | neck_thickness |  | 普通参数 | string |  |  |  |  | 身材美型打勾 |  |  |  |
| 新增事件 | 0 | 1 | sp_bodybeauty_yes | 身材美型打勾 | leg |  | 普通参数 | string |  |  |  |  | 身材美型打勾 |  |  |  |
| 新增事件 | 0 | 1 | sp_bodybeauty_yes | 身材美型打勾 | head |  | 普通参数 | string |  |  |  |  | 身材美型打勾 |  |  |  |
| 新增事件 | 0 | 1 | sp_bodybeauty_yes | 身材美型打勾 | haunch |  | 普通参数 | string |  |  |  |  | 身材美型打勾 |  |  |  |
| 新增事件 | 0 | 1 | sp_bodybeauty_yes | 身材美型打勾 | thinleg |  | 普通参数 | string |  |  |  |  | 身材美型打勾 |  |  |  |
| 新增事件 | 0 | 1 | sp_bodybeauty_yes | 身材美型打勾 | neck_length |  | 普通参数 | string |  |  |  |  | 身材美型打勾 |  |  |  |
| 新增事件 | 0 | 1 | sp_bodybeauty_yes | 身材美型打勾 | waist |  | 普通参数 | string |  |  |  |  | 身材美型打勾 |  |  |  |
| 新增事件 | 0 | 1 | sp_bodybeauty_yes | 身材美型打勾 | breast_enhancement |  | 普通参数 | string |  |  |  |  | 身材美型打勾 |  |  |  |
| 新增事件 | 0 | 1 | sp_bodybeauty_yes | 身材美型打勾 | shoulder |  | 普通参数 | string |  |  |  |  | 身材美型打勾 |  |  |  |
| 新增事件 | 0 | 1 | sp_bodybeauty_yes | 身材美型打勾 | arm |  | 普通参数 | string |  |  |  |  | 身材美型打勾 |  |  |  |
| 影响事件 | 0 | 1 | w_subscription_click | 订阅页点击订阅按钮 | source_module | 进入订阅页来源模块 | 普通参数 | string |  | p_video |  |  | 选中某个plan并点击订阅按钮时上报 |  |  |  |
| 新增事件参数值 | 0 | 1 | w_subscription_click | 订阅页点击订阅按钮 | source_0 | 进入订阅页来源-0 | 普通参数 | string |  | f_picture_quality |  |  | 选中某个plan并点击订阅按钮时上报 |  |  |  |
| 新增事件参数值 | 0 | 1 | w_subscription_click | 订阅页点击订阅按钮 | source_0 | 进入订阅页来源-0 | 普通参数 | string |  | f_bodybeauty |  |  | 选中某个plan并点击订阅按钮时上报 |  |  |  |
| 影响事件 | 0 | 1 | w_subscription_success | 订阅成功 | source_module | 进入订阅页来源模块 | 普通参数 | string |  | p_video |  |  | 进入订阅页时上报 |  |  |  |
| 新增事件参数值 | 0 | 1 | w_subscription_success | 订阅成功 | source_0 | 进入订阅页来源-0 | 普通参数 | string |  | f_picture_quality |  |  | 进入订阅页时上报 |  |  |  |
| 新增事件参数值 | 0 | 1 | w_subscription_success | 订阅成功 | source_0 | 进入订阅页来源-0 | 普通参数 | string |  | f_bodybeauty |  |  | 进入订阅页时上报 |  |  |  |
| 影响事件 | 0 | 1 | w_subscription_enter | 进入订阅页 | source_module | 进入订阅页来源模块 | 普通参数 | string |  | p_video |  |  | 成功订阅时上报成功付费时上报 |  |  |  |
| 新增事件参数值 | 0 | 1 | w_subscription_enter | 进入订阅页 | source_0 | 进入订阅页来源-0 | 普通参数 | string |  | f_picture_quality |  |  | 成功订阅时上报成功付费时上报 |  |  |  |
| 新增事件参数值 | 0 | 1 | w_subscription_enter | 进入订阅页 | source_0 | 进入订阅页来源-0 | 普通参数 | string |  | f_bodybeauty |  |  | 成功订阅时上报成功付费时上报 |  |  |  |
| 影响事件 | 0 | 1 | video_album_enter | 进入视频相册 | enter_from | 进入视频相册来源 | 普通参数 | string |  |  |  |  | 进入视频相册触发 |  |  |  |
| 影响事件 | 0 | 1 | video_face_identify_success | 视频人脸识别成功 | video_time | 视频时长 | 普通参数 | number |  |  |  |  | 视频人脸识别成功时触发 |  |  |  |
| 影响事件 | 0 | 1 | video_face_identify_success | 视频人脸识别成功 | face_time | 人脸识别成功时长 （若视频无人脸，也存在识别耗时） | 普通参数 | number |  |  |  |  | 视频人脸识别成功时触发 |  |  |  |