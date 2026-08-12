
select count(distinct a.user_id) remain_uv
      ,count(distinct case when b.gid is not null then a.user_id end) active_1_remain_uv
      ,count(distinct case when c.gid is not null then a.user_id end) active_90_remain_uv
from
(
  select distinct user_id
  from `beautyplus-bc0ed.dim.dim_dap_credit_credit_snapshot`
  where event_date='2025-02-24'
    and app_name='BeautyPlus'
    and remain_quantity_today>0
) a
left join
(
  select distinct gid
  from `dataintegration-265403.stat.stat_active_advice_detail_d`
  where event_date_hk between date_sub('2025-02-24',interval 0 day) and '2025-02-24'
    and app_name='BeautyPlus'
) b
on a.user_id=b.gid
left join
(
  select distinct gid
  from `dataintegration-265403.stat.stat_active_advice_detail_d`
  where event_date_hk between date_sub('2025-02-24',interval 89 day) and '2025-02-24'
    and app_name='BeautyPlus'
) c
on a.user_id=c.gid
