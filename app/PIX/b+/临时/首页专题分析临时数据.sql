
select event_date,platform,version_type
    ,sum(dau) dau
    ,sum(topic_content_show_uv) topic_content_show_uv
    ,sum(topic_content_show_pv) topic_content_show_pv
    ,sum(topic_content_click_uv) topic_content_click_uv
    ,sum(topic_content_click_pv) topic_content_click_pv
    ,sum(sub_uv) sub_uv
--     ,sum(sub_pay_uv) sub_pay_uv,sum(sub_revenue) sub_revenue
from
(
    select event_date,platform,case when version>='7.7.000' then '>=7.7.000' else '<7.7.000' end version_type
            ,sum(dau) dau
            ,sum(topic_content_show_uv) topic_content_show_uv
            ,sum(topic_content_show_pv) topic_content_show_pv
            ,sum(topic_content_click_uv) topic_content_click_uv
            ,sum(topic_content_click_pv) topic_content_click_pv
            ,0 sub_uv,0 sub_pay_uv,0.0 sub_revenue
    from `beautyplus-bc0ed.marvel.ads_dzp_marvel_homepage_overall_behave`
    where event_date between date_sub('2025-03-15',interval 179 day) and '2025-03-15'
        and version!='all'
    group by 1,2,3

    union all

    select event_date,platform,Version_status version_type
        ,0 dau,0 topic_content_show_uv,0 topic_content_show_pv,0 topic_content_click_uv,0 topic_content_click_pv
        ,sum(Sub) sub_uv,sum(Sub_Pay) sub_pay_uv,sum(Revenue) sub_revenue
    from `beautyplus-bc0ed.Duffle_dataset.ads_dz_marvel2_home_content_new`
    where event_date between date_sub('2025-03-15',interval 179 day) and '2025-03-15'
        and level_type='content_id' and data_type='uv'
        and app_name='BeautyPlus'
        and module='专题'
--         and content_id !=''
    group by 1,2,3
)
group by 1,2,3


-- 分享保存数据

select event_date date,source
        ,sum(enter_uv) enter_uv
        ,sum(enter_pv) enter_pv
        ,sum(save_uv) save_uv
        ,sum(save_pv) save_pv
        ,sum(share_uv) share_uv
        ,sum(share_pv) share_pv
from
(
    select a.event_date,a.source
        ,0 enter_uv
        ,0 enter_pv
        ,0 save_uv
        ,0 save_pv
        ,count(distinct a.user_pseudo_id) share_uv
        ,sum(a.pv) share_pv
    from
    (
        select
            event_date
            ,case when event_name='share_page_clk_bd' and `dataintegration-265403.func`.getParams(event_params,'module').string_value='修图' then 'edit'
                  when event_name='share_page_clk_bd' and `dataintegration-265403.func`.getParams(event_params,'module').string_value='自拍' then 'camera'
            end source
            ,user_pseudo_id
            ,count(1) pv
        from
            `dataintegration-265403.analytics.dwd_dzp_events_function`('2024-09-17', '2025-03-15', 'beautyplus', false)
        where event_name = 'share_page_clk_bd'
                and `dataintegration-265403.func`.getParams(event_params,'module').string_value in ('修图','自拍')  --电影模式也是自拍,iphone模式没有分享
        group by 1,2,3
    ) a
    join `dataintegration-265403.stat.stat_active_advice_detail_d` b
    on a.event_date=b.event_date_hk and a.user_pseudo_id=b.user_pseudo_id
    group by 1,2

    union all

    -- 功能表现
    select
        event_date
        ,case when event_name_en in ('Total Camera Enter','Total Camera Save') then 'camera'
              when event_name_en in ('Edit Enter','Edit Save') then 'edit'
        end source
        ,sum(case when event_name_en in ('Total Camera Enter','Edit Enter') then uv end) enter_uv
        ,sum(case when event_name_en in ('Total Camera Enter','Edit Enter') then pv end) enter_pv
        ,sum(case when event_name_en in ('Total Camera Save','Edit Save') then uv end) save_uv
        ,sum(case when event_name_en in ('Total Camera Save','Edit Save') then pv end) save_pv
        ,0 share_uv
        ,0 share_pv
    from
        beautyplus-bc0ed.event_dataset.ads_dz_event_edit_01
    where
        data='V4.0'
        and event_date between date_sub('2025-03-15',interval 179 day) and '2025-03-15'
        and event_name_en in ('Total Camera Enter','Total Camera Save','Edit Enter','Edit Save')
    group by
        1,2
)
group by 1,2

union all
-- H5
select date,'H5' source
        ,sum(visit_uv) enter_uv
        ,sum(visit_pv) enter_pv
        ,sum(save_uv) save_uv
        ,sum(save_pv) save_pv
        ,sum(share_uv) share_uv
        ,sum(share_pv) share_pv
from `dataintegration-265403.temp.dws_ds_xyz_project_behavior_overall`
where date between date_sub('2025-03-15',interval 179 day) and '2025-03-15'
    and app_name='BeautyPlus'
    and source='H5'
    and entry='All'
    and project_name not in ('Tooniverse','iPhone Cam')
group by 1,2

-- 分享带来的新增看一看有没有吧
select
    `dataintegration-265403.func`.getParams(event_params,'onelink_source').string_value onelink_source
    ,count(1)
from
    `dataintegration-265403.analytics.dwd_dzp_events_function`('2025-03-15', '2025-03-15', 'beautyplus', false)
where event_name = 'link_app_start_bd'
group by 1
;
select
    `dataintegration-265403.func`.getParams(event_params,'APP启动来源').string_value source
    ,count(1)
from
    `dataintegration-265403.analytics.dwd_dzp_events_function`('2025-03-15', '2025-03-15', 'beautyplus', false)
where event_name = 'starpageappr_bd'
group by 1