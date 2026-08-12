
-- 问题列
select date,source_feature_content,source_click_position,pre_page,event_timestamp,user_pseudo_id
FROM `beautyplus-bc0ed.sub_dataset.dwd_oda_spm_uuid_five_page_temp`
where date between '2025-01-27' and '2025-02-23'
--     and event_name in ('page_event')
    and event_name in ('subscription_try_suc')
    and source_feature_content like '%FacialReshape%'  --
    and source_feature_content like '%TON%'  -- 肤色
--     and source_feature_content like '%RetouchHD%'  -- ai焕颜
--     and source_feature_content in ('Remover','Classic Remover','AI Remover')  -- 消除笔
    and (pre_page like '自拍预览页%' or  pre_page like '拍后确认页_拍摄%')

-- 事件明细

select event_date,event_timestamp,event_name,version
         ,`beautyplus-bc0ed.func.getParams`(event_params,'cur_spm').string_value cur_spm
        ,`dataintegration-265403.func`.getParams(event_params,'label').string_value label
        ,`dataintegration-265403.func`.getParams(event_params,'source_click_position').string_value source_click_position
        ,`dataintegration-265403.func`.getParams(event_params,'source_feature_content').string_value source_feature_content
        ,`dataintegration-265403.func`.getParams(event_params,'pre_spm').string_value pre_spm
from `dataintegration-265403.analytics.dwd_dzp_events_function`('2025-02-19', '2025-02-19', 'BeautyPlus', false)
where user_pseudo_id='dfb9f9a5438d5afa6b957d39e0480839'
--     and event_name in ('subscription_try_suc')
    and event_timestamp>=1739968963797135-60000000
order by event_timestamp



