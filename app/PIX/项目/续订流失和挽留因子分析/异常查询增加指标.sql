-- 进入订阅页
-- select *
select date,uuid,sub_page_enter,sub_page_click,force_sub_page_enter,force_sub_page_click
    ,subscript_sub_page_enter,subscript_sub_page_click,other_sub_page_enter,other_sub_page_click
from beautyplus-bc0ed.temp.renewal_order_loss_behave
-- from airbrush-1324.temp.renewal_order_loss_behave
where loss_type='loss af 1 day'
    and sub_page_enter>0
    and date='2024-09-30'
limit 100


select event_timestamp,event_name
     ,`beautyplus-bc0ed.func.getParams`(event_params,'cur_spm').string_value
     ,`beautyplus-bc0ed.func.getParams`(event_params,'cur_page_content').string_value as cur_page_content
     ,`beautyplus-bc0ed.func.getParams`(event_params,'pre_page_content').string_value as pre_page_content
     ,`beautyplus-bc0ed.func.getParams`(event_params,'dpre_page_content').string_value as dpre_page_content
     ,`beautyplus-bc0ed.func.getParams`(event_params,'source_feature_content').string_value as source_feature_content
     ,`beautyplus-bc0ed.func.getParams`(event_params,'source_click_position').string_value as  source_click_position
     ,`dataintegration-265403.func`.getUserprop(user_properties,'UserPaymentStatus').string_value is_pay
from
    `dataintegration-265403.analytics.dwd_dzp_events_function`('2024-09-20', '2024-09-30', 'beautyplus', false)
where
--     (event_name = 'page_event'
--     and `beautyplus-bc0ed.func.decodeSpmNew`(`beautyplus-bc0ed.func.getParams`(event_params,'cur_spm').string_value).page_id like '%1009%')
--     or (event_name in ('subscription_clk_try', 'subscription_try_suc'))
    event_name in ('page_event','subscription_clk_try', 'subscription_try_suc')
    and user_pseudo_id in (
        select key
        from `dataintegration-265403.stat.dmi_dz_idmapping`
        where uuid = '214234440' --128255645,731633121
    )
order by 1


-- 进入首页
-- select *
select date,uuid,homepage_exposure_pv,homepage_click_pv
from beautyplus-bc0ed.temp.renewal_order_loss_behave
-- from airbrush-1324.temp.renewal_order_loss_behave
where loss_type='loss af 1 day'
    and homepage_exposure_pv<0
--     and homepage_exposure_pv=0
    and date='2024-09-30'
limit 100


select event_timestamp,event_name
     ,`beautyplus-bc0ed.func.getParams`(event_params,'cur_spm').string_value
     ,`dataintegration-265403.func`.getUserprop(user_properties,'UserPaymentStatus').string_value is_pay
from
    `dataintegration-265403.analytics.dwd_dzp_events_function`('2024-09-20', '2024-09-30', 'beautyplus', false)
where
--     (event_name = 'page_event'
--     and `beautyplus-bc0ed.func.decodeSpmNew`(`beautyplus-bc0ed.func.getParams`(event_params,'cur_spm').string_value).page_id like '%1009%')
--     or (event_name in ('subscription_clk_try', 'subscription_try_suc'))
--     event_name in ('page_event','subscription_clk_try', 'subscription_try_suc')
--     and
    user_pseudo_id in (
        select key
        from `dataintegration-265403.stat.dmi_dz_idmapping`
        where uuid = '627852620' --282528167,624523184
    )
order by 1



