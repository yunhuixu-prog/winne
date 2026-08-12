| 需求类型 | 事件来源 | 事件类型 | *事件id | *事件名称 | 参数 | 参数名称 | 参数类型 | 参数值类型 | 参数口径 | 参数值 | 参数值名称 | 参数值口径 | *统计口径 | 备注说明 | 事件分组 | 标签 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 删除事件参数值 | 0 | 1 | edit_save | 编辑保存 | prf_third_func | 三级功能参数 | 普通参数 | string | 只到waist | smooth,skin_tone,brighten,dark_circles,0 |  |  | 结束编辑最终保存时触发 | magic保存的时候，不用报到三级，prf_third_func不报该参数 |  |  |
| 新增事件参数 | 0 | 1 | second_func_save | 二级功能保存 | magic_selection |  | 普通参数 | string | 用啥子功能报啥子功能，英文名，英文逗号隔开 |  |  |  | 保存edit下的二级功能 |  |  |  |
| 影响事件 | 0 | 1 | second_func_save | 二级功能保存 | second_func |  | 普通参数 | string | plump | magic |  |  | 保存edit下的二级功能 |  |  |  |