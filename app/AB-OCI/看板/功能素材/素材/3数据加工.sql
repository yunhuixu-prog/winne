-- =============================================================================
-- 节点：material_adz_beidou_stat_uv_agg（北斗 Airbrush 素材统计）
-- 复查修正版（相对初版）：
--   1) feature_sub_feature 维表回填按 material_id + feature + sub_feature 精确关联
--      （与外层 join b 的明细粒度一致），去掉 max(sub_feature) 按 material_id 折叠
--   2) sub_feature CASE 与外层 b 完全一致（含 when a.sub_feature is not null）
--   3) Duffle / 素材中台维表按 join key 去重，避免一对多放大 UV
-- =============================================================================

set hive.exec.dynamic.partition.mode=nonstrict;
set hive.exec.dynamic.partition=true;
set hive.optimize.sort.dynamic.partition=false;
set spark.sql.adaptive.enabled=true;
set spark.sql.adaptive.coalescePartitions.enabled=true;
set spark.sql.adaptive.skewJoin.enabled=true;
set spark.sql.shuffle.partitions=800;

insert overwrite table stat_material.material_adz_beidou_stat_uv_agg partition (date_p = ${date_p})
select
  stat_scope,
  a.material_id,
  os_type,
  case
    when stat_scope = 'material'
    and b.feature is not null then b.feature
    else a.feature
  end as feature,
  case
    when stat_scope = 'material'
    and b.sub_feature is not null then b.sub_feature
    else a.sub_feature
  end as sub_feature,
  category_id,
  is_new,
  is_ua,
  country,
  event_type,
  uv,
  sub_pay_uv,
  pv,
  cast(paid_ord_amt as double) as paid_ord_amt
from (
  -- -------------------------------------------------------------------------
  -- material / exp
  -- -------------------------------------------------------------------------
  select
    'material' as stat_scope,
    material_id,
    coalesce(os_type, '整体') as os_type,
    '整体' as feature,
    '整体' as sub_feature,
    coalesce(category_id, '整体') as category_id,
    coalesce(is_new, '整体') as is_new,
    coalesce(is_ua, '整体') as is_ua,
    coalesce(country, '整体') as country,
    'exp' as event_type,
    count(distinct exp_uv) as uv,
    0 as sub_pay_uv,
    sum(exp_pv) as pv,
    null as paid_ord_amt
  from
    stat_material.material_adz_beidou_stat_info
  where
    date_p = ${date_p}
    and material_id is not null
    and exp_uv is not null
  group by
    os_type,
    is_ua,
    country,
    is_new,
    category_id
  grouping sets (
    (material_id, category_id, os_type, country, is_new, is_ua),
    (material_id, category_id, os_type, country, is_new),
    (material_id, category_id, os_type, country, is_ua),
    (material_id, category_id, os_type, is_new, is_ua),
    (material_id, category_id, country, is_new, is_ua),
    (material_id, category_id, os_type, country),
    (material_id, category_id, os_type, is_new),
    (material_id, category_id, os_type, is_ua),
    (material_id, category_id, country, is_new),
    (material_id, category_id, country, is_ua),
    (material_id, category_id, is_new, is_ua),
    (material_id, category_id, os_type),
    (material_id, category_id, country),
    (material_id, category_id, is_new),
    (material_id, category_id, is_ua),
    (material_id, category_id)
  )

  union all

  -- -------------------------------------------------------------------------
  -- feature_sub_feature / exp
  -- -------------------------------------------------------------------------
  select
    'feature_sub_feature' as stat_scope,
    '整体' as material_id,
    '整体' as os_type,
    coalesce(feature, '整体') as feature,
    coalesce(sub_feature, '整体') as sub_feature,
    '整体' as category_id,
    '整体' as is_new,
    '整体' as is_ua,
    '整体' as country,
    'exp' as event_type,
    count(distinct exp_uv) as uv,
    0 as sub_pay_uv,
    sum(exp_pv) as pv,
    null as paid_ord_amt
  from (
    select
      i.feature,
      coalesce(d.sub_feature, i.sub_feature) as sub_feature,
      i.exp_uv,
      i.exp_pv
    from (
      select
        material_id,
        feature,
        sub_feature,
        exp_uv,
        exp_pv
      from
        stat_material.material_adz_beidou_stat_info
      where
        date_p = ${date_p}
        and exp_uv is not null
    ) i
    left join (
      select
        a.material_id,
        a.feature,
        a.sub_feature as sub_feature_raw,
        case
          when c.material_type is not null then c.material_type
          when b.material_type is not null then b.material_type
          when a.sub_feature is not null then a.sub_feature
        end as sub_feature
      from (
        select
          material_id,
          feature,
          sub_feature,
          regexp_extract(material_id, '([A-Z]{3})', 1) as material_type_id_duffle,
          regexp_extract(substr(material_id, 1, 5), '^([0-9]{5})$', 1) as material_type_id_new
        from
          stat_material.material_adz_beidou_stat_info
        where
          date_p = ${date_p}
          and material_id is not null
          and material_id not in ('-1', 'none')
        group by
          material_id,
          feature,
          sub_feature,
          regexp_extract(material_id, '([A-Z]{3})', 1),
          regexp_extract(substr(material_id, 1, 5), '^([0-9]{5})$', 1)
      ) a
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
      ) b on a.material_type_id_duffle = b.material_type_id
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
      ) c on a.material_type_id_new = c.material_type_id
    ) d
      on i.material_id = d.material_id
     and i.feature = d.feature
     and i.sub_feature = d.sub_feature_raw
  ) x
  group by
    feature,
    sub_feature
  with rollup

  union all

  -- -------------------------------------------------------------------------
  -- material / click
  -- -------------------------------------------------------------------------
  select
    'material' as stat_scope,
    material_id,
    coalesce(os_type, '整体') as os_type,
    '整体' as feature,
    '整体' as sub_feature,
    coalesce(category_id, '整体') as category_id,
    coalesce(is_new, '整体') as is_new,
    coalesce(is_ua, '整体') as is_ua,
    coalesce(country, '整体') as country,
    'click' as event_type,
    count(distinct click_uv) as uv,
    0 as sub_pay_uv,
    sum(click_pv) as pv,
    null as paid_ord_amt
  from
    stat_material.material_adz_beidou_stat_info
  where
    date_p = ${date_p}
    and material_id is not null
    and click_uv is not null
  group by
    os_type,
    is_ua,
    country,
    is_new,
    category_id
  grouping sets (
    (material_id, category_id, os_type, country, is_new, is_ua),
    (material_id, category_id, os_type, country, is_new),
    (material_id, category_id, os_type, country, is_ua),
    (material_id, category_id, os_type, is_new, is_ua),
    (material_id, category_id, country, is_new, is_ua),
    (material_id, category_id, os_type, country),
    (material_id, category_id, os_type, is_new),
    (material_id, category_id, os_type, is_ua),
    (material_id, category_id, country, is_new),
    (material_id, category_id, country, is_ua),
    (material_id, category_id, is_new, is_ua),
    (material_id, category_id, os_type),
    (material_id, category_id, country),
    (material_id, category_id, is_new),
    (material_id, category_id, is_ua),
    (material_id, category_id)
  )

  union all

  -- -------------------------------------------------------------------------
  -- feature_sub_feature / click
  -- -------------------------------------------------------------------------
  select
    'feature_sub_feature' as stat_scope,
    '整体' as material_id,
    '整体' as os_type,
    coalesce(feature, '整体') as feature,
    coalesce(sub_feature, '整体') as sub_feature,
    '整体' as category_id,
    '整体' as is_new,
    '整体' as is_ua,
    '整体' as country,
    'click' as event_type,
    count(distinct click_uv) as uv,
    0 as sub_pay_uv,
    sum(click_pv) as pv,
    null as paid_ord_amt
  from (
    select
      i.feature,
      coalesce(d.sub_feature, i.sub_feature) as sub_feature,
      i.click_uv,
      i.click_pv
    from (
      select
        material_id,
        feature,
        sub_feature,
        click_uv,
        click_pv
      from
        stat_material.material_adz_beidou_stat_info
      where
        date_p = ${date_p}
        and click_uv is not null
    ) i
    left join (
      select
        a.material_id,
        a.feature,
        a.sub_feature as sub_feature_raw,
        case
          when c.material_type is not null then c.material_type
          when b.material_type is not null then b.material_type
          when a.sub_feature is not null then a.sub_feature
        end as sub_feature
      from (
        select
          material_id,
          feature,
          sub_feature,
          regexp_extract(material_id, '([A-Z]{3})', 1) as material_type_id_duffle,
          regexp_extract(substr(material_id, 1, 5), '^([0-9]{5})$', 1) as material_type_id_new
        from
          stat_material.material_adz_beidou_stat_info
        where
          date_p = ${date_p}
          and material_id is not null
          and material_id not in ('-1', 'none')
        group by
          material_id,
          feature,
          sub_feature,
          regexp_extract(material_id, '([A-Z]{3})', 1),
          regexp_extract(substr(material_id, 1, 5), '^([0-9]{5})$', 1)
      ) a
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
      ) b on a.material_type_id_duffle = b.material_type_id
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
      ) c on a.material_type_id_new = c.material_type_id
    ) d
      on i.material_id = d.material_id
     and i.feature = d.feature
     and i.sub_feature = d.sub_feature_raw
  ) x
  group by
    feature,
    sub_feature
  with rollup

  union all

  -- -------------------------------------------------------------------------
  -- material / save
  -- -------------------------------------------------------------------------
  select
    'material' as stat_scope,
    material_id,
    coalesce(os_type, '整体') as os_type,
    '整体' as feature,
    '整体' as sub_feature,
    coalesce(category_id, '整体') as category_id,
    coalesce(is_new, '整体') as is_new,
    coalesce(is_ua, '整体') as is_ua,
    coalesce(country, '整体') as country,
    'save' as event_type,
    count(distinct save_uv) as uv,
    0 as sub_pay_uv,
    sum(save_pv) as pv,
    null as paid_ord_amt
  from
    stat_material.material_adz_beidou_stat_info
  where
    date_p = ${date_p}
    and material_id is not null
    and save_uv is not null
  group by
    os_type,
    is_ua,
    country,
    is_new,
    category_id
  grouping sets (
    (material_id, category_id, os_type, country, is_new, is_ua),
    (material_id, category_id, os_type, country, is_new),
    (material_id, category_id, os_type, country, is_ua),
    (material_id, category_id, os_type, is_new, is_ua),
    (material_id, category_id, country, is_new, is_ua),
    (material_id, category_id, os_type, country),
    (material_id, category_id, os_type, is_new),
    (material_id, category_id, os_type, is_ua),
    (material_id, category_id, country, is_new),
    (material_id, category_id, country, is_ua),
    (material_id, category_id, is_new, is_ua),
    (material_id, category_id, os_type),
    (material_id, category_id, country),
    (material_id, category_id, is_new),
    (material_id, category_id, is_ua),
    (material_id, category_id)
  )

  union all

  -- -------------------------------------------------------------------------
  -- feature_sub_feature / save
  -- -------------------------------------------------------------------------
  select
    'feature_sub_feature' as stat_scope,
    '整体' as material_id,
    '整体' as os_type,
    coalesce(feature, '整体') as feature,
    coalesce(sub_feature, '整体') as sub_feature,
    '整体' as category_id,
    '整体' as is_new,
    '整体' as is_ua,
    '整体' as country,
    'save' as event_type,
    count(distinct save_uv) as uv,
    0 as sub_pay_uv,
    sum(save_pv) as pv,
    null as paid_ord_amt
  from (
    select
      i.feature,
      coalesce(d.sub_feature, i.sub_feature) as sub_feature,
      i.save_uv,
      i.save_pv
    from (
      select
        material_id,
        feature,
        sub_feature,
        save_uv,
        save_pv
      from
        stat_material.material_adz_beidou_stat_info
      where
        date_p = ${date_p}
        and save_uv is not null
    ) i
    left join (
      select
        a.material_id,
        a.feature,
        a.sub_feature as sub_feature_raw,
        case
          when c.material_type is not null then c.material_type
          when b.material_type is not null then b.material_type
          when a.sub_feature is not null then a.sub_feature
        end as sub_feature
      from (
        select
          material_id,
          feature,
          sub_feature,
          regexp_extract(material_id, '([A-Z]{3})', 1) as material_type_id_duffle,
          regexp_extract(substr(material_id, 1, 5), '^([0-9]{5})$', 1) as material_type_id_new
        from
          stat_material.material_adz_beidou_stat_info
        where
          date_p = ${date_p}
          and material_id is not null
          and material_id not in ('-1', 'none')
        group by
          material_id,
          feature,
          sub_feature,
          regexp_extract(material_id, '([A-Z]{3})', 1),
          regexp_extract(substr(material_id, 1, 5), '^([0-9]{5})$', 1)
      ) a
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
      ) b on a.material_type_id_duffle = b.material_type_id
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
      ) c on a.material_type_id_new = c.material_type_id
    ) d
      on i.material_id = d.material_id
     and i.feature = d.feature
     and i.sub_feature = d.sub_feature_raw
  ) x
  group by
    feature,
    sub_feature
  with rollup

  union all

  -- -------------------------------------------------------------------------
  -- material / use
  -- -------------------------------------------------------------------------
  select
    'material' as stat_scope,
    material_id,
    coalesce(os_type, '整体') as os_type,
    '整体' as feature,
    '整体' as sub_feature,
    coalesce(category_id, '整体') as category_id,
    coalesce(is_new, '整体') as is_new,
    coalesce(is_ua, '整体') as is_ua,
    coalesce(country, '整体') as country,
    'use' as event_type,
    count(distinct use_uv) as uv,
    0 as sub_pay_uv,
    sum(use_pv) as pv,
    null as paid_ord_amt
  from
    stat_material.material_adz_beidou_stat_info
  where
    date_p = ${date_p}
    and material_id is not null
    and use_uv is not null
  group by
    os_type,
    is_ua,
    country,
    is_new,
    category_id
  grouping sets (
    (material_id, category_id, os_type, country, is_new, is_ua),
    (material_id, category_id, os_type, country, is_new),
    (material_id, category_id, os_type, country, is_ua),
    (material_id, category_id, os_type, is_new, is_ua),
    (material_id, category_id, country, is_new, is_ua),
    (material_id, category_id, os_type, country),
    (material_id, category_id, os_type, is_new),
    (material_id, category_id, os_type, is_ua),
    (material_id, category_id, country, is_new),
    (material_id, category_id, country, is_ua),
    (material_id, category_id, is_new, is_ua),
    (material_id, category_id, os_type),
    (material_id, category_id, country),
    (material_id, category_id, is_new),
    (material_id, category_id, is_ua),
    (material_id, category_id)
  )

  union all

  -- -------------------------------------------------------------------------
  -- feature_sub_feature / use
  -- -------------------------------------------------------------------------
  select
    'feature_sub_feature' as stat_scope,
    '整体' as material_id,
    '整体' as os_type,
    coalesce(feature, '整体') as feature,
    coalesce(sub_feature, '整体') as sub_feature,
    '整体' as category_id,
    '整体' as is_new,
    '整体' as is_ua,
    '整体' as country,
    'use' as event_type,
    count(distinct use_uv) as uv,
    0 as sub_pay_uv,
    sum(use_pv) as pv,
    null as paid_ord_amt
  from (
    select
      i.feature,
      coalesce(d.sub_feature, i.sub_feature) as sub_feature,
      i.use_uv,
      i.use_pv
    from (
      select
        material_id,
        feature,
        sub_feature,
        use_uv,
        use_pv
      from
        stat_material.material_adz_beidou_stat_info
      where
        date_p = ${date_p}
        and use_uv is not null
    ) i
    left join (
      select
        a.material_id,
        a.feature,
        a.sub_feature as sub_feature_raw,
        case
          when c.material_type is not null then c.material_type
          when b.material_type is not null then b.material_type
          when a.sub_feature is not null then a.sub_feature
        end as sub_feature
      from (
        select
          material_id,
          feature,
          sub_feature,
          regexp_extract(material_id, '([A-Z]{3})', 1) as material_type_id_duffle,
          regexp_extract(substr(material_id, 1, 5), '^([0-9]{5})$', 1) as material_type_id_new
        from
          stat_material.material_adz_beidou_stat_info
        where
          date_p = ${date_p}
          and material_id is not null
          and material_id not in ('-1', 'none')
        group by
          material_id,
          feature,
          sub_feature,
          regexp_extract(material_id, '([A-Z]{3})', 1),
          regexp_extract(substr(material_id, 1, 5), '^([0-9]{5})$', 1)
      ) a
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
      ) b on a.material_type_id_duffle = b.material_type_id
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
      ) c on a.material_type_id_new = c.material_type_id
    ) d
      on i.material_id = d.material_id
     and i.feature = d.feature
     and i.sub_feature = d.sub_feature_raw
  ) x
  group by
    feature,
    sub_feature
  with rollup

  union all

  -- -------------------------------------------------------------------------
  -- material / sub
  -- -------------------------------------------------------------------------
  select
    'material' as stat_scope,
    material_id,
    coalesce(os_type, '整体') as os_type,
    '整体' as feature,
    '整体' as sub_feature,
    coalesce(category_id, '整体') as category_id,
    coalesce(is_new, '整体') as is_new,
    coalesce(is_ua, '整体') as is_ua,
    coalesce(country, '整体') as country,
    'sub' as event_type,
    count(distinct sub_uv) as uv,
    count(distinct sub_pay_uv) as sub_pay_uv,
    sum(sub_pv) as pv,
    cast(sum(paid_ord_amt) as double) as paid_ord_amt
  from
    stat_material.material_adz_beidou_stat_info
  where
    date_p = ${date_p}
    and material_id is not null
    and sub_uv is not null
  group by
    os_type,
    is_ua,
    country,
    is_new,
    category_id
  grouping sets (
    (material_id, category_id, os_type, country, is_new, is_ua),
    (material_id, category_id, os_type, country, is_new),
    (material_id, category_id, os_type, country, is_ua),
    (material_id, category_id, os_type, is_new, is_ua),
    (material_id, category_id, country, is_new, is_ua),
    (material_id, category_id, os_type, country),
    (material_id, category_id, os_type, is_new),
    (material_id, category_id, os_type, is_ua),
    (material_id, category_id, country, is_new),
    (material_id, category_id, country, is_ua),
    (material_id, category_id, is_new, is_ua),
    (material_id, category_id, os_type),
    (material_id, category_id, country),
    (material_id, category_id, is_new),
    (material_id, category_id, is_ua),
    (material_id, category_id)
  )

  union all

  -- -------------------------------------------------------------------------
  -- feature_sub_feature / sub
  -- -------------------------------------------------------------------------
  select
    'feature_sub_feature' as stat_scope,
    '整体' as material_id,
    '整体' as os_type,
    coalesce(feature, '整体') as feature,
    coalesce(sub_feature, '整体') as sub_feature,
    '整体' as category_id,
    '整体' as is_new,
    '整体' as is_ua,
    '整体' as country,
    'sub' as event_type,
    count(distinct sub_uv) as uv,
    count(distinct sub_pay_uv) as sub_pay_uv,
    sum(sub_pv) as pv,
    cast(sum(paid_ord_amt) as double) as paid_ord_amt
  from (
    select
      i.feature,
      coalesce(d.sub_feature, i.sub_feature) as sub_feature,
      i.sub_uv,
      i.sub_pay_uv,
      i.sub_pv,
      i.paid_ord_amt
    from (
      select
        material_id,
        feature,
        sub_feature,
        sub_uv,
        sub_pay_uv,
        sub_pv,
        paid_ord_amt
      from
        stat_material.material_adz_beidou_stat_info
      where
        date_p = ${date_p}
        and sub_uv is not null
    ) i
    left join (
      select
        a.material_id,
        a.feature,
        a.sub_feature as sub_feature_raw,
        case
          when c.material_type is not null then c.material_type
          when b.material_type is not null then b.material_type
          when a.sub_feature is not null then a.sub_feature
        end as sub_feature
      from (
        select
          material_id,
          feature,
          sub_feature,
          regexp_extract(material_id, '([A-Z]{3})', 1) as material_type_id_duffle,
          regexp_extract(substr(material_id, 1, 5), '^([0-9]{5})$', 1) as material_type_id_new
        from
          stat_material.material_adz_beidou_stat_info
        where
          date_p = ${date_p}
          and material_id is not null
          and material_id not in ('-1', 'none')
        group by
          material_id,
          feature,
          sub_feature,
          regexp_extract(material_id, '([A-Z]{3})', 1),
          regexp_extract(substr(material_id, 1, 5), '^([0-9]{5})$', 1)
      ) a
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
      ) b on a.material_type_id_duffle = b.material_type_id
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
      ) c on a.material_type_id_new = c.material_type_id
    ) d
      on i.material_id = d.material_id
     and i.feature = d.feature
     and i.sub_feature = d.sub_feature_raw
  ) x
  group by
    feature,
    sub_feature
  with rollup
) a
left join (
  -- 外层素材维表回填：保持原任务口径；维表侧按 join key 去重，降低一对多风险
  select
    a.material_id,
    a.feature,
    case
      when c.material_type is not null then c.material_type
      when b.material_type is not null then b.material_type
      when a.sub_feature is not null then a.sub_feature
    end as sub_feature
  from (
    select
      material_id,
      feature,
      sub_feature,
      regexp_extract(material_id, '([A-Z]{3})', 1) as material_type_id_duffle,
      regexp_extract(substr(material_id, 1, 5), '^([0-9]{5})$', 1) as material_type_id_new,
      sum(click_pv) as click_pv
    from
      stat_material.material_adz_beidou_stat_info
    where
      date_p = ${date_p}
      and material_id not in ('-1', 'none')
      and material_id is not null
    group by
      material_id,
      feature,
      sub_feature,
      regexp_extract(material_id, '([A-Z]{3})', 1),
      regexp_extract(substr(material_id, 1, 5), '^([0-9]{5})$', 1)
  ) a
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
  ) b on a.material_type_id_duffle = b.material_type_id
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
  ) c on a.material_type_id_new = c.material_type_id
) b on a.material_id = b.material_id
;
