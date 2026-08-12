-- drop table if exists `beautyplus-bc0ed.Duffle_dataset.ads_dz_marvel2_home_content_new`;
-- create table if not exists `beautyplus-bc0ed.Duffle_dataset.ads_dz_marvel2_home_content_new` as
delete from  `beautyplus-bc0ed.Duffle_dataset.ads_dz_marvel2_home_content_new`  where event_date>='{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=14)).strftime("%Y-%m-%d") }}' and event_date<='{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=0)).strftime("%Y-%m-%d") }}';
insert into `beautyplus-bc0ed.Duffle_dataset.ads_dz_marvel2_home_content_new`

WITH t2format AS (
  SELECT
    x.event_date,
    x.app_name,
    x.app_version,
    x.platform,
    x.country,
    x.is_new,
    x.is_ua,
    x.module,
    x.module_id,
    x.content_id,
    [STRUCT( 'pv' AS data_type,
      impression_pv AS exposure,
      click_pv AS click,
      use_pv AS `check`,
      save_pv AS `save`,
      IFNULL(subscription, 0) AS sub,
      IFNULL(sub2paid, 0) AS sub_to_paid,
      IFNULL(paid_amounts, 0) AS revenue),
    STRUCT( 'uv' AS data_type,
      impression_uv AS exposure,
      click_uv AS click,
      use_uv AS `check`,
      save_uv AS `save`,
      IFNULL(subscription, 0) AS sub,
      IFNULL(sub2paid, 0) AS sub_to_paid,
      IFNULL(paid_amounts, 0) AS revenue) ] AS upv,
  FROM
    `dataintegration-265403.duffle_fin.dws_dz_marvel_home_content` x
  where event_date>='{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=14)).strftime("%Y-%m-%d") }}' and event_date<='{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=0)).strftime("%Y-%m-%d") }}'
)
,
marvel_home AS (
SELECT
  event_date,
  app_name,
  app_version,
  platform,
  country,
  is_new,
  is_ua,
  module,
  module_id,
  content_id,
  v.data_type,
  v.exposure,
  v.click,
  v.check,
  v.save,
  v.sub,
  v.sub_to_paid,
  v.revenue
FROM
  t2format,
  UNNEST(t2format.upv) v
)

select  
    'content_id' as level_type
    ,event_date
    ,a.app_name
    ,module
    ,case when module in ('推荐配方','玩法区') then content_id else module_id end module_id
    ,content_id
    ,data_type
    ,m.type module_type
    ,coalesce(m.name,bm.name) as module_name
    ,m.region as marvel_region
    ,c.name as content_name
    ,case   when m.status=1 then '启用'
            when m.status=0 then '禁用'
            else ''
            end as status
    ,case   when c.url is null then s.icon
            when c.media_type='video' then c.cover_img
            else c.url 
            end as pic
    ,c.start_dt as start_date
    ,c.end_dt as end_date
    ,c.effective_time
    ,c.abcode
    ,if(c.version_status='1',c.version_type,"") marvel_version
    ,a.platform
    ,app_version
    ,case when `dataintegration-265403.func`.compare_is_greater_or_equal_version(app_version,'7.7.000') then '>=7.7.000'
          else '<7.7.000'
    end Version_status
    ,case when `dataintegration-265403.func`.compare_is_greater_or_equal_version(app_version,'7.7.000') and module in ('推荐配方入口','推荐配方') then '新版本-算法推荐'
          when `dataintegration-265403.func`.compare_is_greater_or_equal_version(app_version,'7.7.000') and module in ('专题','Banner','金刚区','玩法区','轮播图') then '新版本-人工配置'
          else '老版本'
    end module_category
    ,case when country='China' then 'China Mainland' else country end country
    ,is_ua
    ,case when country in ('South Korea','Thailand','Japan','United States','Indonesia') then country
          when country in ('Turkey','Saudi Arabia','Egypt','United Arab Emirates','Lebanon','Kuwait','Qatar','Iran') then 'Middle East'
          when country in ('Thailand','Indonesia','Vietnam','Malaysia','Philippines','Singapore','Cambodia','Laos') then 'Southeast Asia'
          else 'WW'
    end as region
    ,case when is_new='1' then 'New_user' else 'Old_user' end as is_new
    ,sum(exposure) Explore
    ,sum(click) Click
    ,sum(check) CHeck
    ,sum(save) Save
    ,sum(sub) Sub
    ,sum(sub_to_paid) Sub_Pay
    ,sum(revenue) Revenue
from 
    marvel_home a
    left join (select rid,max(type) type,max(name) name,max(region) region,max(status) status from `dataintegration-265403.duffle_fin.stage_dz_marvel_home_category_v` group by 1) m on a.module_id=m.rid
    -- 金刚区id匹配
    left join (select id,max(name) name from `beautyplus-bc0ed.dim.dim_gs_marvel_homepage_module_name_mapping` group by 1) bm on a.module_id=bm.id
    left join (select rid,max(name) name,max(url) url,max(media_type) media_type,max(start_dt) start_dt,max(end_dt) end_dt,max(effective_time) effective_time,max(abcode) abcode,max(version_status) version_status,max(version_type) version_type,max(cover_img) cover_img from `dataintegration-265403.duffle_fin.stage_dz_marvel_home_category_sub_v` group by 1) c on a.content_id=c.rid
    left join   (select distinct 
                    m_id
                    ,icon
                from
                    (select 
                        *
                        ,row_number() over(partition by m_id order by start_date desc) rn
                    from  
                        `dataintegration-265403.duffle_fin.dmi_da_materials_info` 
                    where 
                        app_id in ('103','104')) a
                    where a.rn=1 )s on s.m_id=a.content_id
where 
    a.app_name in ('BeautyPlus','Beauty Plus Cam')
    and module!='推荐配方入口' 
    and module_id <>'-2' --and exposure>10
    --AND event_date BETWEEN '2022-09-20' AND '2022-09-21'
    and content_id !='any' 
group by 
    1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26

union all 

select  
    'content_id' as level_type
    ,event_date
    ,a.app_name
    ,module
    ,case when module='推荐配方' then content_id else module_id end module_id
    ,content_id
    ,data_type
    ,m.type module_type
    ,coalesce(m.name,bm.name) as module_name
    ,m.region as marvel_region
    ,c.name as content_name
    ,case   when m.status=1 then '启用'
            when m.status=0 then '禁用'
            else ''
            end as status
    ,case   when c.url is null then s.icon
            when c.media_type='video' then c.cover_img
            else c.url 
            end as pic
    ,c.start_dt as start_date
    ,c.end_dt as end_date
    ,c.effective_time
    ,c.abcode
    ,if(c.version_status='1',c.version_type,"") marvel_version
    ,a.platform
    ,app_version
    ,case when `dataintegration-265403.func`.compare_is_greater_or_equal_version(app_version,'7.7.000') then '>=7.7.000'
          else '<7.7.000'
    end Version_status
    ,case when `dataintegration-265403.func`.compare_is_greater_or_equal_version(app_version,'7.7.000') and module in ('推荐配方入口','推荐配方') then '新版本-算法推荐'
          when `dataintegration-265403.func`.compare_is_greater_or_equal_version(app_version,'7.7.000') and module in ('专题','Banner','金刚区','玩法区','轮播图') then '新版本-人工配置'
          else '老版本'
    end module_category
    ,case when country='China' then 'China Mainland' else country end country
    ,is_ua
    ,case when country in ('South Korea','Thailand','Japan','United States','Indonesia') then country
          when country in ('Turkey','Saudi Arabia','Egypt','United Arab Emirates','Lebanon','Kuwait','Qatar','Iran') then 'Middle East'
          when country in ('Thailand','Indonesia','Vietnam','Malaysia','Philippines','Singapore','Cambodia','Laos') then 'Southeast Asia'
          else 'WW'
    end as region
    ,case when is_new='1' then 'New_user' else 'Old_user' end as is_new
    ,sum(exposure) Explore
    ,sum(click) Click
    ,sum(check) CHeck
    ,sum(save) Save
    ,sum(sub) Sub
    ,sum(sub_to_paid) Sub_Pay
    ,sum(revenue) Revenue
from
    marvel_home a
    left join (select rid,max(type) type,max(name) name,max(region) region,max(status) status from `dataintegration-265403.duffle_fin.stage_dz_marvel_home_category_v` group by 1) m on a.module_id=m.rid
    -- 金刚区id匹配
    left join (select id,max(name) name from `beautyplus-bc0ed.dim.dim_gs_marvel_homepage_module_name_mapping` group by 1) bm on a.module_id=bm.id
    left join (select rid,max(name) name,max(url) url,max(media_type) media_type,max(start_dt) start_dt,max(end_dt) end_dt,max(effective_time) effective_time,max(abcode) abcode,max(version_status) version_status,max(version_type) version_type,max(cover_img) cover_img from `dataintegration-265403.duffle_fin.stage_dz_marvel_home_category_sub_v` group by 1) c on a.module_id=c.rid
    left join   (select distinct
                    m_id
                    ,icon
                from
                    (select
                        *
                        ,row_number() over(partition by m_id order by start_date desc) rn
                    from
                        `dataintegration-265403.duffle_fin.dmi_da_materials_info`
                    where
                        app_id in ('103','104')) a
                    where a.rn=1 )s on s.m_id=a.module_id
where
    a.app_name in ('BeautyPlus','Beauty Plus Cam')
    and module='推荐配方入口'
    and module_id <>'-2' --and exposure>10
    --AND event_date BETWEEN '2022-09-20' AND '2022-09-21'
    and content_id !='any'
group by
    1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26

union all

select
    'module_id' as level_type
    ,event_date
    ,a.app_name
    ,module
    ,case when module='推荐配方' then content_id else module_id end module_id
    ,content_id
    ,data_type
    ,m.type module_type
    ,coalesce(m.name,bm.name) as module_name
    ,m.region as marvel_region
    ,'' as content_name
    ,if(m.status=1,'启用','禁用') status
    ,case   when media_type='video' then cover_img
            else m.url
            end as pic
    ,m.start_dt as start_date
    ,m.end_dt as end_date
    ,m.effective_time
    ,m.abcode
    ,if(m.version_status='1',m.version_type,"") marvel_version
    ,a.platform
    ,app_version
    ,case when `dataintegration-265403.func`.compare_is_greater_or_equal_version(app_version,'7.7.000') then '>=7.7.000'
          else '<7.7.000'
    end Version_status
    ,case when `dataintegration-265403.func`.compare_is_greater_or_equal_version(app_version,'7.7.000') and module in ('推荐配方入口','推荐配方') then '新版本-算法推荐'
          when `dataintegration-265403.func`.compare_is_greater_or_equal_version(app_version,'7.7.000') and module in ('专题','Banner','金刚区','玩法区','轮播图') then '新版本-人工配置'
          else '老版本'
    end module_category
    ,case when country='China' then 'China Mainland' else country end country
    ,is_ua
    ,case when country in ('South Korea','Thailand','Japan','United States','Indonesia') then country
          when country in ('Turkey','Saudi Arabia','Egypt','United Arab Emirates','Lebanon','Kuwait','Qatar','Iran') then 'Middle East'
          when country in ('Thailand','Indonesia','Vietnam','Malaysia','Philippines','Singapore','Cambodia','Laos') then 'Southeast Asia'
          else 'WW'
    end as region
    ,case when is_new='1' then 'New_user' else 'Old_user' end as is_new
    ,sum(exposure) Explore
    ,sum(click) Click
    ,sum(check) CHeck
    ,sum(save) Save
    ,sum(sub) Sub
    ,sum(sub_to_paid) Sub_Pay
    ,sum(revenue) Revenue
from 
    marvel_home a
    left join (select rid,max(type) type,max(name) name,max(region) region,max(status) status,max(media_type) media_type,max(start_dt) start_dt,max(end_dt) end_dt,max(effective_time) effective_time,max(abcode) abcode,max(version_status) version_status,max(version_type) version_type,max(cover_img) cover_img,max(url) url from `dataintegration-265403.duffle_fin.stage_dz_marvel_home_category_v` group by 1) m on a.module_id=m.rid 
    -- 金刚区id匹配
    left join (select id,max(name) name from `beautyplus-bc0ed.dim.dim_gs_marvel_homepage_module_name_mapping` group by 1) bm on a.module_id=bm.id
where
    a.app_name in ('BeautyPlus','Beauty Plus Cam')
    and m.type<>'HPB_AD'
    and module is not null 
    and module!='轮播图' 
    and module_id <>'-2' --and exposure>10
    --AND event_date= '2022-10-31'
    and content_id ='any' 
    and module_id!='any' 
    and module !='any'
group by 
    1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26

