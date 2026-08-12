-- 可能还有些量级不大的功能没有匹配上，如果要用的话注意
with function_use as (
    SELECT date_p,gid,sub_func_level2_name
        ,SUM(case when event_type='进入' then cnt end) enter_pv
        ,SUM(case when event_type='打勾' then cnt end) use_pv
        ,SUM(case when event_type='保存' then cnt end) save_pv
    FROM stat_sdk.airbrush_mdz_tool_behavior_detail
    WHERE date_p between ${start_date} and ${end_date}
        AND model_p IN ('image_edit') -- , 'camera', 'sp_edit', 'H5'
        AND tool_level in ('2')
    GROUP BY date_p,gid,sub_func_level2_name
)
,sub_function AS (
    select
            date_p,gid
            ,case when third_source in ('Skin') then fourth_source 
                when first_source='AIGC' then 'AI Image'
        else third_source end third_source
            ,MAX(case when event_id='sub_enter' then 1 end) is_sub_enter
            ,COUNT(case when event_id='sub_enter' then 1 end) sub_enter_pv
            ,MAX(case when event_id='sub_suc' then 1 end) is_sub
            ,MAX(case when event_id='sub_suc' and is_paid=1 then 1 end) is_sub_to_paid
            ,sum(case when event_id='sub_suc' and is_paid=1 then devide_paid_ord_amt end) sub_paid_ord_amt
        from stat_ab.filing_onz_sub_source_event_detail_level
        where date_p between ${start_date} and ${end_date}
            and ((first_source='Edit' and second_source in ('Edit','Retouch','Material')) 
                or (first_source='AIGC' and second_source='AI Filter'))
        group by date_p,gid,case when third_source in ('Skin') then fourth_source 
                when first_source='AIGC' then 'AI Image'
        else third_source end
)
select f.date_p,f.sub_func_level2_name,sum(use_pv) function_use_uv,SUM(is_sub_enter) sub_uv
from (select * from function_use) f
left join (select * from sub_function) s
on f.date_p=s.date_p and f.gid=s.gid and f.sub_func_level2_name=s.third_source
group by f.date_p,f.sub_func_level2_name