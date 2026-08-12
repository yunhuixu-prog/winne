
-- temp
select *
FROM `dataintegration-265403.analytics.dwd_dzp_events_function`('2025-05-30','2025-05-30','beautyplus',false)
WHERE event_name in('beautifysave_bd') --,'camera_appr_bd','ai_editor_save_suc_bd'
  and `dataintegration-265403.func`.compare_is_greater_or_equal_version(app_info.version,'7.10.0')
  and `dataintegration-265403.func`.getParams(event_params,'trace_info').string_value is null
limit 100
;

select event_name,event_timestamp
    ,`beautyplus-bc0ed.func`.decodeSpmNew(`dataintegration-265403.func`.getParams(event_params,'cur_spm').string_value).page_id
    ,`dataintegration-265403.func`.getParams(event_params,'trace_info').string_value trace_info
    ,case when coalesce(`dataintegration-265403.func`.getParams(event_params,'pre_page_content').string_value,'0') != '0'
            then `dataintegration-265403.func`.getParams(event_params,'pre_page_content').string_value
          when coalesce(`dataintegration-265403.func`.getParams(event_params,'dpre_page_content').string_value,'0') != '0'
            then `dataintegration-265403.func`.getParams(event_params,'dpre_page_content').string_value
    end content
    ,`dataintegration-265403.func`.getParams(event_params,'enter_source').string_value enter_source
FROM `dataintegration-265403.analytics.dwd_dzp_events_function`('2025-05-30','2025-05-30','beautyplus',false)
WHERE `dataintegration-265403.func`.compare_is_greater_or_equal_version(app_info.version,'7.10.0')
  and user_pseudo_id='13551b8b23646349e938591ab1b9b9cf'
order by event_timestamp
;





drop table if exists `beautyplus-bc0ed.temp.dwd_trace_id_operation_event_pre`;
create table if not exists `beautyplus-bc0ed.temp.dwd_trace_id_operation_event_pre` as


select event_date,user_pseudo_id,event_name,event_timestamp,platform
        ,case when event_name in ('beauty_appr_bd') then
                if(coalesce(`dataintegration-265403.func`.getParams(event_params,'pre_page_content').string_value,'0') != '0'
                    ,`dataintegration-265403.func`.getParams(event_params,'pre_page_content').string_value
                    ,`dataintegration-265403.func`.getParams(event_params,'dpre_page_content').string_value)
              when event_name in ('camera_appr_bd') then
                  if(coalesce(`dataintegration-265403.func`.getParams(event_params,'enter_source_id').string_value,'0') != '0'
                      ,`dataintegration-265403.func`.getParams(event_params,'enter_source_id').string_value
                      ,`dataintegration-265403.func`.getParams(event_params,'enter_source').string_value)
              when event_name in ('h5_enter_bd','single_function_enter_bd') then `dataintegration-265403.func`.getParams(event_params,'from').string_value
              end as source
        ,case when coalesce(`dataintegration-265403.func`.getParams(event_params,'pre_page_content').string_value,'0') != '0'
                then `dataintegration-265403.func`.getParams(event_params,'pre_page_content').string_value
              when coalesce(`dataintegration-265403.func`.getParams(event_params,'dpre_page_content').string_value,'0') != '0'
                then `dataintegration-265403.func`.getParams(event_params,'dpre_page_content').string_value
        end content
        ,`dataintegration-265403.func`.getParams(event_params,'enter_source').string_value enter_source
        ,`dataintegration-265403.func`.getParams(event_params,'enter_source_id').string_value enter_source_id
        ,`dataintegration-265403.func`.getParams(event_params,'homepage_func_id').string_value homepage_func_id
        ,`dataintegration-265403.func`.getParams(event_params,'trace_info').string_value trace_info
    FROM `dataintegration-265403.analytics.dwd_dzp_events_function`('2025-05-20','2025-05-30','beautyplus',false)
    WHERE (
        event_name in ('beauty_appr_bd'
                       ,'camera_appr_bd','selfie_appr_bd','iphone_mode_appr_bd','stamp_cam_appr_bd','glow_cam_appr_bd','film_cam_appr_bd' -- 后面几个还没加上source且理论上不该用到后面几个，只是camera是后加的埋点
                       ,'h5_enter_bd','single_function_enter_bd'

                       ,'beautifysave_bd'
                       ,'selfiesave_bd','iphone_mode_save_bd','stamp_cam_save_bd','glow_cam_save_bd','film_cam_save_bd'
                       ,'h5_page_button_clk_bd','h5_page_button_clk'
                       ,'ai_editor_save_suc_bd'
                       ,'subscription_try_suc','subscription_clk_try')
        OR (event_name IN ('page_event') AND
            `beautyplus-bc0ed.func`.decodeSpmNew(`dataintegration-265403.func`.getParams(event_params,'cur_spm').string_value).page_id
                    IN ('1009','1008_01') )
        )
        and `dataintegration-265403.func`.compare_is_greater_or_equal_version(app_info.version,'7.10.0')


-- 缺失值的情况
select event_name,platform
    ,if(trace_info is not null,1,0) is_trace_info
    ,count(1) pv
from `beautyplus-bc0ed.temp.dwd_trace_id_operation_event_pre`
group by 1,2,3
order by 1,2,3
;
-- 几个direct source的情况
select event_name
    ,count(1) pv
    ,count(case when content like 'BP_%' then 1 end) content_pv
    ,count(case when enter_source_id like 'BP_%' then 1 end) enter_source_pv
    ,count(case when homepage_func_id like 'BP_%' then 1 end) homepage_func_pv
from `beautyplus-bc0ed.temp.dwd_trace_id_operation_event_pre`
group by 1
order by 1
;
-- 进入事件的source值
select event_name,if(coalesce(source,'0')!='0',1,0) has_source
    ,count(1) pv
from `beautyplus-bc0ed.temp.dwd_trace_id_operation_event_pre`
where event_name in ('beauty_appr_bd','camera_appr_bd','h5_enter_bd')
    and trace_info is not null
group by 1,2
order by 1,2

-- trace_id和spm和直接上报的差别

drop table if exists `beautyplus-bc0ed.temp.dws_trace_id_operation_event`;
create table if not exists `beautyplus-bc0ed.temp.dws_trace_id_operation_event` as

select a.event_date
    , a.trace_info
    , a.user_pseudo_id
    , a.event_name target_event
    , coalesce(b.event_name,c.event_name) enter_event
    , coalesce(b.source,c.source) trace_source
    , a.content direct_source_content
    , a.enter_source direct_source_enter
    , a.homepage_func_id direct_source_homepage_func
    , '-' spm_source, '-' source_feature_content, '-' source_click_position, '-' pre_page, '-' dpre_page
from
(
    -- 保存
    select * from `beautyplus-bc0ed.temp.dwd_trace_id_operation_event_pre`
    where event_name in ('beautifysave_bd','selfiesave_bd','glow_cam_save_bd','iphone_mode_save_bd','stamp_cam_save_bd','film_cam_save_bd')
) a
left join
(
    -- 进入
    select *
    from
    (
        select event_date,user_pseudo_id,event_name,source,trace_info
             ,row_number() over(partition by event_date,user_pseudo_id,event_name,trace_info order by event_timestamp) orders
        from `beautyplus-bc0ed.temp.dwd_trace_id_operation_event_pre`
        where event_name in ('beauty_appr_bd','camera_appr_bd','h5_enter_bd')
            and trace_info is not null
    )
    where orders=1
) b
on a.trace_info=b.trace_info and a.event_date=b.event_date and a.user_pseudo_id=b.user_pseudo_id
left join
(
    -- 进入:这几个事件还没有加入进入来源
    select *
    from
    (
        select distinct event_date,user_pseudo_id,event_name,source,trace_info
            ,row_number() over(partition by event_date,user_pseudo_id,trace_info order by event_timestamp) orders
        from `beautyplus-bc0ed.temp.dwd_trace_id_operation_event_pre`
        where event_name in ('selfie_appr_bd','iphone_mode_appr_bd','stamp_cam_appr_bd','glow_cam_appr_bd','film_cam_appr_bd')
            and trace_info is not null
    )
    where orders=1
) c
on a.trace_info=c.trace_info and a.event_date=c.event_date and a.user_pseudo_id=c.user_pseudo_id

union all

select a.event_date
    , a.trace_info
    , a.user_pseudo_id
    , a.event_name target_event
    , coalesce(b.event_name,c.event_name) enter_event
    , coalesce(b.source,c.source) trace_source
    , a.content direct_source_content
    , a.enter_source direct_source_enter
    , a.homepage_func_id direct_source_homepage_func
    , d.spm_source, d.source_feature_content, d.source_click_position, d.pre_page, d.dpre_page
from
(
    -- 订阅
    select * from `beautyplus-bc0ed.temp.dwd_trace_id_operation_event_pre`
    where event_name in ('subscription_try_suc','subscription_clk_try','page_event')
) a
left join
(
    -- 进入
    select *
    from
    (
        select event_date,user_pseudo_id,event_name,source,trace_info
             ,row_number() over(partition by event_date,user_pseudo_id,event_name,trace_info order by event_timestamp) orders
        from `beautyplus-bc0ed.temp.dwd_trace_id_operation_event_pre`
        where event_name in ('beauty_appr_bd','camera_appr_bd','h5_enter_bd')
            and trace_info is not null
    )
    where orders=1
) b
on a.trace_info=b.trace_info and a.event_date=b.event_date and a.user_pseudo_id=b.user_pseudo_id
left join
(
    -- 进入:这几个事件还没有加入进入来源
    select *
    from
    (
        select distinct event_date,user_pseudo_id,event_name,source,trace_info
            ,row_number() over(partition by event_date,user_pseudo_id,trace_info order by event_timestamp) orders
        from `beautyplus-bc0ed.temp.dwd_trace_id_operation_event_pre`
        where event_name in ('selfie_appr_bd','iphone_mode_appr_bd','stamp_cam_appr_bd','glow_cam_appr_bd','film_cam_appr_bd')
            and trace_info is not null
    )
    where orders=1
) c
on a.trace_info=c.trace_info and a.event_date=c.event_date and a.user_pseudo_id=c.user_pseudo_id
left join
(
    -- spm
    select date,user_pseudo_id,event_name,event_timestamp
        ,CASE
          WHEN coalesce(pre_page_content,'0') != '0' THEN pre_page_content
          WHEN coalesce(dpre_page_content,'0') != '0' THEN dpre_page_content
          WHEN coalesce(ddpre_page_content,'0') != '0' THEN ddpre_page_content
          WHEN coalesce(dddpre_page_content,'0') != '0' THEN dddpre_page_content
        end spm_source,source_feature_content,source_click_position,pre_page,dpre_page
    from `beautyplus-bc0ed.sub_dataset.dwd_oda_spm_uuid_five_page_temp`
    where date between '2025-05-20' and '2025-05-30'
        and `dataintegration-265403.func`.compare_is_greater_or_equal_version(app_version,'7.10.0')
        and (event_name IN ('subscription_try_suc','subscription_clk_try')
            OR (event_name IN ('page_event') AND cur_page IN ('订阅页','OnboardingPage订阅页') )
        )
) d
on a.event_date=d.date and a.user_pseudo_id=d.user_pseudo_id and a.event_timestamp=d.event_timestamp and a.event_name=d.event_name
;



select *
from `beautyplus-bc0ed.temp.dws_trace_id_operation_event`
limit 100
;

-- 对比：先看整体的量级，再看具体是否是一个id
select event_date,target_event
     ,count(distinct user_pseudo_id) uv
     ,count(distinct case when trace_info is not null then user_pseudo_id end) has_trace_uv
     ,count(distinct case when trace_source is not null then user_pseudo_id end) has_trace_from_uv
     ,count(distinct case when trace_source like 'BP_%' then user_pseudo_id end) trace_uv
     ,count(distinct case when direct_source_content like 'BP_%' then user_pseudo_id end) direct_source_content_uv
     ,count(distinct case when direct_source_enter like 'BP_%' then user_pseudo_id end) direct_source_enter_uv
     ,count(distinct case when direct_source_homepage_func like 'BP_%' then user_pseudo_id end) direct_source_homepage_func_uv
     ,count(distinct case when spm_source like 'BP_%' then user_pseudo_id end) spm_source_uv
from `beautyplus-bc0ed.temp.dws_trace_id_operation_event`
-- where
--     case when target_event in ('page_event','subscription_try_suc','subscription_clk_try')
--             then (source_click_position!='H5页面' or source_click_position is null) -- 非从H5进入的
--                      and direct_source_content not in ('BP_POP_00001671','BP_TB_00000079') -- 非直接订阅运营位进入的
--     else 1=1
-- end
group by 1,2
order by 1,2
;

select target_event,trace_source,direct_source_content,direct_source_enter,direct_source_homepage_func,spm_source,count(1) pv
from `beautyplus-bc0ed.temp.dws_trace_id_operation_event`
where trace_info is not null and target_event is not null
    and (trace_source like 'BP_%' or direct_source_content like 'BP_%' or direct_source_enter like 'BP_%' or direct_source_homepage_func like 'BP_%' or spm_source like 'BP_%')
group by 1,2,3,4,5,6


-- 不一样的用户对比
select spm_source,count(1)
from `beautyplus-bc0ed.temp.dws_trace_id_operation_event`
where target_event='page_event' and spm_source like 'BP_%' and trace_source not like 'BP_%'
group by 1
order by 2 desc
;
select *
from `beautyplus-bc0ed.temp.dws_trace_id_operation_event`
where target_event='page_event' and spm_source like 'BP_%' and trace_source not like 'BP_%'
    and spm_source='BP_KKAA_00000026'
limit 100
;
-- 明细对比
-- 问题用户1（traceid少）:直接通过订阅类运营位进入订阅页，无traceid，到时候还要加一层处理逻辑，问下静静怎么处理的
select event_name,event_timestamp
    ,`beautyplus-bc0ed.func`.decodeSpmNew(`dataintegration-265403.func`.getParams(event_params,'cur_spm').string_value).page_id
    ,`dataintegration-265403.func`.getParams(event_params,'trace_info').string_value trace_info
    ,coalesce(`dataintegration-265403.func`.getParams(event_params,'pre_page_content').string_value,`dataintegration-265403.func`.getParams(event_params,'dpre_page_content').string_value) content
    ,`dataintegration-265403.func`.getParams(event_params,'enter_source').string_value enter_source
FROM `dataintegration-265403.analytics.dwd_dzp_events_function`('2025-05-26','2025-05-26','beautyplus',false)
WHERE `dataintegration-265403.func`.compare_is_greater_or_equal_version(app_info.version,'7.10.0')
  and user_pseudo_id='eab41169da99acc8e84410c2930a77fc'
order by event_timestamp

-- 问题用户2（traceid少）:进入H5的,包括ai editor等
select event_name,event_timestamp
    ,`beautyplus-bc0ed.func`.decodeSpmNew(`dataintegration-265403.func`.getParams(event_params,'cur_spm').string_value).page_id
    ,`dataintegration-265403.func`.getParams(event_params,'trace_info').string_value trace_info
    ,coalesce(`dataintegration-265403.func`.getParams(event_params,'pre_page_content').string_value,`dataintegration-265403.func`.getParams(event_params,'dpre_page_content').string_value) content
    ,`dataintegration-265403.func`.getParams(event_params,'enter_source').string_value enter_source
FROM `dataintegration-265403.analytics.dwd_dzp_events_function`('2025-05-26','2025-05-26','beautyplus',false)
WHERE `dataintegration-265403.func`.compare_is_greater_or_equal_version(app_info.version,'7.10.0')
  and user_pseudo_id='63c6e7b5eb2954349c15a529b74ff017'
order by event_timestamp

-- 问题用户3（traceid少）:拍照进入事件少了traceidinfo，关联不到或者关联到了非第一个进入事件，正在处理了
select event_name,event_timestamp
    ,`beautyplus-bc0ed.func`.decodeSpmNew(`dataintegration-265403.func`.getParams(event_params,'cur_spm').string_value).page_id
    ,`dataintegration-265403.func`.getParams(event_params,'trace_info').string_value trace_info
    ,coalesce(`dataintegration-265403.func`.getParams(event_params,'pre_page_content').string_value,`dataintegration-265403.func`.getParams(event_params,'dpre_page_content').string_value) content
    ,`dataintegration-265403.func`.getParams(event_params,'enter_source').string_value enter_source
FROM `dataintegration-265403.analytics.dwd_dzp_events_function`('2025-05-26','2025-05-26','beautyplus',false)
WHERE `dataintegration-265403.func`.compare_is_greater_or_equal_version(app_info.version,'7.10.0')
  and user_pseudo_id='1ff20fe73d7af92d5cfbf6a8f4eac936'
order by event_timestamp

select event_name,event_timestamp
    ,`beautyplus-bc0ed.func`.decodeSpmNew(`dataintegration-265403.func`.getParams(event_params,'cur_spm').string_value).page_id
    ,`dataintegration-265403.func`.getParams(event_params,'trace_info').string_value trace_info
    ,`dataintegration-265403.func`.getParams(event_params,'pre_page_content').string_value
    ,`dataintegration-265403.func`.getParams(event_params,'dpre_page_content').string_value
    ,`dataintegration-265403.func`.getParams(event_params,'enter_source').string_value enter_source
    ,`dataintegration-265403.func`.getParams(event_params,'enter_source_id').string_value enter_source_id
FROM `dataintegration-265403.analytics.dwd_dzp_events_function`('2025-05-28','2025-05-28','beautyplus',false)
WHERE `dataintegration-265403.func`.compare_is_greater_or_equal_version(app_info.version,'7.10.0')
  and user_pseudo_id='eabec1d083d7afbe541af3e3c57a3e2f'
order by event_timestamp


-- 问题4（traceid少）:通过运营位进入拍后页再进入修图的用户订阅的话，spm5步归因算，traceid不算
select event_name,event_timestamp
    ,`beautyplus-bc0ed.func`.decodeSpmNew(`dataintegration-265403.func`.getParams(event_params,'cur_spm').string_value).page_id
    ,`dataintegration-265403.func`.getParams(event_params,'trace_info').string_value trace_info
    ,coalesce(`dataintegration-265403.func`.getParams(event_params,'pre_page_content').string_value,`dataintegration-265403.func`.getParams(event_params,'dpre_page_content').string_value) content
    ,`dataintegration-265403.func`.getParams(event_params,'enter_source').string_value enter_source
FROM `dataintegration-265403.analytics.dwd_dzp_events_function`('2025-05-26','2025-05-26','beautyplus',false)
WHERE `dataintegration-265403.func`.compare_is_greater_or_equal_version(app_info.version,'7.10.0')
  and user_pseudo_id='1ff20fe73d7af92d5cfbf6a8f4eac936'
order by event_timestamp

-- 问题5（traceid少）:拍摄保存时重新上报进入拍照页，第一次进入拍照页没有上报到traceid，保存下后进入拍照页上报了traceid来自保存返回，关联到了第二次
select event_name,event_timestamp
    ,`beautyplus-bc0ed.func`.decodeSpmNew(`dataintegration-265403.func`.getParams(event_params,'cur_spm').string_value).page_id
    ,`dataintegration-265403.func`.getParams(event_params,'trace_info').string_value trace_info
    ,coalesce(`dataintegration-265403.func`.getParams(event_params,'pre_page_content').string_value,`dataintegration-265403.func`.getParams(event_params,'dpre_page_content').string_value) content
    ,`dataintegration-265403.func`.getParams(event_params,'enter_source').string_value enter_source
FROM `dataintegration-265403.analytics.dwd_dzp_events_function`('2025-05-26','2025-05-26','beautyplus',false)
WHERE `dataintegration-265403.func`.compare_is_greater_or_equal_version(app_info.version,'7.10.0')
  and user_pseudo_id='1ff20fe73d7af92d5cfbf6a8f4eac936'
order by event_timestamp


