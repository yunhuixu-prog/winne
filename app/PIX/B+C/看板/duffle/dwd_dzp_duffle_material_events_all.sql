-- 297
delete from `beauty-cam-new.dwd.dwd_dzp_duffle_material_events_all`  where date>='{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=3)).strftime("%Y-%m-%d") }}' and  date <='{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=0)).strftime("%Y-%m-%d") }}' ;
insert into `beauty-cam-new.dwd.dwd_dzp_duffle_material_events_all`
select date_p as date,'duffle' as source,
    country,platform,is_new,is_UA,app_version,
    material_lv1 as feature, case when material_lv2='配方' then 'duffle 配方' else material_lv2 end as sub_feature,
    material_id,
    event_action,event_name, user_pseudo_id,event_timestamp,module
from
     `dataintegration-265403.duffle.dwd_dz_material_events_v` a
where
    --module='修图'
     app_name = 'Beauty Plus Cam'
  --- and date_p="2023-02-01" --and date_p<='2023-02-07'
 and date_p>='{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=3)).strftime("%Y-%m-%d") }}' and date_p<='{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=0)).strftime("%Y-%m-%d") }}'

union all
select event_date as date,'首页' as source,
    country,platform,is_new,is_UA,app_version,
    case
    when content_type='配方素材' then '配方'
    when content_type='涂鸦笔素材' then '涂鸦笔'
    when content_type='贴纸素材' then '贴纸'
    when content_type='滤镜素材' then '滤镜'
    else '' end as feature,
    case
    when content_type='配方素材' then '专题配方'
    when content_type='涂鸦笔素材' then '涂鸦笔'
    when content_type='贴纸素材' then '贴纸'
    when content_type='滤镜素材' then '滤镜'
    else '' end sub_feature,
    content_id as material_id,
    event_action,event_name, user_pseudo_id,event_timestamp,'首页'as module
from
     `dataintegration-265403.duffle_fin.dwd_dz_marvel_home_content_bpc` a
where
     module='专题'
    and app_name = 'Beauty Plus Cam'
   -- and content_type in ('配方素材','涂鸦笔素材' ,'滤镜素材','贴纸素材' )
  --  and event_date="2023-02-01" --and event_date<='2023-02-07'
    and event_date>='{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=3)).strftime("%Y-%m-%d") }}' and event_date<='{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=0)).strftime("%Y-%m-%d") }}'
    and event_action in ('click','impression','save')
    AND content_id LIKE 'BP_%'

union all
select distinct event_date as date,'首页' as source,
    country,platform,is_new,is_UA,app_version,
 case
    when content_id like '%TEM%' then '配方'
    when content_id like '%FIL%' then '滤镜'
    when content_id like 'STI%' then '贴纸'
    else 'others' end as feature,
 case
    when content_id like '%TEM%' then '专题配方'
    when content_id like '%FIL%' then '滤镜'
    when content_id like 'STI%' then '贴纸'
    else 'others' end sub_feature,
    content_id as material_id,
    event_action,event_name, user_pseudo_id,event_timestamp,'首页'as module
from
     `dataintegration-265403.duffle_fin.dwd_dz_marvel_home_content_bpc` a
where
     module='专题'
    and app_name = 'Beauty Plus Cam'
   -- and content_type in ('配方素材','涂鸦笔素材' ,'滤镜素材','贴纸素材' )
  --  and event_date="2023-02-01" --and event_date<='2023-02-07'
     and event_date>='{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=3)).strftime("%Y-%m-%d") }}' and event_date<='{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=0)).strftime("%Y-%m-%d") }}'
    and event_action in ('subscription')
    AND content_id LIKE 'BP_%'

union all
    select event_date as date,'首页' as source,
    country,platform,is_new,is_UA,app_version,
    '配方' as feature,
    'banner配方' as sub_feature,
    b.m_id as material_id,
    event_action,event_name, user_pseudo_id,event_timestamp,'首页'as module
from
     `dataintegration-265403.duffle_fin.dwd_dz_marvel_home_content_bpc` a
     join  `beautyplus-bc0ed.view.stage_dz_marvel_home_category_mid_v` b on a.module_id=b.rid
where
     module='Banner'
    and app_name = 'Beauty Plus Cam'
  --and event_date="2023-02-01" --and event_date<='2023-02-07'
   and event_date>='{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=3)).strftime("%Y-%m-%d") }}' and event_date<='{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=0)).strftime("%Y-%m-%d") }}'
    and event_action in ('click','impression','subscription','save')
    and b.type='HPB_Formula'

union all
    select event_date as date,'首页' as source,
    country,platform,is_new,is_UA,app_version,
    '配方' as feature,
    '推荐配方' as sub_feature,
    content_id as material_id,
    event_action,event_name, user_pseudo_id,event_timestamp,'首页'as module
from
     `dataintegration-265403.duffle_fin.dwd_dz_marvel_home_content_bpc` a
where
     module='推荐配方'
    and app_name = 'Beauty Plus Cam'
  --and event_date="2023-02-01" --and event_date<='2023-02-07'
   and event_date>='{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=3)).strftime("%Y-%m-%d") }}' and event_date<='{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=0)).strftime("%Y-%m-%d") }}'
    and event_action in ('click','impression','subscription','save')
