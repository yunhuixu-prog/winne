    --渠道用户订阅数据，维度到最小粒度Campaign,Campaign_ID,Ad_Group,Ad_Group_ID,Keywords, Keyword_ID,Site_ID,
delete from `dataintegration-265403.roas_dataset_v4.ads_da_ua_install_sub_v4` where 1=1;
insert into `dataintegration-265403.roas_dataset_v4.ads_da_ua_install_sub_v4`

with ua as (
select
App_Name,Platform,Country_Name,Media_Source,Campaign,Campaign_ID,Ad_Group,Ad_Group_ID,Keywords, Keyword_ID,Site_ID,IOS_OS_Version,Attributed_Touch_Date,order_date,install_uv,
--0 as install_first_time_trial_uv, 0 as install_first_time_paid_uv, 0 as install_first_time_trial_to_paid_uv, 0.0 as sub_revenue, 0.0 as forecast_revenue,0 as install_first_time_sub_uv
0 as install_first_time_sub_uv,
0 as install_first_time_sub_to_paid_uv,
0 as install_first_time_sub_to_standard_paid_uv,

0 as install_first_sub_is_trial_uv,
0 as install_first_sub_is_trial_to_paid_uv,
0 as install_first_time_trial_to_standard_paid_uv,

0 as install_first_sub_is_promotional_uv,
0 as install_first_sub_is_promotional_to_paid_uv,
0 as install_first_sub_is_promotional_to_standard_paid_uv,
0 as install_first_sub_is_standard_uv,

0 as promotional_paid_revenue,
0 as standard_paid_revenue,
0 as sub_revenue,
0 as forecast_revenue,

0 as install_first_consumables_paid_uv,
0 as consumables_revenue,
0 as install_first_purchase_uv,
0 as install_first_paid_uv,
0 as revenue
from
(
        SELECT
          App_Name,
          upper(Platform) as Platform,
          fix_firebase_en_name as Country_Name,
          Media_Source,
          Campaign,
          Campaign_ID,
          Ad_Group,
          Ad_Group_ID,
          Keywords,
          Keyword_ID,
          Site_ID,
          IOS_OS_Version,
          Attributed_Touch_Date_hk AS Attributed_Touch_Date,
          count (AppsFlyer_ID) as install_uv
        FROM
          `dataintegration-265403.roas_dataset.dwd_dz_af_ua_info`
          where  Attributed_Touch_Date_hk>='2020-08-01'
          group by
          App_Name,
          upper(Platform),
          fix_firebase_en_name,
          Media_Source,
          Campaign,
          Campaign_ID,
          Ad_Group,
          Ad_Group_ID,
          Keywords,
          Keyword_ID,
          Site_ID,
          IOS_OS_Version,
          Attributed_Touch_Date
    ) a
cross join
    (
    SELECT distinct Attributed_Touch_Date_hk AS order_date FROM `dataintegration-265403.roas_dataset.dwd_dz_af_ua_info`
    where Attributed_Touch_Date_hk>='2020-08-01'
    )b
)
    select
   c.App_Name,c.Platform,c.Country_Name as Country ,c.Media_Source,c.Campaign,c.Campaign_ID, c.Ad_Group, c.Ad_Group_ID, c.Keywords, c.Keyword_ID, c.Site_ID,c.IOS_OS_Version,c.Attributed_Touch_Date as Date,c.order_date,
   IFNULL(sum(c.install_uv), 0) as install_uv,
   /*IFNULL(sum(c.install_first_time_trial_uv), 0) as install_first_time_trial_uv,IFNULL(sum(c.install_first_time_paid_uv), 0) as install_first_time_paid_uv,
   IFNULL(sum(c.install_first_time_trial_to_paid_uv), 0) as install_first_time_trial_to_paid_uv,IFNULL(sum(c.sub_revenue), 0) as sub_revenue,IFNULL(sum(c.forecast_revenue), 0) as forecast_revenue,
   IFNULL(sum(c.install_first_time_sub_uv), 0) as install_first_time_sub_uv*/
      IFNULL(sum(c.install_first_time_sub_uv), 0) as install_first_time_sub_uv,
    IFNULL(sum(c.install_first_time_sub_to_paid_uv), 0) as install_first_time_sub_to_paid_uv,
    IFNULL(sum(c.install_first_time_sub_to_standard_paid_uv), 0) as install_first_time_sub_to_standard_paid_uv,

    IFNULL(sum(c.install_first_sub_is_trial_uv), 0) as install_first_sub_is_trial_uv,
    IFNULL(sum(c.install_first_sub_is_trial_to_paid_uv), 0) as install_first_sub_is_trial_to_paid_uv,
    IFNULL(sum(c.install_first_time_trial_to_standard_paid_uv), 0) as install_first_time_trial_to_standard_paid_uv,

    IFNULL(sum(c.install_first_sub_is_promotional_uv), 0) as install_first_sub_is_promotional_uv,
    IFNULL(sum(c.install_first_sub_is_promotional_to_paid_uv), 0) as install_first_sub_is_promotional_to_paid_uv,
    IFNULL(sum(c.install_first_sub_is_promotional_to_standard_paid_uv), 0) as install_first_sub_is_promotional_to_standard_paid_uv,
    IFNULL(sum(c.install_first_sub_is_standard_uv), 0) as install_first_sub_is_standard_uv,

    IFNULL(sum(c.promotional_paid_revenue), 0) as promotional_paid_revenue,
    IFNULL(sum(c.standard_paid_revenue), 0) as standard_paid_revenue,
    IFNULL(sum(c.sub_revenue), 0) as sub_revenue,
    IFNULL(sum(c.forecast_revenue), 0) as forecast_revenue,

    IFNULL(sum(c.install_first_consumables_paid_uv), 0) as install_first_consumables_paid_uv,
    IFNULL(sum(c.consumables_revenue), 0) as consumables_revenue,
    IFNULL(sum(c.install_first_purchase_uv), 0) as install_first_purchase_uv,
    IFNULL(sum(c.install_first_paid_uv), 0) as install_first_paid_uv,
    IFNULL(sum(c.revenue), 0) as revenue


    from
    (
        SELECT
         App_Name,Platform,Country_Name,Media_Source,Campaign,Campaign_ID,Ad_Group,Ad_Group_ID,Keywords,Keyword_ID,Site_ID,IOS_OS_Version,Attributed_Touch_Date,order_date,install_uv,
         --install_first_time_trial_uv, install_first_time_paid_uv, install_first_time_trial_to_paid_uv, sub_revenue, forecast_revenue,install_first_time_sub_uv
        install_first_time_sub_uv,
        install_first_time_sub_to_paid_uv,
        install_first_time_sub_to_standard_paid_uv,

        install_first_sub_is_trial_uv,
        install_first_sub_is_trial_to_paid_uv,
        install_first_time_trial_to_standard_paid_uv,

        install_first_sub_is_promotional_uv,
        install_first_sub_is_promotional_to_paid_uv,
        install_first_sub_is_promotional_to_standard_paid_uv,
        install_first_sub_is_standard_uv,

        promotional_paid_revenue,
        standard_paid_revenue,
        sub_revenue,
        forecast_revenue,

        install_first_consumables_paid_uv,
        consumables_revenue,
        install_first_purchase_uv,
        install_first_paid_uv,
        revenue
        FROM
          ua
          where  Attributed_Touch_Date>='2020-08-01'

       union all

        SELECT
          App_Name,
          Platform,
          Country as Country_Name,
          Media_Source,
          Campaign,
          Campaign_ID,
          Ad_Group,
          Ad_Group_ID,
          Keywords,
          Keyword_ID,
          Site_ID,
          IOS_OS_Version,
          Date as Attributed_Touch_Date,
          order_date,
          --subscription_period,
          --sku_is_trial,
          0 as install_uv,
          /*
          sum(install_first_time_trial_uv) as install_first_time_trial_uv,
          sum(install_first_time_paid_uv) as install_first_time_paid_uv,
          sum(install_first_time_trial_to_paid_uv) as install_first_time_trial_to_paid_uv,
          sum(sub_revenue) as sub_revenue,
          sum(forecast_revenue) as forecast_revenue,
          sum(install_first_time_sub_uv) as install_first_time_sub_uv
          */
        sum(install_first_time_sub_uv) as install_first_time_sub_uv,
        sum(install_first_time_sub_to_paid_uv) as install_first_time_sub_to_paid_uv,
        sum(install_first_time_sub_to_standard_paid_uv) as install_first_time_sub_to_standard_paid_uv,

        sum(install_first_sub_is_trial_uv) as install_first_sub_is_trial_uv,
        sum(install_first_sub_is_trial_to_paid_uv) as install_first_sub_is_trial_to_paid_uv,
        sum(install_first_time_trial_to_standard_paid_uv) as install_first_time_trial_to_standard_paid_uv,

        sum(install_first_sub_is_promotional_uv) as install_first_sub_is_promotional_uv,
        sum(install_first_sub_is_promotional_to_paid_uv) as install_first_sub_is_promotional_to_paid_uv,
        sum(install_first_sub_is_promotional_to_standard_paid_uv) as install_first_sub_is_promotional_to_standard_paid_uv,
        sum(install_first_sub_is_standard_uv) as install_first_sub_is_standard_uv,

        sum(promotional_paid_revenue) as promotional_paid_revenue,
        sum(standard_paid_revenue) as standard_paid_revenue,
        sum(sub_revenue) as sub_revenue,
        sum(forecast_revenue) as forecast_revenue,

        sum(install_first_consumables_paid_uv) as install_first_consumables_paid_uv,
        sum(consumables_revenue) as consumables_revenue,
        sum(install_first_purchase_uv) as install_first_purchase_uv,
        sum(install_first_paid_uv) as install_first_paid_uv,
        sum(revenue) as revenue

        FROM `dataintegration-265403.roas_dataset_v4.dws_da_ua_sub_ltv_v4`
        group by
          App_Name,
          Platform,
          Country,
          Media_Source,
          Campaign,
          Campaign_ID,
          Ad_Group,
          Ad_Group_ID,
          Keywords,
          Keyword_ID,
          Site_ID,
          IOS_OS_Version,
          Date ,
          order_date
    ) c

--where App_Name='BeautyPlus'
--and Attributed_Touch_Date='2020-12-25' and order_date='2021-02-01'
--and Platform in ('ANDROID') and Country_Name in ('India') and Media_Source in ('gionee') and Campaign in ('Preinstall')

group by
c.App_Name,c.Platform,c.Country_Name,c.Media_Source,c.Campaign,c.Campaign_ID, c.Ad_Group, c.Ad_Group_ID, c.Keywords, c.Keyword_ID, c.Site_ID,c.IOS_OS_Version,c.Attributed_Touch_Date,c.order_date

