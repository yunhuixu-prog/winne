drop table if exists `dataintegration-265403.temp.winne_temp_photocat_user_seq`;
create table `dataintegration-265403.temp.winne_temp_photocat_user_seq` as

with pre_event as
(
    select event_date
         ,event_name
        ,`dataintegration-265403.func`.getParams(event_params,'type').string_value type
        ,`dataintegration-265403.func`.getParams(event_params,'button').string_value button
        ,`dataintegration-265403.func`.getParams(event_params,'source').string_value source
        ,`dataintegration-265403.func`.getParams(event_params,'cur_page').string_value cur_page
        ,`dataintegration-265403.func`.getParams(event_params,'module_type').string_value module_type
        ,`dataintegration-265403.func`.getParams(event_params,'content_type').string_value content_type
        ,`dataintegration-265403.func`.getParams(event_params,'from').string_value `from`
        ,coalesce(`dataintegration-265403.func`.getParams(event_params,'子功能').string_value,
                `dataintegration-265403.func`.getParams(event_params,'一级子功能').string_value,
                `dataintegration-265403.func`.getParams(event_params,'module').string_value) function
        ,user_pseudo_id
        ,event_timestamp
    FROM `dataintegration-265403.analytics.dwd_dzp_events_function`('2025-06-24','2025-07-07','photocat',false)
    WHERE event_name in
            (
--             'no_access_appr','no_access_clk',
            'onboarding_appr',
--             'onboarding_clk',
--             'homepageappr',
            'homepage_clk',
--             'topbar_clk','bottom_clk',
--             'beauty_appr',
            'beauty_tag','beauty_appr_edit_clk',
--             'material_exposure',
--             'material_click',
            'sub_page_imp','subscription_clk_try','subscription_try_suc',
--             'credit_page','credit_purchase_clk','credit_purchase_suc',
            'generate_task_create'
--             ,'beauty_effect_suc',
             'beautifysave',
            'album_impression','album_clk_beauty',
            'result_page_appr','result_page_clk',
            'recycle_bin_appr','recycle_bin_clk'
            )
        and app_info.version>='3.5.0'
)
,event as
(
    select event_date,user_pseudo_id,event_timestamp
        ,case
              when event_name='homepage_clk' and module_type in ('time_album','collection_album') then 'homepage_click_album'
              when event_name='homepage_clk' and module_type in ('ai_tools','creative_ai') then 'homepage_click_ai'
              when event_name='homepage_clk' and module_type in ('delete') then 'homepage_click_delete_button'
              when event_name='album_clk_beauty' then 'choose_photo'
--               when event_name='onboarding_appr' then 'onboarding_imp'
--               when event_name='sub_page_imp' and source = 'onboarding' then 'onboarding_sub_imp'
--               when event_name='subscription_clk_try' and source = 'onboarding' then 'onboarding_sub_clk'
--               when event_name='subscription_try_suc' and source = 'onboarding' then 'onboarding_sub_suc'
              when event_name='sub_page_imp' and source in ('回收站') and cur_page='订阅页' then 'delete_sub_imp'
              when event_name='sub_page_imp' and source in ('AI Enhancer','AI Hairstyle','AI Retouch','AI Restoration','Auto Adjust','AI Filter') then 'ai_sub_imp'
              when event_name='result_page_appr' then 'tag_all'
              when event_name='recycle_bin_clk' and type='click_delete' then 'click_delete'
              when event_name in ('beauty_tag','beauty_appr_edit_clk','generate_task_create','beautifysave','recycle_bin_appr') then event_name
        else 'no_need' end event_name
    from pre_event
)
,group_event as
(
    select event_date,user_pseudo_id,event_name,event_timestamp
            ,sum(if(event_name!=coalesce(pre_event_name,''),1,0)) over(partition by event_date,user_pseudo_id order by event_timestamp) group_event_rank
    from
    (
        select event_date,user_pseudo_id,event_name,event_timestamp
    --          ,row_number() over(partition by event_date,user_pseudo_id order by event_timestamp) event_rank
             ,lag(event_name) over(partition by event_date,user_pseudo_id order by event_timestamp) pre_event_name
        from event
        where event_name!='no_need'
--         where user_pseudo_id='7759387390884A3CB99133190763DADA'
    )
)
,
user_behavior_seq as
(
    select event_date,user_pseudo_id,group_event_rank,event_name
         ,count(1) nums,min(event_timestamp) start_event_timestamp
    from group_event
    group by 1,2,3,4
)

select event_date,user_pseudo_id
        ,STRING_AGG(case when nums=1 then event_name
              when nums>1 then concat(event_name,'*',cast(nums as string))
        end,',' order by group_event_rank) seq_has_times
        ,STRING_AGG(event_name,',' order by group_event_rank) seq
from user_behavior_seq
where group_event_rank<=10
group by 1,2


;
select seq,count(distinct e.user_pseudo_id) uv
from `dataintegration-265403.temp.winne_temp_photocat_user_seq` e
join `dataintegration-265403.stat.stat_active_advice_detail_d` u
on e.user_pseudo_id=u.user_pseudo_id and e.event_date=u.event_date_hk
where u.is_new=1
group by 1
order by 2 desc
;


select split(seq,',')[0] s1
     ,if(array_length(split(seq,','))>1,split(seq,',')[1],null) s2
     ,if(array_length(split(seq,','))>2,split(seq,',')[2],null) s3
     ,if(array_length(split(seq,','))>3,split(seq,',')[3],null) s4
     ,if(array_length(split(seq,','))>4,split(seq,',')[4],null) s5
     ,if(array_length(split(seq,','))>5,split(seq,',')[5],null) s6
     ,if(array_length(split(seq,','))>6,split(seq,',')[6],null) s7
     ,if(array_length(split(seq,','))>7,split(seq,',')[7],null) s8
     ,if(seq like '%click_delete%',1,0) is_delete
     ,count(distinct e.user_pseudo_id) uv
from `dataintegration-265403.temp.winne_temp_photocat_user_seq` e
join `dataintegration-265403.stat.stat_active_advice_detail_d` u
on e.user_pseudo_id=u.user_pseudo_id and e.event_date=u.event_date_hk
where u.is_new=1
group by 1,2,3,4,5,6,7,8,9
;


-- 次日留存
select split(seq,',')[0] s1
     ,if(array_length(split(seq,','))>1,split(seq,',')[1],null) s2
     ,if(array_length(split(seq,','))>2,split(seq,',')[2],null) s3
     ,if(array_length(split(seq,','))>3,split(seq,',')[3],null) s4
     ,if(array_length(split(seq,','))>4,split(seq,',')[4],null) s5
     ,if(array_length(split(seq,','))>5,split(seq,',')[5],null) s6
     ,if(array_length(split(seq,','))>6,split(seq,',')[6],null) s7
     ,if(array_length(split(seq,','))>7,split(seq,',')[7],null) s8
     ,if(seq like '%click_delete%',1,0) is_delete
     ,count(distinct e.user_pseudo_id) uv
     ,count(distinct c1.user_pseudo_id) retention_uv
from `dataintegration-265403.temp.winne_temp_photocat_user_seq` e
join `dataintegration-265403.stat.stat_active_advice_detail_d` u
on e.user_pseudo_id=u.user_pseudo_id and e.event_date=u.event_date_hk
left join `dataintegration-265403.stat.stat_active_advice_detail_d` c1
on e.user_pseudo_id=c1.user_pseudo_id and e.event_date=date_sub(c1.event_date_hk,interval 1 day)
where u.is_new=1
group by 1,2,3,4,5,6,7,8,9


