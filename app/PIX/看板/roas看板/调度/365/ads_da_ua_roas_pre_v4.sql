delete from `dataintegration-265403.roas_dataset_v4.ads_da_ua_roas_pre_v4` where 1=1;
insert into `dataintegration-265403.roas_dataset_v4.ads_da_ua_roas_pre_v4`
with cost as
(
select
app_id,platform,country,Media_Source,Campaign, Campaign_ID, Ad_Group, Ad_Group_ID, Keywords, Keyword_ID, Site_ID, install_date,order_date,amount,
--0 as install_uv, 0 as install_first_time_trial_uv, 0 as install_first_time_paid_uv, 0 as install_first_time_trial_to_paid_uv, 0.0 as sub_revenue, 0.0 as forecast_revenue,0 as install_first_time_sub_uv
0 as install_uv,
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
    product as app_id,
    upper(Trim(Platform)) as platform,
    fix_firebase_en_name as country,
    media_source as Media_Source,
    campaign_name as Campaign,
    campaign_id as Campaign_ID,
    ad_group as Ad_Group,
    ad_group_id as Ad_Group_ID,
    keyword as Keywords,
    keyword_id as Keyword_ID,
    site_id as Site_ID,
    date as install_date,
    sum(amount_spent_usd) as amount
  FROM
    `finance-268602.roi_dataset.dws_dz_campgain_info`

    group by 1,2,3,4,5,6,7,8,9,10,11,12
)a
cross join
(
    SELECT distinct Attributed_Touch_Date_hk AS order_date FROM `dataintegration-265403.roas_dataset.dwd_dz_af_ua_info`
    where Attributed_Touch_Date>='2020-08-01'
)b

)


select
 c.App_Name,c.Platform,c.Country ,c.Media_Source,c.Campaign,c.Campaign_ID, c.Ad_Group, c.Ad_Group_ID, c.Keywords, c.Keyword_ID, c.Site_ID, c.Attributed_Touch_Date as Date,c.order_date,
   IFNULL(sum(c.amount), 0) as amount,IFNULL(sum(c.install_uv), 0) as install_uv,
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
SELECT App_Name, Platform, Country, Media_Source, Campaign, Campaign_ID, Ad_Group, Ad_Group_ID, Keywords, Keyword_ID, Site_ID, Date as Attributed_Touch_Date, order_date,0.0 as amount,
/*sum( install_uv ) as install_uv,sum( install_first_time_trial_uv ) as install_first_time_trial_uv,sum( install_first_time_paid_uv ) as install_first_time_paid_uv,
sum( install_first_time_trial_to_paid_uv )as install_first_time_trial_to_paid_uv,sum( sub_revenue ) as sub_revenue,sum( forecast_revenue ) as forecast_revenue,sum(install_first_time_sub_uv) as install_first_time_sub_uv*/
sum( install_uv ) as install_uv,
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

FROM `dataintegration-265403.roas_dataset_v4.ads_da_ua_install_sub_v4`
group by App_Name, Platform, Country, Media_Source, Campaign,Campaign_ID,Ad_Group,Ad_Group_ID,Keywords, Keyword_ID,Site_ID, Date, order_date

union all

select
app_id as App_Name,platform as Platform,country as Country,Media_Source,Campaign,Campaign_ID,Ad_Group,Ad_Group_ID,Keywords, Keyword_ID,Site_ID, install_date as Attributed_Touch_Date,order_date,amount,
--install_uv,install_first_time_trial_uv, install_first_time_paid_uv, install_first_time_trial_to_paid_uv, sub_revenue, forecast_revenue,install_first_time_sub_uv
install_uv,
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

from cost

)c
group by
 c.App_Name,c.Platform,c.Country ,c.Media_Source,c.Campaign,c.Campaign_ID, c.Ad_Group, c.Ad_Group_ID, c.Keywords, c.Keyword_ID, c.Site_ID,c.Attributed_Touch_Date,c.order_date

