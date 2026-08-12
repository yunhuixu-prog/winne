-- =============================================================================
-- AirBrush 素材数据口径
--
-- 加工代码（须按顺序执行）：
--   1. app/AB-OCI/看板/功能素材/素材/1素材明细.sql
--   2. app/AB-OCI/看板/功能素材/素材/2加入订阅.sql
--   3. app/AB-OCI/看板/功能素材/素材/3数据加工.sql
--   4. app/AB-OCI/看板/功能素材/素材/4最终版本.sql
--
-- 最终 UV 表：stat_material.material_adz_beidou_stat_data
-- 用户粒度来源：stat_material.material_adz_beidou_stat_info
-- 推荐引擎：Hive on Spark；临时查询也可先尝试 Presto。
-- =============================================================================


-- =============================================================================
-- 一、加工链路与中间表说明
-- =============================================================================

-- 1）stat_material.material_adz_beidou_stat_info
--    生成节点：1素材明细.sql；2加入订阅.sql 会回刷最近7天分区。
--    核心粒度：日期 × 用户 × 素材 × 分类 × 事件 × 用户维度。
--    存储形式：同一事件的用户ID分别放在 exp_uv / click_uv / use_uv /
--              save_uv / sub_uv / sub_pay_uv 字段中，而非统一 gid 字段。
--    事件口径：
--      曝光：material_exposure，module='edit'；
--      点击：material_click，module='edit'；
--      打勾：material_check，使用 mids_material_id / mids_category_id；
--      保存：edit_save，但现有任务只保留“同日、同用户、同素材存在点击”的保存；
--      订阅：w_subscription_success，source_0 like 'f_%'；
--      订阅转付费及收入：第2步关联 paid_oda_vip_all_order 后回填。
--    维度来源：新老、UA、平台、国家、素材/分类名称与缩略图。
--    这是用户粒度分析应直接读取的事实中间表。

-- 2）stat_material.material_adz_beidou_stat_uv_agg
--    生成节点：3数据加工.sql。
--    粒度：日期 × stat_scope × 素材/素材类型 × 筛选维度 × event_type。
--    作用：对 info 表按曝光、点击、打勾、保存、订阅分别 count(distinct gid)，
--          并生成看板需要的“整体”组合；同时使用
--          stat_material.material_rna_ab_material_type 统一素材子类型。
--    stat_scope：
--      material：保留 material_id、category_id 及平台/国家/新老/UA组合；
--      feature_sub_feature：material_id='整体'，按素材类型/子类型汇总。

-- 3）stat_material.material_adz_beidou_stat_data
--    生成节点：4最终版本.sql。
--    粒度：日期 × 素材（或素材类型汇总）× 筛选维度。
--    作用：将 uv_agg 的 event_type 行转成曝光/点击/打勾/保存/订阅宽指标，
--          再回填素材名称、分类名称、URL和模块，是北斗素材看板的最终表。
--    限制：只有聚合后的UV/PV/收入，无用户ID，不能用于用户路径、点击素材数、
--          素材复用率或用户分群分析。

-- 4）维表/源表
--    stat_sdk.sdk_odz_source_data：素材行为、保存及订阅成功事件源表。
--    stat_sdk.sdk_odz_new_device_info：当日新用户识别。
--    stat_sdk.sdk_odz_active：UA/自然用户属性。
--    stat_sdk.dim_rna_ip_location：country_id 对应国家名称。
--    stat_material.material_rda_category_name：分类ID对应分类名称。
--    stat_material.material_rda_material_name：素材ID对应素材名称和缩略图URL。
--    stat_material.material_rna_ab_material_type：Duffle/素材中台ID对应素材子类型。
--    stat_vip.paid_oda_vip_all_order：订阅转付费及订单收入回填。

-- 重要限制：
--   A. 保存沿用当前看板口径，只统计能与同日点击匹配的 edit_save；不是所有保存事件。
--   B. 订单含多个 mids_material_id 时，每个素材会获得整笔订单收入归因；
--      paid_ord_amt 可按单素材分析，但不可跨素材直接求和作为产品总收入。
--   C. 用户表按素材保留多行；汇总素材类型UV时必须 count(distinct gid)，
--      不可直接 sum(is_exp/is_click/is_use/is_save)，否则跨素材会重复用户。
--   D. sub_pay_uv 依赖第2步最近7天回填；用户分析应读取已完成第2步加工的分区。


-- =============================================================================
-- 二、最终UV表查询口径（北斗素材看板）
-- =============================================================================

select
  material_id,       -- 素材ID；“整体”代表素材类型/子类型汇总行
  os_type,           -- 操作系统
  feature,           -- 素材类型（二级功能，例如 makeup、relight）
  sub_feature,       -- 素材子类型
  material_name,     -- 素材名称
  category_id,       -- 分类ID
  category_name,     -- 分类名称
  url,               -- 素材缩略图
  is_new,            -- 新用户/老用户/整体
  is_ua,             -- 渠道/自然属性（沿用源表 is_ua）
  country,           -- 国家
  module,            -- 当前主要为图片编辑器
  exp_uv,            -- 曝光UV
  click_uv,          -- 点击UV
  use_uv,            -- 打勾UV
  save_uv,           -- 保存UV
  exp_pv,            -- 曝光PV
  click_pv,          -- 点击PV
  use_pv,            -- 打勾PV
  save_pv,           -- 保存PV
  sub_uv,            -- 订阅成功UV
  sub_pay_uv,        -- 订阅转付费UV
  paid_ord_amt,      -- 付费订单金额（美元口径沿用加工任务）
  date_p
from
  stat_material.material_adz_beidou_stat_data
where
  date_p = 20260801;


-- =============================================================================
-- 三、用户粒度查询口径
--
-- 输出粒度：date_p × gid × material_id × category_id × 平台/国家/新老/UA。
-- is_exp/is_click/is_use/is_save/is_sub/is_sub_pay 为0/1标记；
-- 对同一素材维度求和这些标记，可与最终表的素材UV对账。
-- 跨素材汇总时须重新 count(distinct case when 标记=1 then gid end)。
--
-- 参数：${start_time}、${end_time}，格式 yyyyMMdd。
-- =============================================================================

select
  u.date_p,
  u.gid,
  u.material_id,
  u.os_type,
  u.feature,
  u.sub_feature,
  u.material_name,
  u.category_id,
  u.category_name,
  u.url,
  u.is_new,
  u.is_ua,
  u.country_id,
  u.country,
  u.module,
  max(u.is_exp) as is_exp,             -- 是否曝光该素材
  max(u.is_click) as is_click,         -- 是否点击该素材
  max(u.is_use) as is_use,             -- 是否打勾该素材
  max(u.is_save) as is_save,           -- 是否保存且满足当前点击关联口径
  max(u.is_sub) as is_sub,             -- 是否由该素材触发订阅成功
  max(u.is_sub_pay) as is_sub_pay,     -- 是否由该素材订阅后转付费
  sum(u.exp_pv) as exp_pv,
  sum(u.click_pv) as click_pv,
  sum(u.use_pv) as use_pv,
  sum(u.save_pv) as save_pv,
  sum(u.sub_pv) as sub_pv,
  cast(sum(u.paid_ord_amt) as double) as paid_ord_amt
from
  (
    select
      i.date_p,
      coalesce(i.exp_uv, i.click_uv, i.use_uv, i.save_uv, i.sub_uv) as gid,
      i.material_id,
      i.os_type,
      i.feature,
      case
        when new_type.material_type is not null then new_type.material_type
        when duffle_type.material_type is not null then duffle_type.material_type
        when i.sub_feature is null or i.sub_feature = '' then '未知'
        else i.sub_feature
      end as sub_feature,
      i.material_name,
      i.category_id,
      i.category_name,
      i.url,
      i.is_new,
      i.is_ua,
      i.country_id,
      i.country,
      i.module,
      case when i.exp_uv is not null then 1 else 0 end as is_exp,
      case when i.click_uv is not null then 1 else 0 end as is_click,
      case when i.use_uv is not null then 1 else 0 end as is_use,
      case when i.save_uv is not null then 1 else 0 end as is_save,
      case when i.sub_uv is not null then 1 else 0 end as is_sub,
      case when i.sub_pay_uv is not null then 1 else 0 end as is_sub_pay,
      cast(coalesce(i.exp_pv, 0) as bigint) as exp_pv,
      cast(coalesce(i.click_pv, 0) as bigint) as click_pv,
      cast(coalesce(i.use_pv, 0) as bigint) as use_pv,
      cast(coalesce(i.save_pv, 0) as bigint) as save_pv,
      cast(coalesce(i.sub_pv, 0) as bigint) as sub_pv,
      cast(coalesce(i.paid_ord_amt, 0) as double) as paid_ord_amt
    from
      (
        select
          date_p,
          material_id,
          os_type,
          feature,
          sub_feature,
          material_name,
          category_id,
          category_name,
          url,
          is_new,
          is_ua,
          country_id,
          country,
          module,
          exp_uv,
          click_uv,
          use_uv,
          save_uv,
          sub_uv,
          sub_pay_uv,
          exp_pv,
          click_pv,
          use_pv,
          save_pv,
          sub_pv,
          paid_ord_amt
        from
          stat_material.material_adz_beidou_stat_info
        where
          date_p between ${start_time} and ${end_time}
          and material_id is not null
          and material_id not in ('-1', 'none', '整体')
      ) i
      left join (
        select
          regexp_extract(material_type_id, '([A-Z]{3})', 1) as material_type_id,
          max(material_type) as material_type
        from
          stat_material.material_rna_ab_material_type
        where
          platform = 'Duffle'
        group by
          regexp_extract(material_type_id, '([A-Z]{3})', 1)
      ) duffle_type
        on regexp_extract(i.material_id, '([A-Z]{3})', 1) = duffle_type.material_type_id
      left join (
        select
          material_type_id,
          max(material_type) as material_type
        from
          stat_material.material_rna_ab_material_type
        where
          platform = '素材中台'
        group by
          material_type_id
      ) new_type
        on regexp_extract(substr(i.material_id, 1, 5), '^([0-9]{5})$', 1) = new_type.material_type_id
  ) u
where
  u.gid is not null
  and u.gid <> ''
group by
  u.date_p,
  u.gid,
  u.material_id,
  u.os_type,
  u.feature,
  u.sub_feature,
  u.material_name,
  u.category_id,
  u.category_name,
  u.url,
  u.is_new,
  u.is_ua,
  u.country_id,
  u.country,
  u.module;


-- =============================================================================
-- 四、常用汇总示例
--
-- 1）单素材UV：对用户粒度结果按素材维度 sum(is_exp/is_click/...)。
-- 2）素材类型UV：必须 count(distinct case when is_use=1 then gid end)，
--    因为同一用户可能在同一天使用同类型下多个素材。
-- 3）使用前点击素材数、素材复用率：需保留时间戳或 edit/session 标识；
--    当前 material_adz_beidou_stat_info 仅保留日粒度用户指标，不能还原事件顺序。
-- =============================================================================
