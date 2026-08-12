
with enter_test as (
    select
        date_p event_date
        ,ab_code abcode
        ,case when ab_code in (11116,11118) then '对照组'
               when ab_code in (11117,11119) then '实验组A'
        end code
        ,field device_id
        ,country_id
        ,country
        ,case when is_app_new='2' then 'new user' when is_app_new='1' then 'old user' end as is_new
        ,case when app_key in ('F9B069901A7B2E8D') then 'iOS' when app_key in ('C6FF0769324CD2F1') then 'Android' end platform
        ,receive_time as timestamp
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
        date_p between '2025-06-11' and '2025-06-24' -- 结合最新日期选定时间范围，如果数据回收时效高，可能不能看整个周期的留存率
        and cast(ab_code as string) in ('11116','11117','11118','11119')
        and field_type = 3  -- field_type = 1: user_pseudo_id ，2: gid，3：device_id
        and app_key in ('F9B069901A7B2E8D','C6FF0769324CD2F1')
)
,sub as (
     select
     date
    ,platform,user_pseudo_id,event_timestamp
    ,event_name,device_id,CAST(standard_order_date AS STRING FORMAT 'YYYYMMDD') standard_order_date,CAST(purchase_date AS STRING FORMAT 'YYYYMMDD') purchase_date
    ,payment_price_usd value
    ,sku_type
    ,case when sub_success_offer_type in ('trial','intro_trial','promotion_trial') then 'has_trial'
           when sub_success_offer_type is not null then 'no_trial'
           else sku_has_trial
    end sku_has_trial
    ,case
         when pre_page like '%修图编辑页%'  then 'Photo Editor'
         when pre_page like '自拍预览页%' or  pre_page like '拍后确认页_拍摄%' then 'Shoot'
         when pre_page like '拍后确认页_视频%'  then 'Video'
         when pre_page like '拍后确认页_电影%'  then 'Studio'
         when pre_page like '视频编辑页%' then 'Video Editor'
         when pre_page like '批量编辑页%' then 'Batch Edit'
         else 'others' end as module
    from `beautyplus-bc0ed.sub_dataset.ads_spm_trial_subscription_pre_v5_abtest`--,unnest(agg) as s
    where date between '2025-06-11' and '2025-06-24'
)
,act AS
(
    SELECT distinct event_date_hk
           , case when platform='IOS' then 'iOS' when platform='ANDROID' then 'Android' end platform
           , real_device_id device_id, is_new, country --,user_pseudo_id
    from `dataintegration-265403.dwd.dwd_dzp_behavior_active_device`
    WHERE event_date_hk between '2025-06-11' and '2025-06-24'
        AND app_name = 'BeautyPlus'
)
,fe as( -- 限制进入实验的人,且实验触发日期在进入实验之后
    select
        a.date,b.platform,a.event_name,a.device_id,a.standard_order_date,a.purchase_date,a.value
           ,a.sku_type,a.sku_has_trial,a.module
           ,b.abcode,b.code,b.is_new,b.country
    from sub a
    join enter_test b on a.device_id= b.device_id
    join act u on a.device_id=u.device_id and a.date=u.event_date_hk
    where a.event_timestamp>=b.timestamp-15000000
)

select
    a.date,a.platform,a.abcode,a.code,a.is_new
    ,case   when country in ('Japan') then '日本'
            /*欧盟包括27个国家：奥地利，比利时，保加利亚，英国，匈牙利，德国，希腊，丹麦，爱尔兰，西班牙，意大利，塞浦路斯，拉脱维亚，立陶宛
            ，卢森堡，马耳他，荷兰，波兰，葡萄牙，罗马尼亚，斯洛伐克，斯洛文尼亚，芬兰，法国，克罗地亚，捷克共和国，瑞典，爱沙尼亚。 */
            when  country in ('United States','South Korea','Austria', 'Belgium', 'Bulgaria', 'Hungary', 'Germany', 'Greece', 'Denmark', 'Ireland', 'Spain'
                , 'Italy', 'Cyprus', 'Latvia', 'Lithuania', 'Luxembourg','Malta', 'Netherlands', 'Poland', 'Portugal', 'Romania'
                , 'Slovakia', 'Slovenia', 'Finland', 'France', 'Croatia' , 'Czechia','Sweden','Estonia'
                ,'United Kingdom'
                ) then  '欧美韩' --'欧盟国家'
            when country in ('India') then '印度'
            when country in ('Thailand','Indonesia','Vietnam','Malaysia','Philippines','Singapore','Cambodia','Laos') then '东南亚'
            else '其他'
            end country_group
    ,a.sku_type,a.sku_has_trial,a.module
    -- 付费
    ,count(distinct case when a.event_name ='page_event' then a.device_id end) sub_enter_uv
    ,count(distinct case when a.event_name ='subscription_clk_try' then a.device_id end) sub_click_uv
    ,count(distinct case when event_name= 'subscription_try_suc' and standard_order_date is not null then a.device_id end) sub_success_uv
    ,count(distinct case when event_name= 'subscription_try_suc' and standard_order_date is not null and  purchase_date is not null then a.device_id end) sub_success_to_paid_uv
    ,round(sum(case when event_name= 'subscription_try_suc' and standard_order_date is not null and  purchase_date is not null then value end),2) sub_success_to_paid_gmv

from fe a

group by 1,2,3,4,5,6,7,8,9
