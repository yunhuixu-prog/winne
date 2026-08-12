drop table if exists `dataintegration-265403.temp.temp_xyz_loudou_t`;
create table if not exists `dataintegration-265403.temp.temp_xyz_loudou_t` as

with event as
(
    select
        event_date
        ,platform
        ,app_name
        ,event_timestamp
        ,event_name
        ,event_params
        ,user_properties
        ,user_pseudo_id
        ,geo.country
    from
        -- `beautyplus-bc0ed.analytics.ods_dz_events_tv`('2023-10-16', '2023-10-30')
        `dataintegration-265403.analytics.dwd_dzp_events_function`('2024-12-01', '2025-05-22', 'beautyplus,airbrush', false)
    where
        event_name in ('h5_page_event_bd','h5_page_event','h5_page_button_clk_bd','h5_page_button_clk','h5_page_view_bd','h5_page_view','h5_credit_consume_bd','h5_page_template_clk_bd','h5_page_template_clk','h5_page_template_exp_bd','h5_page_template_exp')
)
select
    event_date
    ,platform
    ,country
    ,event_name
    ,app_name
    ,func.getParams(event_params,'lang').string_value lang
    ,func.getParams(event_params,'project').string_value project
    ,func.getParams(event_params,'内容ID').string_value miniapp_content_id
    ,func.getParams(event_params,'page_id').string_value page_id
    ,func.getParams(event_params,'button_type').string_value button_type
    ,func.getParams(event_params,'save_type').string_value save_type
    ,func.getParams(event_params,'theme_type').string_value theme_type
    ,func.getParams(event_params,'is_from_push').string_value is_from_push
    ,coalesce(func.getParams(event_params,'from_page').string_value,func.getParams(event_params,'entry').string_value) from_page
    ,func.getParams(event_params,'theme').string_value theme
    ,func.getParams(event_params,'url').string_value url
    ,func.getParams(event_params,'source').string_value source
    ,func.getParams(event_params,'credit_amount').string_value credit_amount
    ,func.getParams(event_params,'order_id').string_value order_id
    ,func.getUserprop(user_properties,'hwgid').string_value hwgid
    ,user_pseudo_id
from
    event
where
    case    when event_name in ('h5_page_event_bd','h5_page_event','h5_page_view_bd','h5_page_view','h5_page_button_clk_bd','h5_page_button_clk','h5_credit_consume_bd','h5_page_template_clk_bd','h5_page_template_clk','h5_page_template_exp_bd','h5_page_template_exp')
                    then func.getParams(event_params,'project').string_value in ('ai_filter','ai_portrait')
            else 1=0
            end
;

drop table if exists `dataintegration-265403.temp.temp_xyz_new_user_t`;
create table if not exists `dataintegration-265403.temp.temp_xyz_new_user_t` as

select e.user_pseudo_id,project,min(event_date) first_enter_date
from `dataintegration-265403.temp.dwd_ds_xyz_project_behavior` e
join `dataintegration-265403.stat.stat_active_advice_detail_d` b
on e.user_pseudo_id=b.user_pseudo_id and b.event_date_hk=event_date and e.app_name=b.app_name
where (event_name in ('h5_page_event_bd','h5_page_event') and page_id in ('homepage','home_page_view') and event_date<='2024-11-18')
          or (event_name in ('h5_page_event_bd','h5_page_event') and page_id in ('homepage','home_page_view') and project in ('AI_Pet_Portray') and event_date<='2024-12-13')
          or (event_name in ('h5_page_visit_bd','h5_page_visit') and event_date>'2024-11-18' and project not in ('AI_Pet_Portray'))
          or (event_name in ('h5_page_visit_bd','h5_page_visit') and event_date>'2024-12-13' and project in ('AI_Pet_Portray'))
group by 1,2
;

select
    e.app_name,e.event_date,e.from_page,e.project,e.platform
    ,case when n.first_enter_date<e.event_date then 0 else 1 end is_project_new
    ,case
            when event_name in ('h5_page_event_bd','h5_page_event') and page_id in ('home_page_view','homepage') then '1 进入首页-fu'

            when event_name in ('h5_page_event_bd','h5_page_event') and e.project='ai_filter' and page_id='album_page_view' then '2 AI Filter-进入相册页'
            when event_name in ('h5_page_event_bd','h5_page_event') and e.project='ai_filter' and page_id in ('bundle_page_view1','bundle_page_view2','confirm_page_view','video_confirm_page_view') then '3 AI Filter-进入照片确认页'
            when event_name in ('h5_page_button_clk_bd','h5_page_button_clk') and e.project='ai_filter' and button_type='generate' then '4 AI Filter 生成效果'
            when event_name in ('h5_page_event_bd','h5_page_event') and e.project='ai_filter' and page_id='list_page_view' then '5-1 AI Filter 进入列表页'
            when event_name in ('h5_page_button_clk_bd','h5_page_button_clk') and e.project='ai_filter' and button_type='check_later' then '5-2 AI Filter 点击check later'
            when event_name in ('h5_page_event_bd','h5_page_event') and e.project='ai_filter' and page_id='generated_page_view' then '5-3 AI Filter 进入生成页'
            when event_name in ('h5_page_button_clk_bd','h5_page_button_clk') and e.project='ai_filter' and button_type='view' then '5-4 AI Filter 点击生成图片'
            when event_name in ('h5_page_button_clk_bd','h5_page_button_clk') and e.project='ai_filter' and button_type in ('save','save_all','save_video') then '6 AI Filter 点击保存图片'
            when event_name in ('h5_page_button_clk_bd','h5_page_button_clk') and e.project='ai_filter' and button_type = 'share' then '7 AI Filter 点击分享'

            when event_name in ('h5_page_view_bd','h5_page_view') and e.project='ai_portrait' and page_id='style_page' then '2 AI Portrait-进入风格生成页'
            when event_name in ('h5_page_event_bd','h5_page_event') and e.project='ai_portrait' and page_id='model_create_page' then '3-1 AI Portrait-进入模型创建页'
            when event_name in ('h5_page_button_clk_bd','h5_page_button_clk') and e.project='ai_portrait' and button_type='model_upload' then '3-2 AI Portrait-上传模型'
            when event_name in ('h5_page_button_clk_bd','h5_page_button_clk') and e.project='ai_portrait' and button_type='model_train' then '3-3 AI Portrait-训练模型'
            when event_name in ('h5_page_button_clk_bd','h5_page_button_clk') and e.project='ai_portrait' and button_type='generate' then '4 AI Portrait-生成效果'
            when event_name in ('h5_page_event_bd','h5_page_event') and e.project='ai_portrait' and page_id='generated_page' then '5 AI Portrait-进入生成页'
            when event_name in ('h5_page_button_clk_bd','h5_page_button_clk') and e.project='ai_portrait' and button_type='thumbnail' then '6 AI Portrait-点击生成图片'
            when event_name in ('h5_page_template_exp_bd','h5_page_template_exp') and e.project='ai_portrait' then '7-1 AI Portrait-配方曝光'
            when event_name in ('h5_page_template_clk_bd','h5_page_template_clk') and e.project='ai_portrait' then '7-2 AI Portrait-配方点击'
            when event_name in ('h5_page_button_clk_bd','h5_page_button_clk') and e.project='ai_portrait' and button_type in ('save','save_all','save_video') then '7-3 AI Portrait-点击保存图片'
            when event_name in ('h5_page_button_clk_bd','h5_page_button_clk') and e.project='ai_portrait' and button_type = 'share' then '8 AI Portrait-点击分享'
--             else event_name
            end ch_event_name
    -- ,page_id
    -- ,button_type
    -- ,theme
    ,count(distinct e.user_pseudo_id) uv
    ,count(1) pv
from
    `dataintegration-265403.temp.temp_xyz_loudou_t` e
    join `dataintegration-265403.stat.stat_active_advice_detail_d` b on e.user_pseudo_id=b.user_pseudo_id and b.event_date_hk=event_date and e.app_name=b.app_name
left join `dataintegration-265403.temp.temp_xyz_new_user_t` n on e.user_pseudo_id=n.user_pseudo_id and e.project=n.project
where
case when event_name in ('h5_page_button_clk_bd','h5_page_button_clk') and button_type = 'save'
                    and e.project = 'ai_filter' and event_date>='2024-12-31' and theme_type='photo' then save_type is not null
     else 1=1
end
group by
    1,2,3,4,5,6,7

union all

select
    e.app_name,e.event_date,e.from_page,e.project,e.platform
    ,case when n.first_enter_date<e.event_date then 0 else 1 end is_project_new
    ,'1:进入首页' ch_event_name
    -- ,page_id
    -- ,button_type
    -- ,theme
    ,count(distinct case
            when event_name in ('h5_page_event_bd','h5_page_event','h5_page_view_bd','h5_page_view') and page_id in ('home_page_view','homepage','style_page','album_page_view')
            then e.user_pseudo_id
            end) uv
    ,null pv
from
    `dataintegration-265403.temp.temp_xyz_loudou_t` e
    join `dataintegration-265403.stat.stat_active_advice_detail_d` b on e.user_pseudo_id=b.user_pseudo_id and b.event_date_hk=event_date and e.app_name=b.app_name
left join `dataintegration-265403.temp.temp_xyz_new_user_t` n on e.user_pseudo_id=n.user_pseudo_id and e.project=n.project
where
case when event_name in ('h5_page_button_clk_bd','h5_page_button_clk') and button_type = 'save'
                    and e.project = 'ai_filter' and event_date>='2024-12-31' and theme_type='photo' then save_type is not null
     else 1=1
end
group by
    1,2,3,4,5,6,7

;
-- 保存进了表 beautyplus-bc0ed.temp.dws_temp_winne_xyz_behavior
select *
from beautyplus-bc0ed.temp.dws_temp_winne_xyz_behavior
where event_date >= '2025-04-01'


