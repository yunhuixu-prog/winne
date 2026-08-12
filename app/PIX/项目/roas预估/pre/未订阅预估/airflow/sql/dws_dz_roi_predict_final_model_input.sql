DECLARE mDATE_START DATE DEFAULT '{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=7)).strftime("%Y-%m-%d") }}';
DECLARE mDATE_END DATE DEFAULT '{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=0)).strftime("%Y-%m-%d") }}';

-- drop table if exists beautyplus-bc0ed.temp.dws_dz_roi_predict_final_model_input;
-- create table beautyplus-bc0ed.temp.dws_dz_roi_predict_final_model_input as

delete from beautyplus-bc0ed.temp.dws_dz_roi_predict_final_model_input where date between mDATE_START and mDATE_END;
insert into beautyplus-bc0ed.temp.dws_dz_roi_predict_final_model_input

with
-- sub根据uuid去重，会比下面两张表的id少
is_sub as
(
    select *
    from beautyplus-bc0ed.temp.dws_dz_roi_predict_now_user_sub
    where date between mDATE_START and mDATE_END
)
,
-- 2:投放后7天行为指标
behave_7 as
(
    select *
    from beautyplus-bc0ed.temp.dws_dz_roi_predict_first_week_user_behave
    where date between DATE_ADD(DATE_SUB(mDATE_START, INTERVAL 364 DAY), INTERVAL 6 DAY) and mDATE_END
)
,
-- 3:近X天行为指标
behave as
(
    select *
    from beautyplus-bc0ed.temp.dws_dz_roi_predict_now_user_behave
    where date between mDATE_START and mDATE_END
)


select i.*
    ,c.*except(user_pseudo_id,date,Attributed_Touch_Date,types)
    ,o.*except(user_pseudo_id,date,Attributed_Touch_Date,types)
    ,date_diff(i.date,i.Attributed_Touch_Date,DAY) days
    ,case when coalesce(free_duffle_click_pv,0)=0 and coalesce(pay_duffle_click_pv,0)=0 then null
           else coalesce(pay_duffle_click_pv,0)/(coalesce(free_duffle_click_pv,0)+coalesce(pay_duffle_click_pv,0))
     end pay_duffle_click_ratio
     ,case when coalesce(free_duffle_click_pv_31,0)=0 and coalesce(pay_duffle_click_pv_31,0)=0 then null
           else coalesce(pay_duffle_click_pv_31,0)/(coalesce(free_duffle_click_pv_31,0)+coalesce(pay_duffle_click_pv_31,0))
     end pay_duffle_click_ratio_31

     ,case when coalesce(free_function_click_pv,0)=0 and coalesce(pay_function_click_pv,0)=0 then null
           else coalesce(pay_function_click_pv,0)/(coalesce(free_function_click_pv,0)+coalesce(pay_function_click_pv,0))
     end pay_function_click_ratio
     ,case when coalesce(free_function_click_pv_31,0)=0 and coalesce(pay_function_click_pv_31,0)=0 then null
           else coalesce(pay_function_click_pv_31,0)/(coalesce(free_function_click_pv_31,0)+coalesce(pay_function_click_pv_31,0))
     end pay_function_click_ratio_31

from (select * from is_sub where Attributed_Touch_Date between DATE_SUB(date, INTERVAL 6 DAY) and date) i
left join behave_7 c
on i.user_pseudo_id=c.user_pseudo_id and i.Attributed_Touch_Date=c.Attributed_Touch_Date and i.date=c.date and i.types=c.types
left join behave o
on i.user_pseudo_id=o.user_pseudo_id and i.Attributed_Touch_Date=o.Attributed_Touch_Date and i.date=o.date and i.types=o.types


union all

select i.*
    ,c.*except(user_pseudo_id,date,Attributed_Touch_Date,types)
    ,o.*except(user_pseudo_id,date,Attributed_Touch_Date,types)
    ,date_diff(i.date,i.Attributed_Touch_Date,DAY) days
    ,case when coalesce(free_duffle_click_pv,0)=0 and coalesce(pay_duffle_click_pv,0)=0 then null
           else coalesce(pay_duffle_click_pv,0)/(coalesce(free_duffle_click_pv,0)+coalesce(pay_duffle_click_pv,0))
     end pay_duffle_click_ratio
     ,case when coalesce(free_duffle_click_pv_31,0)=0 and coalesce(pay_duffle_click_pv_31,0)=0 then null
           else coalesce(pay_duffle_click_pv_31,0)/(coalesce(free_duffle_click_pv_31,0)+coalesce(pay_duffle_click_pv_31,0))
     end pay_duffle_click_ratio_31

     ,case when coalesce(free_function_click_pv,0)=0 and coalesce(pay_function_click_pv,0)=0 then null
           else coalesce(pay_function_click_pv,0)/(coalesce(free_function_click_pv,0)+coalesce(pay_function_click_pv,0))
     end pay_function_click_ratio
     ,case when coalesce(free_function_click_pv_31,0)=0 and coalesce(pay_function_click_pv_31,0)=0 then null
           else coalesce(pay_function_click_pv_31,0)/(coalesce(free_function_click_pv_31,0)+coalesce(pay_function_click_pv_31,0))
     end pay_function_click_ratio_31

from (select * from is_sub where Attributed_Touch_Date between DATE_SUB(date, INTERVAL 364 DAY) and DATE_SUB(date, INTERVAL 7 DAY)) i
left join (select * from behave_7 where Attributed_Touch_Date=DATE_SUB(date, INTERVAL 6 DAY)) c
on i.user_pseudo_id=c.user_pseudo_id and i.Attributed_Touch_Date=c.Attributed_Touch_Date and i.types=c.types
left join behave o
on i.user_pseudo_id=o.user_pseudo_id and i.Attributed_Touch_Date=o.Attributed_Touch_Date and i.date=o.date and i.types=o.types




