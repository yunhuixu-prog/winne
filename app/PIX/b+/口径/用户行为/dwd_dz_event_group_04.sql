--event事件聚合表
--delete from `beautyplus-bc0ed.event_dataset_4.dwd_dz_event_group_04` where event_date>='2023-05-25';
delete from  `beautyplus-bc0ed.event_dataset_4.dwd_dz_event_group_04` where event_date>='{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=3)).strftime("%Y-%m-%d") }}'AND event_date<='{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=0)).strftime("%Y-%m-%d") }}';
insert into `beautyplus-bc0ed.event_dataset_4.dwd_dz_event_group_04`
with
event_info as (
select *
from  `beautyplus-bc0ed.event_dataset_4.dmi_da_event_04_view`
),
event_pre as (
select * from `beautyplus-bc0ed.event_dataset_4.dwd_dz_event_04`
--where event_date>='2023-05-25'
where event_date>='{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=3)).strftime("%Y-%m-%d") }}'AND event_date<='{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=0)).strftime("%Y-%m-%d") }}'
)

SELECT event_date, platform, user_pseudo_id, event_name,  k.key_name, k.value_name, k.event_name_cn, k.module, k.class, k.function, k.subfunction, k.subfunction_a, k.action, k.num, k.mark, count(1) as pv
FROM event_pre, UNNEST(k) as k
group by event_date, platform, user_pseudo_id, event_name,  k.key_name, k.value_name, k.event_name_cn, k.module, k.class, k.function, k.subfunction, k.subfunction_a, k.action, k.num, k.mark

union all
select
c.event_date, c.platform, c.user_pseudo_id, c.event_name,c.key_name,c.value_name,b.event_name,b.module, b.class, b.function, b.subfunction, b.subfunction_a, b.action, b.num, b.level,c.pv
from
(

    SELECT event_date, platform, user_pseudo_id,
    case when k.action in ('点击') and k.class in ('美颜') and k.mark=2 then 'beauty_appr_beau_clk_sum_bd'
    when k.action in ('点击') and k.class in ('创意') and k.mark=2 then 'beauty_appr_creativity_clk_sum_bd'
    when k.action in ('点击') and k.class in ('高级编辑') and k.mark=2 then 'beauty_appr_senior_edit_sum_bd'
    when k.action in ('确认') and k.class in ('美颜') and k.mark=2 then 'beauty_yes_bd'
    when k.action in ('确认') and k.class in ('创意') and k.mark=2 then 'creativity_yes_bd'
    when k.action in ('确认') and k.class in ('编辑') and k.mark=2 then 'edit_yes_bd'
    end  as event_name,
    '-' as key_name, '-' as value_name, count(1)as pv
    FROM event_pre, UNNEST(k) as k
    where k.module in ('修图')
    group by event_date, platform, user_pseudo_id,
    case when k.action in ('点击') and k.class in ('美颜') and k.mark=2 then 'beauty_appr_beau_clk_sum_bd'
    when k.action in ('点击') and k.class in ('创意') and k.mark=2 then 'beauty_appr_creativity_clk_sum_bd'
    when k.action in ('点击') and k.class in ('高级编辑') and k.mark=2 then 'beauty_appr_senior_edit_sum_bd'
    when k.action in ('确认') and k.class in ('美颜') and k.mark=2 then 'beauty_yes_bd'
    when k.action in ('确认') and k.class in ('创意') and k.mark=2 then 'creativity_yes_bd'
    when k.action in ('确认') and k.class in ('编辑') and k.mark=2 then 'edit_yes_bd'
    end

    --视频 2023/05/25新增
    union all

        SELECT event_date, platform, user_pseudo_id,
    case
    when k.action in ('点击') and k.class in ('美颜')  and k.mark=2 then 'video_edit_beauty_add_makeup_clk_sum_bd'
    when k.action in ('点击') and k.class in ('美颜') and k.function not in ('美妆') and k.mark=2 then 'video_edit_beauty_clk_sum_bd'
    when k.action in ('确认') and k.class in ('美颜') and k.mark=2 then 'video_edit_beauty_add_makeup_use_sum_bd'
    when k.action in ('确认') and k.class in ('美颜') and k.function not in ('video_edit_beauty_use_sum_bd') and k.mark=2 then 'video_edit_beauty_use_sum_bd'
    end  as event_name,
    '-' as key_name, '-' as value_name, count(1)as pv
    FROM event_pre, UNNEST(k) as k
    where k.module in ('视频编辑')
    group by event_date, platform, user_pseudo_id,
    case
    when k.action in ('点击') and k.class in ('美颜')  and k.mark=2 then 'video_edit_beauty_add_makeup_clk_sum_bd'
    when k.action in ('点击') and k.class in ('美颜') and k.function not in ('美妆') and k.mark=2 then 'video_edit_beauty_clk_sum_bd'
    when k.action in ('确认') and k.class in ('美颜') and k.mark=2 then 'video_edit_beauty_add_makeup_use_sum_bd'
    when k.action in ('确认') and k.class in ('美颜') and k.function not in ('video_edit_beauty_use_sum_bd') and k.mark=2 then 'video_edit_beauty_use_sum_bd'
    end

    union all

    SELECT event_date, platform, user_pseudo_id, 'beau_text_yes_bd' as event_name, '-' as key_name, '-' as value_name, count(1)as pv
    FROM event_pre, UNNEST(k) as k
    where event_name in ('beau_clk_text_use_bd','beau_clk_font_use_bd')
    group by event_date, platform, user_pseudo_id

    union all

    SELECT event_date, platform, user_pseudo_id, 'beaut_background_yes_bd' as event_name, '-' as key_name, '-' as value_name, count(1)as pv
    FROM event_pre, UNNEST(k) as k
    where event_name in ('beauty_background_texture_use_bd','beauty_background_gradient_use_bd')
    group by event_date, platform, user_pseudo_id

    union all

    select
    a.event_date, a.platform, a.user_pseudo_id, a.event_name, a.key_name,a.value_name, count(1)as pv
    from
    (

    SELECT event_date, platform, user_pseudo_id, event_name,event_timestamp,
    case when  k.class in ('美颜') then '美颜'
    when k.class in ('创意')  then '创意'
    when k.class in ('编辑')  then '编辑'
    when k.class in ('美妆')  then '美妆'
    end as key_name, '-' as value_name
    FROM event_pre, UNNEST(k) as k
    where event_name in ('beautifysave_bd') and k.action in ('保存') and k.module in ('修图')  and mark=2
    group by event_date, platform, user_pseudo_id, event_name, event_timestamp,
    case when  k.class in ('美颜') then '美颜'
    when k.class in ('创意')  then '创意'
    when k.class in ('编辑')  then '编辑'
    when k.class in ('美妆')  then '美妆'
    end

    union all

    SELECT event_date, platform, user_pseudo_id, event_name,event_timestamp,
    k.class as key_name,
    '-' as value_name
    FROM event_pre, UNNEST(k) as k
    where event_name in ('selfiesave_bd','selfietakepic_bd') and k.module in ('拍摄') and k.class in ('美妆','美颜') and mark=2 --5.25增加美颜数据
    group by event_date, platform, user_pseudo_id, event_name, event_timestamp,k.class

   --视频
    union all
        SELECT event_date, platform, user_pseudo_id, event_name,event_timestamp,
    case when  k.class in ('美颜') then '美颜'
    when k.class in ('美颜') and k.function not in ('美妆') then '美颜非美妆'
    when k.class in ('调色')  then '调色'
    when k.class in ('美妆')  then '美妆'
    end as key_name, '-' as value_name
    FROM event_pre, UNNEST(k) as k
    where event_name in ('video_edit_save_bd')  and k.action in ('保存') and k.module in ('视频编辑') and mark=2
    group by event_date, platform, user_pseudo_id, event_name, event_timestamp,
    case when  k.class in ('美颜') then '美颜'
    when k.class in ('美颜') and k.function not in ('美妆') then '美颜非美妆'
    when k.class in ('调色')  then '调色'
    when k.class in ('美妆')  then '美妆'
    end


    )a
    group by
    a.event_date, a.platform, a.user_pseudo_id, a.event_name, a.key_name,a.value_name
)c

join event_info b
 on concat(c.event_name,c.key_name,c.value_name)=concat(b.event_id,'_bd',IFNULL(b.key,'-'),IFNULL(b.value,'-'))



