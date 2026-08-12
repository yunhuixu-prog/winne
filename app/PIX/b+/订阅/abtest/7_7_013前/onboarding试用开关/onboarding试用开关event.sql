
with 
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
        date_p>='2023-10-18' and date_p<='2023-11-20'
        and cast(ab_code as string) in ('10330','10331','10347','10348')
        and field_type = 3 --field是3 device-id
        and app_key in ('F9B069901A7B2E8D','C6FF0769324CD2F1')
)
,
event_all as
(
    select event_date,event_name,event_params,receive_time as event_timestamp,platform,meepo_abcode,device_id,country,user_pseudo_id
    from `dataintegration-265403.abtest.stage_aa_meepo_abcountgt1_event`
    where app_name in ('BeautyPlus') 
        and event_date>='2023-10-18' and event_date<='2023-11-20'
        and cast(meepo_abcode as string) in ('10330','10331','10347','10348')
        and device_id is not null --limit 100
),
event_ab as 
(
    select m.*
        ,a.code
        ,case
        when a.code in ('10330','10347') then '对照组'
        when a.code in ('10331','10348') then '实验组'
        end as code_type
        ,a.is_new 
    from 
    (
        select event_date
            ,event_timestamp
            ,platform
            ,country
            ,case when country in ('South Korea','Thailand','Japan','United States') then country else 'WW' end as region
            ,event_name
            ,user_pseudo_id
            ,device_id
            ,coalesce(func.getParams(event_params,'is_trial_open').string_value,cast(func.getParams(event_params,'is_trial_open').int_value as string)) is_trial_open
        from event_all 
        where event_name in  ('page_event','subscription_try_suc')
        and (func.getParams(event_params,'cur_spm').string_value like '%1008%')
    ) m 
    join abcode a
    on  m.device_id=a.device_id  and m.platform=a.platform and m.event_timestamp>=a.timestamp-15000000
)

select platform,code_type,event_name,is_trial_open_type,sum(num)
from 
(
select event_date
        ,event_name
        ,'all' is_trial_open_type
        ,code_type
        ,platform
        ,count(distinct device_id) num
from event_ab
where region='United States'
group by 1,2,3,4,5

union all 

select event_date
        ,event_name
        ,case when is_trial_open='0' then '未开启'
              when is_trial_open='1' then '开启'
        else is_trial_open
        end is_trial_open_type
        ,code_type
        ,platform
        ,count(distinct device_id) num
from event_ab
where region='United States'
group by 1,2,3,4,5
)
group by 1,2,3,4
order by 1,2,3,4