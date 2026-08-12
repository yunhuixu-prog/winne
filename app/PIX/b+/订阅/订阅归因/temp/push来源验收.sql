-- 基本source_feature_content和source_click_position都是空的,pre_spm是1007首页
select *
from
(
    select (b.event_timestamp-a.event_timestamp)/1000000 timediff
        ,row_number() over(partition by b.user_pseudo_id order by b.event_timestamp) ranks
        ,*
    from
    (
        select event_date,event_timestamp,user_pseudo_id
        from `dataintegration-265403.analytics.dwd_dzp_events_function`('2025-04-18', '2025-04-21', 'BeautyPlus', false)
        where event_name = 'notification_open'
            and (`dataintegration-265403.func`.getParams(event_params,'label').string_value like '%PUSH_187%'
                or `dataintegration-265403.func`.getParams(event_params,'label').string_value like '%PUSH_188%'
                or `dataintegration-265403.func`.getParams(event_params,'label').string_value like '%PUSH_189%'
                )
    ) a
    left join
    (
        select event_date,event_timestamp,user_pseudo_id
             ,`dataintegration-265403.func`.getParams(event_params,'source_click_position').string_value source_click_position
             ,`dataintegration-265403.func`.getParams(event_params,'source_feature_content').string_value source_feature_content
             ,`dataintegration-265403.func`.getParams(event_params,'pre_spm').string_value pre_spm
        from `dataintegration-265403.analytics.dwd_dzp_events_function`('2025-04-18', '2025-04-21', 'BeautyPlus', false)
        where event_name = 'page_event'
            and `beautyplus-bc0ed.func.decodeSpmNew`(`beautyplus-bc0ed.func.getParams`(event_params,'cur_spm').string_value).page_id='1009'
    ) b
    on b.event_timestamp-a.event_timestamp>=0 and b.event_timestamp-a.event_timestamp<=30000000 and a.user_pseudo_id=b.user_pseudo_id
)
where ranks=1
;

-- push后的跳转流程(建议下载个包尝试一下)
select event_date,event_timestamp,event_name,user_pseudo_id
        ,`beautyplus-bc0ed.func.getParams`(event_params,'cur_spm').string_value
        ,`dataintegration-265403.func`.getParams(event_params,'label').string_value
        ,`dataintegration-265403.func`.getParams(event_params,'source_click_position').string_value source_click_position
        ,`dataintegration-265403.func`.getParams(event_params,'source_feature_content').string_value source_feature_content
        ,`dataintegration-265403.func`.getParams(event_params,'pre_spm').string_value pre_spm
    from `dataintegration-265403.analytics.dwd_dzp_events_function`('2024-12-02', '2024-12-02', 'BeautyPlus', false)
    where user_pseudo_id='0068489cb5455b6fda7e4df36e3bfa7d'  --1bb7589ada987b41a4020cd9bfd7ada1
order by event_timestamp
;

-- 测试包有没有上报成功：上报成功，并且看了上报流程，是先到首页，再跳到订阅页
select event_date,event_timestamp,user_pseudo_id,platform
         ,`dataintegration-265403.func`.getParams(event_params,'source_click_position').string_value source_click_position
         ,`dataintegration-265403.func`.getParams(event_params,'source_feature_content').string_value source_feature_content
         ,`dataintegration-265403.func`.getParams(event_params,'pre_spm').string_value pre_spm
    from `beautyplus-test.analytics_152810462.events_intraday_20241202`
    where event_name = 'page_event'
        and `beautyplus-bc0ed.func.decodeSpmNew`(`beautyplus-bc0ed.func.getParams`(event_params,'cur_spm').string_value).page_id='1009'
        and `dataintegration-265403.func`.getParams(event_params,'source_feature_content').string_value like '%push%'
;
select event_date,(event_timestamp-1733122863893030)/1000000 second,timestamp_add(timestamp_micros(event_timestamp), interval 8 hour) times,event_name
         ,`beautyplus-bc0ed.func.getParams`(event_params,'cur_spm').string_value
        ,`dataintegration-265403.func`.getParams(event_params,'label').string_value
        ,`dataintegration-265403.func`.getParams(event_params,'source_click_position').string_value source_click_position
        ,`dataintegration-265403.func`.getParams(event_params,'source_feature_content').string_value source_feature_content
        ,`dataintegration-265403.func`.getParams(event_params,'pre_spm').string_value pre_spm
from `beautyplus-test.analytics_152810462.events_intraday_20241202`
where user_pseudo_id='0D13C090DE6E4B548CC3430374A16B92'
    -- and event_name in ('page_event','subscription_clk_try','notification_open','first_open','starpageappr_bd','bp_app_start_bd','sub_page_imp_bd','homepageappr_bd')
    and event_timestamp>=1733122863893030 and event_timestamp<=1733122874322201
order by event_timestamp
;
-- 正式包测试
select * from `dataintegration-265403.temp.valentine_push_sub_data_temp`
where event_name='subscription_try_suc'
limit 100

select event_date,event_timestamp,event_name
         ,`beautyplus-bc0ed.func.getParams`(event_params,'cur_spm').string_value
        ,`dataintegration-265403.func`.getParams(event_params,'label').string_value
        ,`dataintegration-265403.func`.getParams(event_params,'source_click_position').string_value source_click_position
        ,`dataintegration-265403.func`.getParams(event_params,'source_feature_content').string_value source_feature_content
        ,`dataintegration-265403.func`.getParams(event_params,'pre_spm').string_value pre_spm
from `dataintegration-265403.analytics.dwd_dzp_events_function`('2025-02-13', '2025-02-13', 'BeautyPlus', false)
where user_pseudo_id='3E9CC934D2EC4A378AAC102E2A2D12F7'
    and event_name in ('notification_open')
--     and event_timestamp>=1739451962703005
order by event_timestamp

select event_date,event_timestamp,user_pseudo_id,platform
     ,`dataintegration-265403.func`.getParams(event_params,'source_click_position').string_value source_click_position
     ,`dataintegration-265403.func`.getParams(event_params,'source_feature_content').string_value source_feature_content
     ,`dataintegration-265403.func`.getParams(event_params,'pre_spm').string_value pre_spm
from `dataintegration-265403.analytics.dwd_dzp_events_function`('2025-02-13', '2025-02-17', 'BeautyPlus', false)
where event_name = 'page_event'
    and `beautyplus-bc0ed.func.decodeSpmNew`(`beautyplus-bc0ed.func.getParams`(event_params,'cur_spm').string_value).page_id='1009'
    and `dataintegration-265403.func`.getParams(event_params,'source_feature_content').string_value like '%push%'






