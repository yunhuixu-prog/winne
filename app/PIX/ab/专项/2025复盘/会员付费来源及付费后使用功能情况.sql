-- 会员因为什么订阅以及之后7天内用的什么功能
drop table if exists dataintegration-265403.temp.winne_temp_sub_user_use_function;
create table dataintegration-265403.temp.winne_temp_sub_user_use_function as

with sub_event as (
    select
        distinct event_date,user_pseudo_id,platform,country,duration
        ,CASE
            WHEN first in ('Edit') THEN first
            ELSE 'Else'
        END first
        ,CASE
            WHEN first in ('Edit') and second in ('Retouch','Edit','Material') THEN third
            ELSE 'Else'
        END second
    from `airbrush-1324.stat.dws_airbrush_trial_sub_grads`
    where event_date between '2025-01-01' and '2025-12-31'
            and first!='A' and second!='A' and (third!='A' or third is null) and fourth='A'
            and event_name ='sub_suc'
)
,function_use as
(
    select
        event_date,user_pseudo_id
        ,function1,function2
        ,count(case when action='使用' then 1 end) use_pv
        ,count(case when action='保存' then 1 end) save_pv
    FROM
      `dataintegration-265403.dwd.dwd_dzp_behavior_ab_edit_detail`
    WHERE
        event_date between '2025-01-01' and date_add('2025-12-31', interval 7 day)
        and app_name='AirBrush'
        and function0='修图'
        and function_level='2' and function1 is not null and function2 is not null
    group by 1,2,3,4
)

select s.*,u.event_date function_date,u.function1,u.function2,u.use_pv,u.save_pv
from sub_event s
left join function_use u
on s.user_pseudo_id=u.user_pseudo_id and u.event_date between s.event_date and date_add(s.event_date, interval 6 day)


;
select a.second,a.sub_uv
--      ,b.function1
     ,b.is_sub_function,b.use_uv
from
(
    select
        if(REGEXP_CONTAINS(second, r'\d{8}$') OR REGEXP_CONTAINS(second, r'^[A-Z]+_[A-Z]+_\d+_[A-Za-z0-9]+$'),second
            ,REPLACE(REPLACE(REPLACE(INITCAP(REGEXP_REPLACE(second, '_', ' ')), 'F ', ''),'Ai','AI'),'P ','')) second
        ,count(distinct user_pseudo_id) sub_uv
    from dataintegration-265403.temp.winne_temp_sub_user_use_function
    group by 1
) a
left join
(
    select second,case when second=function2 then 1 else 0 end is_sub_function
        ,count(distinct user_pseudo_id) use_uv
    from
    (
        select distinct
                if(REGEXP_CONTAINS(second, r'\d{8}$') OR REGEXP_CONTAINS(second, r'^[A-Z]+_[A-Z]+_\d+_[A-Za-z0-9]+$'),second
                ,REPLACE(REPLACE(REPLACE(INITCAP(REGEXP_REPLACE(second, '_', ' ')), 'F ', ''),'Ai','AI'),'P ','')) second
        --         ,function1
                ,case when function2='Background Adjust' then 'Background'
                when function2 in ('Texture','Volume','Color','Hairstyles','Hairline','Hairdye Finetune') then 'Hair'
                else function2
                end function2,user_pseudo_id
        --         ,count(distinct case when save_pv>0 then user_pseudo_id end) save_uv
        from dataintegration-265403.temp.winne_temp_sub_user_use_function
        where use_pv>0
    )
    group by 1,2
) b
on a.second=b.second

;
select a.second,a.sub_uv
--      ,b.function1
     ,b.function2,b.use_uv
from
(
    select
        if(REGEXP_CONTAINS(second, r'\d{8}$') OR REGEXP_CONTAINS(second, r'^[A-Z]+_[A-Z]+_\d+_[A-Za-z0-9]+$'),second
            ,REPLACE(REPLACE(REPLACE(INITCAP(REGEXP_REPLACE(second, '_', ' ')), 'F ', ''),'Ai','AI'),'P ','')) second
        ,count(distinct user_pseudo_id) sub_uv
    from dataintegration-265403.temp.winne_temp_sub_user_use_function
    group by 1
) a
left join
(
    select
        if(REGEXP_CONTAINS(second, r'\d{8}$') OR REGEXP_CONTAINS(second, r'^[A-Z]+_[A-Z]+_\d+_[A-Za-z0-9]+$'),second
            ,REPLACE(REPLACE(REPLACE(INITCAP(REGEXP_REPLACE(second, '_', ' ')), 'F ', ''),'Ai','AI'),'P ','')) second
--         ,function1
        ,case when function2='Background Adjust' then 'Background'
              when function2 in ('Texture','Volume','Color','Hairstyles','Hairline','Hairdye Finetune') then 'Hair'
        else function2
        end function2
        ,count(distinct case when use_pv>0 then user_pseudo_id end) use_uv
--         ,count(distinct case when save_pv>0 then user_pseudo_id end) save_uv
    from dataintegration-265403.temp.winne_temp_sub_user_use_function
    group by 1,2
) b
on a.second=b.second
;

select 'sub' type,first,second,round(sum(uv)/12) uv
from
(
    select date_trunc(event_date, month) event_date,first
        ,if(REGEXP_CONTAINS(second, r'\d{8}$') OR REGEXP_CONTAINS(second, r'^[A-Z]+_[A-Z]+_\d+_[A-Za-z0-9]+$'),second
            ,REPLACE(REPLACE(REPLACE(INITCAP(REGEXP_REPLACE(second, '_', ' ')), 'F ', ''),'Ai','AI'),'P ','')) second
        ,count(distinct user_pseudo_id) uv
    from dataintegration-265403.temp.winne_temp_sub_user_use_function
    where second!='Else'
    group by 1,2,3
)
group by 1,2,3

union all

select 'use' type,first,second,round(sum(uv)/12) uv
from
(
    select date_trunc(event_date, month) event_date
        ,function1 first
        ,case when function2='Background Adjust' then 'Background'
              when function2 in ('Texture','Volume','Color','Hairstyles','Hairline','Hairdye Finetune') then 'Hair'
        else function2
        end second
        ,count(distinct case when use_pv>0 then user_pseudo_id end) uv
    from dataintegration-265403.temp.winne_temp_sub_user_use_function
    where use_pv>0
    group by 1,2,3
)
group by 1,2,3
