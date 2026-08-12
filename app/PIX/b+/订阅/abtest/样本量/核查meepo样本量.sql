with 
event as(
SELECT
*except(event_date),PARSE_DATE('%Y%m%d', event_date) event_date
FROM
`beautyplus-bc0ed.analytics.stage_dz_event_view`
WHERE event_date>='20231221' and event_date<='20240125'--修改实验日期
and platform in ('IOS')
and app_info.version >='7.7.023'
)
,
user_info as
(
    select
        event_date_hk
        ,app_name
        ,platform
        ,country
        ,user_pseudo_id
        ,max(uuid) uuid
        ,max(is_new) is_new
        ,max(is_UA) is_UA
        ,max(app_version) app_version
    from
        `dataintegration-265403.stat.stat_active_advice_detail_d`
    where
        event_date_hk between date'2023-12-21' and '2024-01-25'  -- 修改查询的数据时间
        and app_name='BeautyPlus'
    group by 1,2,3,4,5
)

SELECT event_date,func.getParams(event_params,'current_abcode').string_value as abcode,count(distinct func.getUserprop(user_properties,'device_id').string_value)
FROM event a
join user_info u on a.event_date=u.event_date_hk and a.user_pseudo_id=u.user_pseudo_id
where
    event_name ='abcode_enter_test'
    and func.getParams(event_params,'current_abcode').string_value in ('10442','10443','10444','10445')
group by 1,2
order by 1,2