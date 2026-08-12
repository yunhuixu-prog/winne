| 需求类型 | 事件来源 | 事件类型 | *事件id | *事件名称 | 参数 | 参数名称 | 参数类型 | 参数值类型 | 参数口径 | 参数值 | 参数值名称 | 参数值口径 | *统计口径 | 备注说明 | 事件分组 | 标签 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 影响事件 | 0 | 1 | material_check | 素材打勾 | material_type | 素材类型 | 普通参数 | string | hair_dye,hairstyles,hair_enrich(hair_enrich新增),volume,texture(对照组报) | ai_tattoo |  |  | 应用功能时触发 |  |  |  |
| 新增事件参数 | 0 | 1 | material_check | 素材打勾 | is_upload |  | 普通参数 | string | 素材是否自主上传,和素材id一一对应 | 0 |  | app内素材 | 应用功能时触发 |  |  |  |
| 新增事件参数 | 0 | 1 | material_check | 素材打勾 | is_upload |  | 普通参数 | string | 素材是否自主上传,和素材id一一对应 | 1 |  | 自主上传 | 应用功能时触发 |  |  |  |
| 新增事件参数 | 0 | 1 | material_check | 素材打勾 | bw |  | 普通参数 | string | ,和素材id一一对应 | 0 |  | 开关未打开 | 应用功能时触发 |  |  |  |
| 新增事件参数 | 0 | 1 | material_check | 素材打勾 | bw |  | 普通参数 | string | ,和素材id一一对应 | 1 |  | 开关打开 | 应用功能时触发 |  |  |  |
| 影响事件 | 0 | 1 | cloudfilter_per_show | 图片云处理权限弹窗点击 | function | 功能 | 普通参数 | string | relight_beach_day,relight_indigo,relight_soft_glow,relight_sunlit | ai_tattoo |  |  |  |  |  |  |
| 影响事件 | 0 | 1 | cloudfilter_per_show_ok | 图片云处理权限弹窗点击 | function |  | 普通参数 | string | relight_beach_day,relight_indigo,relight_soft_glow,relight_sunlit | ai_tattoo |  |  |  |  |  |  |
| 新增事件参数 | 0 | 1 | edit_save | 编辑保存 | is_upload |  | 普通参数 | string | 纹身保存的素材是否来自上传，,和素材id一一对应 | 0 |  | 非 | 结束编辑最终保存时触发 |  |  |  |
| 新增事件参数 | 0 | 1 | edit_save | 编辑保存 | is_upload |  | 普通参数 | string | 纹身保存的素材是否来自上传，,和素材id一一对应 | 1 |  | 是 | 结束编辑最终保存时触发 |  |  |  |