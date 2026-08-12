
select app_name,date,project_name
     ,source
     ,sum(exposure_uv) exposure_uv
     ,sum(exposure_miniapp_uv) exposure_miniapp_uv
     ,sum(exposure_banner_uv) exposure_banner_uv
     ,sum(exposure_function_uv) exposure_function_uv
     ,sum(exposure_popup_uv) exposure_popup_uv
     ,sum(exposure_search_uv) exposure_search_uv
     ,sum(click_uv) click_uv
     ,sum(visit_uv) visit_uv
     ,sum(enter_generate_page_uv) enter_generate_page_uv
     ,sum(click_generate_uv) click_generate_uv
     ,sum(generate_uv) generate_uv
     ,sum(save_uv) save_uv
     ,sum(share_uv) share_uv
     ,sum(onelink_uv) onelink_uv

     ,sum(exposure_pv) exposure_pv
     ,sum(click_pv) click_pv
     ,sum(visit_pv) visit_pv
     ,sum(enter_generate_page_pv) enter_generate_page_pv
     ,sum(click_generate_pv) click_generate_pv
     ,sum(generate_pv) generate_pv
     ,sum(save_pv) save_pv
     ,sum(share_pv) share_pv
     ,sum(onelink_pv) onelink_pv
-- from `dataintegration-265403.temp.dws_ds_xyz_project_behavior_overall`
from `dataintegration-265403.temp.t_dws_ds_xyz_project_behavior_overall`
where date between '2024-09-05' and '2024-09-06'
    and entry='All'
group by 1,2,3,4
order by 1,2,3,4
-- group by 1,2,3
-- order by 1,2,3















select *
from `dataintegration-265403.temp.dws_ds_h5_page_xyz_project_event_level_pre`
where event_name in ('home_content_show_f_bd','home_content_clk_bd') and project=''



select app_name,event_date,project_name
     ,sum(exposure_uv) exposure_uv
     ,sum(exposure_miniapp_uv) exposure_miniapp_uv
     ,sum(exposure_banner_uv) exposure_banner_uv
     ,sum(exposure_function_uv) exposure_function_uv
     ,sum(exposure_popup_uv) exposure_popup_uv
     ,sum(exposure_search_uv) exposure_search_uv
     ,sum(click_uv) click_uv
     ,sum(visit_uv) visit_uv
     ,sum(enter_generate_page_uv) enter_generate_page_uv
     ,sum(generate_uv) generate_uv
     ,sum(save_uv) save_uv
     ,sum(share_uv) share_uv
     ,sum(onelink_uv) onelink_uv

     ,sum(exposure_pv) exposure_pv
     ,sum(click_pv) click_pv
     ,sum(visit_pv) visit_pv
     ,sum(enter_generate_page_pv) enter_generate_page_pv
     ,sum(generate_pv) generate_pv
     ,sum(save_pv) save_pv
     ,sum(share_pv) share_pv
     ,sum(onelink_pv) onelink_pv
from `dataintegration-265403.temp.dws_ds_h5_page_xyz_project_event_level`
where event_date between '2024-10-05' and '2024-10-06'
    and theme='all'
group by 1,2,3
order by 1,2,3

select app_name,date,project_name
    ,sum(generate_success_uv) generate_success_uv
    ,sum(credit_use_uv) credit_use_uv
--     ,sum(credit_topup_imp_uv) credit_topup_imp_uv
--     ,sum(credit_topup_clk_uv) credit_topup_clk_uv
--     ,sum(credit_topup_suc_uv) credit_topup_suc_uv
    ,sum(credit_use_pv) credit_use_pv
--     ,sum(credit_topup_imp_pv) credit_topup_imp_pv
--     ,sum(credit_topup_clk_pv) credit_topup_clk_pv
--     ,sum(credit_topup_suc_pv) credit_topup_suc_pv
    ,sum(credit_num) credit_num
    ,sum(payment_price_usd) payment_price_usd
from `dataintegration-265403.temp.dws_ds_h5_page_xyz_project_pay_level`
where date between '2024-05-05' and '2024-06-03'
    and theme='all'
group by 1,2,3
order by 1,2,3



select app_name,project_name
     ,sum(exposure) exposure
     ,sum(exposure_miniapp) exposure_miniapp
     ,sum(exposure_banner) exposure_banner
     ,sum(exposure_search) exposure_search
     ,sum(exposure_popup) exposure_popup
     ,sum(exposure_function) exposure_function
     ,sum(click) click
     ,sum(visit) visit
     ,sum(enter_generate_page) enter_generate_page
     ,sum(generate) generate
     ,sum(save) save
     ,sum(share) share
     ,sum(onelink) onelink

    ,sum(credit_use) credit_use
--     ,sum(credit_topup_imp) credit_topup_imp
--     ,sum(credit_topup_clk) credit_topup_clk
--     ,sum(credit_topup_suc) credit_topup_suc
    ,sum(credit_num) credit_num
    ,sum(payment_price_usd) payment_price_usd

    ,sum(sub) sub
    ,sum(sub_pay) sub_pay
    ,sum(sub_revenue) sub_revenue
from `dataintegration-265403.aigc.dws_dzp_aigc_h5_page_xyz_project_final_level`
where data_type='uv' --and project_name='AI Portrait 2.0'
    and theme='all'
    and event_date between '2024-05-05' and '2024-06-03'
group by 1,2
order by 1,2







-- 部分未订阅用户生成免费订单排查
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
        event_date_hk between '2024-04-30' and '2024-05-09'
        and app_name in ('BeautyPlus','AirBrush')
    group by 1,2,3,4,5
)
,
credit as
(
    select
        app_name
        ,order_id
        ,credit_num
        ,payment_price_usd
    from
        `beautyplus-bc0ed.dwd.dwd_da_credit_credit_record`
    where
        record_type=2 -- 积分消耗
        and app_name='BeautyPlus'
        and event_date between '2024-04-30' and '2024-05-09'
    group by
        1,2,3,4

    union all

    select
        app_name
        ,order_id
        ,credits credit_num
        ,payment_price_usd
    from
        `airbrush-1324.dwd.dwd_da_credit_detail`
    where
        record_type=2 -- 积分消耗
        and app_name in ('AirBrush')
        and event_date between '2024-04-30' and '2024-05-09'
    group by
        1,2,3,4
)
,
credit_event as
(
    select app_name
        ,event_date
        ,platform
        ,event_name
        ,`dataintegration-265403.func`.getParams(event_params,'project').string_value as project
        ,`dataintegration-265403.func`.getParams(event_params,'source').string_value as source
        ,`dataintegration-265403.func`.getParams(event_params,'order_id').string_value as order_id
        ,`dataintegration-265403.func`.getUserprop(user_properties,'UserPaymentStatus').string_value is_pay
        ,user_pseudo_id
    from
        `dataintegration-265403.analytics.dwd_dzp_events_function`('2024-04-30', '2024-05-09', 'beautyplus,airbrush', false)
    where event_name in ('h5_credit_consume_bd','h5_credit_consume')
)

select *
from (select
        app_name
        ,event_date
        ,platform
        ,project
        ,k order_id
        ,is_pay
        ,user_pseudo_id
        ,count(1) as pv
    from
        credit_event,unnest(split(order_id,',')) k
    where
        event_name in ('h5_credit_consume_bd','h5_credit_consume')
    group by
        1,2,3,4,5,6,7) a
    join user_info u on a.user_pseudo_id=u.user_pseudo_id and a.event_date=u.event_date_hk and a.platform = u.platform and a.app_name = u.app_name
    left join credit c on a.order_id=c.order_id
    join (select H5_name,max(Project) miniapp,max(Status) status from `dataintegration-265403.temp.dwd_da_miniapp_miniapp_name_mapping` group by 1) s on a.project=s.H5_name
where is_pay not in ('Paying') and a.app_name='BeautyPlus' and c.order_id is null




select app_name
        ,event_date
        ,platform
        ,event_name
        ,`dataintegration-265403.func`.getParams(event_params,'project').string_value as project
        ,`dataintegration-265403.func`.getParams(event_params,'source').string_value as source
        ,`dataintegration-265403.func`.getParams(event_params,'order_id').string_value as order_id
        ,`dataintegration-265403.func`.getUserprop(user_properties,'UserPaymentStatus').string_value is_pay
        ,user_pseudo_id
    from
        `dataintegration-265403.analytics.dwd_dzp_events_function`('2024-04-30', '2024-05-09', 'beautyplus,airbrush', false)
    where event_name in ('h5_credit_consume_bd','h5_credit_consume')
        and `dataintegration-265403.func`.getUserprop(user_properties,'UserPaymentStatus').string_value not in ('Paying')
        and `dataintegration-265403.func`.getParams(event_params,'order_id').string_value='__free__'
--     and user_pseudo_id in ('75db47c13a0cc6050f470b116ccc7358','466c4c5f8e6145c31155fc7b5806fd18'
--         ,'d55398c16676f7c26514ae5244f6d6a7','0f4438bb0a518bacff77e82a5efc0132','aca85eb6d308e7329f293a61f42db337'
--         ,'0303fe74464e73f3e55be6cb74c2cf5b','3ca6e44d5a2aebbbfcbf8895b9bed7a1')
    order by 9,2


select app_name
        ,event_date
        ,platform
        ,event_name
        ,event_timestamp
        ,`dataintegration-265403.func`.getParams(event_params,'project').string_value as project
        ,`dataintegration-265403.func`.getParams(event_params,'source').string_value as source
        ,`dataintegration-265403.func`.getParams(event_params,'order_id').string_value as order_id
        ,`dataintegration-265403.func`.getUserprop(user_properties,'UserPaymentStatus').string_value is_pay
        ,user_pseudo_id
    from
        `dataintegration-265403.analytics.dwd_dzp_events_function`('2024-04-30', '2024-05-09', 'beautyplus,airbrush', false)
    where event_name in ('h5_page_event_bd','h5_page_button_clk_bd','h5_credit_consume_bd','h5_page_event','h5_page_button_clk','h5_credit_consume')
--         and `dataintegration-265403.func`.getUserprop(user_properties,'UserPaymentStatus').string_value not in ('Paying')
--         and `dataintegration-265403.func`.getParams(event_params,'order_id').string_value='__free__'
    and user_pseudo_id in ('0303fe74464e73f3e55be6cb74c2cf5b')
    order by 9,5



select event_date
        ,platform
        ,event_name
        ,event_timestamp
        ,`dataintegration-265403.func`.getParams(event_params,'project').string_value as project
        ,`dataintegration-265403.func`.getParams(event_params,'source').string_value as source
        ,`dataintegration-265403.func`.getParams(event_params,'order_id').string_value as order_id
        ,`dataintegration-265403.func`.getUserprop(user_properties,'UserPaymentStatus').string_value is_pay
        ,user_pseudo_id
    from
        beautyplus-bc0ed.analytics.stage_dz_event_view
    where parse_date('%Y%m%d', event_date)>='2024-04-30'
    and event_name in ('h5_credit_consume_bd','h5_credit_consume')
    and user_pseudo_id in ('75db47c13a0cc6050f470b116ccc7358','466c4c5f8e6145c31155fc7b5806fd18'
        ,'d55398c16676f7c26514ae5244f6d6a7','0f4438bb0a518bacff77e82a5efc0132','aca85eb6d308e7329f293a61f42db337'
        ,'0303fe74464e73f3e55be6cb74c2cf5b','3ca6e44d5a2aebbbfcbf8895b9bed7a1')
















