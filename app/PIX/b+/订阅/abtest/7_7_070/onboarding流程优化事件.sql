
with
abcode as
(
    select
        date_p
        ,cast(ab_code as string) code
        ,field as device_id
        ,country_id
--         ,country
        ,case   when country in ('United States','Thailand','South Korea','Japan') then country
            else 'WW'
        end as region
        ,case when is_app_new='2' then 'new user' when is_app_new='1' then 'old user' end as is_new
        ,case when app_key in ('F9B069901A7B2E8D') then 'IOS' when app_key in ('C6FF0769324CD2F1') then 'ANDROID' end as platform,receive_time as timestamp
    from
        `dataintegration-265403.abtest.abtest_odz_flow` a --2.第一次进入实验用户
        left join   (select
                        event_date
                        ,device_id
                        ,max(country) country
                    from
                        `dataintegration-265403.abtest.stage_aa_meepo_enter_event`
                    group by
                        1,2 ) b on a.date_p = b.event_date and a.field = b.device_id
     where
        case    when app_key in ('F9B069901A7B2E8D')  then (date_p between '2024-03-13' and '2024-04-02')
                when app_key in ('C6FF0769324CD2F1') then (date_p between '2024-03-25' and '2024-04-23')
                end
        and cast(ab_code as string) in ('10537','10538','10539','10534','10535')
        and field_type = 3 --field是3 device-id
        and app_key in ('F9B069901A7B2E8D','C6FF0769324CD2F1')
)
,
event_all as
(
    select event_date,event_name,event_params,receive_time as event_timestamp,platform,meepo_abcode,device_id,country,user_pseudo_id
    from `dataintegration-265403.abtest.stage_aa_meepo_abcountgt1_event`
    where app_name in ('BeautyPlus') and
        case    when platform in ('IOS')  then (event_date between '2024-03-13' and '2024-04-02')
                when platform in ('ANDROID') then (event_date between '2024-03-25' and '2024-04-23')
                end
        and cast(meepo_abcode as string) in ('10537','10538','10539','10534','10535')
        and device_id is not null --limit 100
)
,
event_ab as
(
    select m.*
        ,a.code
        ,case   when a.code in ('10537','10534') then '对照组'
                when a.code in ('10538','10535') then '实验组A'
                when a.code in ('10539') then '实验组B'
         end code_type
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
        from event_all
        where event_name in  ('homepageappr_bd')
    ) m
    join abcode a
    on  m.device_id=a.device_id  and m.platform=a.platform and m.event_timestamp>=a.timestamp-15000000 and m.region=a.region
)


select
--     cast(date_p as date) date,
    '0:enter AB Test' event_name
    ,platform
    ,region
    ,case   when code in ('10537','10534') then '对照组'
            when code in ('10538','10535') then '实验组A'
            when code in ('10539') then '实验组B'
            end code
    ,count(distinct device_id) value
from
    abcode
where platform='ANDROID'
-- where platform='IOS'
group by
    1,2,3,4

union all

select
--     event_date date,
    '0-1:enter homepage'event_name
    ,platform
    ,region
    ,code_type code
    ,count(distinct device_id) value
from event_ab
where platform='ANDROID'
-- where platform='IOS'
  and event_name='homepageappr_bd'
group by 1,2,3,4


