-- dataintegration-265403.aigc.dws_ds_h5_page_xyz_project_final_level
-- miniapp mapping: https://docs.google.com/spreadsheets/d/1J-4FIowZHgFOVUfHR8DyLbpS6yhzaPzOJaUD5Di31G4/edit#gid=1398841059
-- `dataintegration-265403.temp.dwd_da_miniapp_material_id_mapping`
-- `dataintegration-265403.temp.dwd_da_miniapp_miniapp_name_mapping`
-- `dataintegration-265403.temp.dwd_da_miniapp_adj_link_mapping`

-- drop table if exists `dataintegration-265403.temp.dws_dzp_aigc_h5_page_xyz_project_final_level`;
-- create table if not exists `dataintegration-265403.temp.dws_dzp_aigc_h5_page_xyz_project_final_level` as
delete from  `dataintegration-265403.aigc.dws_dzp_aigc_h5_page_xyz_project_final_level`  where event_date>='{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=14)).strftime("%Y-%m-%d") }}' and event_date<='{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=0)).strftime("%Y-%m-%d") }}';
insert into `dataintegration-265403.aigc.dws_dzp_aigc_h5_page_xyz_project_final_level`
with user_info as
(
    select
        event_date_hk
        ,app_name
        ,platform
        ,country
        ,user_pseudo_id
        ,max(is_new) is_new
        ,max(is_UA) is_UA
    from
        `dataintegration-265403.stat.stat_active_advice_detail_d`
    where
        event_date_hk between '{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=14)).strftime("%Y-%m-%d") }}' and '{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=0)).strftime("%Y-%m-%d") }}'
        and app_name in ('BeautyPlus','AirBrush','Beauty Plus Cam')
    group by 1,2,3,4,5
)
,
bp_subscription_pre as
(
    select *
        ,case when source2_1 in (select distinct Bp_sub_name from `dataintegration-265403.temp.dwd_da_miniapp_miniapp_name_mapping`) then source2_1
            else source2_2
        end source2
        ,case when source2_1 in (select distinct Bp_sub_name from `dataintegration-265403.temp.dwd_da_miniapp_miniapp_name_mapping`) then source2_2
            else source2_1
        end theme
    from
    (
        select
            'BeautyPlus' app_name
            ,date
            ,platform
            ,country
            ,cur_page_type
            ,source1
            ,split(source2,'+')[0] source2_1
            ,if(ARRAY_LENGTH(split(source2,'+'))>=2,split(source2,'+')[1],null) source2_2
            ,user_pseudo_id
            ,original_order_id
            ,sku_type
            ,sku_has_trial
            ,purchase_date
            ,payment_price_usd
        from
            `beautyplus-bc0ed.sub_dataset.ads_spm_trial_subscription_pre_v5_abtest`
        where
            date between '{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=14)).strftime("%Y-%m-%d") }}' and '{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=0)).strftime("%Y-%m-%d") }}'
            and event_name='subscription_try_suc'
            and standard_order_date is not null
    )
    where source2_1 in (select distinct Bp_sub_name from `dataintegration-265403.temp.dwd_da_miniapp_miniapp_name_mapping`)
        or source2_2 in (select distinct Bp_sub_name from `dataintegration-265403.temp.dwd_da_miniapp_miniapp_name_mapping`)
)
,
ab_subscription_pre as
(
    select 'AirBrush' app_name
            ,event_date date
            ,first
            ,second
--             ,third theme -- 主题
            ,REPLACE(third,'_',' ') theme -- 主题
            ,platform
            ,case when is_new='New' then 1 else 0 end is_new
            ,country
            ,is_ua
            ,sub_success_uv,sub_to_paid_uv,sub_to_paid_revenue_sub
    from airbrush-1324.stat.dws_airbrush_trial_sub_grads_view
    where event_date between '{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=14)).strftime("%Y-%m-%d") }}' and '{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=0)).strftime("%Y-%m-%d") }}'
        and fourth='A' and third not in ('A','all','-') and third is not null
--             and second in (select distinct Ab_sub_name from `dataintegration-265403.temp.dwd_da_miniapp_miniapp_name_mapping`)
        and sale_status not in ('credit')
)
,
subscription as
(
    select e.app_name
        ,e.date
        ,e.platform
        ,e.country
        ,e.is_new
        ,e.is_ua is_UA
        ,'Non-paying' is_pay
        ,s.miniapp project_name
        ,'all' theme
        ,status
        ,sum(sub_success_uv) sub_uv
        ,sum(sub_to_paid_uv) sub_pay_uv
        ,round(sum(sub_to_paid_revenue_sub),2) sub_revenue
    from ab_subscription_pre e
    join (select Ab_sub_name,max(Project) miniapp,max(status) status from `dataintegration-265403.temp.dwd_da_miniapp_miniapp_name_mapping` group by 1) s on e.second=s.Ab_sub_name
    group by 1,2,3,4,5,6,7,8,9,10

    union all

    select e.app_name
        ,e.date
        ,e.platform
        ,e.country
        ,u.is_new
        ,u.is_UA
        ,'Non-paying' is_pay
        ,s.miniapp project_name
        ,'all' theme
        ,status
        ,count(distinct original_order_id) sub_uv
        ,count(distinct case when purchase_date is not null then original_order_id end) sub_pay_uv
        ,round(sum(case when purchase_date is not null then payment_price_usd end),2) sub_revenue
    from bp_subscription_pre e
    left join (select Bp_sub_name,max(Project) miniapp,max(status) status from `dataintegration-265403.temp.dwd_da_miniapp_miniapp_name_mapping` group by 1) s on e.source2=s.Bp_sub_name
    join user_info u on e.user_pseudo_id=u.user_pseudo_id and e.date=u.event_date_hk and e.platform=u.platform and e.app_name=u.app_name
    group by 1,2,3,4,5,6,7,8,9,10

    union all

    select e.app_name
        ,e.date
        ,e.platform
        ,e.country
        ,e.is_new
        ,e.is_ua is_UA
        ,'Non-paying' is_pay
        ,s.miniapp project_name
        ,theme
        ,status
        ,sum(sub_success_uv) sub_uv
        ,sum(sub_to_paid_uv) sub_pay_uv
        ,round(sum(sub_to_paid_revenue_sub),2) sub_revenue
    from ab_subscription_pre e
    join (select Ab_sub_name,max(Project) miniapp,max(status) status from `dataintegration-265403.temp.dwd_da_miniapp_miniapp_name_mapping` group by 1) s on e.second=s.Ab_sub_name
    group by 1,2,3,4,5,6,7,8,9,10

    union all

    select e.app_name
        ,e.date
        ,e.platform
        ,e.country
        ,u.is_new
        ,u.is_UA
        ,'Non-paying' is_pay
        ,s.miniapp project_name
        ,theme
        ,status
        ,count(distinct original_order_id) sub_uv
        ,count(distinct case when purchase_date is not null then original_order_id end) sub_pay_uv
        ,round(sum(case when purchase_date is not null then payment_price_usd end),2) sub_revenue
    from bp_subscription_pre e
    left join (select Bp_sub_name,max(Project) miniapp,max(status) status from `dataintegration-265403.temp.dwd_da_miniapp_miniapp_name_mapping` group by 1) s on e.source2=s.Bp_sub_name
    join user_info u on e.user_pseudo_id=u.user_pseudo_id and e.date=u.event_date_hk and e.platform=u.platform and e.app_name=u.app_name
    group by 1,2,3,4,5,6,7,8,9,10

)
,
event_result as
(
    select *
    from `dataintegration-265403.temp.dws_ds_h5_page_xyz_project_event_level`
    where event_date between '{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=14)).strftime("%Y-%m-%d") }}' and '{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=0)).strftime("%Y-%m-%d") }}'
)
,
credit_result as
(
    select *
    from `dataintegration-265403.temp.dws_ds_h5_page_xyz_project_pay_level`
    where date between '{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=14)).strftime("%Y-%m-%d") }}' and '{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=0)).strftime("%Y-%m-%d") }}'
)
,
-- daily+miniapp
overall as (
select
    coalesce(e.app_name,s.app_name) app_name
    ,coalesce(e.event_date,s.date) event_date
    ,coalesce(e.platform,s.platform) platform
    ,case when coalesce(e.country,s.country)='China'  then 'China Mainland' else coalesce(e.country,s.country) end country
    ,coalesce(e.is_new,s.is_new) is_new
    ,coalesce(e.project_name,s.project_name) project_name
    ,coalesce(e.theme,s.theme) theme
    ,coalesce(e.is_UA,s.is_UA) is_ua
    ,coalesce(e.is_pay,s.is_pay) is_pay
    ,coalesce(e.status,s.status) status
--     e.app_name
--     ,e.event_date
--     ,e.platform
--     ,case when e.country='China' then 'China Mainland' else e.country end country
--     ,e.is_new
--     ,e.is_UA is_ua
--     ,e.is_pay
--     ,e.project_name
--     ,e.status
--     ,e.theme
    ,exposure_uv
    ,click_uv
    ,exposure_miniapp_uv
    ,click_miniapp_uv
    ,exposure_banner_uv
    ,click_banner_uv
    ,exposure_function_uv
    ,click_function_uv
    ,exposure_popup_uv
    ,click_popup_uv
    ,exposure_search_uv
    ,click_search_uv
    ,visit_uv
    ,enter_generate_page_uv
    ,generate_uv
    ,generate_success_uv
    ,save_uv
    ,share_uv
    ,onelink_uv

    ,sub_uv
    ,sub_pay_uv
    ,sub_revenue
    ,credit_use_uv
--     ,credit_topup_imp_uv
--     ,credit_topup_clk_uv
--     ,credit_topup_suc_uv

    ,exposure_pv
    ,click_pv
    ,exposure_miniapp_pv
    ,click_miniapp_pv
    ,exposure_banner_pv
    ,click_banner_pv
    ,exposure_function_pv
    ,click_function_pv
    ,exposure_popup_pv
    ,click_popup_pv
    ,exposure_search_pv
    ,click_search_pv
    ,visit_pv
    ,enter_generate_page_pv
    ,generate_pv
    ,generate_success_pv
    ,save_pv
    ,share_pv
    ,onelink_pv

    ,credit_use_pv
--     ,credit_topup_imp_pv
--     ,credit_topup_clk_pv
--     ,credit_topup_suc_pv

    ,credit_num
    ,payment_price_usd
from
    event_result e
    left join credit_result c on e.app_name=c.app_name
                                            and e.event_date=c.date
                                            and e.platform=c.platform
                                            and e.country=c.country
                                            and e.is_new=c.is_new
                                            and e.is_UA=c.is_UA
                                            and e.is_pay=c.is_pay
                                            and e.project_name=c.project_name
                                            and e.theme=c.theme
    left join subscription s
                              on e.app_name=s.app_name
                                            and e.event_date=s.date
                                            and e.platform=s.platform
                                            and e.country=s.country
                                            and e.is_new=s.is_new
                                            and e.is_UA=s.is_UA
                                            and e.is_pay=s.is_pay
                                            and e.project_name=s.project_name
                                            and e.theme=s.theme
                                            and e.status=s.status
)

select
    app_name
    ,event_date
    ,platform
    ,country
    ,is_new
    ,is_ua
    ,is_pay
    ,project_name
    ,status
    ,theme
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
    ,onelink_uv onelink
    ,sub_uv sub
    ,credit_use_uv credit_use
--     ,credit_topup_imp_uv credit_topup_imp
--     ,credit_topup_clk_uv credit_topup_clk
--     ,credit_topup_suc_uv credit_topup_suc
    ,credit_num
    ,payment_price_usd
    ,sub_pay_uv sub_pay
    ,sub_revenue sub_revenue

    ,generate_success_uv generate_success
    ,exposure_function_uv exposure_function
    ,click_function_uv click_function
from
    overall
where project_name not in ('Tooniverse')

union all

select
    app_name
    ,event_date
    ,platform
    ,country
    ,is_new
    ,is_UA
    ,is_pay
    ,project_name
    ,status
    ,theme
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
    ,onelink_pv onelink
    ,sub_uv sub
    ,credit_use_pv credit_use
--     ,credit_topup_imp_pv credit_topup_imp
--     ,credit_topup_imp_pv credit_topup_clk
--     ,credit_topup_suc_pv credit_topup_suc
    ,credit_num
    ,payment_price_usd
    ,sub_pay_uv sub_pay
    ,sub_revenue sub_revenue

    ,generate_success_pv generate_success
    ,exposure_function_pv exposure_function
    ,click_function_pv click_function
from
    overall
where project_name not in ('Tooniverse')


