-- 进入实验样本量
    select
        event_date_hk event_date,platform
        ,count(distinct user_pseudo_id) uv
    from
        `beautyplus-bc0ed.dim.dim_dzp_portrait_firebase_id_user`
    where
        event_date_hk between '2024-03-20' and '2024-03-26'
        and event_date_hk=last_active_date
        -- and first_active_date between DATE_SUB(event_date_hk, INTERVAL 90 DAY) and DATE_SUB(event_date_hk, INTERVAL 6 DAY)
        and first_active_date <DATE_SUB(event_date_hk, INTERVAL 5 DAY)
        and active_sessions_90d between 2 and 10
    group by 1,2


-- 订阅用户埋点核对
    select
--         parse_date('%Y%m%d', event_date) event_date
--         ,platform
--         ,event_timestamp
--         ,event_name
--         ,event_params
--         ,user_properties
--         ,user_pseudo_id
--         ,geo.country
    distinct func.getParams(event_params,'source_click_position').string_value
    from
        `beautyplus-bc0ed.analytics.stage_dz_event_view`
    where
        event_name in ('subscription_try_suc') --'homepage_sub_pop_appr_bd','homepage_sub_pop_clk_bd',
--         and user_pseudo_id='D8158E63311644DCBE3878CB0572421A'
        and parse_date('%Y%m%d', event_date) between '2024-03-30' and '2024-04-01'
        and func.getParams(event_params,'sku_tag').string_value ='首次订阅优惠'
--     order by event_timestamp





