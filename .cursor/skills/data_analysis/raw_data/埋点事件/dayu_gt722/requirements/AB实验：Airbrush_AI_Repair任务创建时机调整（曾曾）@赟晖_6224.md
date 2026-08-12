| 需求类型 | 事件来源 | 事件类型 | *事件id | *事件名称 | 参数 | 参数名称 | 参数类型 | 参数值类型 | 参数口径 | 参数值 | 参数值名称 | 参数值口径 | *统计口径 | 备注说明 | 事件分组 | 标签 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 影响事件 | 0 | 1 | ai_func_use_result | 使用ai算法请求结果返回 | first_func | 一级功能参数 | 普通参数 | string |  | edit |  |  | 使用ai算法请求结果返回时触发 |  |  |  |
| 影响事件 | 0 | 1 | ai_func_use_result | 使用ai算法请求结果返回 | second_func | 二级功能参数 | 普通参数 | string |  | ai_repair |  |  | 使用ai算法请求结果返回时触发 |  |  |  |
| 影响事件 | 0 | 1 | ai_func_use_result | 使用ai算法请求结果返回 | is_success | 应用效果(图片处理)是否成功 | 普通参数 | number |  | 0 |  | 应用失败 | 使用ai算法请求结果返回时触发 |  |  |  |
| 影响事件 | 0 | 1 | ai_func_use_result | 使用ai算法请求结果返回 | is_success | 应用效果(图片处理)是否成功 | 普通参数 | number |  | 1 |  | 应用成功 | 使用ai算法请求结果返回时触发 |  |  |  |
| 影响事件 | 0 | 1 | ai_func_use_result | 使用ai算法请求结果返回 | is_success | 应用效果(图片处理)是否成功 | 普通参数 | number |  | 2 |  | 用户点cancel（非立即取消，任务已创建） | 使用ai算法请求结果返回时触发 |  |  |  |
| 影响事件 | 0 | 1 | ai_func_use_result | 使用ai算法请求结果返回 | func | 功能 | 普通参数 | string | image_quality:off,hd,portrait;resolution:off,2k,4k;,color_enhance:of,on;denoise:off,low,medium,high;colorize:off,on |  |  |  | 使用ai算法请求结果返回时触发 |  |  |  |
| 影响事件 | 0 | 1 | ai_func_use_result | 使用ai算法请求结果返回 | is_recommend | 是否推荐模式 | 普通参数 | number |  | 1 |  | 推荐模式的参数，包含用户修改后最终还是推荐模式的参数 | 使用ai算法请求结果返回时触发 |  |  |  |
| 影响事件 | 0 | 1 | ai_func_use_result | 使用ai算法请求结果返回 | is_recommend | 是否推荐模式 | 普通参数 | number |  | 0 |  | 只要用户有修改推荐模式 | 使用ai算法请求结果返回时触发 |  |  |  |
| 新增事件参数值 | 0 | 1 | ai_func_use_result | 使用ai算法请求结果返回 | is_success | 应用效果(图片处理)是否成功 | 普通参数 | number |  | -1 |  | 用户立即取消并未真正发起任务 | 使用ai算法请求结果返回时触发 |  |  |  |