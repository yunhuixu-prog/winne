-- 二级功能
SELECT date_p,gid,sub_func_level2_name
        ,SUM(case when event_type='进入' then cnt end) enter_pv
        ,SUM(case when event_type='打勾' then cnt end) use_pv
        ,SUM(case when event_type='保存' then cnt end) save_pv
    FROM stat_sdk.airbrush_mdz_tool_behavior_detail
    WHERE date_p between ${start_date} and ${end_date}
        AND model_p IN ('image_edit') -- , 'camera', 'sp_edit', 'H5'
        AND tool_level in ('2')
    GROUP BY date_p,gid,sub_func_level2_name

;
-- 三级子功能
SELECT date_p,sub_func_level2_name,sub_func_level3_name
        ,SUM(case when event_type='进入' then cnt end) enter_pv
        ,SUM(case when event_type='打勾' then cnt end) use_pv
        ,SUM(case when event_type='保存' then cnt end) save_pv
    FROM stat_ab.airbrush_mdz_tool_behavior_detail_v2
    WHERE date_p between ${start_date} and ${end_date}
        AND model_p IN ('image_edit') -- , 'camera', 'sp_edit', 'H5'
        AND tool_level in ('3')
    GROUP BY date_p,sub_func_level2_name,sub_func_level3_name
;
-- 三级子功能付费情况
select function,sub_function,pay_type
from stat_ab.filing_rna_function_pay_type