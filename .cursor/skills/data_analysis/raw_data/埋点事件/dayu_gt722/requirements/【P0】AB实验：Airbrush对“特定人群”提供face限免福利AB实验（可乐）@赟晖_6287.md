| 需求类型 | 事件来源 | 事件类型 | *事件id | *事件名称 | 参数 | 参数名称 | 参数类型 | 参数值类型 | 参数口径 | 参数值 | 参数值名称 | 参数值口径 | *统计口径 | 备注说明 | 事件分组 | 标签 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 影响事件 | 0 | 1 | popup_click | 点击popup弹窗confirm  button | page_name | 弹窗出现的页面名称 | 普通参数 | string |  | edit |  |  | 点击popup弹窗confirm  button触发 (不包括评分弹窗) | popup_click点击「let's got」时上报 |  |  |
| 新增事件参数值 | 0 | 1 | popup_click | 点击popup弹窗confirm  button | pop_name | 弹窗name | 普通参数 | string |  | face_free_limit | face限免弹窗 |  | 点击popup弹窗confirm  button触发 (不包括评分弹窗) | popup_click点击「let's got」时上报 |  |  |
| 影响事件 | 0 | 1 | popup_show | popup弹窗出现 | page_name | 弹窗出现的页面名称 | 普通参数 | string |  | edit |  |  | popup弹窗出现时触发(不包括评分弹窗) | popup_click点击「let's got」时上报 |  |  |
| 新增事件参数值 | 0 | 1 | popup_show | popup弹窗出现 | pop_name | 弹窗name | 普通参数 | string |  | face_free_limit | face限免弹窗 |  | popup弹窗出现时触发(不包括评分弹窗) | popup_click点击「let's got」时上报 |  |  |
| 影响事件 | 1 | 1 | limited_banner_show | 限免保存横幅展示 | first_func | 一级功能参数 | 普通参数 | string |  | retouch |  |  | 限免保存横幅展示时上报 |  |  |  |
| 影响事件 | 1 | 1 | limited_banner_show | 限免保存横幅展示 | second_func | 二级功能参数 | 普通参数 | string |  | face |  |  | 限免保存横幅展示时上报 |  |  |  |
| 新增事件参数 | 1 | 1 | limited_banner_show | 限免保存横幅展示 | position |  | 普通参数 | string |  | top | 顶部横幅 |  | 限免保存横幅展示时上报 |  |  |  |
| 新增事件参数 | 1 | 1 | limited_banner_show | 限免保存横幅展示 | position |  | 普通参数 | string |  | right_bottom | 右下部悬浮倒计时 |  | 限免保存横幅展示时上报 |  |  |  |
| 新增事件参数 | 1 | 1 | limited_banner_show | 限免保存横幅展示 | remain | 剩余次数 | 普通参数 | string |  |  |  |  | 限免保存横幅展示时上报 |  |  |  |
| 新增事件参数 | 1 | 1 | limited_banner_show | 限免保存横幅展示 | remain_time | 剩余时间（小时） | 普通参数 | string |  |  |  |  | 限免保存横幅展示时上报 |  |  |  |
| 影响事件 | 1 | 1 | limited_banner_click | 限免保存横幅点击 | first_func |  | 普通参数 | string |  | retouch |  |  | 限免保存横幅点击时上报 |  |  |  |
| 影响事件 | 1 | 1 | limited_banner_click | 限免保存横幅点击 | second_func |  | 普通参数 | string |  | face |  |  | 限免保存横幅点击时上报 |  |  |  |
| 影响事件 | 1 | 1 | limited_banner_click | 限免保存横幅点击 | type |  | 普通参数 | string |  | close | 点击右上角「X」 | 顶部横幅和悬浮倒计时均包括 | 限免保存横幅点击时上报 |  |  |  |
| 新增事件参数值 | 1 | 1 | limited_banner_click | 限免保存横幅点击 | type |  | 普通参数 | string |  | content | 点击悬浮倒计时 |  | 限免保存横幅点击时上报 |  |  |  |
| 新增事件参数 | 1 | 1 | limited_banner_click | 限免保存横幅点击 | position |  | 普通参数 | string |  | top | 顶部横幅 |  | 限免保存横幅点击时上报 |  |  |  |
| 新增事件参数 | 1 | 1 | limited_banner_click | 限免保存横幅点击 | position |  | 普通参数 | string |  | right_bottom | 右下部悬浮倒计时 |  | 限免保存横幅点击时上报 |  |  |  |
| 新增事件参数 | 1 | 1 | limited_banner_click | 限免保存横幅点击 | remain | 剩余次数 | 普通参数 | string |  |  |  |  | 限免保存横幅点击时上报 |  |  |  |
| 新增事件参数 | 1 | 1 | limited_banner_click | 限免保存横幅点击 | remain_time | 剩余时间（小时） | 普通参数 | string |  |  |  |  | 限免保存横幅点击时上报 |  |  |  |
| 影响事件 | 0 | 1 | second_func_enter | 点击二级功能页面 | first_func | 一级功能参数 | 普通参数 | string |  | retouch |  |  | 点击二级功能页面时上报 |  |  |  |
| 影响事件 | 0 | 1 | second_func_enter | 点击二级功能页面 | second_func | 二级功能参数 | 普通参数 | string | plump | face |  |  | 点击二级功能页面时上报 |  |  |  |
| 影响事件 | 0 | 1 | second_func_use | 二级功能打勾 | first_func | 一级功能参数 | 普通参数 | string |  | retouch |  |  | 应用edit下的二级功能时触发 |  |  |  |
| 影响事件 | 0 | 1 | second_func_use | 二级功能打勾 | second_func | 二级功能参数 | 普通参数 | string | makeup | face |  |  | 应用edit下的二级功能时触发 |  |  |  |
| 影响事件 | 0 | 1 | second_func_save | 二级功能保存 | first_func |  | 普通参数 | string |  | retouch |  |  | 保存edit下的二级功能 |  |  |  |
| 影响事件 | 0 | 1 | second_func_save | 二级功能保存 | second_func |  | 普通参数 | string | plump | face |  |  | 保存edit下的二级功能 |  |  |  |