-- miniapp mapping: https://docs.google.com/spreadsheets/d/139gJOB4-DMb3eCALFuBVJkeq2hpNbAl58o9NduJoy3g/edit#gid=0
-- `beautyplus-bc0ed.content_data.dwd_da_miniapp_material_mapping`
-- `beautyplus-bc0ed.content_data.dwd_da_miniapp_status`
-- `beautyplus-bc0ed.content_data.credit_good_mapping`
-- 347_ads_dz_miniapp_data
-- 新增进入生成页面，生成按钮点击，目前仅保证9.14后上线的miniapp的数据
-- 新增额度充值弹窗曝光，额度充值点击，额度购买成功
-- drop table if exists `beautyplus-bc0ed.temp.dws_da_h5_event_miniapp_credit_level`;
-- create table if not exists `beautyplus-bc0ed.temp.dws_da_h5_event_miniapp_credit_level` as
delete from  `beautyplus-bc0ed.temp.dws_da_h5_event_miniapp_credit_level`  where date>='{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=3)).strftime("%Y-%m-%d") }}' and date<='{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=0)).strftime("%Y-%m-%d") }}';
insert into `beautyplus-bc0ed.temp.dws_da_h5_event_miniapp_credit_level`
with user_info as
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
        -- event_date_hk between date'2023-08-01' and '{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=0)).strftime("%Y-%m-%d") }}'  -- 修改查询的数据时间
        event_date_hk between '{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=3)).strftime("%Y-%m-%d") }}' and '{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=0)).strftime("%Y-%m-%d") }}'
        and app_name='BeautyPlus'
    group by 1,2,3,4,5
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
        *
    from
        `beautyplus-bc0ed.analytics.stage_dz_event_view`
    where
        -- parse_date('%Y%m%d', event_date) between '2023-08-01' and '{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=0)).strftime("%Y-%m-%d") }}'
        parse_date('%Y%m%d', event_date) between '{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=3)).strftime("%Y-%m-%d") }}' and '{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=0)).strftime("%Y-%m-%d") }}'
        and platform in ('IOS','ANDROID')
        and event_name='h5_credit_consume_bd'
)
,
final_credit_event as
(
select
    event_date date
    ,miniapp miniapp_name
    ,a.platform
    ,is_new
    ,country
    ,count(distinct a.user_pseudo_id) credit_use_uv
    ,sum(pv) credit_use_pv
    ,sum(credit_num) credit_num
    ,sum(payment_price_usd) payment_price_usd
from
    (
        select
            parse_date('%Y%m%d', event_date) event_date
            ,platform
            ,`dataintegration-265403.func`.getParams(event_params,'project').string_value as project
            ,k order_id
            ,user_pseudo_id
            ,count(1) as pv
        from
            credit_event,unnest(split(`dataintegration-265403.func`.getParams(event_params,'order_id').string_value,',')) k
        where
            event_name in ('h5_credit_consume_bd')
            -- and `dataintegration-265403.func`.getParams(event_params,'project').string_value in ('AI_Zodiac_Persona','AI_Image_Photo')
        group by
            1,2,3,4,5
    ) a
    join user_info u on a.user_pseudo_id=u.user_pseudo_id and a.event_date=u.event_date_hk and a.platform = u.platform
    join credit c on a.order_id=c.order_id
    left join (select buried_miniapp,max(miniapp) miniapp,max(status) status from `beautyplus-bc0ed.content_data.dwd_da_miniapp_status` group by 1) s on a.project=s.buried_miniapp
group by
    1,2,3,4,5
)
,
credit_purpase_event as
(
    select
        event_date
        ,platform
        ,event_name
        ,`dataintegration-265403.func`.getParams(event_params,'source').string_value as source
        ,user_pseudo_id
    from
        -- `beautyplus-bc0ed.analytics.ods_dz_events_tv`('{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=3)).strftime("%Y-%m-%d") }}', '{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=0)).strftime("%Y-%m-%d") }}')
        `dataintegration-265403.analytics.dwd_dzp_events_function`('{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=3)).strftime("%Y-%m-%d") }}', '{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=0)).strftime("%Y-%m-%d") }}', 'beautyplus', false)
    where event_name in ('credit_page_bd','credit_purchase_clk_bd','credit_order_purchase_suc_bd')
          and `dataintegration-265403.func`.getParams(event_params,'source').string_value != 'Credit Account'
    group by 1,2,3,4,5
)
,
final_credit_purpase_event as
(
    select
        event_date date
        ,a.platform
        ,coalesce(miniapp,'else') miniapp_name
        ,is_new
        ,country
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
            ,user_pseudo_id
        from credit_purpase_event,unnest(split(source,',')) c
        group by 1,2,3,4,5
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
    group by 1,2,3,4,5
)


-- daily+miniapp
select
    coalesce(e.date,c.date) date
    ,coalesce(e.platform,c.platform) platform
    ,coalesce(e.country,c.country) country
    ,coalesce(e.is_new,c.is_new) is_new
    ,coalesce(e.miniapp_name,c.miniapp_name) miniapp_name
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
    and e.miniapp_name=c.miniapp_name

