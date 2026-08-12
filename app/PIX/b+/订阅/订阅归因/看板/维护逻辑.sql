-- event event_sku module usertype层看payment_price_usd
-- category层看share_revenue


-- step1:表需要新增新增项
select distinct pre_page
from `beautyplus-bc0ed.sub_dataset.dwd_oda_spm_uuid_five_page_temp` a
left join `beautyplus-bc0ed.sub_dataset.dmi_da_spm_page_info` b
ON a.pre_page = b.page_name
where a.date between '2024-01-01' and '2024-03-31' and b.page_name is null
;
select pre_page,source_click_position,count(1)
from `beautyplus-bc0ed.sub_dataset.dwd_oda_spm_uuid_five_page_temp` a
left join `beautyplus-bc0ed.sub_dataset.dmi_da_spm_clk_info` c
ON a.source_click_position = c.clk_s
where a.date between '2024-01-01' and '2024-03-31' and c.clk_s is null
  and source_click_position is not null
  and source_click_position!='额度管理默认入口'
group by 1,2
order by 3 desc
;

-- step2:查询匹配不上的原本表具体情况
select source_feature_content,count(1)
from `beautyplus-bc0ed.sub_dataset.dwd_oda_spm_uuid_five_page_temp`
where source_click_position='生成' and pre_page='相册页' --试用期挽留横幅
group by 1
-- limit 10

-- step2:查看手写表及加入新字段
select * from `beautyplus-bc0ed.sub_dataset.dmi_da_spm_clk_info`
INSERT `beautyplus-bc0ed.sub_dataset.dmi_da_spm_clk_info` (clk_s, clk_m,clk_type)
VALUES('首页触发订阅弹窗','首页触发订阅弹窗',2),('首页订阅横幅','首页订阅横幅',2 ),('首页订阅卡片','首页订阅卡片',2 )


-- step3:生成后的表null检查/奇怪值检查
select b.pre_page,b.source_click_position,b.source_feature_content,u.category1,count(1)
from `beautyplus-bc0ed.sub_dataset.ads_spm_trial_subscription_pre_v5_temp` a,unnest(agg) u
left join `beautyplus-bc0ed.sub_dataset.dwd_oda_spm_uuid_five_page_temp` b
on a.date=b.date and a.uuid=b.uuid and a.event_timestamp=b.event_timestamp
where a.date between '2024-01-01' and '2024-03-31'
-- and u.category2 is null
and u.category2='none'
and a.event_name in ('subscription_try_suc')
group by 1,2,3,4
order by 5 desc

-- step4：sku问题核查
select SKU_ID,count(1)
from `beautyplus-bc0ed.sub_dataset.dwd_oda_spm_uuid_five_page_temp` a
left join `finance-268602.app_store.dim_da_sku_info_fix_temp2` s
ON a.SKU_ID=s.product_id
    AND a.platform=s.platform
     AND (s.product_type='subscription' AND (PARSE_DATE('%Y%m%d', s.start_date)<=DATE(TIMESTAMP(a.date, "Etc/UTC"))
                                    AND PARSE_DATE('%Y%m%d', s.end_date)>DATE(TIMESTAMP(a.date, "Etc/UTC"))))
where a.date between '2024-01-01' and '2024-03-31'
    and s.product_id is null and a.event_name IN ('subscription_try_suc','subscription_clk_try')
group by 1
order by 2 desc
;
select CONCAT(s.duration,s.duration_unit),count(1)
from `beautyplus-bc0ed.sub_dataset.dwd_oda_spm_uuid_five_page_temp` a
left join `finance-268602.app_store.dim_da_sku_info_fix_temp2` s
ON a.SKU_ID=s.product_id
    AND a.platform=s.platform
     AND (s.product_type='subscription' AND (PARSE_DATE('%Y%m%d', s.start_date)<=DATE(TIMESTAMP(a.date, "Etc/UTC"))
                                    AND PARSE_DATE('%Y%m%d', s.end_date)>DATE(TIMESTAMP(a.date, "Etc/UTC"))))
where a.date between '2024-02-27' and '2024-03-27'
    and a.event_name IN ('subscription_try_suc','subscription_clk_try')
group by 1
order by 2 desc
;
select sku_type,count(1)
from `beautyplus-bc0ed.sub_dataset.ads_spm_trial_subscription_pre_v5_temp`
where date between '2024-02-27' and '2024-03-27' and event_name IN ('subscription_try_suc','subscription_clk_try')
group by 1
order by 2 desc
;
select sku_type,count(1)
from `beautyplus-bc0ed.sub_dataset.ads_spm_trial_subscription_v5_temp`
where date between '2024-02-27' and '2024-03-27' and event_name IN ('sub_suc')
    and data_type in ('event_and_sku') and event_name != 'enter_subscription_page'
    and REGEXP_CONTAINS(app_version,r'^[0-9]') and app_version not in ('8.5.25.4.52')
group by 1
order by 2 desc
;
select sku_type,count(1)
from
(
    select * from beautyplus-bc0ed.sub_dataset.ads_dz_sub_dtype_eventSKU
    where edition='V5.0'
)
where date between '2024-02-27' and '2024-03-27' and event_name IN ('Sub success')
group by 1
;
select sku_type,sum(case when event_name in ('Sub success') then  uv end)
from
(
    select * from beautyplus-bc0ed.sub_dataset.ads_dz_sub_dtype_eventSKU
    where edition='V5.0'
)
where date between '2024-02-27' and '2024-03-27'
group by 1


-- step5：内容表维护，确实会导致catogory字段归为other，即看板的分beauty、creative material的会有问题
select u.category1,u.category2,count(1)
from `beautyplus-bc0ed.sub_dataset.ads_spm_trial_subscription_pre_v5_temp` a,unnest(agg) u
left join
(
    select key,max(category_1) category_1,max(english_name) english_name,max(chinese_name) chinese_name,max(category) category
    from `dataintegration-265403.dim.dim_aa_content_dict`
    where key is not null
    group by 1
) b
on u.category2=b.key
where a.date between '2024-01-01' and '2024-03-31' and b.key is null
and event_name in ('subscription_try_suc')
group by 1,2
order by 3 desc




-- 其他

-- select source_click_position,count(1)
select *
from
`beautyplus-bc0ed.sub_dataset.dwd_oda_spm_uuid_five_page_temp` a
where date>='2024-01-01'
and pre_page_content in ('AI修复')
-- and user_pseudo_id='ffdb004299bac3678ee1a29865a555c2'
and (cur_page in ('订阅页','OnboardingPage订阅页') or event_name in ('subscription_try_suc','subscription_clk_try'))
-- group by 1
limit 100

select *
from
`beautyplus-bc0ed.sub_dataset.dwd_oda_spm_uuid_five_page_temp` a
where date='2023-11-20'
and source_feature_content like '%AIR%'
and event_name in ('subscription_try_suc')
-- limit 100

WITH
  event AS (
  SELECT
    DISTINCT a.date,
    a.event_name,
    a.platform,
    a.country,
    CASE
      WHEN a.source_feature_content IN ('点击入口') THEN NULL
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
  LEFT JOIN
    `beautyplus-bc0ed.sub_dataset.dmi_da_spm_clk_info` c
  ON
    a.source_click_position = c.clk_s
  LEFT JOIN
      `finance-268602.app_store.dim_da_sku_info_fix_temp2`  s --2022/11/11换成这个表，因为原表的halloween sku信息更改后无法同步
  ON
    a.SKU_ID=s.product_id
    AND a.platform=s.platform
     AND (s.product_type='subscription' AND (PARSE_DATE('%Y%m%d', s.start_date)<=DATE(TIMESTAMP(a.date, "Etc/UTC"))
                                    AND PARSE_DATE('%Y%m%d', s.end_date)>DATE(TIMESTAMP(a.date, "Etc/UTC"))))
  WHERE
    a.date >= '2024-01-01'
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
      WHEN pre_page_content IS NOT NULL AND (pre_page_content NOT IN ('0','马赛克','裁剪','抠图','消除笔','虚化','照片修复','视频美颜','拼图','构图','AI修复','BP','BP_','BP_P','BP_PO','HF','B','BP_ ') and pre_page_content NOT like '%BP_MIN%') THEN 'content'
      WHEN dpre_page_content IS NOT NULL AND (dpre_page_content NOT IN ('0','马赛克','裁剪','抠图','消除笔','虚化','照片修复','视频美颜','拼图','构图','AI修复','BP','BP_','BP_P','BP_PO','HF','B','BP_ ') and dpre_page_content NOT like '%BP_MIN%') THEN 'content'
      WHEN ddpre_page_content IS NOT NULL AND (ddpre_page_content NOT IN ('0','马赛克','裁剪','抠图','消除笔','虚化','照片修复','视频美颜','拼图','构图','AI修复','BP','BP_','BP_P','BP_PO','HF','B','BP_ ') and ddpre_page_content NOT like '%BP_MIN%') THEN 'content'
      WHEN dddpre_page_content IS NOT NULL AND (dddpre_page_content NOT IN ('0','马赛克','裁剪','抠图','消除笔','虚化','照片修复','视频美颜','拼图','构图','AI修复','BP','BP_','BP_P','BP_PO','HF','B','BP_ ') and dddpre_page_content NOT like '%BP_MIN%') THEN 'content'
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
      WHEN pre_page_content IS NOT NULL AND (pre_page_content NOT IN ('0','马赛克','裁剪','抠图','消除笔','虚化','照片修复','视频美颜','拼图','构图','AI修复','BP','BP_','BP_P','BP_PO','HF','B','BP_ ') and pre_page_content NOT like '%BP_MIN%') THEN pre_page_content
      WHEN dpre_page_content IS NOT NULL AND (dpre_page_content NOT IN ('0','马赛克','裁剪','抠图','消除笔','虚化','照片修复','视频美颜','拼图','构图','AI修复','BP','BP_','BP_P','BP_PO','HF','B','BP_ ') and dpre_page_content NOT like '%BP_MIN%') THEN dpre_page_content
      WHEN ddpre_page_content IS NOT NULL AND (ddpre_page_content NOT IN ('0','马赛克','裁剪','抠图','消除笔','虚化','照片修复','视频美颜','拼图','构图','AI修复','BP','BP_','BP_P','BP_PO','HF','B','BP_ ') and ddpre_page_content NOT like '%BP_MIN%') THEN ddpre_page_content
      WHEN dddpre_page_content IS NOT NULL AND (dddpre_page_content NOT IN ('0','马赛克','裁剪','抠图','消除笔','虚化','照片修复','视频美颜','拼图','构图','AI修复','BP','BP_','BP_P','BP_PO','HF','B','BP_ ') and dddpre_page_content NOT like '%BP_MIN%') THEN dddpre_page_content
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
)

-- select distinct subSTRING(c,4, 3)
select *
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
    1/source2_amount as source_amount_proportion,
     SPLIT(source2, '、') AS raw_source_feature_content
  FROM
    sub_source
GROUP BY
    1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,
    to_json_STRING(SPLIT(source2, '、'))

     ) a
LEFT JOIN
  UNNEST(raw_source_feature_content) c
-- where a.source1 IN ('content') and a.source2 like '%BP_POP%'
where a.source1 IN ('content') and c like '%AI修复%'
limit 10






select a.category2,count(distinct user_pseudo_id)
-- select *
FROM
`beautyplus-bc0ed.sub_dataset.ads_spm_trial_subscription_pre_v5_temp`,unnest(agg) a
where date>='2024-01-01' and date<='2024-01-09'
  -- and event_name in ('page_event') AND cur_page IN ('订阅页','OnboardingPage订阅页')
  -- and event_name IN ('subscription_try_suc','subscription_clk_try')
  and a.category1='content'
-- limit 10
group by 1


select category2,sum(uv)
-- select *
FROM
`beautyplus-bc0ed.sub_dataset.ads_spm_trial_subscription_v5_temp`
where date>='2024-01-01' and date<='2024-01-09'
  and data_type = 'category2'
  and category1='material'
-- limit 10
group by 1









-- 查取某个tem
SELECT * FROM `beautyplus-bc0ed.sub_dataset.ads_spm_trial_subscription_v5_temp`
where (category3_cid='BP_TEM_00004098' or category3_mid='BP_TEM_00004098')
  and date>='2023-12-04'
  and date<='2023-12-31'
  and event_name in ('sub_suc')
  and data_type='category3'
-- LIMIT 1000


SELECT * FROM `beautyplus-bc0ed.sub_dataset.ads_spm_trial_subscription_pre_v5_temp`
where standard_order_date between '2024-04-30' and '2024-05-12'
                and event_name='subscription_try_suc'
                and standard_order_date is not null
                and source2 like '%ai_portrait%'
-- LIMIT 1000


SELECT
    source_feature_content,
    CASE
      WHEN a.source_feature_content IN ('点击入口') THEN NULL
      WHEN a.source_feature_content like '%ai_portrait%' THEN REPLACE(a.source_feature_content,'、','+')
    ELSE
    a.source_feature_content
  END
    AS source_feature_content_1
  FROM
    `beautyplus-bc0ed.sub_dataset.dwd_oda_spm_uuid_five_page_temp` a
  where a.source_feature_content like '%ai_portrait%'


SELECT event_name,count(distinct uuid),sum(payment_price_usd)
FROM `beautyplus-bc0ed.sub_dataset.ads_spm_trial_subscription_pre_v5_temp`
where standard_order_date between '2024-04-30' and '2024-05-12'
                and event_name='subscription_try_suc'
                and standard_order_date is not null
--                 and source2 like '%ai_portrait%'
group by 1


