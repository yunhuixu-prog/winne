with sub_source AS
(
 select *,
  CASE
      WHEN pre_page_content IS NOT NULL AND pre_page_content NOT IN ('0','马赛克','裁剪','抠图','消除笔','虚化','照片修复','视频美颜','拼图','构图','AI修复','BP','BP_','BP_P','BP_PO','HF','B','BP_ ') THEN pre_page_content
      WHEN dpre_page_content IS NOT NULL AND dpre_page_content NOT IN ('0','马赛克','裁剪','抠图','消除笔','虚化','照片修复','视频美颜','拼图','构图','AI修复','BP','BP_','BP_P','BP_PO','HF','B','BP_ ') THEN dpre_page_content
      WHEN ddpre_page_content IS NOT NULL AND ddpre_page_content NOT IN ('0','马赛克','裁剪','抠图','消除笔','虚化','照片修复','视频美颜','拼图','构图','AI修复','BP','BP_','BP_P','BP_PO','HF','B','BP_ ') THEN ddpre_page_content
      WHEN dddpre_page_content IS NOT NULL AND dddpre_page_content NOT IN ('0','马赛克','裁剪','抠图','消除笔','虚化','照片修复','视频美颜','拼图','构图','AI修复','BP','BP_','BP_P','BP_PO','HF','B','BP_ ') THEN dddpre_page_content
   ELSE 'others'
  END
    AS source
  FROM
    `beautyplus-bc0ed.sub_dataset.dwd_oda_spm_uuid_five_page_temp`
  where
    date >= '2025-01-14' --and  a.date <= '2022-08-05'
    and event_name='subscription_try_suc'
    and (source_feature_content like '%ai_portrait%' or source_feature_content like '%ai_filter%' or source_feature_content like '%ai_portrait%')
)
select *
from
  sub_source a
  WHERE source!='others'

