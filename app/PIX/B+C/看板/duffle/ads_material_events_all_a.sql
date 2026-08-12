--ads_material_events_all_a
with
  action_info as
(
SELECT 'BeautyPlus' app_name,'uv' as data_type,case
when module='拍摄' then '自拍'
else module end as module,
 event_date as date, platform,case when country='China' then 'China Mainland'
  else country end as country,    case
    when country in ('South Korea','Thailand','Japan','United States','China') then country
    when country in ('Turkey','Saudi Arabia','Egypt','United Arab Emirates','Lebanon','Kuwait','Qatar','Iran') then 'Middle East'
    else 'general' end as key_country,version,  event_name, dau,uv
FROM `beautyplus-bc0ed.event_dataset_4.ads_dz_event_data_04`
where event_name in
(
'beautifysave_bd',
'selfiesave_bd',
'video_edit_save_bd'
)
and key_name in ('-') and value_name in ('-')
and event_date>='2022-01-01'

) ,
material_info as
(
    select 'BeautyPlus' app_name,*,   case
        when country in ('South Korea','Thailand','Japan','United States','China','Indonesia') then country
        when country in ('Turkey','Saudi Arabia','Egypt','United Arab Emirates','Lebanon','Kuwait','Qatar','Iran') then 'Middle East'
        else 'general' end as key_country
    from `beautyplus-bc0ed.duffle.dws_dzp_duffle_dz_material_events_all_function`
    where date>='2022-01-01'

    union all

    select 'Beauty Plus Cam' app_name,*,   case
        when country in ('South Korea','Thailand','Japan','United States','China','Indonesia') then country
        when country in ('Turkey','Saudi Arabia','Egypt','United Arab Emirates','Lebanon','Kuwait','Qatar','Iran') then 'Middle East'
        else 'general' end as key_country
    from `beauty-cam-new.duffle.dws_dzp_duffle_material_events_all_function`
    where date>='2022-01-01'
)
--计算按功能去重的素材汇总数据
select a.app_name,a.date,
   a.data_type,
    a.key_country,a.country,
    feature, sub_feature,  a.platform,
    'all' as paid_type,
    app_version,a.module,
    case when is_available ='1' then 'available'
    when is_available ='0' then 'unavailable'
    else 'unknown'
    end as is_available,
    sum(exposure) exposure ,sum(click) click,0 check,sum(save) save,sum(sub) sub,0 sub_to_paid,0 revenue,0 save_uv,0 dau
from
     material_info  a
group by 1 ,2,3,4,5,6,7,8,9,10,11,12
--计算修图保存、自拍保存
union all
select a.app_name,a.date,
   a.data_type,
    key_country,a.country,
    'total'feature, ''sub_feature,  a.platform,
     'all' as paid_type,
    version,a.module,'' as is_available,
    0 exposure ,0 click,0 check,0 save,0 sub,0 sub_to_paid,0 revenue,sum(uv) save_uv,0 dau
from
     action_info  a
group by 1 ,2,3,4,5,6,7,8,9,10,11,12
--只计算dau
union all
select a.app_name,a.date,
   a.data_type,
    key_country,a.country,
    'total'feature, ''sub_feature,  a.platform,
     'all' as paid_type,
    version,'' as module,'' as is_available,
    0 exposure ,0 click,0 check,0 save,0 sub,0 sub_to_paid,0 revenue,0 save_uv,sum(dau) dau
from
     action_info  a
where event_name='beautifysave_bd' --一个事件会挂所有的dau,因此只需要限定任意一个事件即可
group by 1 ,2,3,4,5,6,7,8,9,10,11,12
--将修图/自拍保存和dau挂到素材功能后面，为了看板方便计算
union all
select a.app_name,a.date,
   a.data_type,
    key_country,a.country,
    feature, ''sub_feature,  a.platform,
     'all' as paid_type,
    version,a.module,'' as is_available,
    0 exposure ,0 click,0 check,0 save,0 sub,0 sub_to_paid,0 revenue,sum(uv) save_uv,sum(dau) dau
from
     action_info  a
     left join
     (select module,feature,app_name from material_info group by 1,2,3) b
     on a.module=b.module and a.app_name=b.app_name
group by 1 ,2,3,4,5,6,7,8,9,10,11,12
