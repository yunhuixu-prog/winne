--new five page
delete from `beautyplus-bc0ed.sub_dataset.dwd_oda_spm_subscription_events`  where date >= '{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=3)).strftime("%Y-%m-%d") }}'and date <= '{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=0)).strftime("%Y-%m-%d") }}';
--delete from `beautyplus-bc0ed.sub_dataset.dwd_oda_spm_subscription_events`  where date >= '2023-08-01'  ;
insert into `beautyplus-bc0ed.sub_dataset.dwd_oda_spm_subscription_events`
with event_source as (
    SELECT *
-- FROM `beautyplus-bc0ed.analytics.ods_dz_events_tv`('2023-08-01', '2023-08-01')
from  `dataintegration-265403.analytics.dwd_dzp_events_function`('{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=3)).strftime("%Y-%m-%d") }}', '{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=0)).strftime("%Y-%m-%d") }}','beautyplus',true)
)
 select
   event_date_hk as date,
    CAST(event_date_hk AS STRING FORMAT 'YYYYMMDD') as event_date,
    platform,user_pseudo_id, event_timestamp, event_name,
   coalesce(nullif(`beautyplus-bc0ed.func.getUserprop`(user_properties,'gid').string_value, '') ,
   nullif(`beautyplus-bc0ed.func.getUserprop`(user_properties,'advertising_id').string_value, ''),
   nullif(`beautyplus-bc0ed.func.getUserprop`(user_properties,'gid').string_value, '') ,
   nullif(`beautyplus-bc0ed.func.getUserprop`(user_properties,'vendor_id').string_value, '') ,
   nullif(user_pseudo_id, ''),
   nullif(`beautyplus-bc0ed.func.getParams`(event_params,'appsflyer_id').string_value, '')) as unified_id,
   `beautyplus-bc0ed.func.getParams`(event_params,'session_id').string_value session_id,
    [`beautyplus-bc0ed.func.decodeSpmNew`(`beautyplus-bc0ed.func.getParams`(event_params,'cur_spm').string_value) ,`beautyplus-bc0ed.func.decodeSpmNew`(`beautyplus-bc0ed.func.getParams`(event_params,'pre_spm').string_value),`beautyplus-bc0ed.func.decodeSpmNew`(`beautyplus-bc0ed.func.getParams`(event_params,'dpre_spm').string_value)] spm,
    `beautyplus-bc0ed.func.getParams`(event_params,'cur_page_content').string_value as cur_page_content,
    `beautyplus-bc0ed.func.getParams`(event_params,'pre_page_content').string_value as pre_page_content,
    `beautyplus-bc0ed.func.getParams`(event_params,'dpre_page_content').string_value as dpre_page_content,
    `beautyplus-bc0ed.func.getParams`(event_params,'source_feature_content').string_value as source_feature_content,
    `beautyplus-bc0ed.func.getParams`(event_params,'source_click_position').string_value as  source_click_position,
    `beautyplus-bc0ed.func.getParams`(event_params,'SKU_ID').string_value as SKU_ID,
    version   as app_version,
    geo,
      `beautyplus-bc0ed.func.getParams`(event_params,'sub_user_type').string_value  as sub_user_type,
       `beautyplus-bc0ed.func.getParams`(event_params,'sku_tag').string_value  as sku_tag,
     func.getUserprop(user_properties, 'device_id').string_value AS device_id
     -- event_params,
    from event_source
    -- change to latest date
--where event_date >= '20220206' and event_date<='20220216'
--where event_date >= '{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=3)).strftime("%Y%m%d") }}'
-- where _TABLE_SUFFIX between format_date('%Y%m%d', date_sub(current_date , interval 4 day)) and format_date('%Y%m%d', date_sub(current_date , interval 2 day))
  where event_name in ('subscription_clk_try', 'subscription_try_suc', 'page_event')
;



delete from `beautyplus-bc0ed.sub_dataset.dwd_oda_spm_tmp_result_temp`   where date >= '{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=3)).strftime("%Y-%m-%d") }}'and date <= '{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=0)).strftime("%Y-%m-%d") }}';
--delete from `beautyplus-bc0ed.sub_dataset.dwd_oda_spm_tmp_result_temp`  where date >= '2023-08-01' ;
insert into `beautyplus-bc0ed.sub_dataset.dwd_oda_spm_tmp_result_temp`
WITH subscription_page_event AS (
    SELECT date,
    a.event_date,
    platform,
    user_pseudo_id,
--     coalesce(b.uuid,a.unified_id) as uuid,
    a.unified_id as uuid,
    event_timestamp, event_name, session_id,
    spm,
    cur_page_content,
    pre_page_content,
    dpre_page_content,
    source_feature_content,
    source_click_position,
    SKU_ID,
    app_version,
    geo.country as country,
    sub_user_type,
    sku_tag,
    device_id
     --event_params

    from `beautyplus-bc0ed.sub_dataset.dwd_oda_spm_subscription_events` a
--     left join
--       (
--           select
--               t2.uuid as uuid
--               ,t2.id as id
--               ,t2.type as type
--               ,t2.event_date as event_date
--           from
--           (
--               select
--                   max(event_date) as event_date
--               from
--                   `beautyplus-bc0ed.warehouse_gid.id_mapping`
--           ) t1
--           join
--           (
--               select
--                   uuid
--                   ,id
--                   ,type
--                   ,event_date
--               from
--                   `beautyplus-bc0ed.warehouse_gid.id_mapping`
--               where
--                   ifnull(uuid,'') <> '' and uuid != '-1'
--           ) t2
--           on t1.event_date = t2.event_date
--       ) b
--       on a.unified_id = b.id and parse_date('%Y%m%d',a.event_date) = b.event_date
        where date >= '{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=3)).strftime("%Y-%m-%d") }}'and date <= '{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=0)).strftime("%Y-%m-%d") }}'
      --where  a.date >=  '2023-08-01' --and date <= '2023-08-11'
   ),
decode_all_event_spm as (
        SELECT  m.date, uuid, m.event_date,m.platform,m.user_pseudo_id,event_timestamp, event_name, session_id, replace(source_feature_content,",","、") as source_feature_content,m.source_click_position,
        case when m.spm[SAFE_OFFSET(0)].page_id = '0' then null else concat(m.spm[SAFE_OFFSET(0)].page_id, '@', m.spm[SAFE_OFFSET(0)].incrid) end as cur_page1,
        case when m.spm[SAFE_OFFSET(1)].page_id = '0' then null else concat(m.spm[SAFE_OFFSET(1)].page_id, '@', m.spm[SAFE_OFFSET(1)].incrid) end as pre_page1,
        case when m.spm[SAFE_OFFSET(2)].page_id = '0' then null else concat(m.spm[SAFE_OFFSET(2)].page_id, '@', m.spm[SAFE_OFFSET(2)].incrid) end as dpre_page1,
        m.spm[SAFE_OFFSET(0)].page_id as page1,
        m.spm[SAFE_OFFSET(1)].page_id as page2,
        m.spm[SAFE_OFFSET(2)].page_id as page3,
        s1.page_name as cur_page,
        s2.page_name as pre_page,
        s3.page_name as dpre_page,
        m.cur_page_content,
        m.pre_page_content,
        m.dpre_page_content,
        SKU_ID,
         app_version,
        country,
        sub_user_type,
        sku_tag,
        device_id
        --event_params
        FROM subscription_page_event m
        -- 替换为最新维护的spm page表
        left join `beautyplus-bc0ed.sub_dataset.dmi_da_spm_page_info` s1
        on m.spm[SAFE_OFFSET(0)].page_id=s1.page_id
        left join `beautyplus-bc0ed.sub_dataset.dmi_da_spm_page_info` s2
        on m.spm[SAFE_OFFSET(1)].page_id=s2.page_id
        left join `beautyplus-bc0ed.sub_dataset.dmi_da_spm_page_info` s3
        on m.spm[SAFE_OFFSET(2)].page_id=s3.page_id
),
dedup_page as (
  select   a.date, a.event_date, a.uuid, a.platform, a.event_name, a.event_timestamp, a.session_id,
    a.user_pseudo_id,a.source_feature_content,a.source_click_position,
    a.cur_page1,
    a.pre_page1,
    a.dpre_page1,
    b.dpre_page1 as ddpre_page1,
    c.dpre_page1 as dddpre_page1,
    d.dpre_page1 as ddddpre_page1,
    a.cur_page,a.pre_page,a.dpre_page,
    b.dpre_page as ddpre_page,
    c.dpre_page as dddpre_page,
    d.dpre_page as ddddpre_page,
    a.cur_page_content,
    a.pre_page_content,
    a.dpre_page_content,
    b.dpre_page_content as ddpre_page_content,
    c.dpre_page_content as dddpre_page_content,
    d.dpre_page_content as ddddpre_page_content,
    a.SKU_ID,
    a.app_version,
    a.country,
    a.sub_user_type,
    a.sku_tag,
    a.device_id
    --a.event_params
    from decode_all_event_spm a
    left join decode_all_event_spm b
    on a.user_pseudo_id = b.user_pseudo_id and a.session_id = b.session_id and a.platform = b.platform and a.pre_page1 = b.cur_page1 and a.dpre_page1 = b.pre_page1 and a.event_timestamp > b.event_timestamp
    left join decode_all_event_spm c
    on b.user_pseudo_id = c.user_pseudo_id and b.session_id = c.session_id and b.platform = c.platform and b.pre_page1 = c.cur_page1 and b.dpre_page1 = c.pre_page1 and b.event_timestamp > c.event_timestamp
    left join decode_all_event_spm d
    on c.user_pseudo_id = d.user_pseudo_id and c.session_id = d.session_id and c.platform = d.platform and c.pre_page1 = d.cur_page1 and c.dpre_page1 = d.pre_page1 and c.event_timestamp > d.event_timestamp
)
select

  date, b.event_date, uuid, user_pseudo_id, b.platform, event_name,event_timestamp, session_id, b.source_feature_content,b.source_click_position,
  cur_page1,
  case when cur_page = pre_page  then dpre_page1 else pre_page1 end as pre_page1,
  case when pre_page = dpre_page then ddpre_page1 else dpre_page1 end as dpre_page1,
  case when dpre_page = ddpre_page then dddpre_page1 else ddpre_page1 end as ddpre_page1,
  case when ddpre_page = dddpre_page then ddddpre_page1 else dddpre_page1 end as dddpre_page1,
  b.cur_page,
  case when cur_page = pre_page  then dpre_page else pre_page end as pre_page,
  case when pre_page = dpre_page  then ddpre_page else dpre_page end as dpre_page,
  case when dpre_page = ddpre_page  then dddpre_page else ddpre_page end as ddpre_page,
  case when ddpre_page = dddpre_page  then ddddpre_page else dddpre_page end as dddpre_page,
  b.cur_page_content,
  case when cur_page = pre_page  then dpre_page_content else pre_page_content end as pre_page_content,
  case when pre_page = dpre_page  then ddpre_page_content else dpre_page_content end as dpre_page_content,
  case when dpre_page = ddpre_page  then dddpre_page_content else ddpre_page_content end as ddpre_page_content,
  case when dpre_page = ddpre_page  then ddddpre_page_content else dddpre_page_content end as dddpre_page_content,
  b.SKU_ID,
  b.app_version,
  country,
  sub_user_type,
  sku_tag,
  device_id
 -- event_params
from dedup_page b
-- where  b.cur_page != b.dpre_page
;


delete from `beautyplus-bc0ed.sub_dataset.dwd_oda_spm_uuid_five_page_temp`    where date >= '{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=3)).strftime("%Y-%m-%d") }}'and date <= '{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=0)).strftime("%Y-%m-%d") }}';
--delete from `beautyplus-bc0ed.sub_dataset.dwd_oda_spm_uuid_five_page_temp`   where date >= '2023-08-01'  ;
insert into `beautyplus-bc0ed.sub_dataset.dwd_oda_spm_uuid_five_page_temp`
  select date, uuid, user_pseudo_id,  event_date, platform, event_name,event_timestamp, session_id, source_feature_content,
    source_click_position,
    cur_page1,
    pre_page1,
    dpre_page1,
    ddpre_page1,
    dddpre_page1,
    cur_page,
    pre_page,
    dpre_page,
    ddpre_page,
    dddpre_page,
    cur_page_content,
    pre_page_content,
    dpre_page_content,
    ddpre_page_content,
    dddpre_page_content,
    SKU_ID,
    app_version,
    country,
    sub_user_type,
    sku_tag,
    device_id
  from
   `beautyplus-bc0ed.sub_dataset.dwd_oda_spm_tmp_result_temp`
      where date >= '{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=3)).strftime("%Y-%m-%d") }}'and date <= '{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=0)).strftime("%Y-%m-%d") }}'
  group by date, uuid, user_pseudo_id, event_date, platform, event_name,event_timestamp, session_id, source_feature_content,source_click_position,
  cur_page1,
  pre_page1,
  dpre_page1,
  ddpre_page1,
  dddpre_page1,
  cur_page,
  pre_page,
  dpre_page,
  ddpre_page,
  dddpre_page,
  cur_page_content,
  pre_page_content,
  dpre_page_content,
  ddpre_page_content,
  dddpre_page_content,
  SKU_ID,
  app_version,
  country,
  sub_user_type,
  sku_tag,
  device_id

