


select a.event_date_hk
     ,count(distinct a.gid) uv
     ,count(distinct case when a.user_pseudo_id!=b.last_user_pseudo_id then a.gid end) uv_uninstall_in_campaign
     ,count(distinct case when a.user_pseudo_id!=c.first_user_pseudo_id then a.gid end) uv_uninstall
from
(
    select distinct
        event_date_hk
        ,user_pseudo_id
        ,gid
    from
        `dataintegration-265403.stat.stat_active_advice_detail_d`
    where
        event_date_hk between '2024-11-29' and '2024-12-03'
        and app_name in ('BeautyPlus') --and is_new=1
) a
left join
(
    select gid,last_user_pseudo_id,first_user_pseudo_id
    from `beautyplus-bc0ed.dim.dim_dzp_portrait_gid_user`
    where event_date_hk='2024-11-28'
) b
on a.gid=b.gid
left join
(
    select gid,last_user_pseudo_id,first_user_pseudo_id
    from `beautyplus-bc0ed.dim.dim_dzp_portrait_gid_user`
    where event_date_hk='2024-12-10'
) c
on a.gid=c.gid
group by 1



with act as( select distinct user_pseudo_id,gid from dataintegration-265403.stat.stat_active_advice_detail_d where event_date_hk between '2024-12-01' and '2024-12-07' and app_name='BeautyPlus'),
gid_user as (select gid,first_user_pseudo_id,last_user_pseudo_id from `beautyplus-bc0ed.dim.dim_dzp_portrait_gid_user` where event_date_hk='2024-12-07')
select
distinct act.user_pseudo_id,'卸载重装'
from act  join gid_user on act.gid = gid_user.gid
where  user_pseudo_id <> first_user_pseudo_id


