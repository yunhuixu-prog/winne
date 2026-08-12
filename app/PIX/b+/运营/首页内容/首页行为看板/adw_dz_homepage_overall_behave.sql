-- 首页整体看板
delete from `beautyplus-bc0ed.marvel.ads_dzp_marvel_homepage_overall_behave` where event_date between '{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=3)).strftime("%Y-%m-%d") }}' and '{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=0)).strftime("%Y-%m-%d") }}';
insert into `beautyplus-bc0ed.marvel.ads_dzp_marvel_homepage_overall_behave`
(
    event_date,platform,detail_country,country,is_new,is_UA,is_pay
    ,dau,exposure_uv,exposure_pv,click_uv,click_pv,material_show_pv
    ,time_uv,time_uv_30s,time_uv_1min,time_uv_3min,time_sum_h
    ,position_uv,position_uv_5,position_uv_10,position_uv_20,position_sum
    ,feature_content_show_uv,feature_content_show_pv,feature_content_click_uv,feature_content_click_pv
    ,banner_content_show_uv,banner_content_show_pv,banner_content_click_uv,banner_content_click_pv
    ,reconmend_content_show_uv,reconmend_content_show_pv,reconmend_content_click_uv,reconmend_content_click_pv
    ,topic_content_show_uv,topic_content_show_pv,topic_content_click_uv,topic_content_click_pv
    ,miniapp_content_show_uv,miniapp_content_show_pv,miniapp_content_click_uv,miniapp_content_click_pv
    ,version
    ,selfie_click_uv,selfie_click_pv,edit_click_uv,edit_click_pv
    ,topbanner_content_show_uv,topbanner_content_show_pv,topbanner_content_click_uv,topbanner_content_click_pv
    ,xyz_content_show_uv,xyz_content_show_pv,xyz_content_click_uv,xyz_content_click_pv
    ,tab_click_uv,tab_click_pv,homepage_search_click_uv,homepage_search_click_pv
    ,pop_click_uv,pop_click_pv,vip_click_uv,vip_click_pv
)
with
user_info as
(
    select
        event_date event_date_hk
        ,platform
--         ,case when country in ('South Korea','Thailand','Japan','United States') then country
--           when country in ('Turkey','Saudi Arabia','Egypt','United Arab Emirates','Lebanon','Kuwait','Qatar','Iran') then 'Middle East'
--           else 'WW'
--         end as country
        ,country
        ,user_pseudo_id
        ,max(case when is_new='New users' then 1 else 0 end) is_new
        ,max(is_UA) is_UA
        ,max(is_pay) is_pay
        ,max(version) version
    from
        `beautyplus-bc0ed.event_dataset_2.dws_dz_active_user_02`
    where
        event_date between '{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=3)).strftime("%Y-%m-%d") }}' and '{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=0)).strftime("%Y-%m-%d") }}'
    group by 1,2,3,4
)


select a.event_date,a.platform
    ,a.country detail_country
     ,case when a.country in ('South Korea','Thailand','Japan','United States','Indonesia') then a.country
          when a.country in ('Turkey','Saudi Arabia','Egypt','United Arab Emirates','Lebanon','Kuwait','Qatar','Iran') then 'Middle East'
          else 'WW'
     end as country
    ,case when a.is_new=1 then 'new' else 'old' end is_new,a.is_UA,a.is_pay
    ,a.dau
    ,b.exposure_uv,b.exposure_pv,b.click_uv,b.click_pv,b.material_show_pv
--     ,round(b.exposure_uv/a.dau,4) homepage_exp_ratio_uv
--     ,round(b.click_uv/b.exposure_uv,4) click_ratio_uv
--     ,round(b.exposure_pv/b.exposure_uv,4) exp_times_per
--     ,round(b.click_pv/b.click_uv,4) click_times_per
--     ,round(b.material_show_pv/b.exposure_uv,4) material_show_times_per

    ,c.time_uv,c.time_uv_30s,c.time_uv_1min,c.time_uv_3min,c.time_sum_h
--     ,round(time_uv_30s/time_uv,4) valid_ratio_30s
--     ,round(time_uv_1min/time_uv,4) valid_ratio_1min
--     ,round(time_uv_3min/time_uv,4) valid_ratio_3min
--     ,round(time_sum_h/time_uv*60,4) time_per_min
    ,c.position_uv,c.position_uv_5,c.position_uv_10,c.position_uv_20,c.position_sum
--     ,round(position_uv_5/position_uv,4) position_ratio_5
--     ,round(position_uv_10/position_uv,4) position_ratio_10
--     ,round(position_uv_20/position_uv,4) position_ratio_20
--     ,round(position_sum/position_uv,4) position_per

    ,feature_content_show_uv,feature_content_show_pv,feature_content_click_uv,feature_content_click_pv
    ,banner_content_show_uv,banner_content_show_pv,banner_content_click_uv,banner_content_click_pv
    ,reconmend_content_show_uv,reconmend_content_show_pv,reconmend_content_click_uv,reconmend_content_click_pv
    ,topic_content_show_uv,topic_content_show_pv,topic_content_click_uv,topic_content_click_pv
    ,miniapp_content_show_uv,miniapp_content_show_pv,miniapp_content_click_uv,miniapp_content_click_pv
    ,'all' version
    ,selfie_click_uv,selfie_click_pv,edit_click_uv,edit_click_pv
    ,topbanner_content_show_uv,topbanner_content_show_pv,topbanner_content_click_uv,topbanner_content_click_pv
    ,xyz_content_show_uv,xyz_content_show_pv,xyz_content_click_uv,xyz_content_click_pv
    ,tab_click_uv,tab_click_pv,homepage_search_click_uv,homepage_search_click_pv
    ,pop_click_uv,pop_click_pv,vip_click_uv,vip_click_pv
from
(
    select event_date_hk event_date,platform,country,is_new,is_UA,is_pay,count(user_pseudo_id) dau
    from user_info
    group by 1,2,3,4,5,6
) a
left join
(
    select event_date,platform,country,is_new,is_UA,is_pay
            ,count(distinct case when event_name='homepageappr_bd' then user_pseudo_id end) exposure_uv
            ,sum(case when event_name='homepageappr_bd' then pv end) exposure_pv
            ,count(distinct case when event_name in ('home_content_clk_bd','home_clk_selfie_bd','home_clk_beautify_bd','home_clk_edit_bd','tabbar_clk_bd','material_search_button_clk_bd','home_page_pop_clk_bd','page_event') then user_pseudo_id end) click_uv
            ,sum(case when event_name in ('home_content_clk_bd','home_clk_selfie_bd','home_clk_beautify_bd','home_clk_edit_bd','tabbar_clk_bd','material_search_button_clk_bd','home_page_pop_clk_bd','page_event') then pv end) click_pv
            ,sum(case when event_name='home_content_show_f_bd' and module_type not in ('推荐功能','miniapp','XYZ','Topbanner') then pv end) material_show_pv
    from `beautyplus-bc0ed.temp.dwd_dz_homepage_overall_behave_pre`
    where event_date between '{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=3)).strftime("%Y-%m-%d") }}' and '{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=0)).strftime("%Y-%m-%d") }}'
        and event_name in ('homepageappr_bd','home_content_clk_bd','home_content_show_f_bd','home_clk_selfie_bd','home_clk_beautify_bd','home_clk_edit_bd','tabbar_clk_bd','material_search_button_clk_bd','home_page_pop_clk_bd','page_event')
    group by 1,2,3,4,5,6
) b
on a.event_date = b.event_date and a.platform = b.platform and a.country = b.country
       and a.is_new = b.is_new and a.is_UA = b.is_UA and a.is_pay = b.is_pay
left join
(
    -- 看停留时长,下滑情况
    select event_date,platform,country,is_new,is_UA,is_pay
        ,count(distinct case when time>0 then user_pseudo_id end) time_uv
        ,count(distinct case when time>=30*1000 then user_pseudo_id end) time_uv_30s
        ,count(distinct case when time>=60*1000 then user_pseudo_id end) time_uv_1min
        ,count(distinct case when time>=3*60*1000 then user_pseudo_id end) time_uv_3min
        ,sum(time)/1000/3600 time_sum_h

        ,count(distinct case when max_module_positon>0 then user_pseudo_id end) position_uv
        ,count(distinct case when max_module_positon>=5 then user_pseudo_id end) position_uv_5
        ,count(distinct case when max_module_positon>=10 then user_pseudo_id end) position_uv_10
        ,count(distinct case when max_module_positon>=20 then user_pseudo_id end) position_uv_20
        ,sum(max_module_positon) position_sum
    from
    (
        select event_date,platform,country,is_new,is_UA,is_pay
            ,user_pseudo_id
            ,sum(case when event_name='home_page_time_bd' then time*pv end) time
            ,max(case when event_name='home_content_show_f_bd' then module_positon end) max_module_positon
        from `beautyplus-bc0ed.temp.dwd_dz_homepage_overall_behave_pre`
        where event_date between '{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=3)).strftime("%Y-%m-%d") }}' and '{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=0)).strftime("%Y-%m-%d") }}'
            and event_name in ('home_page_time_bd','home_content_show_f_bd')
        group by 1,2,3,4,5,6,7
    )
    group by 1,2,3,4,5,6
) c
on a.event_date = c.event_date and a.platform = c.platform and a.country = c.country
       and a.is_new = c.is_new and a.is_UA = c.is_UA and a.is_pay = c.is_pay
-- 分模块
left join
(
    select event_date,platform,country,is_new,is_UA,is_pay
    ,count(distinct case when module_type='推荐功能' and event_name='home_content_show_f_bd' then user_pseudo_id end) feature_content_show_uv
    ,sum(case when module_type='推荐功能' and event_name='home_content_show_f_bd' then pv end) feature_content_show_pv
    ,count(distinct case when module_type='推荐功能' and event_name='home_content_clk_bd' then user_pseudo_id end) feature_content_click_uv
    ,sum(case when module_type='推荐功能' and event_name='home_content_clk_bd' then pv end) feature_content_click_pv

    ,count(distinct case when module_type='Banner' and event_name='home_content_show_f_bd' then user_pseudo_id end) banner_content_show_uv
    ,sum(case when module_type='Banner' and event_name='home_content_show_f_bd' then pv end) banner_content_show_pv
    ,count(distinct case when module_type='Banner' and event_name='home_content_clk_bd' then user_pseudo_id end) banner_content_click_uv
    ,sum(case when module_type='Banner' and event_name='home_content_clk_bd' then pv end) banner_content_click_pv

    ,count(distinct case when module_type='推荐配方' and event_name='home_content_show_f_bd' then user_pseudo_id end) reconmend_content_show_uv
    ,sum(case when module_type='推荐配方' and event_name='home_content_show_f_bd' then pv end) reconmend_content_show_pv
    ,count(distinct case when module_type='推荐配方' and event_name='home_content_clk_bd' then user_pseudo_id end) reconmend_content_click_uv
    ,sum(case when module_type='推荐配方' and event_name='home_content_clk_bd' then pv end) reconmend_content_click_pv

    ,count(distinct case when module_type='专题' and event_name='home_content_show_f_bd' then user_pseudo_id end) topic_content_show_uv
    ,sum(case when module_type='专题' and event_name='home_content_show_f_bd' then pv end) topic_content_show_pv
    ,count(distinct case when module_type='专题' and event_name='home_content_clk_bd' then user_pseudo_id end) topic_content_click_uv
    ,sum(case when module_type='专题' and event_name='home_content_clk_bd' then pv end) topic_content_click_pv

    ,count(distinct case when module_type='miniapp' and event_name='home_content_show_f_bd' then user_pseudo_id end) miniapp_content_show_uv
    ,sum(case when module_type='miniapp' and event_name='home_content_show_f_bd' then pv end) miniapp_content_show_pv
    ,count(distinct case when module_type='miniapp' and event_name='home_content_clk_bd' then user_pseudo_id end) miniapp_content_click_uv
    ,sum(case when module_type='miniapp' and event_name='home_content_clk_bd' then pv end) miniapp_content_click_pv

    ,count(distinct case when module_type='Topbanner' and event_name='home_content_show_f_bd' then user_pseudo_id end) topbanner_content_show_uv
    ,sum(case when module_type='Topbanner' and event_name='home_content_show_f_bd' then pv end) topbanner_content_show_pv
    ,count(distinct case when module_type='Topbanner' and event_name='home_content_clk_bd' then user_pseudo_id end) topbanner_content_click_uv
    ,sum(case when module_type='Topbanner' and event_name='home_content_clk_bd' then pv end) topbanner_content_click_pv

    ,count(distinct case when module_type='XYZ' and event_name='home_content_show_f_bd' then user_pseudo_id end) xyz_content_show_uv
    ,sum(case when module_type='XYZ' and event_name='home_content_show_f_bd' then pv end) xyz_content_show_pv
    ,count(distinct case when module_type='XYZ' and event_name='home_content_clk_bd' then user_pseudo_id end) xyz_content_click_uv
    ,sum(case when module_type='XYZ' and event_name='home_content_clk_bd' then pv end) xyz_content_click_pv

    ,count(distinct case when event_name='home_clk_selfie_bd' then user_pseudo_id end) selfie_click_uv
    ,sum(case when event_name='home_clk_selfie_bd' then pv end) selfie_click_pv

    ,count(distinct case when event_name in ('home_clk_beautify_bd','home_clk_edit_bd') then user_pseudo_id end) edit_click_uv
    ,sum(case when event_name in ('home_clk_beautify_bd','home_clk_edit_bd') then pv end) edit_click_pv

    ,count(distinct case when event_name='tabbar_clk_bd' then user_pseudo_id end) tab_click_uv
    ,sum(case when event_name='tabbar_clk_bd' then pv end) tab_click_pv

    ,count(distinct case when event_name in ('material_search_button_clk_bd') then user_pseudo_id end) homepage_search_click_uv
    ,sum(case when event_name in ('material_search_button_clk_bd') then pv end) homepage_search_click_pv

    ,count(distinct case when event_name in ('home_page_pop_clk_bd') then user_pseudo_id end) pop_click_uv
    ,sum(case when event_name in ('home_page_pop_clk_bd') then pv end) pop_click_pv

    ,count(distinct case when event_name in ('page_event') then user_pseudo_id end) vip_click_uv
    ,sum(case when event_name in ('page_event') then pv end) vip_click_pv

    from `beautyplus-bc0ed.temp.dwd_dz_homepage_overall_behave_pre`
    where event_date between '{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=3)).strftime("%Y-%m-%d") }}' and '{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=0)).strftime("%Y-%m-%d") }}'
        and event_name in ('home_content_show_f_bd','home_content_clk_bd','home_clk_selfie_bd','home_clk_beautify_bd','home_clk_edit_bd','tabbar_clk_bd','material_search_button_clk_bd','home_page_pop_clk_bd','page_event')
    group by 1,2,3,4,5,6
) d
on a.event_date = d.event_date and a.platform = d.platform and a.country = d.country
       and a.is_new = d.is_new and a.is_UA = d.is_UA and a.is_pay = d.is_pay

union all

select a.event_date,a.platform
    ,a.country detail_country
     ,case when a.country in ('South Korea','Thailand','Japan','United States','Indonesia') then a.country
          when a.country in ('Turkey','Saudi Arabia','Egypt','United Arab Emirates','Lebanon','Kuwait','Qatar','Iran') then 'Middle East'
          else 'WW'
     end as country
    ,case when a.is_new=1 then 'new' else 'old' end is_new,a.is_UA,a.is_pay
    ,a.dau
    ,b.exposure_uv,b.exposure_pv,b.click_uv,b.click_pv,b.material_show_pv
--     ,round(b.exposure_uv/a.dau,4) homepage_exp_ratio_uv
--     ,round(b.click_uv/b.exposure_uv,4) click_ratio_uv
--     ,round(b.exposure_pv/b.exposure_uv,4) exp_times_per
--     ,round(b.click_pv/b.click_uv,4) click_times_per
--     ,round(b.material_show_pv/b.exposure_uv,4) material_show_times_per

    ,c.time_uv,c.time_uv_30s,c.time_uv_1min,c.time_uv_3min,c.time_sum_h
--     ,round(time_uv_30s/time_uv,4) valid_ratio_30s
--     ,round(time_uv_1min/time_uv,4) valid_ratio_1min
--     ,round(time_uv_3min/time_uv,4) valid_ratio_3min
--     ,round(time_sum_h/time_uv*60,4) time_per_min
    ,c.position_uv,c.position_uv_5,c.position_uv_10,c.position_uv_20,c.position_sum
--     ,round(position_uv_5/position_uv,4) position_ratio_5
--     ,round(position_uv_10/position_uv,4) position_ratio_10
--     ,round(position_uv_20/position_uv,4) position_ratio_20
--     ,round(position_sum/position_uv,4) position_per

    ,feature_content_show_uv,feature_content_show_pv,feature_content_click_uv,feature_content_click_pv
    ,banner_content_show_uv,banner_content_show_pv,banner_content_click_uv,banner_content_click_pv
    ,reconmend_content_show_uv,reconmend_content_show_pv,reconmend_content_click_uv,reconmend_content_click_pv
    ,topic_content_show_uv,topic_content_show_pv,topic_content_click_uv,topic_content_click_pv
    ,miniapp_content_show_uv,miniapp_content_show_pv,miniapp_content_click_uv,miniapp_content_click_pv
    ,a.version
    ,selfie_click_uv,selfie_click_pv,edit_click_uv,edit_click_pv
    ,topbanner_content_show_uv,topbanner_content_show_pv,topbanner_content_click_uv,topbanner_content_click_pv
    ,xyz_content_show_uv,xyz_content_show_pv,xyz_content_click_uv,xyz_content_click_pv
    ,tab_click_uv,tab_click_pv,homepage_search_click_uv,homepage_search_click_pv
    ,pop_click_uv,pop_click_pv,vip_click_uv,vip_click_pv
from
(
    select event_date_hk event_date,platform,country,is_new,is_UA,is_pay,version,count(user_pseudo_id) dau
    from user_info
    group by 1,2,3,4,5,6,7
) a
left join
(
    select event_date,platform,country,is_new,is_UA,is_pay,version
            ,count(distinct case when event_name='homepageappr_bd' then user_pseudo_id end) exposure_uv
            ,sum(case when event_name='homepageappr_bd' then pv end) exposure_pv
            ,count(distinct case when event_name in ('home_content_clk_bd','home_clk_selfie_bd','home_clk_beautify_bd','home_clk_edit_bd','tabbar_clk_bd','material_search_button_clk_bd','home_page_pop_clk_bd','page_event') then user_pseudo_id end) click_uv
            ,sum(case when event_name in ('home_content_clk_bd','home_clk_selfie_bd','home_clk_beautify_bd','home_clk_edit_bd','tabbar_clk_bd','material_search_button_clk_bd','home_page_pop_clk_bd','page_event') then pv end) click_pv
            ,sum(case when event_name='home_content_show_f_bd' and module_type not in ('推荐功能','miniapp','XYZ','Topbanner') then pv end) material_show_pv
    from `beautyplus-bc0ed.temp.dwd_dz_homepage_overall_behave_pre`
    where event_date between '{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=3)).strftime("%Y-%m-%d") }}' and '{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=0)).strftime("%Y-%m-%d") }}'
        and event_name in ('homepageappr_bd','home_content_clk_bd','home_content_show_f_bd','home_clk_selfie_bd','home_clk_beautify_bd','home_clk_edit_bd','tabbar_clk_bd','material_search_button_clk_bd','home_page_pop_clk_bd','page_event')
    group by 1,2,3,4,5,6,7
) b
on a.event_date = b.event_date and a.platform = b.platform and a.country = b.country
       and a.is_new = b.is_new and a.is_UA = b.is_UA and a.is_pay = b.is_pay and a.version = b.version
left join
(
    -- 看停留时长,下滑情况
    select event_date,platform,country,is_new,is_UA,is_pay,version
        ,count(distinct case when time>0 then user_pseudo_id end) time_uv
        ,count(distinct case when time>=30*1000 then user_pseudo_id end) time_uv_30s
        ,count(distinct case when time>=60*1000 then user_pseudo_id end) time_uv_1min
        ,count(distinct case when time>=3*60*1000 then user_pseudo_id end) time_uv_3min
        ,sum(time)/1000/3600 time_sum_h

        ,count(distinct case when max_module_positon>0 then user_pseudo_id end) position_uv
        ,count(distinct case when max_module_positon>=5 then user_pseudo_id end) position_uv_5
        ,count(distinct case when max_module_positon>=10 then user_pseudo_id end) position_uv_10
        ,count(distinct case when max_module_positon>=20 then user_pseudo_id end) position_uv_20
        ,sum(max_module_positon) position_sum
    from
    (
        select event_date,platform,country,is_new,is_UA,is_pay,version
            ,user_pseudo_id
            ,sum(case when event_name='home_page_time_bd' then time*pv end) time
            ,max(case when event_name='home_content_show_f_bd' then module_positon end) max_module_positon
        from `beautyplus-bc0ed.temp.dwd_dz_homepage_overall_behave_pre`
        where event_date between '{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=3)).strftime("%Y-%m-%d") }}' and '{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=0)).strftime("%Y-%m-%d") }}'
            and event_name in ('home_page_time_bd','home_content_show_f_bd')
        group by 1,2,3,4,5,6,7,8
    )
    group by 1,2,3,4,5,6,7
) c
on a.event_date = c.event_date and a.platform = c.platform and a.country = c.country
       and a.is_new = c.is_new and a.is_UA = c.is_UA and a.is_pay = c.is_pay and a.version = c.version
-- 分模块
left join
(
    select event_date,platform,country,is_new,is_UA,is_pay,version
    ,count(distinct case when module_type='推荐功能' and event_name='home_content_show_f_bd' then user_pseudo_id end) feature_content_show_uv
    ,sum(case when module_type='推荐功能' and event_name='home_content_show_f_bd' then pv end) feature_content_show_pv
    ,count(distinct case when module_type='推荐功能' and event_name='home_content_clk_bd' then user_pseudo_id end) feature_content_click_uv
    ,sum(case when module_type='推荐功能' and event_name='home_content_clk_bd' then pv end) feature_content_click_pv

    ,count(distinct case when module_type='Banner' and event_name='home_content_show_f_bd' then user_pseudo_id end) banner_content_show_uv
    ,sum(case when module_type='Banner' and event_name='home_content_show_f_bd' then pv end) banner_content_show_pv
    ,count(distinct case when module_type='Banner' and event_name='home_content_clk_bd' then user_pseudo_id end) banner_content_click_uv
    ,sum(case when module_type='Banner' and event_name='home_content_clk_bd' then pv end) banner_content_click_pv

    ,count(distinct case when module_type='推荐配方' and event_name='home_content_show_f_bd' then user_pseudo_id end) reconmend_content_show_uv
    ,sum(case when module_type='推荐配方' and event_name='home_content_show_f_bd' then pv end) reconmend_content_show_pv
    ,count(distinct case when module_type='推荐配方' and event_name='home_content_clk_bd' then user_pseudo_id end) reconmend_content_click_uv
    ,sum(case when module_type='推荐配方' and event_name='home_content_clk_bd' then pv end) reconmend_content_click_pv

    ,count(distinct case when module_type='专题' and event_name='home_content_show_f_bd' then user_pseudo_id end) topic_content_show_uv
    ,sum(case when module_type='专题' and event_name='home_content_show_f_bd' then pv end) topic_content_show_pv
    ,count(distinct case when module_type='专题' and event_name='home_content_clk_bd' then user_pseudo_id end) topic_content_click_uv
    ,sum(case when module_type='专题' and event_name='home_content_clk_bd' then pv end) topic_content_click_pv

    ,count(distinct case when module_type='miniapp' and event_name='home_content_show_f_bd' then user_pseudo_id end) miniapp_content_show_uv
    ,sum(case when module_type='miniapp' and event_name='home_content_show_f_bd' then pv end) miniapp_content_show_pv
    ,count(distinct case when module_type='miniapp' and event_name='home_content_clk_bd' then user_pseudo_id end) miniapp_content_click_uv
    ,sum(case when module_type='miniapp' and event_name='home_content_clk_bd' then pv end) miniapp_content_click_pv

    ,count(distinct case when module_type='Topbanner' and event_name='home_content_show_f_bd' then user_pseudo_id end) topbanner_content_show_uv
    ,sum(case when module_type='Topbanner' and event_name='home_content_show_f_bd' then pv end) topbanner_content_show_pv
    ,count(distinct case when module_type='Topbanner' and event_name='home_content_clk_bd' then user_pseudo_id end) topbanner_content_click_uv
    ,sum(case when module_type='Topbanner' and event_name='home_content_clk_bd' then pv end) topbanner_content_click_pv

    ,count(distinct case when module_type='XYZ' and event_name='home_content_show_f_bd' then user_pseudo_id end) xyz_content_show_uv
    ,sum(case when module_type='XYZ' and event_name='home_content_show_f_bd' then pv end) xyz_content_show_pv
    ,count(distinct case when module_type='XYZ' and event_name='home_content_clk_bd' then user_pseudo_id end) xyz_content_click_uv
    ,sum(case when module_type='XYZ' and event_name='home_content_clk_bd' then pv end) xyz_content_click_pv

    ,count(distinct case when event_name='home_clk_selfie_bd' then user_pseudo_id end) selfie_click_uv
    ,sum(case when event_name='home_clk_selfie_bd' then pv end) selfie_click_pv

    ,count(distinct case when event_name in ('home_clk_beautify_bd','home_clk_edit_bd') then user_pseudo_id end) edit_click_uv
    ,sum(case when event_name in ('home_clk_beautify_bd','home_clk_edit_bd') then pv end) edit_click_pv

    ,count(distinct case when event_name='tabbar_clk_bd' then user_pseudo_id end) tab_click_uv
    ,sum(case when event_name='tabbar_clk_bd' then pv end) tab_click_pv

    ,count(distinct case when event_name in ('material_search_button_clk_bd') then user_pseudo_id end) homepage_search_click_uv
    ,sum(case when event_name in ('material_search_button_clk_bd') then pv end) homepage_search_click_pv

    ,count(distinct case when event_name in ('home_page_pop_clk_bd') then user_pseudo_id end) pop_click_uv
    ,sum(case when event_name in ('home_page_pop_clk_bd') then pv end) pop_click_pv

    ,count(distinct case when event_name in ('page_event') then user_pseudo_id end) vip_click_uv
    ,sum(case when event_name in ('page_event') then pv end) vip_click_pv

    from `beautyplus-bc0ed.temp.dwd_dz_homepage_overall_behave_pre`
    where event_date between '{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=3)).strftime("%Y-%m-%d") }}' and '{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=0)).strftime("%Y-%m-%d") }}'
        and event_name in ('home_content_show_f_bd','home_content_clk_bd','home_clk_selfie_bd','home_clk_beautify_bd','home_clk_edit_bd','tabbar_clk_bd','material_search_button_clk_bd','home_page_pop_clk_bd','page_event')
    group by 1,2,3,4,5,6,7
) d
on a.event_date = d.event_date and a.platform = d.platform and a.country = d.country
       and a.is_new = d.is_new and a.is_UA = d.is_UA and a.is_pay = d.is_pay and a.version = d.version


