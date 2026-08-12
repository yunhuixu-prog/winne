| 需求类型 | 事件来源 | 事件类型 | *事件id | *事件名称 | 参数 | 参数名称 | 参数类型 | 参数值类型 | 参数口径 | 参数值 | 参数值名称 | 参数值口径 | *统计口径 | 备注说明 | 事件分组 | 标签 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 影响事件 | 0 | 1 | first_func_enter | 点击一级功能页面 | first_func | 一级功能参数 | 普通参数 | string |  | hair |  |  | 点击一级功能页面时上报 |  |  |  |
| 影响事件 | 0 | 1 | first_func_use | 一级功能使用 | first_func |  | 普通参数 | string |  | hair |  |  | 一级功能使用时触发 |  |  |  |
| 影响事件 | 0 | 1 | second_func_exposure | 二级功能曝光 | first_func |  | 普通参数 | string |  | hair |  |  | 功能icon曝光 |  |  |  |
| 影响事件 | 0 | 1 | second_func_exposure | 二级功能曝光 | second_func |  | 普通参数 | string | glowup | hair_enrich |  |  | 功能icon曝光 |  |  |  |
| 影响事件 | 0 | 1 | second_func_exposure | 二级功能曝光 | second_func |  | 普通参数 | string | glowup | hair_dye |  |  | 功能icon曝光 |  |  |  |
| 影响事件 | 0 | 1 | second_func_enter | 点击二级功能页面 | first_func | 一级功能参数 | 普通参数 | string |  | hair |  |  | 点击二级功能页面时上报 |  |  |  |
| 影响事件 | 0 | 1 | second_func_enter | 点击二级功能页面 | second_func | 二级功能参数 | 普通参数 | string | plump | hair_enrich |  |  | 点击二级功能页面时上报 |  |  |  |
| 影响事件 | 0 | 1 | second_func_enter | 点击二级功能页面 | second_func | 二级功能参数 | 普通参数 | string | plump | hair_dye |  |  | 点击二级功能页面时上报 |  |  |  |
| 影响事件 | 0 | 1 | edit_save | 编辑保存 | prf_first_func | 一级功能参数 | 普通参数 | string | 多个分割, 一级、二级、三级功能一一对应 | hair |  |  | 结束编辑最终保存时触发 |  |  |  |
| 影响事件 | 0 | 1 | edit_save | 编辑保存 | mids_category_id | 分类id | 普通参数 | string |  |  |  |  | 结束编辑最终保存时触发 |  |  |  |
| 影响事件 | 0 | 1 | edit_save | 编辑保存 | mids_material_id | 素材id | 普通参数 | string |  |  |  |  | 结束编辑最终保存时触发 |  |  |  |
| 影响事件 | 0 | 1 | edit_save | 编辑保存 | prf_material_type | 素材类型 | 普通参数 | string | hair_dye,hair_enrich |  |  |  | 结束编辑最终保存时触发 |  |  |  |