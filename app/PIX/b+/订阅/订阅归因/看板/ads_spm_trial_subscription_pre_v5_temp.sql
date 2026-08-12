/* spm_pre
* @Last Modified by:   zhoutao
* @Last Modified time: 2023-08-25,2023-05-22
* @Last Modified content: 指标体系升级+切换订阅中间表，更新H5 miniapp入口的数据
* @to_do:
*/
--   create or replace table `beautyplus-bc0ed.sub_dataset.ads_spm_trial_subscription_pre`
--   partition by date
--   cluster by platform, country
--   options (description = "add in order data from server side",
--             labels = [('owner', 'zhoutao')]

delete from `beautyplus-bc0ed.sub_dataset.ads_spm_trial_subscription_pre_v5_temp` where date >= '{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=15)).strftime("%Y-%m-%d") }}';
--delete from `beautyplus-bc0ed.sub_dataset.ads_spm_trial_subscription_pre_v5_temp` where date >= '2023-08-01';

insert into   `beautyplus-bc0ed.sub_dataset.ads_spm_trial_subscription_pre_v5_temp`
--create table if not exists  `beautyplus-bc0ed.sub_dataset.ads_spm_trial_subscription_pre_v5_temp` as

WITH
  event AS (
  SELECT
    DISTINCT a.date,
    a.event_name,
    a.platform,
    a.country,
    CASE
      WHEN a.source_feature_content IN ('点击入口') THEN NULL
      WHEN a.source_feature_content like '%ai_portrait%' THEN REPLACE(a.source_feature_content,'、','+')
      WHEN a.source_feature_content like 'FacialReshape%' and `dataintegration-265403.func`.compare_is_greater_or_equal_version(app_version,'7.9.0') THEN replace(a.source_feature_content,'FacialReshape、','')
      WHEN a.source_feature_content like '%、Remover%' and `dataintegration-265403.func`.compare_is_greater_or_equal_version(app_version,'7.12.0') THEN replace(a.source_feature_content,'、Remover','')
    ELSE
    a.source_feature_content
  END
    AS source_feature_content,
    a.source_click_position,
    a.SKU_ID,
    case when s.trial_duration > 0 then 'has_trial'
             else 'no_trial'
         end as sku_has_trial,
    a.app_version,
    a.uuid,
    a.user_pseudo_id,
    a.cur_page,
    a.pre_page,
    a.dpre_page,
    a.ddpre_page,
    a.dddpre_page,
    REPLACE(a.cur_page_content,'-','') AS cur_page_content,
    REPLACE(a.pre_page_content,'-','') AS pre_page_content,
    REPLACE(a.dpre_page_content,'-','') AS dpre_page_content,
    REPLACE(a.ddpre_page_content,'-','') AS ddpre_page_content,
    REPLACE(a.dddpre_page_content,'-','') AS dddpre_page_content,
    b.page_type AS pre_page_type,
    CONCAT(s.duration,s.duration_unit) AS sku_type,
    --周期单位
    c.clk_m,
    c.clk_type,
    a.event_timestamp,
    a.device_id,
    a.sub_user_type,
    a.sku_tag
  FROM
    `beautyplus-bc0ed.sub_dataset.dwd_oda_spm_uuid_five_page_temp` a
  LEFT JOIN
    `beautyplus-bc0ed.sub_dataset.dmi_da_spm_page_info` b
  ON
    a.pre_page = b.page_name
--     split(a.pre_page1,'@')[0] = b.page_id
  LEFT JOIN
    `beautyplus-bc0ed.sub_dataset.dmi_da_spm_clk_info` c
  ON
    a.source_click_position = c.clk_s
  LEFT JOIN
      `finance-268602.dim.dim_da_subscription_sku_info`  s
  ON
    a.SKU_ID=s.product_id
    AND a.platform=s.platform
     AND (s.product_type='subscription' AND (PARSE_DATE('%Y%m%d', s.start_date)<=DATE(TIMESTAMP(a.date, "Etc/UTC"))
                                    AND PARSE_DATE('%Y%m%d', s.end_date)>DATE(TIMESTAMP(a.date, "Etc/UTC"))))
  WHERE
    a.date >= '{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=15)).strftime("%Y-%m-%d") }}'
  --  a.date >= '2023-08-01' --and  a.date < '2023-01-01'
    ),
sub_source AS
(
  SELECT
    date,
    CASE
      WHEN cur_page IN ('订阅页', 'OnboardingPage订阅页', '订阅详情页') THEN cur_page
    ELSE
    '其他页面'
  END
    AS cur_page_type,
    event_name,
    platform,
    country,
    source_feature_content,
    source_click_position,
    SKU_ID,
    sku_type,
    sku_has_trial,
    cur_page,
    pre_page,
    dpre_page,
    ddpre_page,
    dddpre_page,
    cur_page_content,
    pre_page_content,
    dpre_page_content,
    ddpre_page_content,
    dddpre_page_content,
     CASE
      when source_feature_content IS NOT NULL and source_click_position='额度管理默认入口' then 'else-source_click_position' --2023/11/16 新增：积分充值页订阅横幅的来源
      WHEN pre_page_content IS NOT NULL AND (pre_page_content NOT IN ('0','马赛克','裁剪','抠图','消除笔','虚化','照片修复','视频美颜','拼图','构图','AI修复','BP','BP_','BP_P','BP_PO','HF','B','BP_ ','相机','个人空间','编辑器按钮','拍摄按钮','再修一张','证件照') and pre_page_content NOT like '%BP_MIN%' and pre_page_content NOT like '%BP_AC%') THEN 'content'
      WHEN dpre_page_content IS NOT NULL AND (dpre_page_content NOT IN ('0','马赛克','裁剪','抠图','消除笔','虚化','照片修复','视频美颜','拼图','构图','AI修复','BP','BP_','BP_P','BP_PO','HF','B','BP_ ','相机','个人空间','编辑器按钮','拍摄按钮','再修一张','证件照') and dpre_page_content NOT like '%BP_MIN%' and dpre_page_content NOT like '%BP_AC%') THEN 'content'
      WHEN ddpre_page_content IS NOT NULL AND (ddpre_page_content NOT IN ('0','马赛克','裁剪','抠图','消除笔','虚化','照片修复','视频美颜','拼图','构图','AI修复','BP','BP_','BP_P','BP_PO','HF','B','BP_ ','相机','个人空间','编辑器按钮','拍摄按钮','再修一张','证件照') and ddpre_page_content NOT like '%BP_MIN%' and ddpre_page_content NOT like '%BP_AC%') THEN 'content'
      WHEN dddpre_page_content IS NOT NULL AND (dddpre_page_content NOT IN ('0','马赛克','裁剪','抠图','消除笔','虚化','照片修复','视频美颜','拼图','构图','AI修复','BP','BP_','BP_P','BP_PO','HF','B','BP_ ','相机','个人空间','编辑器按钮','拍摄按钮','再修一张','证件照') and dddpre_page_content NOT like '%BP_MIN%' and dddpre_page_content NOT like '%BP_AC%') THEN 'content'
      WHEN source_feature_content IS NOT NULL THEN 'feature'
      WHEN clk_type>=1
    AND clk_type<=2 THEN 'else-source_click_position'
    ELSE
    'else-pre_page_type'
  END
    AS source1,
    --modify by zxy 2022/08/30 剔除tabbar推荐的功能入口
    CASE
      when source_feature_content IS NOT NULL and source_click_position='额度管理默认入口' then '额度管理默认入口' --2023/11/16 新增：积分充值页订阅横幅的来源
      WHEN pre_page_content IS NOT NULL AND (pre_page_content NOT IN ('0','马赛克','裁剪','抠图','消除笔','虚化','照片修复','视频美颜','拼图','构图','AI修复','BP','BP_','BP_P','BP_PO','HF','B','BP_ ','相机','个人空间','编辑器按钮','拍摄按钮','再修一张','证件照') and pre_page_content NOT like '%BP_MIN%' and pre_page_content NOT like '%BP_AC%') THEN pre_page_content
      WHEN dpre_page_content IS NOT NULL AND (dpre_page_content NOT IN ('0','马赛克','裁剪','抠图','消除笔','虚化','照片修复','视频美颜','拼图','构图','AI修复','BP','BP_','BP_P','BP_PO','HF','B','BP_ ','相机','个人空间','编辑器按钮','拍摄按钮','再修一张','证件照') and dpre_page_content NOT like '%BP_MIN%' and dpre_page_content NOT like '%BP_AC%') THEN dpre_page_content
      WHEN ddpre_page_content IS NOT NULL AND (ddpre_page_content NOT IN ('0','马赛克','裁剪','抠图','消除笔','虚化','照片修复','视频美颜','拼图','构图','AI修复','BP','BP_','BP_P','BP_PO','HF','B','BP_ ','相机','个人空间','编辑器按钮','拍摄按钮','再修一张','证件照') and ddpre_page_content NOT like '%BP_MIN%' and ddpre_page_content NOT like '%BP_AC%') THEN ddpre_page_content
      WHEN dddpre_page_content IS NOT NULL AND (dddpre_page_content NOT IN ('0','马赛克','裁剪','抠图','消除笔','虚化','照片修复','视频美颜','拼图','构图','AI修复','BP','BP_','BP_P','BP_PO','HF','B','BP_ ','相机','个人空间','编辑器按钮','拍摄按钮','再修一张','证件照') and dddpre_page_content NOT like '%BP_MIN%' and dddpre_page_content NOT like '%BP_AC%') THEN dddpre_page_content
      WHEN source_feature_content IS NOT NULL THEN source_feature_content
      WHEN clk_type>=1 AND clk_type<=2 THEN clk_m
      WHEN clk_type=3 AND clk_m IN ('保存') AND pre_page_type IN ('自拍预览页', '拍后确认页', '修图编辑页') THEN CONCAT(pre_page_type,'-',clk_m)
      WHEN clk_type=3 AND clk_m IN ('拍摄') AND pre_page_type IN ('自拍预览页') THEN CONCAT(pre_page_type,'-',clk_m)
      WHEN clk_type=3 AND clk_m IN ('功能弹窗', '打勾确认', '图层编辑') AND pre_page_type IN ('修图编辑页') THEN CONCAT(pre_page_type,'-',clk_m)
      WHEN clk_type=4 AND pre_page_type IN ('首页','自拍预览页','拍后确认页','修图编辑页') THEN CONCAT(pre_page_type,'-',clk_m)
      WHEN pre_page_type IN ('首页', '自拍预览页', '拍后确认页', '修图编辑页') THEN CONCAT(pre_page_type,'-其他入口')
    ELSE pre_page_type
   END
    AS source2,
    uuid,
    user_pseudo_id,
    app_version,
    event_timestamp,
    device_id,
    sub_user_type,
    sku_tag,
    ifnull(array_length(SPLIT(source_feature_content, '、')),1) as source2_amount
  FROM
    event
  WHERE
    --event_date='20201222'
    event_name IN ('subscription_try_suc','subscription_clk_try')
    --and cur_page in ('订阅详情页')
    --modify by zt 2022/03/29  去除了重复的union
    OR (event_name IN ('page_event') AND cur_page IN ('订阅页','OnboardingPage订阅页') )
),
temp_output as (

SELECT
  a.date,
  a.platform,
  a.country,
  a.event_name,
  a.cur_page_type,
  SKU_ID,
  a.sku_type,
  sku_has_trial,
  a.source1,
  a.source2,
  a.uuid,
  a.user_pseudo_id,
  app_version,
    event_timestamp,
    device_id,
    cur_page,
    pre_page,
    dpre_page,
    sub_user_type,
    sku_tag,
    source_amount_proportion,
  ARRAY_AGG(STRUCT<category1 string, category2 string, category3_mid string, category3_cid string,category3_feature_content string, category3_id string>
    (CASE
        WHEN a.source1 IN ('feature') AND (c LIKE '%1HSS%' OR c LIKE '%1HIB%'  OR c LIKE '%1HIC%'  OR c LIKE '%WP%' OR a.source2 like '%ai_portrait%' OR a.source2 like '%ai_filter%' OR a.source2 like '%puriplus%' OR a.source2 like '%tooniverse%' OR a.source2 like '%AI Pet Portraits%' OR a.source2 IN ('AIArt','tab','button','AI Motion Comic','AI Style Morph Pet','AISketch') )THEN 'H5'
        WHEN a.source1 IN ('feature') AND (c LIKE '1%' OR c LIKE '2%' OR c LIKE 'BP%') THEN 'material'
        WHEN a.source1 IN ('else-pre_page_type',
        'else-source_click_position') THEN 'else'
      ELSE
      a.source1
    END  --category1 string
      ,
      -- modified by ethan 2021/07/30 for new template
      LTRIM(CASE
        WHEN a.source1 IN ('content') and (c like '%ARR%'  OR C LIKE '%AAR%')THEN 'HomePage AR Section'
        WHEN a.source1 IN ('content') and ( c like '%FIL%' )THEN 'HomePage Filter Section'
        WHEN a.source1 IN ('content') and c like '%BRU%'  THEN 'HomePage Brush Section'
        WHEN a.source1 IN ('content') and c like '%TEM%'  THEN 'HomePage Template Section'
        WHEN a.source1 IN ('content') and c like '%STI%'  THEN 'HomePage Sticker Section'
        WHEN a.source1 IN ('content') and c like '%TEX%'  THEN 'HomePage Text Section'
        WHEN a.source1 IN ('content') and c like '%STP%'  THEN 'HomePage Sticker Package Section'
        WHEN a.source1 IN ('content') and c like '%BP_KKAA%'  THEN 'HomePage Topbar'
        WHEN a.source1 IN ('content') and c like '%BP_TB%'  THEN 'Homepage TopBanner'
        WHEN a.source1 IN ('content') and a.source2 like '%BP_POP%' THEN subSTRING(c,4, 3) --拆分首页弹窗
        WHEN a.source1 IN ('content') and c like '%搜索%' THEN 'HomePage Search' -- 增加首页搜索
        WHEN a.source1 IN ('content') THEN subSTRING(c, 1, 3) --拆分为简称(3)
        WHEN a.source1 IN ('feature') AND subSTRING(c,1,1) IN ('1','2') THEN subSTRING(c,2,3)--拆分为简称(3)+ID， [简称，ID1，ID2]
        WHEN a.source1 IN ('feature') AND c LIKE 'BP%' THEN REGEXP_EXTRACT(c, r'(?:1|2|BP\_|BP\-|BP)([A-Z]{3})[\_]?.*')
        WHEN a.source1 IN ('feature') AND c LIKE 'WP%'  THEN 'WallPaper' --H5 墙纸素材
        WHEN a.source1 IN ('feature') AND subSTRING(c, 1,1) NOT IN ('1','2') AND c NOT LIKE 'BP%' THEN c
      ELSE a.source2
    END) --category2 string
      ,
      CASE
        --WHEN a.source1 IN ('feature') AND subSTRING(c, 1, 1) IN ('1', '2') THEN subSTRING(c, 5, 50) --无用sql
        --WHEN a.source1 IN ('feature')
      --AND c LIKE 'BP%' THEN REGEXP_EXTRACT(c, r"(?:1|2|BP\_|BP\-|BP)(?:[A-Z]{3})[\_\-]?(.*)")
        WHEN a.source1 IN ('content') and (a.source2 like '%BP_POP%') THEN a.source2--拆分首页弹窗
        WHEN a.source1 IN ('content') and (a.source2 like '%HPP%'or a.source2 like '%LBD%') THEN  subSTRING(c,4, 50)
        WHEN a.source1 IN ('content') and (not `dataintegration-265403.func`.compare_is_greater_or_equal_version(app_version,'7.5.095')) THEN SUBSTR(SPLIT(c, '_')[ OFFSET (0)], 4, 50)
        WHEN a.source1 IN ('content') and `dataintegration-265403.func`.compare_is_greater_or_equal_version(app_version,'7.5.095') THEN SPLIT(c, ',')[SAFE_OFFSET(1)]  --新首页的模块id
    END --category3_mid string
      ,
      CASE
        WHEN a.source1 IN ('content') and (a.source2 like '%BP_POP%'or a.source2 like '%HPP%'or a.source2 like '%LBD%') THEN ''
        WHEN a.source1 IN ('content') and (not `dataintegration-265403.func`.compare_is_greater_or_equal_version(app_version,'7.5.095')) THEN SPLIT(c, '_')[SAFE_OFFSET(1)]
        WHEN a.source1 IN ('content') and `dataintegration-265403.func`.compare_is_greater_or_equal_version(app_version,'7.5.095') THEN SPLIT(c, ',')[SAFE_OFFSET(2)]
    END --category3_cid string
      ,
      CASE
        WHEN a.source1 IN ('content') THEN source_feature_content
    END,
    --- add by zxy 20211222 完整的ID
      CASE
        WHEN a.source1 IN ('feature') AND subSTRING(c, 1, 1) IN ('1', '2') THEN c
        WHEN a.source1 IN ('feature') AND c LIKE 'BP%' THEN c
        WHEN a.source1 IN ('feature') AND c LIKE '%WP%' THEN c
        --WHEN a.source1 IN ('content') THEN c
    END  --category3_id string
      )) AS agg
  --array_agg(struct(c as source_feature_content,case when substring(c, 1,1) = '1' then substring(c, 2, 3) else c end as key, d.english_name,  d.chinese_name)) as source_feature_content_name
FROM (
  SELECT
    date,
    platform,
    country,
    event_name,
    cur_page_type,
    SKU_ID,
    sku_type,
    sku_has_trial,
    source_feature_content,
    source1,
    source2,
    uuid,
    user_pseudo_id,
    app_version,
    event_timestamp,
    device_id,
    cur_page,
    pre_page,
    dpre_page,
    sub_user_type,
    sku_tag,
    1/ifnull(array_length(SPLIT(source2, '、')),1) as source_amount_proportion,
     SPLIT(source2, '、') AS raw_source_feature_content
  FROM
    sub_source
GROUP BY
    1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,
    to_json_STRING(SPLIT(source2, '、'))

     ) a
LEFT JOIN
  UNNEST(raw_source_feature_content) c
GROUP BY 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21
),
--新增订阅逻辑 2022-06-07
--服务端订阅临时表

final_output_pre as (
 select
        a.*,
        b.uuid as new_uuid
        from temp_output a
        left join `dataintegration-265403.stat.dmi_dz_idmapping` b
        on a.user_pseudo_id = b.key

),
final_output_12m as(

select
    f.* ,sub_success_order_id as original_order_id,
    curr_order_id as order_id,
    sub_success_server_date as standard_order_date,
    sub_success_to_paid_date as purchase_date,
    sub_success_to_paid_order_id as purchase_order_id,
    sub_success_to_paid_revenue as payment_price_usd,
    sub_success_to_standard_paid_revenue,
    Promotional_revenue,
    curr_order_order_expire_date,
    sub_success_offer_type,
    sub_success_to_standard_paid_order_id,
    sub_success_to_standard_paid_sub_type
   from final_output_pre f
   left join `dataintegration-265403.subscription.dwd_dz_sub_union_order` s on f.event_name=s.event_name --此关联无实际效用，只为和union all的字段数对齐
   where  f.event_name not in  ('subscription_try_suc')

union all

select
    f.*, sub_success_order_id as original_order_id,
    curr_order_id as order_id,
    sub_success_server_date as standard_order_date,
    sub_success_to_paid_date as purchase_date,
    sub_success_to_paid_order_id as purchase_order_id,
    sub_success_to_paid_revenue as payment_price_usd,
    sub_success_to_standard_paid_revenue,
    Promotional_revenue,
    curr_order_order_expire_date,
    sub_success_offer_type,
    sub_success_to_standard_paid_order_id,
    sub_success_to_standard_paid_sub_type
from final_output_pre f
left join `dataintegration-265403.subscription.dwd_dz_sub_union_order` s
on f.new_uuid = s.uuid   and f.date between date_sub(sub_success_server_date, interval 1 day) and date_add(sub_success_server_date, interval 1 day)   and s.app_name='BeautyPlus'  --and f.sku_id = s.sku
where  f.event_name in  ('subscription_try_suc')

)
select
    t.date,
    t.platform,
    t.country,
    t.event_name,
    t.cur_page_type,
    t.sku_type,
    t.sku_has_trial,
    t.source1,
    t.source2,
    t.uuid,
    t.user_pseudo_id,
    t.app_version,
    t.agg,
    t.new_uuid,
     original_order_id,
     order_id,
    standard_order_date,
    t.sku_id as sku,
     purchase_date,
     purchase_order_id,
     payment_price_usd,
    sub_success_to_standard_paid_revenue,
    Promotional_revenue,
    curr_order_order_expire_date,
    sub_success_offer_type,
    event_timestamp,
    device_id,
    cur_page,
    pre_page,
    dpre_page,
    sub_user_type,
    sku_tag,
    source_amount_proportion,
    sub_success_to_standard_paid_order_id,
    sub_success_to_standard_paid_sub_type
from final_output_12m t
--limit 1000