-- 看起来卸载用户似乎都没有活跃数据哎
drop table if exists `beautyplus-bc0ed.temp.temp_winne_enter_homepage`;
create table if not exists `beautyplus-bc0ed.temp.temp_winne_enter_homepage` as

-- with info as (
  select
distinct event_name,event_date,user_pseudo_id
  from `dataintegration-265403.analytics.dwd_dzp_events_function`('2024-03-13', '2024-04-02', 'beautyplus', false)
where (event_name in ('first_open','homepageappr_bd')
        or (event_name ='page_event' and regexp_contains(`dataintegration-265403.func`.getParams(event_params,'cur_spm').string_value,'1008')))
    and platform='IOS'
-- )

;
select sum(first_open_uv) first_open_uv
     ,sum(enter_onboarding_uv) enter_onboarding_uv
     ,sum(enter_home_uv) enter_home_uv
     ,sum(enter_onboarding_home_uv) enter_onboarding_home_uv
     ,sum(enter_onboarding_uv)/sum(first_open_uv) enter_onboarding_ratio
     ,sum(enter_home_uv)/sum(first_open_uv) enter_home_ratio
from
(
select
a.event_date,count(distinct a.user_pseudo_id) first_open_uv
     ,count(distinct c.user_pseudo_id) enter_onboarding_uv
     ,count(distinct b.user_pseudo_id) enter_home_uv
     ,count(distinct case when c.user_pseudo_id is not null then b.user_pseudo_id end) enter_onboarding_home_uv
from (select * from `beautyplus-bc0ed.temp.temp_winne_enter_homepage` where event_name='first_open') a
left join (select * from `beautyplus-bc0ed.temp.temp_winne_enter_homepage` where event_name='homepageappr_bd') b
on a.user_pseudo_id = b.user_pseudo_id and a.event_date=b.event_date
left join (select * from `beautyplus-bc0ed.temp.temp_winne_enter_homepage` where event_name='page_event') c
on a.user_pseudo_id = c.user_pseudo_id and a.event_date=c.event_date
group by 1
)
;


select *
from (select * from `beautyplus-bc0ed.temp.temp_winne_enter_homepage` where event_name='first_open') a
join (select * from `beautyplus-bc0ed.temp.temp_winne_enter_homepage` where event_name='homepageappr_bd') b
on a.user_pseudo_id = b.user_pseudo_id and a.event_date=b.event_date
left join (select * from `beautyplus-bc0ed.temp.temp_winne_enter_homepage` where event_name='page_event') c
on a.user_pseudo_id = c.user_pseudo_id and a.event_date=c.event_date
where c.user_pseudo_id is null
limit 10


;
select *
from `dataintegration-265403.analytics.dwd_dzp_events_function`('2024-03-13', '2024-03-13', 'beautyplus', false)
where
--     (event_name in ('first_open','homepageappr_bd')
--         or (event_name ='page_event' and regexp_contains(`dataintegration-265403.func`.getParams(event_params,'cur_spm').string_value,'1008')))
--     and
    platform='IOS'
    and user_pseudo_id='7093E41B8CF5437A8CE3A37BD6D29643'
order by event_timestamp


2A83656A6C604E60BD8484EEDF919D9F
B961B0ADB00748FB8F03FF183CA917D8
AA2E0EE9EDCD4962BA3FACF2FC000A23






