select *
from beautyplus-bc0ed.Duffle_dataset.dwd_home_module_position_new
where event_date>='2024-07-12'
    and event_name in ('home_content_clk_bd','home_content_show_f_bd') and platform='IOS'
    and version>='7.7.114'
limit 10
;
select event_date,tab_name
     ,count(distinct case when event_name = 'home_content_show_f_bd' then user_pseudo_id end) exp_uv
     ,count(case when event_name = 'home_content_show_f_bd' then 1 end) exp_pv
     ,count(distinct case when event_name = 'home_content_clk_bd' then user_pseudo_id end) clk_uv
     ,count(case when event_name = 'home_content_clk_bd' then 1 end) clk_pv
from beautyplus-bc0ed.Duffle_dataset.dwd_home_module_position_new
where event_date>='2024-07-12'
    and event_name in ('home_content_clk_bd','home_content_show_f_bd')
    and version>='7.7.114'
    and platform='IOS'
    and module_type not in ('推荐功能','横幅')
group by 1,2
order by 1,3 desc


