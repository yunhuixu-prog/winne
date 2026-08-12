with event_pre as
(
    select event_date
         ,event_name
        ,`dataintegration-265403.func`.getParams(event_params,'type').string_value type
        ,`dataintegration-265403.func`.getParams(event_params,'button').string_value button
        ,`dataintegration-265403.func`.getParams(event_params,'source').string_value source
        ,`dataintegration-265403.func`.getParams(event_params,'module_type').string_value module_type
        ,`dataintegration-265403.func`.getParams(event_params,'content_type').string_value content_type
        ,`dataintegration-265403.func`.getParams(event_params,'from').string_value `from`
        ,coalesce(`dataintegration-265403.func`.getParams(event_params,'子功能').string_value,
                `dataintegration-265403.func`.getParams(event_params,'一级子功能').string_value,
                `dataintegration-265403.func`.getParams(event_params,'module').string_value) function
        ,user_pseudo_id
    FROM `dataintegration-265403.analytics.dwd_dzp_events_function`('2025-05-29','2025-06-04','photocat',false)
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
)

-- 一级
select event_date
        ,u.is_new
        ,u.is_UA
        ,case when event_name = 'sub_page_imp' and source = 'onboarding' then '0-1:onboarding订阅页曝光'
              when event_name = 'subscription_clk_try' and source = 'onboarding' then '0-2:onboarding订阅页点击'
              when event_name = 'subscription_try_suc' and source = 'onboarding' then '0-3:onboarding订阅成功'
              when event_name = 'no_access_appr' then '0-4:授权页面曝光'
              when event_name = 'no_access_clk' and button='go_to_setting' then '0-5:点击去授权'
              when event_name = 'homepageappr' then '1-1:首页曝光'
              when event_name = 'homepage_clk' and module_type in ('time_album','collection_album') then '1-2-1:首页点击相册'
              when event_name = 'homepage_clk' and module_type in ('ai_tools') then '1-2-2:首页点击ai tools'
--               when event_name = 'homepage_clk' and module_type in ('ai_tools') and content_type in ('AI Retouch','AI Hairstyle') then '1-2-2-1:首页点击ai tools-素材类'
--               when event_name = 'homepage_clk' and module_type in ('ai_tools') and content_type in ('AI Enhancer','AI Restoration') then '1-2-2-2:首页点击ai tools-非素材类'
              when event_name = 'homepage_clk' and module_type in ('creative_ai') then '1-2-3:首页点击creative_ai'
              when event_name = 'homepage_clk' and module_type in ('delete') then '1-2-4:首页点击delete'
              when event_name in ('topbar_clk','bottom_clk')
                    or (event_name = 'homepage_clk' and module_type in ('sorted','delete')) then '1-2-5:首页点击其他-包括设置等'
              when event_name in ('beauty_appr') then '2-1:进入照片管理编辑页'
              when event_name in ('beauty_tag') then '2-2:图片标记'
              when event_name in ('beauty_appr_edit_clk') then '2-3:点击功能'
--               when event_name in ('beauty_appr_edit_clk') and function in ('AI Retouch','AI Hairstyle') then '2-3-1:点击素材类功能'
--               when event_name in ('beauty_appr_edit_clk') and function in ('AI Enhancer','AI Restoration','Auto Adjust') then '2-3-2:点击非素材类功能'
              when event_name in ('album_impression') then '3-1:进入相册页'
              when event_name in ('album_clk_beauty') then '3-2:相册页点击照片'
              -- 以下包括照片管理页和ai工具
              when event_name in ('material_exposure') and function!='AI Filter' then '4-1:素材曝光(不包括首页ai filter)'
              when event_name in ('material_click') and function!='AI Filter' then '4-2:素材点击(不包括首页ai filter)'
              when event_name in ('sub_page_imp') and source in ('AI Enhancer','AI Hairstyle','AI Retouch','AI Restoration','Auto Adjust','AI Filter') then '5-1:通过点击ai功能进入订阅页'
              when event_name in ('subscription_clk_try') and source in ('AI Enhancer','AI Hairstyle','AI Retouch','AI Restoration','Auto Adjust','AI Filter') then '5-2:通过点击ai功能订阅页点击'
              when event_name in ('subscription_try_suc') and source in ('AI Enhancer','AI Hairstyle','AI Retouch','AI Restoration','Auto Adjust','AI Filter') then '5-3:通过点击ai功能订阅成功'
              when event_name in ('h5_credit_consume','generate_task_create') then '6-1:成功生成任务'
              when event_name in ('beauty_effect_suc') then '6-2:照片生成成功'
              when event_name in ('beautifysave') then '6-3:照片保存'
              when event_name in ('result_page_appr') then '7-1:结果页曝光'
              when event_name in ('result_page_clk') and type='review_and_delete' then '7-2:结果页点击review_and_delete'
              when event_name in ('recycle_bin_appr') then '8-1:回收站曝光'
              when event_name in ('recycle_bin_clk') and type='select_all' then '8-2:回收站点击select_all'
              when event_name in ('recycle_bin_clk') and type='delete' then '8-3-1:回收站点击delete'
              when event_name in ('recycle_bin_clk') and type='keep' then '8-3-2:回收站点击keep'
              when event_name in ('sub_page_imp') and source in ('回收站') then '9-1:通过回收站进入订阅页'
              when event_name in ('subscription_clk_try') and source in ('回收站') then '9-2:通过回收站订阅页点击'
              when event_name in ('subscription_try_suc') and source in ('回收站') then '9-3:通过回收站订阅成功'
              when event_name in ('sub_page_imp') and source in ('首页默认入口','设置页默认入口') then '9-4:通过默认入口进入订阅页'
              when event_name in ('subscription_clk_try') and source in ('首页默认入口','设置页默认入口') then '9-5:通过默认入口订阅页点击'
              when event_name in ('subscription_try_suc') and source in ('首页默认入口','设置页默认入口') then '9-6:通过默认入口订阅成功'
        end action_I
        ,'All' action_II
        ,count(distinct e.user_pseudo_id) uv
        ,count(1) pv
from event_pre e
join `dataintegration-265403.stat.stat_active_advice_detail_d` u
on e.user_pseudo_id=u.user_pseudo_id and e.event_date=u.event_date_hk
group by 1,2,3,4,5


union all

select
    event_date_hk event_date,is_new,is_UA
    ,'0-0:dau' action_I
    ,'All' action_II
    ,count(distinct user_pseudo_id) uv
    ,null pv
from
    `dataintegration-265403.stat.stat_active_advice_detail_d`
where
    event_date_hk between '2025-05-29' and '2025-06-04'
    and app_name in ('PhotoCat')
group by 1,2,3,4,5


-- 二级





-- B+订阅草稿
-- 到用户粒度的数据，主要取用户类型
select event_name,round(sum(uv)/7) uv
from
(
    select
        event_name
        ,date
        ,count(distinct a.user_pseudo_id) uv
    from
        `beautyplus-bc0ed.sub_dataset.ads_spm_trial_subscription_pre_v5_abtest` a,unnest(agg) ag
    join `dataintegration-265403.stat.stat_active_advice_detail_d`  u
    on a.user_pseudo_id=u.user_pseudo_id and a.date=u.event_date_hk and a.platform=u.platform
    where date between '2025-05-29' and '2025-06-04'
        and u.app_name = 'BeautyPlus'
        and (event_name in ('page_event','subscription_clk_try') or (event_name='subscription_try_suc' and standard_order_date is not null))
        and u.is_new=1 and u.is_UA='non-Organic'
        and ag.category1 in ('feature','material')
    group by
        1,2
)
group by 1


