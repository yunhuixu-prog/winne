

drop table if exists `beautyplus-bc0ed.temp.dwd_photocat_event_pre`;
create table if not exists `beautyplus-bc0ed.temp.dwd_photocat_event_pre` as

    select e.event_date,e.platform
        ,e.event_name
        ,e.event_timestamp
        ,`dataintegration-265403.func`.getParams(event_params,'type').string_value type
        ,`dataintegration-265403.func`.getParams(event_params,'button').string_value button
        ,`dataintegration-265403.func`.getParams(event_params,'source').string_value source
        ,`dataintegration-265403.func`.getParams(event_params,'module_type').string_value module_type
        ,`dataintegration-265403.func`.getParams(event_params,'content_type').string_value content_type
        ,`dataintegration-265403.func`.getParams(event_params,'from').string_value `from`
        ,coalesce(`dataintegration-265403.func`.getParams(event_params,'子功能').string_value,
                `dataintegration-265403.func`.getParams(event_params,'一级子功能').string_value,
                `dataintegration-265403.func`.getParams(event_params,'module').string_value) function
        ,e.user_pseudo_id
        ,u.is_new,u.is_UA
    FROM `dataintegration-265403.analytics.dwd_dzp_events_function`('2025-06-08','2025-06-22','photocat',false) e
    join `dataintegration-265403.stat.stat_active_advice_detail_d` u
    on e.user_pseudo_id=u.user_pseudo_id and e.event_date=u.event_date_hk
    WHERE event_name in
            ('no_access_appr','no_access_clk'
            ,'homepageappr','topbar_clk','bottom_clk','homepage_clk'
            ,'beauty_appr','beauty_tag','beauty_appr_edit_clk'
            ,'material_exposure','material_click'
            ,'sub_page_imp','subscription_clk_try','subscription_try_suc','h5_credit_consume'
            ,'credit_page','credit_purchase_clk','credit_purchase_suc'
            ,'generate_task_create','beauty_effect_suc','beautifysave'
            ,'album_impression','album_clk_beauty'
            ,'result_page_appr','result_page_clk','recycle_bin_appr','recycle_bin_clk'
            ,'homesetting','home_set_clk')
--         and app_info.version>='3.3.0'
;


select types,event_date,if(action_before='','无上述行为',action_before) action_before,is_new,is_UA,uv
from
(
    select 'sub users' types,e.event_date
             ,CONCAT(
                CASE WHEN e1.user_pseudo_id is not null THEN '图片标记,' ELSE '' END
                ,CASE WHEN e5.user_pseudo_id is not null THEN '进入回收站,' ELSE '' END
                ,CASE WHEN e2.user_pseudo_id is not null THEN '回收站点击,' ELSE '' END
                ,CASE WHEN e3.user_pseudo_id is not null THEN '功能效果图展示,' ELSE '' END
                ,CASE WHEN e4.user_pseudo_id is not null THEN '功能保存,' ELSE '' END
              ) AS action_before
            ,e.is_new,e.is_UA
            ,count(distinct e.user_pseudo_id) uv
    from (select user_pseudo_id,is_new,is_UA,event_date,event_timestamp from `beautyplus-bc0ed.temp.dwd_photocat_event_pre` where event_name='subscription_try_suc' and source not in ('onboarding')) e
    left join (select user_pseudo_id,event_date,event_timestamp from `beautyplus-bc0ed.temp.dwd_photocat_event_pre` where event_name='beauty_tag') e1
    on e.user_pseudo_id=e1.user_pseudo_id and e.event_date=e1.event_date and e.event_timestamp>e1.event_timestamp
    left join (select user_pseudo_id,event_date,event_timestamp from `beautyplus-bc0ed.temp.dwd_photocat_event_pre` where event_name='recycle_bin_clk') e2
    on e.user_pseudo_id=e2.user_pseudo_id and e.event_date=e2.event_date and e.event_timestamp>e2.event_timestamp
    left join (select user_pseudo_id,event_date,event_timestamp from `beautyplus-bc0ed.temp.dwd_photocat_event_pre` where event_name = 'beauty_effect_suc') e3
    on e.user_pseudo_id=e3.user_pseudo_id and e.event_date=e3.event_date and e.event_timestamp>e3.event_timestamp
    left join (select user_pseudo_id,event_date,event_timestamp from `beautyplus-bc0ed.temp.dwd_photocat_event_pre` where event_name = 'beautifysave') e4
    on e.user_pseudo_id=e4.user_pseudo_id and e.event_date=e4.event_date and e.event_timestamp>e4.event_timestamp
    left join (select user_pseudo_id,event_date,event_timestamp from `beautyplus-bc0ed.temp.dwd_photocat_event_pre` where event_name = 'recycle_bin_appr') e5
    on e.user_pseudo_id=e5.user_pseudo_id and e.event_date=e5.event_date and e.event_timestamp>e5.event_timestamp
    group by 1,2,3,4,5

    union all

    select 'sub enter no sub users' types,e.event_date
             ,CONCAT(
                CASE WHEN e1.user_pseudo_id is not null THEN '图片标记,' ELSE '' END
                ,CASE WHEN e5.user_pseudo_id is not null THEN '进入回收站,' ELSE '' END
                ,CASE WHEN e2.user_pseudo_id is not null THEN '回收站点击,' ELSE '' END
                ,CASE WHEN e3.user_pseudo_id is not null THEN '功能效果图展示,' ELSE '' END
                ,CASE WHEN e4.user_pseudo_id is not null THEN '功能保存,' ELSE '' END
              ) AS action_before
            ,e.is_new,e.is_UA
            ,count(distinct e.user_pseudo_id) uv
    from (select user_pseudo_id,is_new,is_UA,event_date,event_timestamp from `beautyplus-bc0ed.temp.dwd_photocat_event_pre` where event_name='sub_page_imp' and source not in ('onboarding')) e
    left join (select distinct user_pseudo_id,event_date from `beautyplus-bc0ed.temp.dwd_photocat_event_pre` where event_name='subscription_try_suc') ep
    on e.user_pseudo_id=ep.user_pseudo_id and e.event_date=ep.event_date
    left join (select user_pseudo_id,event_date,event_timestamp from `beautyplus-bc0ed.temp.dwd_photocat_event_pre` where event_name='beauty_tag') e1
    on e.user_pseudo_id=e1.user_pseudo_id and e.event_date=e1.event_date and e.event_timestamp>e1.event_timestamp
    left join (select user_pseudo_id,event_date,event_timestamp from `beautyplus-bc0ed.temp.dwd_photocat_event_pre` where event_name='recycle_bin_clk') e2
    on e.user_pseudo_id=e2.user_pseudo_id and e.event_date=e2.event_date and e.event_timestamp>e2.event_timestamp
    left join (select user_pseudo_id,event_date,event_timestamp from `beautyplus-bc0ed.temp.dwd_photocat_event_pre` where event_name = 'beauty_effect_suc') e3
    on e.user_pseudo_id=e3.user_pseudo_id and e.event_date=e3.event_date and e.event_timestamp>e3.event_timestamp
    left join (select user_pseudo_id,event_date,event_timestamp from `beautyplus-bc0ed.temp.dwd_photocat_event_pre` where event_name = 'beautifysave') e4
    on e.user_pseudo_id=e4.user_pseudo_id and e.event_date=e4.event_date and e.event_timestamp>e4.event_timestamp
    left join (select user_pseudo_id,event_date,event_timestamp from `beautyplus-bc0ed.temp.dwd_photocat_event_pre` where event_name = 'recycle_bin_appr') e5
    on e.user_pseudo_id=e5.user_pseudo_id and e.event_date=e5.event_date and e.event_timestamp>e5.event_timestamp
    where ep.user_pseudo_id is null
    group by 1,2,3,4,5
)


;
-- 不同用户的订阅转化
select e.event_date,e.platform
        ,if(e1.user_pseudo_id is not null,1,0) is_beauty_tag
        ,if(e2.user_pseudo_id is not null,1,0) is_delete
        ,if(e3.user_pseudo_id is not null,1,0) is_beauty_effect_suc
        ,if(e4.user_pseudo_id is not null,1,0) is_beautifysave
        ,e.is_new,e.is_UA
        ,count(distinct case when e.event_name='sub_page_imp' then e.user_pseudo_id end) sub_enter_uv
        ,count(distinct case when e.event_name='subscription_clk_try' then e.user_pseudo_id end) sub_click_uv
        ,count(distinct case when e.event_name='subscription_try_suc' then e.user_pseudo_id end) sub_suc_uv
from
(
    select platform,user_pseudo_id,is_new,is_UA,event_date,event_name,event_timestamp from `beautyplus-bc0ed.temp.dwd_photocat_event_pre`
    where event_name in ('sub_page_imp','subscription_clk_try','subscription_try_suc') and source not in ('onboarding')
) e
left join (select user_pseudo_id,event_date,event_timestamp from `beautyplus-bc0ed.temp.dwd_photocat_event_pre` where event_name='beauty_tag') e1
on e.user_pseudo_id=e1.user_pseudo_id and e.event_date=e1.event_date and e.event_timestamp>e1.event_timestamp
left join (select user_pseudo_id,event_date,event_timestamp from `beautyplus-bc0ed.temp.dwd_photocat_event_pre` where event_name='recycle_bin_clk' and type='delete') e2
on e.user_pseudo_id=e2.user_pseudo_id and e.event_date=e2.event_date and e.event_timestamp>e2.event_timestamp
left join (select user_pseudo_id,event_date,event_timestamp from `beautyplus-bc0ed.temp.dwd_photocat_event_pre` where event_name = 'beauty_effect_suc') e3
on e.user_pseudo_id=e3.user_pseudo_id and e.event_date=e3.event_date and e.event_timestamp>e3.event_timestamp
left join (select user_pseudo_id,event_date,event_timestamp from `beautyplus-bc0ed.temp.dwd_photocat_event_pre` where event_name = 'beautifysave') e4
on e.user_pseudo_id=e4.user_pseudo_id and e.event_date=e4.event_date and e.event_timestamp>e4.event_timestamp
group by 1,2,3,4,5,6,7,8




