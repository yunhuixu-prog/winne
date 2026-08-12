-- miniapp mapping: https://docs.google.com/spreadsheets/d/139gJOB4-DMb3eCALFuBVJkeq2hpNbAl58o9NduJoy3g/edit#gid=0
-- `beautyplus-bc0ed.content_data.dwd_da_miniapp_material_mapping`
-- `beautyplus-bc0ed.content_data.dwd_da_miniapp_status`
-- `beautyplus-bc0ed.content_data.credit_good_mapping`
-- 347_ads_dz_miniapp_data
-- 新增进入生成页面，生成按钮点击，目前仅保证9.14后上线的miniapp的数据
-- 新增额度充值弹窗曝光，额度充值点击，额度购买成功
-- drop table if exists `beautyplus-bc0ed.temp.dws_da_h5_event_miniapp_credit_level_v2`;
-- create table if not exists `beautyplus-bc0ed.temp.dws_da_h5_event_miniapp_credit_level_v2` as
delete from  `beautyplus-bc0ed.temp.dws_da_h5_event_miniapp_credit_level_v2`  where date>='{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=3)).strftime("%Y-%m-%d") }}' and date<='{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=0)).strftime("%Y-%m-%d") }}';
insert into `beautyplus-bc0ed.temp.dws_da_h5_event_miniapp_credit_level_v2`
with user_info as
(
    select
        event_date event_date_hk
        ,platform
        ,country
        ,user_pseudo_id
        ,max(case when is_new='New users' then 1 else 0 end) is_new
        ,max(is_UA) is_UA
        ,max(is_pay) is_pay
    from
        `beautyplus-bc0ed.event_dataset_2.dws_dz_active_user_02`
    where
        -- event_date_hk between date'2023-08-01' and '{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=0)).strftime("%Y-%m-%d") }}'  -- 修改查询的数据时间
        event_date between '{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=3)).strftime("%Y-%m-%d") }}' and '{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=0)).strftime("%Y-%m-%d") }}'
--         and app_name='BeautyPlus'
    group by 1,2,3,4
)
,
credit as
(
    select
        order_id
        ,credit_num
        ,payment_price_usd
    from
        `beautyplus-bc0ed.dwd.dwd_da_credit_credit_record`
    where
        record_type=2 -- 积分消耗
        and app_name='BeautyPlus'
        -- and event_date between '2023-08-01' and '{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=0)).strftime("%Y-%m-%d") }}'
        and event_date between '{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=3)).strftime("%Y-%m-%d") }}' and '{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=0)).strftime("%Y-%m-%d") }}'
    group by
        1,2,3
)
,
credit_event as
(
    select
        parse_date('%Y%m%d', event_date) event_date
        ,platform
        ,event_name
        ,`dataintegration-265403.func`.getParams(event_params,'project').string_value as project
        ,`dataintegration-265403.func`.getParams(event_params,'source').string_value as source
        ,`dataintegration-265403.func`.getParams(event_params,'order_id').string_value as order_id
        ,coalesce(app_info.version,'unknown') version
        ,coalesce(`dataintegration-265403.func`.getParams(event_params,'from_page').string_value,'unknown') as from_page
        ,user_pseudo_id
    from
        `beautyplus-bc0ed.analytics.stage_dz_event_view`
    where
        -- parse_date('%Y%m%d', event_date) between '2023-08-01' and '{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=0)).strftime("%Y-%m-%d") }}'
        parse_date('%Y%m%d', event_date) between '{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=3)).strftime("%Y-%m-%d") }}' and '{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=0)).strftime("%Y-%m-%d") }}'
        and platform in ('IOS','ANDROID')
        and (event_name='h5_credit_consume_bd'
            or
            (event_name in ('credit_page_bd','credit_purchase_clk_bd','credit_order_purchase_suc_bd')
                and `dataintegration-265403.func`.getParams(event_params,'source').string_value != 'Credit Account'))
)
,
final_credit_event as
(
select
    event_date date
    ,s.miniapp miniapp_name
    ,a.platform
    ,u.is_new
    ,u.is_UA
    ,u.is_pay
    ,u.country
    ,if(a.version>='7.6.020','>=7.6.020','<7.6.020') version
    ,a.from_page
    ,count(distinct a.user_pseudo_id) credit_use_uv
    ,sum(a.pv) credit_use_pv
    ,sum(c.credit_num) credit_num
    ,sum(c.payment_price_usd) payment_price_usd
from (select
        event_date
        ,platform
        ,project
        ,k order_id
        ,version
        ,from_page
        ,user_pseudo_id
        ,count(1) as pv
    from
        credit_event,unnest(split(order_id,',')) k
    where
        event_name in ('h5_credit_consume_bd')
        -- and `dataintegration-265403.func`.getParams(event_params,'project').string_value in ('AI_Zodiac_Persona','AI_Image_Photo')
    group by
        1,2,3,4,5,6,7) a
    join user_info u on a.user_pseudo_id=u.user_pseudo_id and a.event_date=u.event_date_hk and a.platform = u.platform
    join credit c on a.order_id=c.order_id
    left join (select buried_miniapp,max(miniapp) miniapp,max(status) status from `beautyplus-bc0ed.content_data.dwd_da_miniapp_status` group by 1) s on a.project=s.buried_miniapp
group by
    1,2,3,4,5,6,7,8,9

union all

select
    event_date date
    ,s.miniapp miniapp_name
    ,a.platform
    ,u.is_new
    ,u.is_UA
    ,u.is_pay
    ,u.country
    ,if(a.version>='7.6.020','>=7.6.020','<7.6.020') version
    ,'All' as from_page
    ,count(distinct a.user_pseudo_id) credit_use_uv
    ,sum(a.pv) credit_use_pv
    ,sum(c.credit_num) credit_num
    ,sum(c.payment_price_usd) payment_price_usd
from
    (
        select
            event_date
            ,platform
            ,project
            ,k order_id
            ,version
            ,from_page
            ,user_pseudo_id
            ,count(1) as pv
        from
            credit_event,unnest(split(order_id,',')) k
        where
            event_name in ('h5_credit_consume_bd')
            -- and `dataintegration-265403.func`.getParams(event_params,'project').string_value in ('AI_Zodiac_Persona','AI_Image_Photo')
        group by
            1,2,3,4,5,6,7
    ) a
    join user_info u on a.user_pseudo_id=u.user_pseudo_id and a.event_date=u.event_date_hk and a.platform = u.platform
    join credit c on a.order_id=c.order_id
    left join (select buried_miniapp,max(miniapp) miniapp,max(status) status from `beautyplus-bc0ed.content_data.dwd_da_miniapp_status` group by 1) s on a.project=s.buried_miniapp
group by
    1,2,3,4,5,6,7,8
)
,
final_credit_purpase_event as
(
    select
        event_date date
        ,a.platform
        ,case when a.source in ('tooniverse') then a.source
              else coalesce(m.miniapp,'else')
        end miniapp_name
        ,u.is_new
        ,u.is_UA
        ,u.is_pay
        ,u.country
        ,if(a.version>='7.6.020','>=7.6.020','<7.6.020') version
        ,a.from_page
        -- ,count(distinct case when event_name='credit_popup_appr_bd' then a.user_pseudo_id end) credit_popup_uv
        -- ,count(distinct case when event_name='credit_popup_clk_bd' then a.user_pseudo_id end) credit_popup_click_uv
        ,count(distinct case when event_name='credit_page_bd' then a.user_pseudo_id end) credit_topup_imp_uv
        ,count(distinct case when event_name='credit_purchase_clk_bd' then a.user_pseudo_id end) credit_topup_clk_uv
        ,count(distinct case when event_name='credit_order_purchase_suc_bd' then a.user_pseudo_id end) credit_topup_suc_uv
    from
    (
        select
            event_date
            ,platform
            ,event_name
            ,c source
            ,version
            ,from_page
            ,user_pseudo_id
        from credit_event,unnest(split(source,',')) c
        where event_name in ('credit_page_bd','credit_purchase_clk_bd','credit_order_purchase_suc_bd')
        group by 1,2,3,4,5,6,7
    ) a
    join user_info u on a.user_pseudo_id=u.user_pseudo_id and a.event_date=u.event_date_hk and a.platform = u.platform
    left join
        (
        select cast(id as string) good_id
              ,max(case when name like '%AI Image%' or name like '%AI image%' then 'B+ AI'
                    when name like '%AI Pet%' or name like '%AI pet%' then 'AI Pet Portrait'
                    when name like '%AI Zodiac%' or name like '%AI zodiac%' then 'Zodiac Persona'
                    when name like '%AI portray%' or name like '%AI Portray%'
                      or name like '%AI professional%' or name like '%AI Professional%' then 'AI Studio Photo'
                    when name like '%AI Pair Photo%' or name like '%AI pair photo%' then 'AI Pair Photo'
              end) miniapp
        from `beautyplus-bc0ed.ods.ods_da_credit_goods`
        group by 1
        ) m on a.source=m.good_id
    group by 1,2,3,4,5,6,7,8,9

    union all

    select
        event_date date
        ,a.platform
        ,case when a.source in ('tooniverse') then a.source
              else coalesce(m.miniapp,'else')
        end miniapp_name
        ,u.is_new
        ,u.is_UA
        ,u.is_pay
        ,u.country
        ,if(a.version>='7.6.020','>=7.6.020','<7.6.020') version
        ,'All' as from_page
        -- ,count(distinct case when event_name='credit_popup_appr_bd' then a.user_pseudo_id end) credit_popup_uv
        -- ,count(distinct case when event_name='credit_popup_clk_bd' then a.user_pseudo_id end) credit_popup_click_uv
        ,count(distinct case when event_name='credit_page_bd' then a.user_pseudo_id end) credit_topup_imp_uv
        ,count(distinct case when event_name='credit_purchase_clk_bd' then a.user_pseudo_id end) credit_topup_clk_uv
        ,count(distinct case when event_name='credit_order_purchase_suc_bd' then a.user_pseudo_id end) credit_topup_suc_uv
    from
    (
        select
            event_date
            ,platform
            ,event_name
            ,c source
            ,version
            ,from_page
            ,user_pseudo_id
        from credit_event,unnest(split(source,',')) c
        where event_name in ('credit_page_bd','credit_purchase_clk_bd','credit_order_purchase_suc_bd')
        group by 1,2,3,4,5,6,7
    ) a
    join user_info u on a.user_pseudo_id=u.user_pseudo_id and a.event_date=u.event_date_hk and a.platform = u.platform
    left join
        (
        select cast(id as string) good_id
              ,max(case when name like '%AI Image%' or name like '%AI image%' then 'B+ AI'
                    when name like '%AI Pet%' or name like '%AI pet%' then 'AI Pet Portrait'
                    when name like '%AI Zodiac%' or name like '%AI zodiac%' then 'Zodiac Persona'
                    when name like '%AI portray%' or name like '%AI Portray%'
                      or name like '%AI professional%' or name like '%AI Professional%' then 'AI Studio Photo'
                    when name like '%AI Pair Photo%' or name like '%AI pair photo%' then 'AI Pair Photo'
              end) miniapp
        from `beautyplus-bc0ed.ods.ods_da_credit_goods`
        group by 1
        ) m on a.source=m.good_id
    group by 1,2,3,4,5,6,7,8
)


-- daily+miniapp
select
    coalesce(e.date,c.date) date
    ,coalesce(e.platform,c.platform) platform
    ,coalesce(e.country,c.country) country
    ,coalesce(e.is_new,c.is_new) is_new
    ,coalesce(e.miniapp_name,c.miniapp_name) miniapp_name
    ,coalesce(e.is_UA,c.is_UA) is_UA
    ,coalesce(e.is_pay,c.is_pay) is_pay
    ,coalesce(e.version,c.version) version
    ,coalesce(e.from_page,c.from_page) from_page
    ,credit_use_uv
    ,credit_topup_imp_uv
    ,credit_topup_clk_uv
    ,credit_topup_suc_uv

    ,credit_use_pv
    ,credit_num
    ,payment_price_usd
from
    final_credit_event e
full join final_credit_purpase_event c
on e.date=c.date
    and e.platform=c.platform
    and e.country=c.country
    and e.is_new=c.is_new
    and e.is_UA=c.is_UA
    and e.is_pay=c.is_pay
    and e.miniapp_name=c.miniapp_name
    and e.version=c.version
    and e.from_page=c.from_page

