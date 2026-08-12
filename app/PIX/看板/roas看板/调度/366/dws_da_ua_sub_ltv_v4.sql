delete from `dataintegration-265403.roas_dataset_v4.dws_da_ua_sub_ltv_v4` where 1=1;
insert into `dataintegration-265403.roas_dataset_v4.dws_da_ua_sub_ltv_v4`
with  sub as
(
SELECT
app_id, platform, country, Media_Source, Campaign, Campaign_ID, Ad_Group, Ad_Group_ID, Keywords,Keyword_ID, Site_ID, IOS_OS_Version, Attributed_Touch_Time as install_date,standard_order_date as  order_date, sub_event, subscription_period, sku_is_trial, count(original_order_id) as uv,sum(payment_price_usd) as revenue
FROM `dataintegration-265403.roas_dataset_v4.dwd_da_ua_sub_event_v4`
group by 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17

union all

SELECT
app_id, platform, country, Media_Source, Campaign, Campaign_ID, Ad_Group, Ad_Group_ID, Keywords,Keyword_ID, Site_ID, IOS_OS_Version, Attributed_Touch_Time as install_date,standard_order_date as  order_date, sub_event, subscription_period, sku_is_trial, count(original_order_id) as uv,sum(payment_price_usd) as revenue
FROM `dataintegration-265403.roas_dataset_v4.dwd_da_ua_sub_cr_v4`
group by 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17

union all

SELECT
app_id, platform, country, Media_Source, Campaign, Campaign_ID, Ad_Group, Ad_Group_ID, Keywords,Keyword_ID, Site_ID, IOS_OS_Version, Attributed_Touch_Time as install_date,standard_order_date as  order_date, sub_event, subscription_period, sku_is_trial, count(original_order_id) as uv,sum(payment_price_usd) as revenue
FROM `dataintegration-265403.roas_dataset_v4.dwd_da_ua_consumables_event_v4`
group by 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17

),
date_t as
(
    select
    app_id, platform, country, Media_Source, Campaign, Campaign_ID, Ad_Group, Ad_Group_ID, Keywords, Keyword_ID, Site_ID, IOS_OS_Version, install_date, sub_event, subscription_period, sku_is_trial,Attributed_Touch_Date
    from
    (
    SELECT distinct app_id, platform, country,Media_Source, Campaign, Campaign_ID, Ad_Group, Ad_Group_ID, Keywords, Keyword_ID, Site_ID, IOS_OS_Version, install_date, sub_event, subscription_period, sku_is_trial
    FROM sub
    )a
    cross join
    (
    SELECT distinct Attributed_Touch_Date_hk AS Attributed_Touch_Date FROM `dataintegration-265403.roas_dataset.dwd_dz_af_ua_info`
 where Attributed_Touch_Date>='2020-08-01'
    )b
),
forecast as (
  select * from  `dataintegration-265403.roas_dataset_v4.dws_da_ua_forecast_revenue_every_day_v4`
)
select
          app_id as App_Name,
          platform as Platform,
          country as Country,
          Media_Source,
          Campaign,
          Campaign_ID,
          Ad_Group,
          Ad_Group_ID,
          Keywords,
          Keyword_ID,
          Site_ID,
          IOS_OS_Version,
          install_date as Date,
          order_date,
          subscription_period,
          case when sku_is_trial in ('has_trial') then 'Have trial' else 'No trial' end as sku_is_trial,

          IFNULL(sum(case when sub_event in ('install_first_time_sub') then uv_sum end),0) as install_first_time_sub_uv,
          IFNULL(sum(case when sub_event in ('install_first_time_sub_to_paid') then uv_sum end),0) as install_first_time_sub_to_paid_uv,
          IFNULL(sum(case when sub_event in ('install_first_time_sub_to_standard_paid') then uv_sum end),0) as install_first_time_sub_to_standard_paid_uv,

          IFNULL(sum(case when sub_event in ('install_first_sub_is_trial') then uv_sum end),0) as install_first_sub_is_trial_uv,
          IFNULL(sum(case when sub_event in ('install_first_sub_is_trial_to_paid') then uv_sum end),0) as install_first_sub_is_trial_to_paid_uv,
          IFNULL(sum(case when sub_event in ('install_first_time_trial_to_standard_paid') then uv_sum end),0) as install_first_time_trial_to_standard_paid_uv,

          IFNULL(sum(case when sub_event in ('install_first_sub_is_promotional') then uv_sum end),0) as install_first_sub_is_promotional_uv,
          IFNULL(sum(case when sub_event in ('install_first_sub_is_promotional_to_paid') then uv_sum end),0) as install_first_sub_is_promotional_to_paid_uv,
          IFNULL(sum(case when sub_event in ('install_first_sub_is_promotional_to_standard_paid') then uv_sum end),0) as install_first_sub_is_promotional_to_standard_paid_uv,--补充一个优惠价到标准价的追踪，目前还没有

          IFNULL(sum(case when sub_event in ('install_first_sub_is_standard') then uv_sum end),0) as install_first_sub_is_standard_uv,

          IFNULL(sum(case when sub_event in ('promotional_paid_revenue') then revenue_sum end),0) as promotional_paid_revenue,
          IFNULL(sum(case when sub_event in ('standard_paid_revenue') then revenue_sum end),0)  as standard_paid_revenue,
          IFNULL(sum(case when sub_event in ('sub_revenue') then revenue_sum end),0) as sub_revenue,
          IFNULL(sum(case when sub_event in ('forecast_revenue','sub_revenue_365','consumables_revenue_365') then revenue_sum end),0)  as forecast_revenue, ---加上单购的收入

          IFNULL(sum(case when sub_event in ('install_first_consumables_paid') then uv_sum end),0) as install_first_consumables_paid_uv,
          IFNULL(sum(case when sub_event in ('consumables_revenue') then revenue_sum end),0) as consumables_revenue,
          IFNULL(sum(case when sub_event in ('install_first_purchase') then uv_sum end),0) as install_first_purchase_uv,
          IFNULL(sum(case when sub_event in ('install_first_paid') then uv_sum end),0) as install_first_paid_uv,
          IFNULL(sum(case when sub_event in ('sub_revenue','consumables_revenue') then revenue_sum end),0)  as revenue

from
(
  select
  e.app_id, e.platform, e.country, e.Media_Source, e.Campaign,  e.Campaign_ID, e.Ad_Group, e.Ad_Group_ID, e.Keywords, e.Keyword_ID, e.Site_ID, e.IOS_OS_Version, e.install_date, e.order_date,
  e.sub_event, e.subscription_period, e.sku_is_trial, e.uv_sum, e.revenue_sum
  from
    (
    SELECT
        c.app_id, c.platform, c.country, c.Media_Source, c.Campaign, c.Campaign_ID, c.Ad_Group, c.Ad_Group_ID, c.Keywords, c.Keyword_ID, c.Site_ID, c.IOS_OS_Version, c.install_date, c.order_date,
        c.sub_event, c.subscription_period, c.sku_is_trial, sum(c.uv) as uv, sum(c.revenue) as revenue,
        sum(sum(c.uv))  OVER (partition by  c.app_id, c.platform, c.country, c.Media_Source, c.Campaign, c.Campaign_ID, c.Ad_Group, c.Ad_Group_ID, c.Keywords, c.Keyword_ID, c.Site_ID, c.IOS_OS_Version, c.install_date,
        c.sub_event, c.subscription_period, c.sku_is_trial
         ORDER BY c.order_date ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS uv_sum,
         sum(sum(c.revenue))  OVER (partition by  c.app_id, c.platform, c.country, c.Media_Source, c.Campaign, c.Campaign_ID, c.Ad_Group, c.Ad_Group_ID, c.Keywords, c.Keyword_ID, c.Site_ID, c.IOS_OS_Version, c.install_date,
        c.sub_event, c.subscription_period, c.sku_is_trial
         ORDER BY c.order_date ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS revenue_sum
        from
        (
        select
        d.app_id, d.platform, d.country, d.Media_Source, d.Campaign, d.Campaign_ID, d.Ad_Group, d.Ad_Group_ID, d.Keywords, d.Keyword_ID, d.Site_ID, d.IOS_OS_Version, d.install_date, d.Attributed_Touch_Date as order_date,
        d.sub_event, d.subscription_period, d.sku_is_trial,t.uv,t.revenue
        from
        date_t d
        full join sub t
        on d.app_id=t.app_id and d.platform=t.platform and d.install_date=t.install_date and d.Attributed_Touch_Date=t.order_date
        and IFNULL(d.country,'-')= IFNULL(t.country,'-') and IFNULL(d.Media_Source,'-')=IFNULL(t.Media_Source,'-') and IFNULL(d.Campaign,'-')=IFNULL(t.Campaign,'-')
        and IFNULL(d.Keywords,'-')= IFNULL(t.Keywords,'-') and IFNULL(d.Site_ID,'-')=IFNULL(t.Site_ID,'-') and IFNULL(d.IOS_OS_Version,'-')=IFNULL(t.IOS_OS_Version,'-')
        and IFNULL(d.sub_event,'-')= IFNULL(t.sub_event,'-') and IFNULL(d.subscription_period,'-')=IFNULL(t.subscription_period,'-') and IFNULL(d.sku_is_trial,'-')=IFNULL(t.sku_is_trial,'-')
        and IFNULL(d.Campaign_ID,'-')=IFNULL(t.Campaign_ID,'-') and IFNULL(d.Ad_Group,'-')=IFNULL(t.Ad_Group,'-') and IFNULL(d.Ad_Group_ID,'-')=IFNULL(t.Ad_Group_ID,'-') and IFNULL(d.Keyword_ID,'-')=IFNULL(t.Keyword_ID,'-')
        )c
        group by c.app_id, c.platform, c.country, c.Media_Source, c.Campaign, c.Campaign_ID, c.Ad_Group, c.Ad_Group_ID, c.Keywords, c.Keyword_ID, c.Site_ID, c.IOS_OS_Version, c.install_date, c.order_date,
        c.sub_event, c.subscription_period, c.sku_is_trial
     )e

   UNION  ALL

   SELECT app_id, platform, country, Media_Source, Campaign,  Campaign_ID, Ad_Group, Ad_Group_ID, Keywords, Keyword_ID, Site_ID, IOS_OS_Version, install_date, order_date, sub_event, subscription_period, sku_is_trial, uv as uv_sum, revenue  as revenue_sum
   FROM forecast
)
 where subscription_period not in ('inapp')
 and install_date>='2020-08-01'--上线后时间限制去掉
 group by
    app_id,
          platform,
          country,
          Media_Source,
          Campaign,
          Campaign_ID,
          Ad_Group,
          Ad_Group_ID,
          Keywords,
          Keyword_ID,
          Site_ID,
          IOS_OS_Version,
          install_date,
          order_date,
          subscription_period,
          sku_is_trial
