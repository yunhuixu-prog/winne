
select event_date,event_timestamp,event_name
         ,`beautyplus-bc0ed.func.getParams`(event_params,'cur_spm').string_value
        ,`dataintegration-265403.func`.getParams(event_params,'label').string_value
        ,`dataintegration-265403.func`.getParams(event_params,'source_click_position').string_value source_click_position
        ,`dataintegration-265403.func`.getParams(event_params,'source_feature_content').string_value source_feature_content
        ,`dataintegration-265403.func`.getParams(event_params,'pre_spm').string_value pre_spm
from `dataintegration-265403.analytics.dwd_dzp_events_function`('2025-02-13', '2025-02-13', 'BeautyPlus', false)
where event_name in ('subscription_try_suc')
    and `dataintegration-265403.func`.getParams(event_params,'source_feature_content').string_value like '1%'

select `beautyplus-bc0ed.func.decodeSpmNew`(`dataintegration-265403.func`.getParams(event_params,'pre_spm').string_value).page_id,count(1)
from `dataintegration-265403.analytics.dwd_dzp_events_function`('2025-05-01', '2025-05-10', 'beautyplus', false)
-- where event_name='subscription_try_suc' and `dataintegration-265403.func`.compare_is_greater_or_equal_version(version,'7.10.0')
--   and `dataintegration-265403.func`.getParams(event_params,'source_feature_content').string_value like 'BP_POL%'
where event_name='page_event'
  and `dataintegration-265403.func`.getParams(event_params,'pre_spm').string_value like '1008%'
group by 1



-- select source_feature_content,source_click_position,pre_page
select source_feature_content,count(distinct user_pseudo_id) uv,count(1) pv
FROM `beautyplus-bc0ed.sub_dataset.dwd_oda_spm_uuid_five_page_temp`
where date between '2025-04-18' and '2025-04-21'
    and event_name in ('subscription_try_suc')
    and (pre_page_content in ('BP_POP_00001668','BP_TB_00000068')
        or dpre_page_content in ('BP_POP_00001668','BP_TB_00000068')
        or ddpre_page_content in ('BP_POP_00001668','BP_TB_00000068')
        or dddpre_page_content in ('BP_POP_00001668','BP_TB_00000068')
        )
group by 1
order by 2 desc
--     and
--     (
--     (pre_page_content IS NOT NULL AND (pre_page_content NOT IN ('0','马赛克','裁剪','抠图','消除笔','虚化','照片修复','视频美颜','拼图','构图','AI修复','BP','BP_','BP_P','BP_PO','HF','B','BP_ ') and pre_page_content NOT like '%BP_MIN%' and pre_page_content NOT like '%BP_AC%'))
--     or
--     (dpre_page_content IS NOT NULL AND (dpre_page_content NOT IN ('0','马赛克','裁剪','抠图','消除笔','虚化','照片修复','视频美颜','拼图','构图','AI修复','BP','BP_','BP_P','BP_PO','HF','B','BP_ ') and dpre_page_content NOT like '%BP_MIN%' and dpre_page_content NOT like '%BP_AC%'))
--     or
--     (ddpre_page_content IS NOT NULL AND (ddpre_page_content NOT IN ('0','马赛克','裁剪','抠图','消除笔','虚化','照片修复','视频美颜','拼图','构图','AI修复','BP','BP_','BP_P','BP_PO','HF','B','BP_ ') and ddpre_page_content NOT like '%BP_MIN%' and ddpre_page_content NOT like '%BP_AC%'))
--     or
--     (dddpre_page_content IS NOT NULL AND (dddpre_page_content NOT IN ('0','马赛克','裁剪','抠图','消除笔','虚化','照片修复','视频美颜','拼图','构图','AI修复','BP','BP_','BP_P','BP_PO','HF','B','BP_ ') and dddpre_page_content NOT like '%BP_MIN%' and dddpre_page_content NOT like '%BP_AC%'))
--     )


select subSTRING(source_feature_content,2,3),count(1) pv
FROM `beautyplus-bc0ed.sub_dataset.dwd_oda_spm_uuid_five_page_temp`
where date between '2025-01-27' and '2025-02-23'
    and event_name in ('subscription_try_suc')
    and source_feature_content like '1%'
group by 1
order by 2 desc


select source_click_position
     ,pre_page1,pre_page,app_version
     ,count(1) pv
FROM `beautyplus-bc0ed.sub_dataset.dwd_oda_spm_uuid_five_page_temp`
where date between '2025-01-27' and '2025-05-23'
    and event_name in ('subscription_try_suc')
--     and source_feature_content like '1%'
    and source_click_position = '默认入口'
    and pre_page1 not like '1005%'
    and pre_page1 not like '1007%'
    and pre_page1 not like '1015%'
    and pre_page1 not like '1001%'
    and pre_page1 not like '1002%'
    and pre_page1 like '1010%'
group by 1,2,3,4
order by 5 desc




select s.category1,s.category2,count(1) pv
from `beautyplus-bc0ed.sub_dataset.ads_spm_trial_subscription_pre_v5_abtest` a,unnest(agg) s
where date between '2025-01-27' and '2025-02-23'
    and event_name in ('subscription_try_suc')
    and s.category2='首页-默认入口'
group by 1,2
order by 3 desc


-- 用homepage_module_id匹配
--弹窗,启动页
select distinct a.id as module_id, a.title as module_title
FROM
(
    SELECT
    *, row_number () over (partition by id order by date desc)as ranking
    FROM `beautyplus-bc0ed.sub_dataset.beauty_plus_advert`
    where title is not null
) a
where  a.ranking=1
--首页内容2.0
union all

select id module_id,max(name) module_name
from
(
    select id,max(name) name
    from `beautyplus-bc0ed.dim.dim_gs_marvel_homepage_module_name_mapping` group by 1
    union all
    select id,max(name) name
    from `beautyplus-bc0ed.dim.dim_gs_marvel_homepage_pop_type_mapping` where id is not null group by 1
    union all
    select rid id,max(name) name
    from `dataintegration-265403.duffle_fin.stage_dz_marvel_home_category_v` group by 1
)
group by 1

-- 用homepage_content_id匹配
select rid content_id,max(name) content_name
from `dataintegration-265403.duffle_fin.stage_dz_marvel_home_category_sub_v` group by 1



-- sub_user_type的去重情况
select date,event_name,sub_user_type,count(distinct user_pseudo_id) uv,count(1) pv
from `beautyplus-bc0ed.sub_dataset.ads_spm_trial_subscription_pre_v5_abtest` a,unnest(agg) s
where date between '2025-05-01' and '2025-05-20'
group by 1,2,3

union all

select date,event_name,'All' sub_user_type,count(distinct user_pseudo_id) uv,count(1) pv
from `beautyplus-bc0ed.sub_dataset.ads_spm_trial_subscription_pre_v5_abtest` a,unnest(agg) s
where date between '2025-05-01' and '2025-05-20'
group by 1,2,3


-- 只有source_feature_content有分成吗：source_click_position无
select *
from
(
select `dataintegration-265403.func`.getParams(event_params,'source_feature_content').string_value source_feature_content
      ,`dataintegration-265403.func`.getParams(event_params,'source_click_position').string_value source_click_position
from `dataintegration-265403.analytics.dwd_dzp_events_function`('2025-05-10', '2025-05-10', 'beautyplus', false)
-- where event_name='subscription_try_suc' and `dataintegration-265403.func`.compare_is_greater_or_equal_version(version,'7.10.0')
--   and `dataintegration-265403.func`.getParams(event_params,'source_feature_content').string_value like 'BP_POL%'
where event_name='subscription_clk_try'
)
where array_length(SPLIT(source_click_position, '、'))>1
limit 100








