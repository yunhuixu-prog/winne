
DECLARE mDATE DATE DEFAULT '2024-09-01';

drop table if exists `dataintegration-265403.temp.temp_roas_evaluate_data`;
create table if not exists `dataintegration-265403.temp.temp_roas_evaluate_data` as

-- delete from  `dataintegration-265403.temp.temp_roas_evaluate_data`  where look_date=mDATE;
-- insert into `dataintegration-265403.temp.temp_roas_evaluate_data`

select
    new_forecast.look_date,
    detail.attributed_date,
    detail.attributed_id_type,
    detail.app_name,
    -- detail.platform,
    -- detail.media_source,
    -- detail.campaign,
    -- detail.first_country,
    sum(sub_revenue) as sub_revenue,
    sum(consumables_revenue) as consumables_revenue,
    sum(no_order_forecast) as no_order_forecast,
    sum(has_order_forecast) as has_order_forecast
from
    (
        select
            attributed_id_type,
            uuid,
            app_name,
            attributed_date,
                sum(if(is_sub_order=1,payment_price_usd,0))                                                                 AS  sub_revenue
        ,   sum(if(is_consumables_order=1,payment_price_usd,0))                                                         AS  consumables_revenue,
            array_agg(distinct media_source ignore nulls) [0] as media_source,
            array_agg(distinct campaign ignore nulls) [0] as campaign,
            array_agg(distinct platform ignore nulls) [0] as platform,
            --少量uuid跨端
            array_agg(distinct first_country ignore nulls) [0] as first_country
        from
            `dataintegration-265403.dwd.dwd_dzp_roas_user_detail`
        where
            attributed_id <> '-1'
            and uuid is not null
            and app_name in ('AirBrush', 'BeautyPlus')
            and attributed_date > date_sub(mDATE, interval 1 year)
        group by
            1,
            2,
            3,
            4
    ) detail
  left  join (
        select
            date as look_date,
            types,
            app_name,
            attributed_touch_date as attributed_date,
            uuid,
            sum(
                case
                    when is_current_pay = 0 then predict_sub_revenue_att_365_from_now
                    else 0
                end
            ) as no_order_forecast,
            --没有订单用户的预测收入
            sum(
                case
                    when is_current_pay = 1 then predict_order_revenue
                    else 0
                end
            ) as has_order_forecast -- 有订单用户的预测收入
            -- *
        from
            `dataintegration-265403.roas.dws_dzp_roas_sub_365_from_att_predict` --该表t-2产出,关联前日数据作为昨日近似预测值
            -- 该表date即为观测日期
        where
            date = mDATE
        group by
            1,
            2,
            3,
            4,
            5
    ) new_forecast on detail.attributed_id_type = new_forecast.types
    and detail.app_name = new_forecast.app_name
    and detail.attributed_date = new_forecast.attributed_date
    and detail.uuid = new_forecast.uuid
group by
    1,
    2,
    3,
    4

;

select b.attributed_id_type,b.look_date date,b.attributed_date,date_diff(b.look_date,b.attributed_date,DAY) days,b.app_name
    ,round(b.no_order_forecast,2) no_order_forecast,round(b.has_order_forecast,2) has_order_forecast,c.sub_revenue,a.real_revenue
from
(
    select *
    from `dataintegration-265403.temp.temp_roas_evaluate_data`
    where look_date between '2023-01-01' and '2023-07-31'
) b
left join
(
    select App_Name,'new' types,Date attr_date,sum(install_uv),round(sum(forecast_revenue)) real_revenue
    from dataintegration-265403.roas_dataset_v2.ads_da_ua_roas_v2
    where Data='Daily New Report V5' and order_date='2024-09-01'
        -- and order_date between date_sub(date,interval 365 day) and date
        and date between '2022-01-01' and '2023-07-31'
        and App_name in ('BeautyPlus','AirBrush')
    group by 1,2,3

    union all

    select App_Name,'ua' types,Date attr_date,sum(install_uv),round(sum(forecast_revenue)) real_revenue
    from dataintegration-265403.roas_dataset_v2.ads_da_ua_roas_v2
    where Data='Daily Report V5' and order_date='2024-09-01'
        -- and order_date between date_sub(date,interval 365 day) and date
        and date between '2022-01-01' and '2023-07-31'
        and App_name in ('BeautyPlus','AirBrush')
    group by 1,2,3
) a
on a.App_Name=b.app_name and a.attr_date=b.attributed_date and a.types=b.attributed_id_type

left join
(
    select App_Name,'new' types,Date attr_date,order_date date,sum(install_uv),round(sum(sub_revenue)) sub_revenue
    from dataintegration-265403.roas_dataset_v2.ads_da_ua_roas_v2
    where Data='Daily New Report V5' and order_date between '2023-01-01' and '2023-07-31'
        -- and order_date between date_sub(date,interval 365 day) and date
        and date between '2022-01-01' and '2023-07-31'
        and App_name in ('BeautyPlus','AirBrush')
    group by 1,2,3,4

    union all

    select App_Name,'ua' types,Date attr_date,order_date date,sum(install_uv),round(sum(sub_revenue)) sub_revenue
    from dataintegration-265403.roas_dataset_v2.ads_da_ua_roas_v2
    where Data='Daily Report V5' and order_date between '2023-01-01' and '2023-07-31'
        -- and order_date between date_sub(date,interval 365 day) and date
        and date between '2022-01-01' and '2023-07-31'
        and App_name in ('BeautyPlus','AirBrush')
    group by 1,2,3,4
) c
on c.App_Name=b.app_name and c.attr_date=b.attributed_date and c.types=b.attributed_id_type and c.date=b.look_date
order by 1,4,2,3




-- 当前数据核查

select b.attributed_id_type,b.look_date date,b.attributed_date,date_diff(b.look_date,b.attributed_date,DAY) days,b.app_name
    ,round(b.no_order_forecast,2) no_order_forecast,round(b.has_order_forecast,2) has_order_forecast,c.sub_revenue
from
(
    select *
    from `dataintegration-265403.temp.temp_roas_evaluate_data`
    where look_date between '2024-09-01' and '2024-09-01'
        and app_name='AirBrush' and attributed_id_type='ua'
) b
left join
(
    select App_Name,'new' types,Date attr_date,order_date date,sum(install_uv),round(sum(sub_revenue)) sub_revenue
    from dataintegration-265403.roas_dataset_v2.ads_da_ua_roas_v2
    where Data='Daily New Report V5' and order_date = '2024-09-01'
        -- and order_date between date_sub(date,interval 365 day) and date
        and date between '2023-09-01' and '2024-09-01'
        and App_name in ('BeautyPlus','AirBrush')
    group by 1,2,3,4

    union all

    select App_Name,'ua' types,Date attr_date,order_date date,sum(install_uv),round(sum(sub_revenue)) sub_revenue
    from dataintegration-265403.roas_dataset_v2.ads_da_ua_roas_v2
    where Data='Daily Report V5' and order_date = '2024-09-01'
        -- and order_date between date_sub(date,interval 365 day) and date
        and date between '2023-09-01' and '2024-09-01'
        and App_name in ('BeautyPlus','AirBrush')
    group by 1,2,3,4
) c
on c.App_Name=b.app_name and c.attr_date=b.attributed_date and c.types=b.attributed_id_type and c.date=b.look_date
order by 1,4,2,3


SELECT
    attributed_id_type
,   attributed_date
,   sum(install_uv)                         AS  install
,   sum(dau)                                AS  dau
,   sum(dnu)                                AS  dnu
,   sum(amount)                             AS  cost
,   sum(ads_revenue)                        AS  ads_revenue
,   sum(install_first_purchase_uv)          AS  purchase
,   sum(install_first_paid_uv)              AS  paid
,   sum(sub_revenue+consumables_revenue)    AS  total_booking
,   sum(forecast_revenue)                   AS  fore
FROM
    `dataintegration-265403.roas.dws_dap_roas_look_date`
WHERE
    look_date           =   "2024-09-01"
AND app_name            =   'AirBrush'
AND attributed_id_type  =   'ua'            -- and first_country='United States'
AND is_skan             =   0
GROUP BY
    1
,   2
order BY    2   desc



