| 需求类型 | 事件来源 | 事件类型 | *事件id | *事件名称 | 参数 | 参数名称 | 参数类型 | 参数值类型 | 参数口径 | 参数值 | 参数值名称 | 参数值口径 | *统计口径 | 备注说明 | 事件分组 | 标签 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 影响事件 | 0 | 1 | second_func_enter | 点击二级功能页面 | second_func | 二级功能参数 | 普通参数 | string |  | ai_repair |  |  | 点击二级功能页面时上报 |  |  |  |
| 新增事件参数值 | 0 | 1 | second_func_enter | 点击二级功能页面 | from | 进入功能来源 | 普通参数 | string |  | primary_entry |  | 从金刚位Repair进 | 点击二级功能页面时上报 |  |  |  |
| 影响事件 | 0 | 1 | second_func_save | 二级功能保存 | second_func |  | 普通参数 | string | plump | ai_repair |  |  | 保存edit下的二级功能 |  |  |  |
| 影响事件 | 0 | 1 | second_func_use | 二级功能打勾 | second_func | 二级功能参数 | 普通参数 | string | makeup | ai_repair |  |  | 应用edit下的二级功能时触发 |  |  |  |
| 影响事件 | 1017 | 1 | sp_picture_quality_click |  | icon_name |  | 普通参数 | number |  |  |  |  |  |  |  |  |
| 新增事件参数 | 1017 | 1 | sp_picture_quality_click |  | from |  | 普通参数 | string |  | primary_entry |  | 从金刚位来的 |  |  |  |  |
| 影响事件 | 1017 | 1 | sp_picture_quality_yes |  | tab_name |  | 普通参数 | string |  |  |  |  |  |  |  |  |
| 新增事件参数值 | 0 | 1 | edit_enter | 进入编辑页 | edit_enter_from | 编辑页进入来源 | 普通参数 | string |  | t_repair |  |  | 进入编辑页时触发 |  |  |  |
| 新增事件参数值 | 0 | 1 | video_start_edit | 选择视频相册后开始 | enter_from | 进入视频编辑器来源 | 普通参数 | string |  | t_repair |  |  | 选择视频相册后开始编辑触发 |  |  |  |