-- miniapp mapping: https://docs.google.com/spreadsheets/d/139gJOB4-DMb3eCALFuBVJkeq2hpNbAl58o9NduJoy3g/edit#gid=0
-- `beautyplus-bc0ed.content_data.dwd_da_miniapp_material_mapping`
-- `beautyplus-bc0ed.content_data.dwd_da_miniapp_status`
-- `beautyplus-bc0ed.content_data.credit_good_mapping`
-- 347_ads_dz_miniapp_data
-- 新增进入生成页面，生成按钮点击，目前仅保证9.14后上线的miniapp的数据
-- 新增额度充值弹窗曝光，额度充值点击，额度购买成功
-- drop table if exists `beautyplus-bc0ed.content_data.dws_da_h5_event_miniapp_level_v2`;
-- create table if not exists `beautyplus-bc0ed.content_data.dws_da_h5_event_miniapp_level_v2` as
delete from  `beautyplus-bc0ed.aigc.dws_dzp_aigc_h5_event_miniapp_level_v2`  where event_date>='{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=14)).strftime("%Y-%m-%d") }}' and event_date<='{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=0)).strftime("%Y-%m-%d") }}';
insert into `beautyplus-bc0ed.aigc.dws_dzp_aigc_h5_event_miniapp_level_v2`
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
        event_date between '{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=14)).strftime("%Y-%m-%d") }}' and '{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=0)).strftime("%Y-%m-%d") }}'
--         and app_name='BeautyPlus'
    group by 1,2,3,4
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
            date between '{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=14)).strftime("%Y-%m-%d") }}' and '{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=0)).strftime("%Y-%m-%d") }}'
            and k.category1='H5'
            and event_name='subscription_try_suc'
            and standard_order_date is not null
        ) e
        left join (select sub_miniapp,max(miniapp) miniapp,max(status) status from `beautyplus-bc0ed.content_data.dwd_da_miniapp_status` group by 1) s on e.category2=s.sub_miniapp

)
,
subscription_attr_result as
(
    select
        date
        ,e.platform
        ,e.country
        ,u.is_new
        ,u.is_UA
        ,u.is_pay
        ,miniapp_name
        ,status
        ,'>=7.6.020' version  -- 首页miniapp曝光点击7.6.020之前没有数，统一只看7.6.020之后的数，订阅底表未区分版本，默认定位7.6.020之后
        ,'All' from_page
        ,count(distinct original_order_id) sub_uv
        ,count(distinct case when purchase_date is not null then original_order_id end) sub_pay_uv
        ,round(sum(case when purchase_date is not null then payment_price_usd end),2) sub_revenue
    from
        subscription_attr_raw e
        join user_info u on e.user_pseudo_id=u.user_pseudo_id and e.date=u.event_date_hk and e.platform=u.platform
    group by
        1,2,3,4,5,6,7,8
)
,
event_result as
(
    select *
    from `beautyplus-bc0ed.temp.dws_da_h5_event_miniapp_event_level_v2`
    where event_date between '{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=14)).strftime("%Y-%m-%d") }}' and '{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=0)).strftime("%Y-%m-%d") }}'
)
,
credit_result as
(
    select *
    from `beautyplus-bc0ed.temp.dws_da_h5_event_miniapp_credit_level_v2`
    where date between '{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=14)).strftime("%Y-%m-%d") }}' and '{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=0)).strftime("%Y-%m-%d") }}'
)
,
-- daily+miniapp
overall as (
select
    e.event_date
    ,e.platform
    ,case when e.country='China' then 'China Mainland' else e.country end country
    ,e.is_new
    ,e.is_UA is_ua
    ,e.is_pay
    ,e.miniapp_name
    ,e.status
    ,e.version
    ,e.from_page
    ,exposure_uv
    ,click_uv
    ,exposure_miniapp_uv
    ,click_miniapp_uv
    ,exposure_banner_uv
    ,click_banner_uv
    ,exposure_popup_uv
    ,click_popup_uv
    ,exposure_search_uv
    ,click_search_uv
    ,visit_uv
    ,enter_generate_page_uv
    ,generate_uv
    ,save_uv
    ,share_uv
    ,share_uv_user
    ,sub_uv
    ,sub_pay_uv
    ,sub_revenue
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
    ,exposure_search_pv
    ,click_search_pv
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
                                            and e.is_UA=s.is_UA
                                            and e.is_pay=s.is_pay
                                            and e.miniapp_name=s.miniapp_name
                                            and e.status=s.status
                                            and e.version=s.version
                                            and e.from_page=s.from_page
    left join credit_result c on e.event_date=c.date
                                            and e.platform=c.platform
                                            and e.country=c.country
                                            and e.is_new=c.is_new
                                            and e.is_UA=c.is_UA
                                            and e.is_pay=c.is_pay
                                            and e.miniapp_name=c.miniapp_name
                                            and e.version=c.version
                                            and e.from_page=c.from_page
)

select
    event_date
    ,platform
    ,country
    ,is_new
    ,is_ua
    ,is_pay
    ,miniapp_name
    ,status
    ,version
    ,from_page
    ,'uv' data_type
    ,exposure_uv exposure
    ,click_uv click
    ,exposure_miniapp_uv exposure_miniapp
    ,click_miniapp_uv click_miniapp
    ,exposure_banner_uv exposure_banner
    ,click_banner_uv click_banner
    ,exposure_popup_uv exposure_popup
    ,click_popup_uv click_popup
    ,exposure_search_uv exposure_search
    ,click_search_uv click_search

    ,visit_uv visit
    ,enter_generate_page_uv enter_generate_page
    ,generate_uv generate
    ,save_uv save
    ,share_uv share
    ,share_uv_user share_user
    ,sub_uv sub
    ,credit_use_uv credit_use
    ,credit_topup_imp_uv credit_topup_imp
    ,credit_topup_clk_uv credit_topup_clk
    ,credit_topup_suc_uv credit_topup_suc
    ,credit_num
    ,payment_price_usd
    ,sub_pay_uv sub_pay  -- 新增
    ,sub_revenue sub_revenue  -- 新增
from
    overall

union all

select
    event_date
    ,platform
    ,country
    ,is_new
    ,is_UA
    ,is_pay
    ,miniapp_name
    ,status
    ,version
    ,from_page
    ,'pv' data_type
    ,exposure_pv exposure
    ,click_pv click
    ,exposure_miniapp_pv exposure_miniapp
    ,click_miniapp_pv click_miniapp
    ,exposure_banner_pv exposure_banner
    ,click_banner_pv click_banner
    ,exposure_popup_pv exposure_popup
    ,click_popup_pv click_popup
    ,exposure_search_pv exposure_search
    ,click_search_pv click_search
    ,visit_pv visit
    ,enter_generate_page_pv enter_generate_page
    ,generate_pv generate
    ,save_pv save
    ,share_pv share
    ,share_pv_user share_user
    ,sub_uv sub
    ,credit_use_pv credit_use
    ,null credit_topup_imp
    ,null credit_topup_clk
    ,null credit_topup_suc
    ,credit_num
    ,payment_price_usd
    ,sub_pay_uv sub_pay  -- 新增
    ,sub_revenue sub_revenue  -- 新增
from
    overall

