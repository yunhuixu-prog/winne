-- 功能使用表，每一行代表用户在某个日期使用某个功能的行为
SELECT date_p
    ,os_type -- 操作系统
    ,country_id -- 国家id
    ,gid -- 用户标识id
    ,sub_func_level2_name -- 二级功能名称
    -- ,sub_func_level3_name -- 三级功能名称（目前暂未统计）
    ,event_type -- 事件类型：进入、打勾、保存
    ,cnt -- 次数
FROM stat_sdk.airbrush_mdz_tool_behavior_detail
WHERE date_p between ${start_date} and ${end_date}
    AND model_p IN ('image_edit') -- 图片编辑，一般默认选择这个。另外还有camera：拍照等
    AND tool_level in ('2') -- 层级（目前仅有1、2）：2对应sub_func_level2_name
;
-- 三级功能，和功能表结构基本一致
SELECT date_p,sub_func_level2_name,sub_func_level3_name
    ,SUM(case when event_type='进入' then cnt end) enter_pv
    ,SUM(case when event_type='打勾' then cnt end) use_pv
    ,SUM(case when event_type='保存' then cnt end) save_pv
FROM stat_ab.airbrush_mdz_tool_behavior_detail_v2
WHERE date_p between ${start_date} and ${end_date}
    AND model_p IN ('image_edit') -- , 'camera', 'sp_edit', 'H5'
    AND tool_level in ('3')
GROUP BY date_p,sub_func_level2_name,sub_func_level3_name