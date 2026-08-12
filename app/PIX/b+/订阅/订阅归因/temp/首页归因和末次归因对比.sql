select source_feature_content,count(distinct user_pseudo_id) uv,count(1) pv
FROM `beautyplus-bc0ed.sub_dataset.dwd_oda_spm_uuid_five_page_temp`
where date between '2025-01-27' and '2025-02-23'
    and event_name in ('subscription_try_suc')
    and (pre_page_content in ('BP_POP_00001638','BP_POP_00001639')
        or dpre_page_content in ('BP_POP_00001638','BP_POP_00001639')
        or ddpre_page_content in ('BP_POP_00001638','BP_POP_00001639')
        or dddpre_page_content in ('BP_POP_00001638','BP_POP_00001639')
        )
group by 1

select count(distinct user_pseudo_id) uv,count(1) pv
FROM `beautyplus-bc0ed.sub_dataset.dwd_oda_spm_uuid_five_page_temp`
where date between '2025-01-27' and '2025-02-23'
    and event_name in ('subscription_try_suc')
    and (pre_page_content in ('BP_POP_00001638','BP_POP_00001639')
        or dpre_page_content in ('BP_POP_00001638','BP_POP_00001639')
        or ddpre_page_content in ('BP_POP_00001638','BP_POP_00001639')
        or dddpre_page_content in ('BP_POP_00001638','BP_POP_00001639')
        )


select *
FROM `beautyplus-bc0ed.sub_dataset.dwd_oda_spm_uuid_five_page_temp`
where date between '2025-01-27' and '2025-02-23'
    and event_name in ('subscription_try_suc')
    and (pre_page_content in ('BP_POP_00001638','BP_POP_00001639')
        or dpre_page_content in ('BP_POP_00001638','BP_POP_00001639')
        or ddpre_page_content in ('BP_POP_00001638','BP_POP_00001639')
        or dddpre_page_content in ('BP_POP_00001638','BP_POP_00001639')
        )
    and source_feature_content!='Plump'


select event_date,event_timestamp,event_name
         ,`beautyplus-bc0ed.func.getParams`(event_params,'cur_spm').string_value cur_spm
          ,`beautyplus-bc0ed.func.getParams`(event_params,'pop_id').string_value pop_id
        ,`dataintegration-265403.func`.getParams(event_params,'label').string_value label
        ,`dataintegration-265403.func`.getParams(event_params,'source_click_position').string_value source_click_position
        ,`dataintegration-265403.func`.getParams(event_params,'source_feature_content').string_value source_feature_content
        ,`dataintegration-265403.func`.getParams(event_params,'pre_spm').string_value pre_spm
        ,`dataintegration-265403.func`.getParams(event_params,'pre_page_content').string_value pre_page_content
        ,`dataintegration-265403.func`.getParams(event_params,'dpre_page_content').string_value dpre_page_content
from `dataintegration-265403.analytics.dwd_dzp_events_function`('2025-02-17', '2025-02-17', 'BeautyPlus', false)
where user_pseudo_id='D4990D634E114811864A7028575EEA5C'
-- and event_timestamp>=1739754234470012
and event_name in ('page_event','home_page_pop_clk_bd')
order by event_timestamp

