with
user_activity_pre as
(
    select
        distinct event_date,event_name,user_pseudo_id,platform,version
    from `dataintegration-265403.analytics.dwd_dzp_events_function`('2023-11-20', '2023-12-27', 'beautypluscam', false)
    where event_name in ('selfietakepic_bd','home_clk_edit_bd','home_clk_selfie_bd','home_clk_beautify_bd')
)
,
user_info as
(
    select
        user_pseudo_id
        ,is_new
        ,is_UA
        ,user_type
        ,country
        ,event_date_hk
        ,platform
    from
        `dataintegration-265403.stat.stat_active_advice_detail_d` u
    where
        -- u.event_date_hk between date'2023-07-01' and date'2023-07-05'
        -- u.event_date_hk between date'2022-10-01' and date_sub(current_date,interval'1'day)
        u.event_date_hk>='2023-11-20'
        and u.event_date_hk<='2023-12-27'
)

    select event_name
        ,case when version>='7.7.010' then '>=7.7.010' else 'old' end as version
        ,count(distinct a.user_pseudo_id) event_uv
    from user_activity_pre a
    join user_info u
    on a.user_pseudo_id=u.user_pseudo_id
                and a.event_date=u.event_date_hk
                and a.platform=u.platform
    group by 1,2
