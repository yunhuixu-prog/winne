select content_id,sum(Explore)
from `beautyplus-bc0ed.Duffle_dataset.ads_dz_marvel2_home_content_new`
where event_date='2024-06-20' and module='专题' and module_id='BP_cat_HPB_00002854' and data_type='uv' and marvel_region='COMMON'
group by 1

select content_id,sum(impression_pv) impression_pv,sum(impression_uv) impression_uv
from `dataintegration-265403.duffle_fin.dws_dz_marvel_home_content`
where event_date='2024-07-06' and module='专题' and module_id='BP_cat_HPB_00002854'
group by 1

select content_id,sum(impression_pv) impression_pv,sum(impression_uv) impression_uv,sum(subscription) subscription
from `dataintegration-265403.duffle_fin.dws_dz_marvel_home_content`
where event_date='2024-07-01' and module='推荐配方' and content_id='any'
group by 1

select content_id,sum(impression_pv) impression_pv,sum(impression_uv) impression_uv,sum(subscription) subscription
from `dataintegration-265403.temp.tmp_dws_dz_marvel_home_content`
where event_date='2024-07-01' and module='推荐配方' and content_id='any'
group by 1

-- 验收表
select content_id,sum(impression_pv) impression_pv,sum(impression_uv) impression_uv
     ,sum(click_pv) click_pv,sum(click_uv) click_uv
     ,sum(save_pv) save_pv,sum(save_uv) save_uv
     ,sum(subscription) subscription,sum(sub2paid) sub2paid,sum(paid_amounts) paid_amounts
from `dataintegration-265403.temp.tmp_dws_dz_marvel_home_content`
where event_date='2024-07-03' and module='轮播图'
  and platform='ANDROID' and app_version>='7.7.120'
group by 1

-- 首页曝光
select
        app_name
        ,event_date
        ,event_name
        ,platform
        ,`dataintegration-265403.func`.getParams(event_params,'模块类型').string_value module_type
        ,`dataintegration-265403.func`.getParams(event_params,'内容类型').string_value content_type
        ,count(distinct user_pseudo_id) uv,count(1) pv
    from
        `dataintegration-265403.analytics.dwd_dzp_events_function`('2025-03-07', '2025-03-10', 'beautyplus', false)
    where event_name in ('home_content_show_f_bd','home_content_clk_bd')
      and `dataintegration-265403.func`.getParams(event_params,'模块类型').string_value='Topbanner'
      and `dataintegration-265403.func`.getParams(event_params,'内容类型').string_value='BP_TB_00000044'
    and platform='ANDROID'
group by 1,2,3,4,5,6

--订阅
select source2,count(distinct uuid)
from
  `beautyplus-bc0ed.sub_dataset.ads_spm_trial_subscription_pre_v5_temp`
  WHERE source2 like '%ABVC_BP%'
    and date='2024-07-01'
    and event_name='subscription_try_suc'
group by 1

-- 保存
select
        app_name
        ,event_date
        ,count(distinct user_pseudo_id) uv,count(1) pv
    from
        `dataintegration-265403.analytics.dwd_dzp_events_function`('2024-07-01', '2024-07-01', 'beautyplus', false)
    where event_name in ('beautifysave_bd','selfiesave_bd','video_edit_save_bd')
      and `dataintegration-265403.func`.getParams(event_params,'homepage_func_id').string_value='ABVC_BP_00000034'
group by 1,2

select
        app_name
        ,event_date
        ,platform
        ,count(distinct user_pseudo_id) uv,count(1) pv
    from
        `dataintegration-265403.analytics.dwd_dzp_events_function`('2024-07-01', '2024-07-01', 'beautyplus', false)
    where event_name in ('puzzle_save_bd')
      and `dataintegration-265403.func`.getParams(event_params,'source').string_value='首页推荐'
group by 1,2,3
