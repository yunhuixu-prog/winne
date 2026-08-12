drop table if exists `dataintegration-265403.temp.winne_temp_dws_subscription_overview_monthly`;
create table `dataintegration-265403.temp.winne_temp_dws_subscription_overview_monthly`  as

-- delete from
--  `dataintegration-265403.temp.winne_temp_dws_subscription_overview_monthly`
-- where
-- event_month = date_sub(date_trunc(current_date, month),interval 1 month) ;
-- -- 重新跑上个月的数据
--
-- insert into  `dataintegration-265403.temp.winne_temp_dws_subscription_overview_monthly`

DECLARE start int64 DEFAULT 1;
DECLARE cal_date DEFAULT date('{{ (data_interval_end + macros.timedelta(hours=8) - macros.timedelta(days=0)).strftime("%Y-%m-%d") }}');

with app_subscription_order as (
  --用调度当天产出的订单表
  select * from `dataintegration-265403.subscription.dwd_trial_subscription_retention_daily_temp_history_backup` where  update_date = cal_date
 ),
    dws_act_subscription_month as (
        select
            event_month,
            user_pseudo_id,
            app_name,
            platform,
            country,
            --取最后出现的uuid
            m.uuid as uuid,
            max(is_new) is_new,
            max(is_ua) is_ua,
            max(user_source) as user_source
        from
            (
                select
                    date_trunc(event_date_hk, month) as event_month,
                    event_date_hk as event_date,
                    app_name,
                    user_pseudo_id,
                    max(platform) as platform,
                    max(country) as country,
                    max(is_new) as is_new,
                    min(user_type) as user_type,
                    max(is_ua) as is_ua,
                    max(user_source) as user_source
                from
                    (
                        select
                            a.*
                        except
                            (country),
                            fix_firebase_en_name country
                        from
                            (
                                select
                                    *
                                except
                                    (app_name),
                                    --统一调整app_name
                                    case
                                        when app_name = 'pomelo' then 'Pomelo'
                                        when app_name = 'airbrush' then 'AirBrush'
                                        when app_name = 'airglow' then 'AirGlow'
                                        when app_name = 'plusme' then 'PlusMe'
                                        else app_name
                                    end app_name
                                from
                                    `dataintegration-265403.stat.stat_active_advice_detail_d`
                                where
                                    event_date_hk between date_sub(
                                        date_trunc(cal_date, month),
                                        interval start month
                                    )
                                    and date_trunc(cal_date, month)
                            ) a
                            left join (
                                select
                                    distinct key,
                                    fix_firebase_en_name
                                from
                                    `dataintegration-265403.dmi.dmi_ya_country_code`,
                                    unnest(names) key
                            ) b on a.country = b.key
                    ) t
                group by
                    date_trunc(event_date_hk, month),
                    event_date_hk,
                    app_name,
                    user_pseudo_id
            ) tt
            left join `dataintegration-265403.stat.dmi_dz_idmapping` m
            on tt.user_pseudo_id = m.key
        group by
            1,
            2,
            3,
            4,
            5,
            6
    ),
    dws_act_subscription_month_uuid_rank as (
        select
            *,
            row_number() over(
                partition by event_month,
                app_name,
                platform,
                uuid
                order by
                    country,
                    is_new,
                    is_ua
            ) uuid_rk
        from
            dws_act_subscription_month
    ),
    dws_trial_subscription_retention_valid_month as (
        select
            *,
            date_sub(
                date_trunc(cal_date, month),
                interval start month
            ) as event_month
        from
            (
                select
                    *
                except
                    (order_date, order_expire_date) --转化时区后的日期
,
                    standard_order_date as order_date,
                    case
                        when subscription_period = 'lifetime' then '2099-12-31' -- AB 的lifetime 没有截止日期
                        when order_status = 0 then standard_order_expire_date
                        when date_sub(date_trunc(cal_date, month),interval start month) >= '2024-05-01'
                            then if(is_in_grace_period = 1,cal_date,coalesce(grace_actual_end_date,standard_order_expire_date))
                        else standard_order_expire_date
                    end order_expire_date
                from
                    app_subscription_order
                where
                    concat(app_id, '-', original_order_id, '-', order_id) not in (
                        select
                            distinct concat(app_id, '-', original_order_id, '-', order_id)
                        from
                            app_subscription_order
                        where
                            subscription_user_type = 'refund' --and (date_trunc(standard_order_date,month) = date_sub(date_trunc(cal_date, month),interval start month) or date_trunc(standard_order_expire_date,month) = date_sub(date_trunc(cal_date, month),interval start month))
                    ) --and original_order_id='60001131175143' -- 计算vlaid排除退款用户
                    and date_trunc(
                     case
                        when subscription_period = 'lifetime' then cal_date
                        when order_status = 0 then standard_order_expire_date
                        when date_sub(cal_date, interval start day) >= '2024-05-01' then if(is_in_grace_period = 1,cal_date,coalesce(grace_actual_end_date,standard_order_expire_date))
                        else standard_order_expire_date
                         end,
                        month
                    ) >= date_sub(
                        date_trunc(cal_date, month),
                        interval start month
                    )
                    and date_trunc(standard_order_date, month) <= date_sub(
                        date_trunc(cal_date, month),
                        interval start month
                    )
            ) t,
            unnest(
                generate_date_array(order_date, order_expire_date)
            ) as event_date
        where
            date_trunc(event_date, month) = date_sub(
                date_trunc(cal_date, month),
                interval start month
            )
    ),
    unnormal_uuid as (
        --选取在前一个月内单个uuid对应了10个及以上有效订单的uuid
        select
            distinct uuid
        from
            (
                select
                    uuid,
                    count(distinct original_order_id) order_cnt
                from
                    dws_trial_subscription_retention_valid_month
                where
                    uuid is not null
                group by
                    1
            )
        where
            order_cnt >= 10
    ),
    no_all_country_1 as (
        select
            event_month,
            app_id as app_name,
            platform,
            country,
            is_ua,
            user_source,
            0 as MAU,
            0 as uuid_MAU,
            0 as MNU,
            0 as Valid_trial_users,
            0 as Valid_paid_users,
            0 as Vaild_Standard_Paid_Users,
            0 as Vaild_Promotional_Paid_Users,
            0 as Active_valid_paid_users,
            0 as Active_valid_trial_users,
            0 as Active_Vaild_Standard_Paid_Users,
            0 as Active_Vaild_Promotional_Paid_Users,
            0 as Paid_users,
            count(
                distinct case
                    when t3.order_status = 0 then t3.original_order_id
                    else null
                end
            ) as Trial_users,
            count(
                distinct case
                    when t3.order_status = 0
                    and t3.next_sku_offer_method not in ('trial')
                    and DATE(t3.next_order_date) <= t3.standard_order_expire_date then t3.original_order_id
                    else null
                end
            ) as Trial_to_pay_users,
            count(
                distinct case
                    when t3.subscription_user_type in (
                        'first_time_subscription',
                        'first_time_return_subscription'
                    ) then t3.original_order_id
                    else null
                end
            ) as New_paid_users,
            sum(
                case
                    when t3.subscription_user_type in (
                        'first_time_subscription',
                        'first_time_return_subscription'
                    ) then t3.payment_price_usd
                    else 0
                end
            ) as New_paid_revenue,
            count(
                distinct case
                    when t3.subscription_user_type in ('repeated_renewal', 'return_renewal') then t3.original_order_id
                    else null
                end
            ) as Renewal_users,
            sum(
                case
                    when t3.subscription_user_type in ('repeated_renewal', 'return_renewal') then t3.payment_price_usd
                    else 0
                end
            ) as Renewal_revenue,
            count(
                distinct case
                    when t3.subscription_user_type = 'first_time_return_subscription' then t3.original_order_id
                    else null
                end
            ) as New_return_users,
            sum(
                case
                    when t3.subscription_user_type = 'first_time_return_subscription' then t3.payment_price_usd
                    else 0
                end
            ) as New_return_revenue,
           sum(t3.payment_price_usd) as VAS,
            round(sum(t3.payment_price_usd) * 0.7, 4) as CM,
            count(
                distinct case
                    when t3.offer_method not in('trial', 'normal')
                    and t3.order_status != 0
                    and t3.subscription_user_type != 'refund' then t3.original_order_id
                    else null
                end
            ) Promotional_paid_users --这里问题：把退款算进来了 还有一个distinct
            --,sum(distinct case when t3.offer_method not in('trial','normal')   then t3.payment_price_usd else 0 end) Promotional_paid_revenue
,
            sum(
                case
                    when t3.offer_method not in('trial', 'normal')
                    and t3.subscription_user_type != 'refund' then t3.payment_price_usd
                    else 0
                end
            ) Promotional_paid_revenue,
            count(
                distinct case
                    when t3.offer_method not in ('trial', 'normal')
                    and t3.offer_method != 'pay as you go'
                    and t3.order_status in (1, 2)
                    and t3.next_sku_offer_method in ('normal')
                    and DATE(t3.next_order_date) <= t3.standard_order_expire_date then t3.original_order_id
                    when t3.offer_method = 'pay as you go'
                    and offer_times = 1
                    and t3.next_sku_offer_method in ('normal') then t3.original_order_id
                    else null
                end
            ) Promotional_to_standard_paid_users
        from
            (
                select
                    *,
                    date_trunc(standard_order_date, month) event_month
                from
                    app_subscription_order
                where
                    date_trunc(standard_order_date, month) = date_sub(
                        date_trunc(cal_date, month),
                        interval start month
                    )

            ) t3
        group by
            1,
            2,
            3,
            4,
            5,
            6
    ),
    no_all_country_2 as (
        select
            event_month,
            app_name,
            platform,
            country,
            is_ua,
            user_source,
            count(distinct t5.user_pseudo_id) MAU,
            0 as uuid_MAU,
            count(
                distinct case
                    when t5.is_new = 1 then t5.user_pseudo_id
                    else null
                end
            ) MNU,
            0 as Valid_trial_users,
            0 as Valid_paid_users,
            0 as Vaild_Standard_Paid_Users,
            0 as Vaild_Promotional_Paid_Users,
            0 as Active_valid_paid_users,
            0 as Active_valid_trial_users,
            0 as Active_Vaild_Standard_Paid_Users,
            0 as Active_Vaild_Promotional_Paid_Users,
            0 as Paid_users,
            0 as Trial_users,
            0 as Trial_to_pay_users,
            0 as New_paid_users,
            0 as New_paid_revenue,
            0 as Renewal_users,
            0 as Renewal_revenue,
            0 as New_return_users,
            0 as New_return_revenue,
            0 as VAS,
            0 as CM,
            0 as Promotional_paid_users,
            0 as Promotional_paid_revenue,
            0 as Promotional_to_standard_paid_users
        from
            (
                select
                    *
                from
                    dws_act_subscription_month
                where
                    event_month = date_sub(
                        date_trunc(cal_date, month),
                        interval start month
                    )
            ) t5
        group by
            1,
            2,
            3,
            4,
            5,
            6
    ),
    no_all_country_3 as (
        select
            event_month,
            app_id as app_name,
            platform,
            country,
            is_ua,
            user_source,
            0 as MAU,
            0 as uuid_MAU,
            0 as MNU,
            count(
                distinct case
                    when order_status = 0 then t4.original_order_id
                    else null
                end
            ) as Valid_trial_users,
            count(
                distinct case
                    when t4.order_status in (1, 2) then t4.original_order_id
                    else null
                end
            ) as Valid_paid_users,
            count(
                distinct case
                    when t4.offer_method in ('normal') then t4.original_order_id
                    else null
                end
            ) Vaild_Standard_Paid_Users,
            count(
                distinct case
                    when t4.offer_method not in('trial', 'normal')
                    and t4.order_status in (1, 2) then t4.original_order_id
                    else null
                end
            ) Vaild_Promotional_Paid_Users,
            0 as Active_valid_paid_users,
            0 as Active_valid_trial_users,
            0 as Active_Vaild_Standard_Paid_Users,
            0 as Active_Vaild_Promotional_Paid_Users,
            0 as Paid_users,
            0 as Trial_users,
            0 as Trial_to_pay_users,
            0 as New_paid_users,
            0 as New_paid_revenue,
            0 as Renewal_users,
            0 as Renewal_revenue,
            0 as New_return_users,
            0 as New_return_revenue,
            0 as VAS,
            0 as CM,
            0 as Promotional_paid_users,
            0 as Promotional_paid_revenue,
            0 as Promotional_to_standard_paid_users
        from
            (
                select
                    distinct event_month,
                    app_id,
                    platform,
                    uuid,
                    original_order_id,
                    order_id,
                    order_status,
                    offer_method,
                    last_sku_offer_method,
                    country,
                    is_ua,
                    user_source
                from
                    dws_trial_subscription_retention_valid_month
                where
                    event_month = date_sub(
                        date_trunc(cal_date, month),
                        interval start month
                    )
            ) t4
        group by
            1,
            2,
            3,
            4,
            5,
            6
    ),
    no_all_country_4 as (
        select
            event_month,
            app_id as app_name,
            platform,
            country,
            is_ua,
            user_source,
            0 as MAU,
            0 as uuid_MAU,
            0 as MNU,
            0 as Valid_trial_users,
            0 as Valid_paid_users,
            0 as Vaild_Standard_Paid_Users,
            0 as Vaild_Promotional_Paid_Users,
            0 as Active_valid_paid_users,
            0 as Active_valid_trial_users,
            0 as Active_Vaild_Standard_Paid_Users,
            0 as Active_Vaild_Promotional_Paid_Users,
             count(
                distinct case
                    when t3.order_status in (1, 2) then t3.original_order_id
                    else null
                end
            ) as Paid_users,
            0 as Trial_users,
            0 as Trial_to_pay_users,
            0 as New_paid_users,
            0 as New_paid_revenue,
            0 as Renewal_users,
            0 as Renewal_revenue,
            0 as New_return_users,
            0 as New_return_revenue,
            0 as VAS,
            0 as CM,
            0 as Promotional_paid_users,
            0 as Promotional_paid_revenue,
            0 as Promotional_to_standard_paid_users
        from
            (
               select
                    *,
                    date_trunc(standard_order_date, month) event_month
                from
                    app_subscription_order
                where
                    date_trunc(standard_order_date, month) = date_sub(
                        date_trunc(cal_date, month),
                        interval start month
                    ) and  concat(original_order_id ,order_id) not in (select concat(original_order_id,order_id) from  app_subscription_order where order_status = 3 )
            ) t3
        group by
            1,
            2,
            3,
            4,
            5,
            6
    ),
    -- 到country粒度登陆活跃指标
         login_active as (
            select
            event_month,
            app_name,
            platform,
            country,
            is_ua,
            is_ua as user_source,
            0 as MAU,
            0 as uuid_MAU,
            0 as MNU,
            0 as Valid_trial_users,
            0 as Valid_paid_users,
            0 as Vaild_Standard_Paid_Users,
            0 as Vaild_Promotional_Paid_Users,
            0 as Active_valid_paid_users,
            0 as Active_valid_trial_users,
            0 as Active_Vaild_Standard_Paid_Users,
            0 as Active_Vaild_Promotional_Paid_Users,
            0 as Paid_users,
            0 as Trial_users,
            0 as Trial_to_pay_users,
            0 as New_paid_users,
            0 as New_paid_revenue,
            0 as Renewal_users,
            0 as Renewal_revenue,
            0 as New_return_users,
            0 as New_return_revenue,
            0 as VAS,
            0 as CM,
            0 as Promotional_paid_users,
            0 as Promotional_paid_revenue,
            0 as Promotional_to_standard_paid_users,
            0 as Sign_users,
            count(distinct login_id) as Login_active_users
        from (

            select
                date_trunc(event_date, month) as event_month,
                app_name,
                platform,
                country,
                login_id,
                max(is_ua) as is_ua
            from
                `dataintegration-265403.dwd.dwd_dzp_login_platform_active`
            where
                date_trunc(event_date, month) = date_sub(
                    date_trunc(cal_date, month),
                    interval start month
                )
                and is_app=1
            group by
                date_trunc(event_date, month),
                app_name,
                platform,
                country,
                login_id
            )login_active
        group by
            event_month,
            app_name,
            platform,
            country,
            is_ua,
            is_ua
        )
select
    event_month,
    app_name,
    platform,
    country,
    is_ua,
    user_source,
    sum(MAU) MAU,
    sum(uuid_MAU) uuid_MAU,
    sum(MNU) MNU,
    sum(Valid_trial_users) Valid_trial_users,
    sum(Valid_paid_users) Valid_paid_users,
    sum(Vaild_Standard_Paid_Users) Vaild_Standard_Paid_Users,
    sum(Vaild_Promotional_Paid_Users) Vaild_Promotional_Paid_Users,
    sum(Active_valid_paid_users) Active_valid_paid_users,
    sum(Active_valid_trial_users) Active_valid_trial_users,
    sum(Trial_users) Trial_users,
    sum(Paid_users) Paid_users,
    sum(New_paid_users) New_paid_users,
    sum(New_paid_revenue) New_paid_revenue,
    sum(Renewal_users) Renewal_users,
    sum(Renewal_revenue) Renewal_revenue,
    sum(New_return_users) New_return_users,
    sum(New_return_revenue) New_return_revenue,
    sum(Promotional_paid_users) Promotional_paid_users,
    sum(Promotional_paid_revenue) Promotional_paid_revenue,
    sum(Trial_to_pay_users) Trial_to_paid_users,
    sum(Promotional_to_standard_paid_users) Promotional_to_standard_paid_users,
    sum(VAS) VAS,
    sum(CM) CM,
    sum(Sign_users) as Sign_users,
    sum(Login_active_users) as Login_active_users
from
    (
        select
            event_month,
            app_name,
            platform,
            'all' as country,
            is_ua,
            user_source,
            sum(MAU) MAU,
            0 as uuid_MAU,
            sum(MNU) MNU,
            0 as Valid_trial_users,
            0 as Valid_paid_users,
            0 as Vaild_Standard_Paid_Users,
            0 as Vaild_Promotional_Paid_Users,
            0 as Active_valid_paid_users,
            0 as Active_valid_trial_users,
            0 as Active_Vaild_Standard_Paid_Users,
            0 as Active_Vaild_Promotional_Paid_Users,
            0 as Paid_users,
            0 as Trial_users,
            0 as Trial_to_pay_users,
            0 as New_paid_users,
            0 as New_paid_revenue,
            0 as Renewal_users,
            0 as Renewal_revenue,
            0 as New_return_users,
            0 as New_return_revenue,
            0 as VAS,
            0 as CM,
            0 as Promotional_paid_users,
            0 as Promotional_paid_revenue,
            0 as Promotional_to_standard_paid_users,
            0 as Sign_users,
            0 as Login_active_users
        from
            no_all_country_2
        group by
            1,
            2,
            3,
            4,
            5,
            6
        union
        all
        select
            *,
            0 as Sign_users,
            0 as Login_active_users
        from
            no_all_country_2
        union
        all
        select
            COALESCE(t1.event_month, t2.event_month) as event_month,
            COALESCE(t1.app_name, t2.app_id) as app_name,
            COALESCE(t1.platform, t2.platform) as platform,
            COALESCE(t1.country, t2.country) as country,
            COALESCE(t1.is_ua, t2.is_ua) as is_ua,
            COALESCE(t1.user_source, t2.user_source) as user_source,
            0 as MAU,
            count(distinct t1.uuid) as uuid_MAU,
            0 as MNU --,count(distinct t1.user_pseudo_id) MAU
            --,count(distinct t1.uuid) uuid_MAU
            --,count(distinct case when t1.is_new = 1 then t1.user_pseudo_id else null end)  MNU
,
            0 as Valid_trial_users,
            0 as Valid_paid_users,
            0 as Vaild_Standard_Paid_Users,
            0 as Vaild_Promotional_Paid_Users,
            count(
                distinct case
                    when t1.uuid is not null
                    and t2.uuid is not null
                    and t2.order_status in (1, 2) then t2.original_order_id
                    else null
                end
            ) as Active_valid_paid_users --活跃且订阅有效期的用户,用uuid 计算
            --这里统计口径是user_pseudo_id，需要修改为original_order_id
            --,count(distinct case when t1.uuid is not null and t2.uuid is not null and t2.order_status in (0)  then t1.user_pseudo_id else null end) Active_valid_trial_users
,
            count(
                distinct case
                    when t1.uuid is not null
                    and t2.uuid is not null
                    and t2.order_status in (0) then t2.original_order_id
                    else null
                end
            ) Active_valid_trial_users,
            count(
                distinct case
                    when t1.uuid is not null
                    and t2.uuid is not null
                    and t2.offer_method in ('normal')
                    and t2.order_status in (1, 2) then t2.original_order_id
                    else null
                end
            ) Active_Vaild_Standard_Paid_Users,
            count(
                distinct case
                    when t1.uuid is not null
                    and t2.uuid is not null
                    and t2.offer_method not in('trial', 'normal')
                    and t2.order_status in (1, 2) then t2.original_order_id
                    else null
                end
            ) Active_Vaild_Promotional_Paid_Users,
            0 as Paid_users,
            0 as Trial_users,
            0 as Trial_to_pay_users,
            0 as New_paid_users,
            0 as New_paid_revenue,
            0 as Renewal_users,
            0 as Renewal_revenue,
            0 as New_return_users,
            0 as New_return_revenue,
            0 as VAS,
            0 as CM,
            0 as Promotional_paid_users,
            0 as Promotional_paid_revenue,
            0 as Promotional_to_standard_paid_users,
            0 as Sign_users,
            0 as Login_active_users
        from
            (
                select
                    a.event_month,
                    a.user_pseudo_id,
                    a.uuid,
                    a.app_name,
                    a.platform,
                    a.country,
                    a.is_new,
                    a.is_ua,
                    a.user_source
                from
                    dws_act_subscription_month_uuid_rank a
                    left join unnormal_uuid b on a.uuid = b.uuid
                where
                    a.uuid_rk <= 5
                    and b.uuid is null
                    and event_month = date_sub(
                        date_trunc(cal_date, month),
                        interval start month
                    )
            ) t1 full
            outer join (
                select
                    distinct event_month,
                    app_id,
                    platform,
                    uuid,
                    original_order_id,
                    order_id,
                    order_status,
                    offer_method,
                    last_sku_offer_method,
                    country,
                    is_ua,
                    user_source
                from
                    dws_trial_subscription_retention_valid_month
                where
                    event_month = date_sub(
                        date_trunc(cal_date, month),
                        interval start month
                    )
            ) t2 on t1.uuid = t2.uuid
            and t1.event_month = t2.event_month
            and t1.app_name = t2.app_id
            and t1.platform = t2.platform
        group by
            1,
            2,
            3,
            4,
            5,
            6
        union
        all
        select
            COALESCE(t1.event_month, t2.event_month) as event_month,
            COALESCE(t1.app_name, t2.app_id) as app_name,
            COALESCE(t1.platform, t2.platform) as platform,
            'all' as country,
            COALESCE(t1.is_ua, t2.is_ua) as is_ua,
            COALESCE(t1.user_source, t2.user_source) as user_source,
            0 as MAU,
            count(distinct t1.uuid) as uuid_MAU,
            0 as MNU --,count(distinct t1.user_pseudo_id) MAU
            --,count(distinct t1.uuid) uuid_MAU
            --,count(distinct case when t1.is_new = 1 then t1.user_pseudo_id else null end)  MNU
,
            0 as Valid_trial_users,
            0 as Valid_paid_users,
            0 as Vaild_Standard_Paid_Users,
            0 as Vaild_Promotional_Paid_Users,
            count(
                distinct case
                    when t1.uuid is not null
                    and t2.uuid is not null
                    and t2.order_status in (1, 2) then t2.original_order_id
                    else null
                end
            ) as Active_valid_paid_users --活跃且订阅有效期的用户,用uuid 计算
            --这里统计口径是user_pseudo_id，需要修改为original_order_id
            --,count(distinct case when t1.uuid is not null and t2.uuid is not null and t2.order_status in (0)  then t1.user_pseudo_id else null end) Active_valid_trial_users
,
            count(
                distinct case
                    when t1.uuid is not null
                    and t2.uuid is not null
                    and t2.order_status in (0) then t2.original_order_id
                    else null
                end
            ) Active_valid_trial_users,
            count(
                distinct case
                    when t1.uuid is not null
                    and t2.uuid is not null
                    and t2.offer_method in ('normal')
                    and t2.order_status in (1, 2) then t2.original_order_id
                    else null
                end
            ) Active_Vaild_Standard_Paid_Users,
            count(
                distinct case
                    when t1.uuid is not null
                    and t2.uuid is not null
                    and t2.offer_method not in('trial', 'normal')
                    and t2.order_status in (1, 2) then t2.original_order_id
                    else null
                end
            ) Active_Valid_Promotional_Paid_Users,
            0 as Paid_users,
            0 as Trial_users,
            0 as Trial_to_pay_users,
            0 as New_paid_users,
            0 as New_paid_revenue,
            0 as Renewal_users,
            0 as Renewal_revenue,
            0 as New_return_users,
            0 as New_return_revenue,
            0 as VAS,
            0 as CM,
            0 as Promotional_paid_users,
            0 as Promotional_paid_revenue,
            0 as Promotional_to_standard_paid_users,
            0 as Sign_users,
            0 as Login_active_users
        from
            (
                select
                    a.event_month,
                    a.user_pseudo_id,
                    a.uuid,
                    a.app_name,
                    a.platform,
                    a.country,
                    a.is_new,
                    a.is_ua,
                    a.user_source
                from
                    dws_act_subscription_month_uuid_rank a
                    left join unnormal_uuid b on a.uuid = b.uuid
                where
                    a.uuid_rk = 1
                    and b.uuid is null
                    and event_month = date_sub(
                        date_trunc(cal_date, month),
                        interval start month
                    )
            ) t1 full
            outer join (
                select
                    distinct event_month,
                    app_id,
                    platform,
                    uuid,
                    original_order_id,
                    order_id,
                    order_status,
                    offer_method,
                    last_sku_offer_method,
                    country,
                    is_ua,
                    user_source
                from
                    dws_trial_subscription_retention_valid_month
                where
                    event_month = date_sub(
                        date_trunc(cal_date, month),
                        interval start month
                    )
            ) t2 on t1.uuid = t2.uuid
            and t1.event_month = t2.event_month
            and t1.app_name = t2.app_id
            and t1.platform = t2.platform
        group by
            1,
            2,
            3,
            4,
            5,
            6
        union
        all
        select
            event_month,
            app_name,
            platform,
            'all' as country,
            is_ua,
            user_source,
            0 as MAU,
            0 as uuid_MAU,
            0 as MNU,
            sum(Valid_trial_users) as Valid_trial_users,
            sum(Valid_paid_users) as Valid_paid_users,
            sum(Vaild_Standard_Paid_Users) as Vaild_Standard_Paid_Users,
            sum(Vaild_Promotional_Paid_Users) as Vaild_Promotional_Paid_Users,
            0 as Active_valid_paid_users,
            0 as Active_valid_trial_users,
            0 as Active_Vaild_Standard_Paid_Users,
            0 as Active_Vaild_Promotional_Paid_Users,
            0 as Paid_users,
            0 as Trial_users,
            0 as Trial_to_pay_users,
            0 as New_paid_users,
            0 as New_paid_revenue,
            0 as Renewal_users,
            0 as Renewal_revenue,
            0 as New_return_users,
            0 as New_return_revenue,
            0 as VAS,
            0 as CM,
            0 as Promotional_paid_users,
            0 as Promotional_paid_revenue,
            0 as Promotional_to_standard_paid_users,
            0 as Sign_users,
            0 as Login_active_users
        from
            no_all_country_3
        group by
            1,
            2,
            3,
            4,
            5,
            6
        union
        all
        select
            *,
            0 as Sign_users,
            0 as Login_active_users
        from
            no_all_country_3

        union
        all
        select
            event_month,
            app_name,
            platform,
            'all' as country,
            is_ua,
            user_source,
            0 as MAU,
            0 as uuid_MAU,
            0 as MNU,
            0 as Valid_trial_users,
            0 as Valid_paid_users,
            0 as Vaild_Standard_Paid_Users,
            0 as Vaild_Promotional_Paid_Users,
            0 as Active_valid_paid_users,
            0 as Active_valid_trial_users,
            0 as Active_Vaild_Standard_Paid_Users,
            0 as Active_Vaild_Promotional_Paid_Users,
            sum(Paid_users) as Paid_users,
            0 as Trial_users,
            0 as Trial_to_pay_users,
            0 as New_paid_users,
            0 as New_paid_revenue,
            0 as Renewal_users,
            0 as Renewal_revenue,
            0 as New_return_users,
            0 as New_return_revenue,
            0 as VAS,
            0 as CM,
            0 as Promotional_paid_users,
            0 as Promotional_paid_revenue,
            0 as Promotional_to_standard_paid_users,
            0 as Sign_users,
            0 as Login_active_users
        from
            no_all_country_4
        group by
            1,
            2,
            3,
            4,
            5,
            6
        union
        all
        select
            *,
            0 as Sign_users,
            0 as Login_active_users
        from
            no_all_country_4

        union
        all

        select
            a.event_month,
            a.app_name,
            a.platform,
            'all' as country,
            a.is_ua,
            a.user_source,
            0 as MAU,
            0 as uuid_MAU,
            0 as MNU,
            0 as Valid_trial_users,
            0 as Valid_paid_users,
            0 as Vaild_Standard_Paid_Users,
            0 as Vaild_Promotional_Paid_Users,
            0 as Active_valid_paid_users,
            0 as Active_valid_trial_users,
            0 as Active_Vaild_Standard_Paid_Users,
            0 as Active_Vaild_Promotional_Paid_Users,
            sum(a.Paid_users) as Paid_users,
            sum(a.Trial_users) as Trial_users,
            sum(a.Trial_to_pay_users) as Trial_to_pay_users,
            sum(a.New_paid_users) as New_paid_users,
            sum(a.New_paid_revenue) as New_paid_revenue,
            sum(a.Renewal_users) as Renewal_users,
            sum(a.Renewal_revenue) as Renewal_revenue,
            sum(a.New_return_users) as New_return_users,
            sum(a.New_return_revenue) as New_return_revenue,
            sum(a.VAS) as VAS,
            sum(a.CM) as CM,
            sum(a.Promotional_paid_users) as Promotional_paid_users,
            sum(a.Promotional_paid_revenue) as Promotional_paid_revenue,
            sum(a.Promotional_to_standard_paid_users) as Promotional_to_standard_paid_users,
            0 as Sign_users,
            0 as Login_active_users
        from
            no_all_country_1 a
        group by
            1,
            2,
            3,
            4,
            5,
            6
        union
        all
        select
            *,
            0 as Sign_users,
            0 as Login_active_users
        from
            no_all_country_1
        union
        all
        select
            date_trunc(event_date, month) as event_month,
            app_name,
            first_platform as platform,
            country,
            is_ua,
            is_ua as user_source,
            0 as MAU,
            0 as uuid_MAU,
            0 as MNU,
            0 as Valid_trial_users,
            0 as Valid_paid_users,
            0 as Vaild_Standard_Paid_Users,
            0 as Vaild_Promotional_Paid_Users,
            0 as Active_valid_paid_users,
            0 as Active_valid_trial_users,
            0 as Active_Vaild_Standard_Paid_Users,
            0 as Active_Vaild_Promotional_Paid_Users,
            0 as Paid_users,
            0 as Trial_users,
            0 as Trial_to_pay_users,
            0 as New_paid_users,
            0 as New_paid_revenue,
            0 as Renewal_users,
            0 as Renewal_revenue,
            0 as New_return_users,
            0 as New_return_revenue,
            0 as VAS,
            0 as CM,
            0 as Promotional_paid_users,
            0 as Promotional_paid_revenue,
            0 as Promotional_to_standard_paid_users,
            count(distinct login_id) as Sign_users,
            0 as Login_active_users
        from
            `airbrush-1324.dim.dim_da_account_sign_user`
        where
            date_trunc(event_date, month) = date_sub(
                date_trunc(cal_date, month),
                interval start month
            )
        group by
            date_trunc(event_date, month),
            app_name,
            first_platform,
            country,
            is_ua,
            is_ua
        union
        all
        select
            date_trunc(event_date, month) as event_month,
            app_name,
            first_platform as platform,
            'all' as country,
            is_ua,
            is_ua as user_source,
            0 as MAU,
            0 as uuid_MAU,
            0 as MNU,
            0 as Valid_trial_users,
            0 as Valid_paid_users,
            0 as Vaild_Standard_Paid_Users,
            0 as Vaild_Promotional_Paid_Users,
            0 as Active_valid_paid_users,
            0 as Active_valid_trial_users,
            0 as Active_Vaild_Standard_Paid_Users,
            0 as Active_Vaild_Promotional_Paid_Users,
            0 as Paid_users,
            0 as Trial_users,
            0 as Trial_to_pay_users,
            0 as New_paid_users,
            0 as New_paid_revenue,
            0 as Renewal_users,
            0 as Renewal_revenue,
            0 as New_return_users,
            0 as New_return_revenue,
            0 as VAS,
            0 as CM,
            0 as Promotional_paid_users,
            0 as Promotional_paid_revenue,
            0 as Promotional_to_standard_paid_users,
            count(distinct login_id) as Sign_users,
            0 as Login_active_users
        from
            `airbrush-1324.dim.dim_da_account_sign_user`
        where
            date_trunc(event_date, month) = date_sub(
                date_trunc(cal_date, month),
                interval start month
            )
        group by
            date_trunc(event_date, month),
            app_name,
            first_platform,
            is_ua,
            is_ua

        union
        all

        select * from login_active --到country粒度登陆活跃用户数
        union all
        -- 非country登陆活跃用户数
        select
            event_month,
            app_name,
            platform,
            'all' as country,
            is_ua,
            is_ua as user_source,
            0 as MAU,
            0 as uuid_MAU,
            0 as MNU,
            0 as Valid_trial_users,
            0 as Valid_paid_users,
            0 as Vaild_Standard_Paid_Users,
            0 as Vaild_Promotional_Paid_Users,
            0 as Active_valid_paid_users,
            0 as Active_valid_trial_users,
            0 as Active_Vaild_Standard_Paid_Users,
            0 as Active_Vaild_Promotional_Paid_Users,
            0 as Paid_users,
            0 as Trial_users,
            0 as Trial_to_pay_users,
            0 as New_paid_users,
            0 as New_paid_revenue,
            0 as Renewal_users,
            0 as Renewal_revenue,
            0 as New_return_users,
            0 as New_return_revenue,
            0 as VAS,
            0 as CM,
            0 as Promotional_paid_users,
            0 as Promotional_paid_revenue,
            0 as Promotional_to_standard_paid_users,
            0 as Sign_users,
            sum(Login_active_users) as Login_active_users
        from login_active
        group by
            event_month,
            app_name,
            platform,
            is_ua,
            is_ua



    ) t
group by
    1,
    2,
    3,
    4,
    5,
    6;

