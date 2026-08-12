-- drop table if exists `beauty-cam-new.event_data.dwd_da_save_event`;
-- create table if not exists `beauty-cam-new.event_data.dwd_da_save_event` as
delete from  `beauty-cam-new.event_data.dwd_da_save_event`  where event_date>='{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=3)).strftime("%Y-%m-%d") }}' and event_date<='{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=0)).strftime("%Y-%m-%d") }}';
insert into `beauty-cam-new.event_data.dwd_da_save_event`
with app_event as
(
    select
        date(timestamp_add(timestamp_micros(event_timestamp), interval 8 hour)) date
        ,case when device.operating_system='Android' then 'ANDROID' else device.operating_system end platform
        ,app_info.version app_version
        ,event_name
        ,user_pseudo_id
        ,count(1) as pv
    from
        -- `beauty-cam-new.analytics.ods_dz_events_tv`('2023-07-01','2023-07-05') a
        -- `beauty-cam-new.analytics.ods_dz_events_tv`('2022-10-01',date_sub(current_date,interval'1'day)) a
        `dataintegration-265403.analytics.dwd_dzp_events_function`('{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=3)).strftime("%Y-%m-%d") }}', '{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=0)).strftime("%Y-%m-%d") }}', 'beautypluscam', false) a
--         `beauty-cam-new.analytics.ods_dz_events_tv`('{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=3)).strftime("%Y-%m-%d") }}', '{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=0)).strftime("%Y-%m-%d") }}') a
    where
        event_name in ('selfiesave_bd','ad_beautifysvclk','beautifysave_bd','beautifysave_second_clk_bd','ai_editor_save_clk_bd')
    group by
        1,2,3,4,5
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
        u.event_date_hk>='{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=3)).strftime("%Y-%m-%d") }}'
        and u.event_date_hk<='{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=0)).strftime("%Y-%m-%d") }}'
)
,
andriod_device_and_is_pay as
(
    select
        p.platform
        ,p.date
        ,p.user_pseudo_id
        ,case   when p.if_high=3 then '高端机'
                when p.if_high=2 then '中端机'
                else '低端机'
                end if_high
        ,case when is_pay=1 then 'Paying' else 'un-Paying' end is_pay
    from
        (select
            d.platform
            ,d.date
            ,d.user_pseudo_id
            ,max(if_high) as if_high
            ,max(is_pay) as is_pay
        from
            (select distinct
                platform
                ,date
                ,user_pseudo_id
                ,case   when screen_width >'1080' and ram_size >'2001' then 3
                        when screen_width >'720' and ram_size >'3001' then 3
                        when screen_width >'1080' and ram_size >'1001' then 2
                        when screen_width >'720' and ram_size >'1001' then 2
                        when screen_width <='720' and ram_size >'1001' then 2
                        else 1
                        end if_high
                ,case when UserPaymentStatus='Paying' then 1 else 0 end is_pay
            from
                (select
                    platform
                    ,date(timestamp_add(timestamp_micros(event_timestamp), interval 8 hour)) date
                    ,user_pseudo_id
                    ,`dataintegration-265403.func.getUserprop`(user_properties,'ram_size').string_value ram_size /*> 5100MB 代表 6GB 设备> 7100MB 代表 8GB 设备*/
                    ,`dataintegration-265403.func.getUserprop`(user_properties,'screen_width').string_value screen_width
                    ,`dataintegration-265403.func.getUserprop`(user_properties,'UserPaymentStatus').string_value UserPaymentStatus
                from
                    -- `beauty-cam-new.analytics.ods_dz_events_tv`('2023-07-01','2023-07-05') a
                    -- `beauty-cam-new.analytics.ods_dz_events_tv`('2022-10-01',date_sub(current_date,interval'1'day)) a
--                     `beauty-cam-new.analytics.ods_dz_events_tv`('{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=3)).strftime("%Y-%m-%d") }}', '{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=0)).strftime("%Y-%m-%d") }}') a
                    `dataintegration-265403.analytics.dwd_dzp_events_function`('{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=3)).strftime("%Y-%m-%d") }}', '{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=0)).strftime("%Y-%m-%d") }}', 'beautypluscam', false) a
                where
                    device.operating_system='Android'
                group by
                    1,2,3,4,5,6) t) d
        group by
            1,2,3) p
)

select
    a.date event_date
    ,a.platform
    ,a.app_version
    ,a.event_name
    ,a.user_pseudo_id
    ,case when u.is_new=1 then 'New users' else 'Old users' end is_new
    ,u.is_UA
    ,case   when u.user_type=1 then 'New users'
            when u.user_type=2 then 'Low active users'
            when u.user_type=3 then 'Middle active users'
            when u.user_type=4 then 'High active users'
            end user_type
    ,u.country
    ,d.if_high
    ,d.is_pay
    ,a.pv
from
    app_event a
    join user_info u on    a.user_pseudo_id=u.user_pseudo_id
                                and a.date=u.event_date_hk
                                and a.platform=u.platform
    left join andriod_device_and_is_pay d on    a.user_pseudo_id=d.user_pseudo_id
                                                and a.date=d.date
                                                and a.platform=d.platform
