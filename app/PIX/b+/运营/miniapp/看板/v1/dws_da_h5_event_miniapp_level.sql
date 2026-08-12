-- miniapp mapping: https://docs.google.com/spreadsheets/d/139gJOB4-DMb3eCALFuBVJkeq2hpNbAl58o9NduJoy3g/edit#gid=0
-- `beautyplus-bc0ed.content_data.dwd_da_miniapp_material_mapping`
-- `beautyplus-bc0ed.content_data.dwd_da_miniapp_status` 
-- `beautyplus-bc0ed.content_data.credit_good_mapping`
-- 347_ads_dz_miniapp_data
-- 新增进入生成页面，生成按钮点击，目前仅保证9.14后上线的miniapp的数据
-- 新增额度充值弹窗曝光，额度充值点击，额度购买成功
-- drop table if exists `beautyplus-bc0ed.content_data.dws_da_h5_event_miniapp_level`; 
-- create table if not exists `beautyplus-bc0ed.content_data.dws_da_h5_event_miniapp_level` as
delete from  `beautyplus-bc0ed.content_data.dws_da_h5_event_miniapp_level`  where event_date>='{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=3)).strftime("%Y-%m-%d") }}' and event_date<='{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=0)).strftime("%Y-%m-%d") }}';
insert into `beautyplus-bc0ed.content_data.dws_da_h5_event_miniapp_level`
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
subscription_attr_raw as
(
    select
        date
        ,platform
        ,country
        ,cur_page_type
        ,source1
        ,source2
        ,category1
        ,category2 -- miniapp project
        ,coalesce(miniapp,category2) miniapp_name
        ,status
        ,user_pseudo_id
        ,original_order_id
        ,sku_type
        ,sku_has_trial
        ,purchase_date
        ,payment_price_usd
    from
        (select
            date
            ,platform
            ,country
            ,cur_page_type
            ,source1
            ,source2
            ,k.category1
            ,k.category2 -- miniapp project
            -- ,k.category3_mid
            -- ,k.category3_cid
            -- ,k.category3_feature_content
            -- ,k.category3_id
            ,user_pseudo_id
            ,original_order_id
            ,sku_type
            ,sku_has_trial
            ,purchase_date
            ,payment_price_usd
        from
            `beautyplus-bc0ed.sub_dataset.ads_spm_trial_subscription_pre_v5_abtest` ,unnest(agg) k
        where
            -- date between '2023-08-01' and '{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=0)).strftime("%Y-%m-%d") }}'
            -- date between '2023-08-10' and '{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=0)).strftime("%Y-%m-%d") }}'
            date between '{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=3)).strftime("%Y-%m-%d") }}' and '{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=0)).strftime("%Y-%m-%d") }}'
            and k.category1='H5'
            and event_name='subscription_try_suc') e
        left join (select sub_miniapp,max(miniapp) miniapp,max(status) status from `beautyplus-bc0ed.content_data.dwd_da_miniapp_status` group by 1) s on e.category2=s.sub_miniapp

)
,
subscription_attr_result as
(
    select
        date
        ,e.platform
        ,e.country
        ,is_new
        ,miniapp_name
        ,status
        ,count(distinct original_order_id) sub_uv
    from
        subscription_attr_raw e
        join user_info u on e.user_pseudo_id=u.user_pseudo_id and e.date=u.event_date_hk and e.platform=u.platform
    group by
        1,2,3,4,5,6
)
,
event_result as
(
    select *
    from `beautyplus-bc0ed.temp.dws_da_h5_event_miniapp_event_level`
    where event_date between '{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=3)).strftime("%Y-%m-%d") }}' and '{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=0)).strftime("%Y-%m-%d") }}'
)
,
credit_result as
(
    select *
    from `beautyplus-bc0ed.temp.dws_da_h5_event_miniapp_credit_level`
    where date between '{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=3)).strftime("%Y-%m-%d") }}' and '{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=0)).strftime("%Y-%m-%d") }}'
)

-- daily+miniapp
select
    e.event_date
    ,e.platform
    ,case when e.country='China' then 'China Mainland' else e.country end country
    ,e.is_new
    ,e.miniapp_name
    ,e.status
    ,exposure_uv
    ,click_uv
    ,exposure_miniapp_uv
    ,click_miniapp_uv
    ,exposure_banner_uv
    ,click_banner_uv
    ,exposure_popup_uv
    ,click_popup_uv
    ,visit_uv
    ,enter_generate_page_uv
    ,generate_uv
    ,save_uv
    ,share_uv
    ,share_uv_user
    ,sub_uv
    ,credit_use_uv
    ,credit_topup_imp_uv
    ,credit_topup_clk_uv
    ,credit_topup_suc_uv

    ,exposure_pv
    ,click_pv
    ,exposure_miniapp_pv
    ,click_miniapp_pv
    ,exposure_banner_pv
    ,click_banner_pv
    ,exposure_popup_pv
    ,click_popup_pv
    ,visit_pv
    ,enter_generate_page_pv
    ,generate_pv
    ,save_pv
    ,share_pv 
    ,share_pv_user
    ,credit_use_pv
    ,credit_num
    ,payment_price_usd
from 
    event_result e
    left join subscription_attr_result s on e.event_date=s.date 
                                            and e.platform=s.platform 
                                            and e.country=s.country
                                            and e.is_new=s.is_new 
                                            and e.miniapp_name=s.miniapp_name
                                            and e.status=s.status
    left join credit_result c on e.event_date=c.date
                                            and e.platform=c.platform
                                            and e.country=c.country
                                            and e.is_new=c.is_new
                                            and e.miniapp_name=c.miniapp_name
