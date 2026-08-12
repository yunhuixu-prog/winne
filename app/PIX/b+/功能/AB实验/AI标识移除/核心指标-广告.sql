with abcode as
(
    select
        date_p date
        ,ab_code abcode
        ,case when ab_code in (11050,11053) then '对照组'
               when ab_code in (11051,11054) then '实验组A'
               when ab_code in (11052,11055) then '实验组B'
        end code
        ,field user_pseudo_id
        ,country_id
        ,country
        ,case when is_app_new='2' then 'new user' when is_app_new='1' then 'old user' end as is_new
        ,case when app_key in ('F9B069901A7B2E8D') then 'iOS' when app_key in ('C6FF0769324CD2F1') then 'Android' end platform
        ,receive_time as timestamp
    from
        `dataintegration-265403.abtest.abtest_odz_flow` a --2.第一次进入实验用户
        left join   (select
                        event_date
                        ,user_pseudo_id
                        ,max(country) country
                    from
                        `dataintegration-265403.abtest.stage_aa_meepo_enter_event`
                    group by
                        1,2 ) b on a.date_p = b.event_date and a.field = b.user_pseudo_id
    where
        date_p between '2025-03-10' and '2025-03-23' -- 结合最新日期选定时间范围，如果数据回收时效高，可能不能看整个周期的留存率
        and cast(ab_code as string) in ('11050','11051','11052','11053','11054','11055')
        and field_type = 1  -- field_type = 1: user_pseudo_id ，2: gid，3：device_id
        and app_key in ('F9B069901A7B2E8D','C6FF0769324CD2F1')
)
,
ads_revenue_pre as -- 仅包含 MAX 数据，Admob需要到`dataintegration-265403.advertisement.dws_dzp_ad_placement_info`取
(
    select
        event_date
        ,app_name
        ,user_pseudo_id
        ,b.abcode
        ,b.code
        ,a.platform
        ,ad_unit_name
        ,ad_format
        ,placement
        ,b.country
        ,b.is_new
        ,sum(revenue) revenue
        ,count(1) imp
    from
        `dataintegration-265403.dwd.dwd_dzp_advertisement_max_user_detail` a
        join abcode b on a.firebase_id = b.user_pseudo_id and timestamp_micros(b.timestamp) < timestamp(event_time)
    where
        event_date between '2025-03-10' and '2025-03-23' -- 结合最新日期选定时间范围，如果数据回收时效高，可能不能看整个周期的留存率
        and app_name='BeautyPlus'
        -- and placement in ('inter__album_portrait')
    group by
        1,2,3,4,5,6,7,8,9,10,11
)

select
    platform
    ,abcode
    ,code
    ,is_new
    ,case   when country in ('Japan') then '日本'
            when country in ('South Korea') then '韩国'
            /*欧盟包括27个国家：奥地利，比利时，保加利亚，英国，匈牙利，德国，希腊，丹麦，爱尔兰，西班牙，意大利，塞浦路斯，拉脱维亚，立陶宛
            ，卢森堡，马耳他，荷兰，波兰，葡萄牙，罗马尼亚，斯洛伐克，斯洛文尼亚，芬兰，法国，克罗地亚，捷克共和国，瑞典，爱沙尼亚。 */
            when  country in ('United States','Austria', 'Belgium', 'Bulgaria', 'Hungary', 'Germany', 'Greece', 'Denmark', 'Ireland', 'Spain'
                , 'Italy', 'Cyprus', 'Latvia', 'Lithuania', 'Luxembourg','Malta', 'Netherlands', 'Poland', 'Portugal', 'Romania'
                , 'Slovakia', 'Slovenia', 'Finland', 'France', 'Croatia' , 'Czechia','Sweden','Estonia'
                ,'United Kingdom'
                ) then  '欧美' --'欧盟国家'
            when country in ('India') then '印度'
            when country in ('Thailand','Indonesia','Vietnam','Malaysia','Philippines','Singapore','Cambodia','Laos') then '东南亚'
            else '其他'
            end country_group
    ,count(distinct case when placement in ('appopen__app_open') then user_pseudo_id end) ab_ads_uv
    ,count(distinct user_pseudo_id) ads_uv
    ,sum(case when placement in ('appopen__app_open') then revenue end) ab_revenue
    ,sum(revenue) revenue
    ,sum(case when placement in ('appopen__app_open') then imp end) ab_imp
    ,sum(imp) imp
from
    ads_revenue_pre
group by
    1,2,3,4,5