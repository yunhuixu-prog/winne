
with 
event_all as
(
    select event_date,event_name,event_params,receive_time as event_timestamp,platform,meepo_abcode,device_id,country,user_pseudo_id
    from `dataintegration-265403.abtest.stage_aa_meepo_abcountgt1_event`
    where app_name in ('BeautyPlus') 
        and event_date>='2023-09-26' and event_date<='2023-10-25'
        and cast(meepo_abcode as string) in ('10256', '10257','10258','10259')
        and device_id is not null --limit 100
),

abcode as 
(
    SELECT
        date_p, cast(ab_code as string) code
    , field as device_id
    , country_id
    , case when is_app_new='2' then 'new user' when is_app_new='1' then 'old user' end as is_new
    , case when app_key in ('F9B069901A7B2E8D') then 'IOS' when app_key in ('C6FF0769324CD2F1') then 'ANDROID' end as platform,receive_time as timestamp
    FROM
    `dataintegration-265403.abtest.abtest_odz_flow`--2.第一次进入实验用户
    WHERE
        date_p>='2023-09-26' and date_p<='2023-10-25'
        and cast(ab_code as string) in ('10256', '10257','10258','10259')
        and field_type = 3 --field是3 device-id
        and app_key in ('F9B069901A7B2E8D','C6FF0769324CD2F1')
)
,
event_ab as 
(
    select m.*
        ,a.code
        ,case
        when a.code in ('10256','10258') then '对照组'
        when a.code in ('10257','10259') then '实验组'
        end as code_type
        ,a.is_new 
    from 
    (
        select event_date
            ,event_timestamp
            ,platform
            ,country
            ,event_name
            ,user_pseudo_id
            ,device_id
            ,func.getParams(event_params,'reason').string_value reason
            ,func.getParams(event_params,'type').string_value type 
            ,func.getParams(event_params,'content').string_value content
            ,func.getParams(event_params,'discount_cutdown').string_value discount_cutdown
        from event_all 
        where event_name in  ('coupon_pop_appr_bd','trial_pop_appr_bd','vip_cancel_page_imp_bd',
                'coupon_pop_clk_bd','trial_pop_clk_bd','vip_cancel_payment_survey_bd','vip_cancel_payment_survey_other_reasons_bd',
                'page_event','subscription_clk_try','subscription_try_suc')
    ) m 
    join abcode a
    on  m.device_id=a.device_id  and m.platform=a.platform and m.event_timestamp>=a.timestamp-15000000
)
,
event_ab_final as
(
    select a.*,coalesce(reason_write,'未触发or未填写') reason_write
    FROM event_ab a 
    --关联用户选择类型
    left join 
    (
        -- select platform
        --         ,event_name
        --         ,device_id
        --         ,code
        --         ,code_type 
        --         ,is_new 
        --         ,min(event_timestamp) timestamp
        --         ,count(1) pv 
        -- from event_ab
        -- where event_name in ('coupon_pop_appr_bd','trial_pop_appr_bd')
        -- group by 1,2,3,4,5,6

        select device_id
                ,max(reason) reason_write 
        from event_ab 
        where event_name in ('vip_cancel_payment_survey_bd')
        group by 1
    ) u 
    on a.device_id=u.device_id  
)


select event_date,code_type,platform,event_name,reason,reason_write,type,content,count(distinct device_id) as uv
from event_ab_final
group by 1,2,3,4,5,6,7,8;
