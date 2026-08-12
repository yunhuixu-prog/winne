drop table if exists beautyplus-bc0ed.temp.dws_dz_roi_predict_model_input;
create table beautyplus-bc0ed.temp.dws_dz_roi_predict_model_input as

-- delete from beautyplus-bc0ed.temp.dws_dz_roi_predict_model_input where date between '2023-01-01' and '2023-06-30';
-- insert into beautyplus-bc0ed.temp.dws_dz_roi_predict_model_input

-- 0:目标用户(限制投放当天活跃，后续用户id维表出来了就没有这个限制了)
-- dataintegration-265403.temp.temp_roi_predict_sub_lable_pre，后续改个名字规划一下

with
is_sub as
(
    select *
    from beautyplus-bc0ed.temp.dws_dz_roi_predict_model_pre_all
    where date between '2023-01-01' and '2023-06-30'
)
,
-- 2:素材指标搭建及其他行为指标
other as
(
    select *
    from beautyplus-bc0ed.temp.dws_dz_roi_predict_user_other_behave
    where date between '2023-01-01' and '2023-06-30'
)
,
-- 3:行为指标构建
behave as
(
    select *
    from beautyplus-bc0ed.temp.dws_dz_roi_predict_user_behave
    where date between '2023-01-01' and '2023-06-30'
)
,
-- 4.长期维度指标
other_month as
(
    select *
    from beautyplus-bc0ed.temp.dws_dz_roi_predict_user_behave_month
    where date between '2023-01-01' and '2023-06-30'
)


select i.*
--     ,u.*except(user_pseudo_id)
    ,c.*except(user_pseudo_id,date,Attributed_Touch_Date)
    ,o.*except(user_pseudo_id,date,Attributed_Touch_Date)
    ,m.active_days_90,m.active_days_60,m.active_days_31,m.active_days_14
    ,m.pay_function_click_pv pay_function_click_pv_31
    ,m.free_function_click_pv free_function_click_pv_31
    ,m.free_function_save_pv free_function_save_pv_31
    ,m.aigc_enter_pv aigc_enter_pv_31
    ,m.aigc_use_pv aigc_use_pv_31
    ,m.aigc_save_pv aigc_save_pv_31
    ,m.pop_exposure pop_exposure_31
    ,m.pop_click pop_click_31
    ,m.content_exposure content_exposure_31
    ,m.content_click content_click_31
    ,m.max_module_positon max_module_positon_31
    ,m.sub_page_enter sub_page_enter_31
    ,m.sub_page_click sub_page_click_31
    ,m.max_impression_pv max_impression_pv_31
    ,m.impression_pv impression_pv_31
    ,m.click_pv click_pv_31
    ,m.function_num function_num_31
from is_sub i
-- left join user_profile u
-- on i.user_pseudo_id=u.user_pseudo_id
left join other c
on i.user_pseudo_id=c.user_pseudo_id and i.Attributed_Touch_Date=c.Attributed_Touch_Date and i.date=c.date
left join behave o
on i.user_pseudo_id=o.user_pseudo_id and i.Attributed_Touch_Date=o.Attributed_Touch_Date and i.date=o.date
left join other_month m
on i.user_pseudo_id=m.user_pseudo_id and i.Attributed_Touch_Date=m.Attributed_Touch_Date and i.date=m.date





