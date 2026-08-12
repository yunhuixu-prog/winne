        select
            *,
            date_sub(
                date_trunc(current_date, month),
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
                        else standard_order_expire_date
                    end order_expire_date
                from
                    `dataintegration-265403.subscription.dwd_trial_subscription_retention_daily_temp`
                where
                    concat(app_id, '-', original_order_id, '-', order_id) not in (
                        select
                            distinct concat(app_id, '-', original_order_id, '-', order_id)
                        from
                            `dataintegration-265403.subscription.dwd_trial_subscription_retention_daily_temp`
                        where
                            subscription_user_type = 'refund' --and (date_trunc(standard_order_date,month) = date_sub(date_trunc(current_date, month),interval start month) or date_trunc(standard_order_expire_date,month) = date_sub(date_trunc(current_date, month),interval start month))
                    ) --and original_order_id='60001131175143' -- 计算vlaid排除退款用户
                    and date_trunc(
                        case
                            when subscription_period = 'lifetime' then current_date
                            else standard_order_expire_date
                        end,
                        month
                    ) >= date_sub(
                        date_trunc(current_date, month),
                        interval start month
                    )
                    and date_trunc(standard_order_date, month) <= date_sub(
                        date_trunc(current_date, month),
                        interval start month
                    )
            ) t,
            unnest(
                generate_date_array(order_date, order_expire_date)
            ) as event_date
        where
            date_trunc(event_date, month) = date_sub(
                date_trunc(current_date, month),
                interval start month
            )