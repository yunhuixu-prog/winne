| 需求类型 | 事件来源 | 事件类型 | *事件id | *事件名称 | 参数 | 参数名称 | 参数类型 | 参数值类型 | 参数口径 | 参数值 | 参数值名称 | 参数值口径 | *统计口径 | 备注说明 | 事件分组 | 标签 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 新增事件参数值 | 0 | 1 | second_func_enter | 点击二级功能页面 | first_func | 一级功能参数 | 普通参数 | string |  | relight |  |  | 进入二级功能页面时上报 | relight由对照组二级变成实验组一级，下列实验组埋点（对照组埋点维持历史逻辑上报）;first_func_enter和second_func_enter from参数记录值homepage表示从首页来的 |  |  |
| 新增事件参数值 | 0 | 1 | first_func_use | 一级功能使用 | first_func |  | 普通参数 | string |  | relight |  |  | 一级功能使用时触发 | relight由对照组二级变成实验组一级，下列实验组埋点（对照组埋点维持历史逻辑上报）;first_func_enter和second_func_enter from参数记录值homepage表示从首页来的 |  |  |
| 新增事件参数值 | 0 | 1 | first_func_enter | 点击一级功能页面 | first_func | 一级功能参数 | 普通参数 | string |  | relight |  |  | 点击一级功能页面时上报 | relight由对照组二级变成实验组一级，下列实验组埋点（对照组埋点维持历史逻辑上报）;first_func_enter和second_func_enter from参数记录值homepage表示从首页来的 |  |  |
| 新增事件参数值 | 0 | 1 | edit_save | 编辑保存 | prf_first_func | 一级功能参数 | 普通参数 | string | 多个分割, 一级、二级、三级功能一一对应 | relight |  |  | 结束编辑最终保存时触发 |  |  |  |
| 新增事件 | 0 | 1 | first_func_save | 一级功能保存 | first_func |  | 普通参数 | string |  | relight |  |  | 一级relight保存 |  |  |  |
| 新增事件 | 0 | 1 | first_func_save | 一级功能保存 | presets_selection |  | 普通参数 | string | 子项功能名，和历史一致 |  |  |  | 一级relight保存 |  |  |  |