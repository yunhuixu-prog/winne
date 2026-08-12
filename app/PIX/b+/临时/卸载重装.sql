with act as
(
    select distinct event_date_hk,user_pseudo_id,gid
    from dataintegration-265403.stat.stat_active_advice_detail_d
    where event_date_hk between '2024-01-01' and '2024-12-31' and app_name='BeautyPlus'
        and country='Japan'
)
,
gid_user as
(
    select gid,first_user_pseudo_id,last_user_pseudo_id
    from `beautyplus-bc0ed.dim.dim_dzp_portrait_gid_user`
    where event_date_hk='2024-12-31'
)

select event_date_hk,count(distinct act.user_pseudo_id),'卸载重装'
from act
join gid_user on act.gid = gid_user.gid
where  user_pseudo_id <> first_user_pseudo_id
group by 1

union all

select event_date_hk,count(distinct act.user_pseudo_id),'总体'
from act
group by 1
