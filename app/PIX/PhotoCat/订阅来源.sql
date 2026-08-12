with event_pre as
(
    select event_date
         ,event_name
        ,`dataintegration-265403.func`.getParams(event_params,'type').string_value type
        ,`dataintegration-265403.func`.getParams(event_params,'button').string_value button
        ,`dataintegration-265403.func`.getParams(event_params,'source').string_value source
        ,`dataintegration-265403.func`.getParams(event_params,'module_type').string_value module_type
        ,`dataintegration-265403.func`.getParams(event_params,'content_type').string_value content_type
        ,`dataintegration-265403.func`.getParams(event_params,'from').string_value `from`
        ,`dataintegration-265403.func`.getParams(event_params,'sku_type').string_value sku_type
        ,coalesce(`dataintegration-265403.func`.getParams(event_params,'子功能').string_value,
                `dataintegration-265403.func`.getParams(event_params,'一级子功能').string_value,
                `dataintegration-265403.func`.getParams(event_params,'module').string_value) function
        ,user_pseudo_id
    FROM `dataintegration-265403.analytics.dwd_dzp_events_function`('2025-05-29','2025-06-04','photocat',false)
    WHERE event_name in
            ('no_access_appr','no_access_clk'
            ,'homepageappr','topbar_clk','bottom_clk','homepage_clk'
            ,'beauty_appr','beauty_tag','beauty_appr_edit_clk'
            ,'material_exposure','material_click'
            ,'sub_page_imp','subscription_clk_try','subscription_try_suc','h5_credit_consume'
            ,'credit_page','credit_purchase_clk','credit_purchase_suc'
            ,'generate_task_create','beauty_effect_suc','beautifysave'
            ,'album_impression','album_clk_beauty'
            ,'result_page_appr','result_page_clk','recycle_bin_appr','recycle_bin_clk'
            ,'homesetting','home_set_clk')
--         and app_info.version>='3.3.0'
)

-- 一级
select event_date
--         ,source
        ,sku_type
        ,case
              when event_name in ('sub_page_imp') then '1:进入订阅页'
              when event_name in ('subscription_clk_try') then '2:订阅页点击'
              when event_name in ('subscription_try_suc') then '3:订阅成功'
        end action_I
        ,count(distinct e.user_pseudo_id) uv
        ,count(1) pv
from event_pre e
join `dataintegration-265403.stat.stat_active_advice_detail_d` u
on e.user_pseudo_id=u.user_pseudo_id and e.event_date=u.event_date_hk
where e.event_name in ('sub_page_imp','subscription_clk_try','subscription_try_suc')
    and u.is_new=1 and u.is_UA='non-Organic'
group by 1,2,3


