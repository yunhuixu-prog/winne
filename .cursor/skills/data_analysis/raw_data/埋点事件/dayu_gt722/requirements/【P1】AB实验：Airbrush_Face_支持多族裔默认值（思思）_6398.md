| 需求类型 | 事件来源 | 事件类型 | *事件id | *事件名称 | 参数 | 参数名称 | 参数类型 | 参数值类型 | 参数口径 | 参数值 | 参数值名称 | 参数值口径 | *统计口径 | 备注说明 | 事件分组 | 标签 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 影响事件 | 0 | 1 | second_func_enter | 点击二级功能页面 | second_func | 二级功能参数 | 普通参数 | string |  | face |  |  | 点击二级功能页面时上报 |  |  |  |
| 新增事件参数 | 0 | 1 | second_func_enter | 点击二级功能页面 | race | 人种 | 普通参数 | string | 多人脸顺序上报，用逗号隔开 |  |  |  | 点击二级功能页面时上报 |  |  |  |
| 新增事件参数 | 0 | 1 | second_func_enter | 点击二级功能页面 | gender | 性别 | 普通参数 | string | 多人脸顺序上报，用逗号隔开 |  |  |  | 点击二级功能页面时上报 |  |  |  |
| 新增事件参数 | 0 | 1 | second_func_enter | 点击二级功能页面 | age | 年龄 | 普通参数 | string | 多人脸顺序上报，用逗号隔开 |  |  |  | 点击二级功能页面时上报 |  |  |  |
| 影响事件 | 0 | 1 | second_func_use | 二级功能打勾 | second_func | 二级功能参数 | 普通参数 | string | 功能名 | face |  |  | 应用edit下的二级功能时触发 |  |  |  |
| 影响事件 | 0 | 1 | second_func_use | 二级功能打勾 | is_effect | 是否有应用任一效果 | 普通参数 | string |  |  |  |  | 应用edit下的二级功能时触发 |  |  |  |
| 影响事件 | 0 | 1 | second_func_use | 二级功能打勾 | prf_nose_mod | nose各项调整数值 | 普通参数 | string | size:xx;length:xx;width:xx;bridge:xx;tip:xx;root:xx |  |  |  | 应用edit下的二级功能时触发 |  |  |  |
| 影响事件 | 0 | 1 | second_func_use | 二级功能打勾 | prf_jaw_mod | jaw各项调整数值 | 普通参数 | string | chin:xx;double_chin:xx;jaw:xx;jaw_line:xx;length:xx;jaw_shape:xx;double_chin_pro:xx |  |  |  | 应用edit下的二级功能时触发 |  |  |  |
| 影响事件 | 0 | 1 | second_func_use | 二级功能打勾 | prf_face_mod | face各项调整数值 | 普通参数 | string |  |  |  |  | 应用edit下的二级功能时触发 |  |  |  |
| 影响事件 | 0 | 1 | second_func_use | 二级功能打勾 | prf_eye_mod | eye各项调整数值 | 普通参数 | string |  |  |  |  | 应用edit下的二级功能时触发 |  |  |  |
| 影响事件 | 0 | 1 | second_func_use | 二级功能打勾 | prf_lip_mod | lip各项调整数值 | 普通参数 | string |  |  |  |  | 应用edit下的二级功能时触发 |  |  |  |
| 影响事件 | 0 | 1 | second_func_use | 二级功能打勾 | prf_eyebrow_mod | eyebrow各项调整数值 | 普通参数 | string |  |  |  |  | 应用edit下的二级功能时触发 |  |  |  |
| 影响事件 | 0 | 1 | second_func_save | 二级功能保存 | second_func |  | 普通参数 | string | plump | face |  |  | 保存edit下的二级功能 |  |  |  |
| 影响事件 | 0 | 1 | second_func_save | 二级功能保存 | prf_nose_mod |  | 普通参数 | string | size:xx;length:xx;width:xx;bridge:xx;tip:xx;root:xx |  |  |  | 保存edit下的二级功能 |  |  |  |
| 影响事件 | 0 | 1 | second_func_save | 二级功能保存 | prf_jaw_mod |  | 普通参数 | string | chin:xx;double_chin:xx;jaw:xx;jaw_line:xx;length:xx;jaw_shape:xx;double_chin_pro:xx |  |  |  | 保存edit下的二级功能 |  |  |  |
| 影响事件 | 0 | 1 | second_func_save | 二级功能保存 | prf_face_mod |  | 普通参数 | string |  |  |  |  | 保存edit下的二级功能 |  |  |  |
| 影响事件 | 0 | 1 | second_func_save | 二级功能保存 | prf_eye_mod |  | 普通参数 | string |  |  |  |  | 保存edit下的二级功能 |  |  |  |
| 影响事件 | 0 | 1 | second_func_save | 二级功能保存 | prf_lip_mod |  | 普通参数 | string |  |  |  |  | 保存edit下的二级功能 |  |  |  |
| 影响事件 | 0 | 1 | second_func_save | 二级功能保存 | prf_eyebrow_mod |  | 普通参数 | string |  |  |  |  | 保存edit下的二级功能 |  |  |  |
| 影响事件 | 0 | 1 | editor_race_detect | 进入编辑页 | race |  | 普通参数 | string | 上报算法获得的人种信息，英文名 |  |  |  | 获得人种结果时上报 |  |  |  |
| 影响事件 | 0 | 1 | editor_race_detect | 进入编辑页 | gender |  | 普通参数 | string |  |  |  |  | 获得人种结果时上报 |  |  |  |
| 新增事件参数 | 0 | 1 | editor_race_detect | 进入编辑页 | age | 年龄 | 普通参数 | string | 上报算法获得的人年龄 |  |  |  | 获得人种结果时上报 |  |  |  |