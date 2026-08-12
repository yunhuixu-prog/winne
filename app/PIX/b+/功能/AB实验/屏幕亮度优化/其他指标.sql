-- 其他指标
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
,eves as (
select
     event_date_hk as date
    ,platform,user_pseudo_id,event_timestamp
    ,case when event_name in ('glow_cam_appr_bd','glow_cam_save_bd') then 'glow'
          when event_name in ('selfie_appr_bd','selfietakepic_bd','selfiesave_bd') then 'classic'
          when event_name in ('iphone_mode_appr_bd','iphone_mode_save_bd') then 'iphone'
          when event_name in ('stamp_cam_appr_bd','stamp_cam_save_bd') then 'stamp'
          when event_name in ('film_cam_appr_bd','film_cam_taken_bd','film_cam_save_bd') then 'film'
          when event_name in ('movie_appr_bd','movie_takepic_bd','movecheck_save_bd') then 'movie'
    end module
    ,case
          when event_name in (
                            'selfie_appr_bd',
                            'movie_appr_bd',
                            'iphone_mode_appr_bd',
                            'stamp_cam_appr_bd',
                            'glow_cam_appr_bd',
                            'film_cam_appr_bd') then 'enter'
          when event_name in (
                            'selfietakepic_bd',
                            'movie_takepic_bd',
                            'film_cam_taken_bd') then 'take'
          when event_name in (
                            'selfiesave_bd',
                            'movecheck_save_bd',
                            'iphone_mode_save_bd',
                            'stamp_cam_save_bd',
                            'glow_cam_save_bd',
                            'film_cam_save_bd') then 'save'
    else event_name
    end event_name
    ,func.getUserprop(user_properties,'device_id').string_value as device_id
--     , '' standard_order_date,'' purchase_date
--     ,0 value
from `dataintegration-265403.analytics.dwd_dzp_events_function`('2025-06-11', '2025-06-24', 'BeautyPlus', false)
where
    event_name in ('glow_cam_appr_bd','glow_cam_save_bd'
                    ,'film_cam_appr_bd','film_cam_taken_bd','film_cam_save_bd'
                    ,'selfie_appr_bd','selfietakepic_bd','selfiesave_bd'
                    ,'iphone_mode_appr_bd','iphone_mode_save_bd'
                    ,'stamp_cam_appr_bd','stamp_cam_save_bd'
                    ,'movie_appr_bd','movie_takepic_bd','movecheck_save_bd')
)
,sub as (
     select
     date
    ,platform,user_pseudo_id,event_timestamp
    ,'All' module
    ,'sub' event_name,device_id
--     ,CAST(standard_order_date AS STRING FORMAT 'YYYYMMDD') standard_order_date,CAST(purchase_date AS STRING FORMAT 'YYYYMMDD') purchase_date
--     ,payment_price_usd value
    from `beautyplus-bc0ed.sub_dataset.ads_spm_trial_subscription_pre_v5_abtest`--,unnest(agg) as s
    where date between '2025-06-11' and '2025-06-24'
        and event_name= 'subscription_try_suc' and standard_order_date is not null
        and (pre_page like '自拍预览页%' or  pre_page like '拍后确认页_拍摄%')
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
        a.date,b.platform,a.event_name,a.module,a.device_id --,a.standard_order_date,a.purchase_date,a.value
           ,b.abcode,b.code,b.is_new,b.country
    from
        (select * from eves
        union all
        select * from sub
        )a
    join enter_test b on a.device_id= b.device_id
    join act u on a.device_id=u.device_id and a.date=u.event_date_hk
    where a.event_timestamp>=b.timestamp-15000000

    union all

    select event_date as date
        ,platform,'enter_abtest' event_name,'All' module,device_id
--         ,'' standard_order_date,'' purchase_date,0 value
        ,abcode,code,is_new,country
    from enter_test

    union all

    select
        fa.event_date_hk date,fa.platform,'enter_abtest_dau' event_name,'All' module,b.device_id
--         ,'' standard_order_date,'' purchase_date,0 value
        ,b.abcode,b.code,b.is_new,b.country
    from act fa  -- 活跃天
    join enter_test b  -- 进入实验当天
    ON b.device_id = fa.device_id and b.event_date <= fa.event_date_hk
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
    ,module
    ,count(distinct case when a.event_name ='enter_abtest_dau' then a.device_id end) enter_abtest_dau
    -- 付费
    ,count(distinct case when a.event_name ='sub' then a.device_id end) sub_uv

    -- 用户行为
    ,count(distinct case when a.event_name ='enter' then a.device_id end) enter_uv
    ,count(distinct case when a.event_name ='take' then a.device_id end) take_uv
    ,count(distinct case when a.event_name ='save' then a.device_id end) save_uv

    ,count(case when a.event_name ='enter' then 1 end) enter_pv
    ,count(case when a.event_name ='take' then 1 end) take_pv
    ,count(case when a.event_name ='save' then 1 end) save_pv
    -- 进入实验用户（进入实验当天）
    ,count(distinct case when a.event_name ='enter_abtest' then a.device_id end) enter_abtest_uv

from fe a

group by 1,2,3,4,5,6,7

