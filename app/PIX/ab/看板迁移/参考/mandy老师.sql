--subscription_vpu
set hive.exec.dynamic.partition.mode=nonstrict;
INSERT OVERWRITE TABLE stat_beauty_plus.bplus_ama_subscription_vpu  PARTITION(date_p)
select
     nvl(country,'整体') country
    ,nvl(platform,'整体') platform
    ,sum(mau) mau
    ,sum(valid_paying_users) valid_paying_users
    ,date_p
from
(
select
    date_p
    ,nvl(platform,'unknown') platform
    ,nvl(country,'unknown') country
    ,sum(mau) mau
    ,sum(valid_paid_users) valid_paying_users
from stat_beauty_plus.filing_amz_pix_view_subscription_overview_monthly
where date_p between ${start_time} and  ${end_time}
and app = 'BeautyPlus'
and (country <> 'All' or country is null)
group by date_p,platform,country
)a
group by date_p,platform,country  with cube
having date_p is not null