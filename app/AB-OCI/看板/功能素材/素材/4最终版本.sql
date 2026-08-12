set spark.driver.maxResultSize=5g;
set hive.exec.dynamic.partition.mode=nonstrict;
set hive.exec.dynamic.partition=true;
set hive.optimize.sort.dynamic.partition=false;
set spark.sql.adaptive.enabled=true;
set spark.sql.adaptive.coalescePartitions.enabled=true;
set spark.sql.adaptive.skewJoin.enabled=true;
set spark.sql.shuffle.partitions=400;
set spark.sql.codegen.wholeStage=false;
with agg_wide as (
  select
    stat_scope,
    material_id,
    os_type,
    feature,
    sub_feature,
    category_id,
    is_new,
    is_ua,
    country,
    sum(
      case
        when event_type = 'exp' then uv
        else 0
      end
    ) as exp_uv,
    sum(
      case
        when event_type = 'click' then uv
        else 0
      end
    ) as click_uv,
    sum(
      case
        when event_type = 'use' then uv
        else 0
      end
    ) as use_uv,
    sum(
      case
        when event_type = 'save' then uv
        else 0
      end
    ) as save_uv,
    sum(
      case
        when event_type = 'exp' then pv
        else 0
      end
    ) as exp_pv,
    sum(
      case
        when event_type = 'click' then pv
        else 0
      end
    ) as click_pv,
    sum(
      case
        when event_type = 'use' then pv
        else 0
      end
    ) as use_pv,
    sum(
      case
        when event_type = 'save' then pv
        else 0
      end
    ) as save_pv,
    sum(
      case
        when event_type = 'sub' then pv
        else 0
      end
    ) as sub_pv,
    sum(
      case
        when event_type = 'sub' then uv
        else 0
      end
    ) as sub_uv,
    sum(coalesce(sub_pay_uv, 0)) as sub_pay_uv,
    sum(coalesce(paid_ord_amt, 0)) as paid_ord_amt
  from
    stat_material.material_adz_beidou_stat_uv_agg
  where
    date_p = ${date_p}
    and (
      (
        stat_scope = 'material'
        and material_id <> '整体'
      )
      or stat_scope = 'feature_sub_feature'
    )
  group by
    stat_scope,
    material_id,
    os_type,
    feature,
    sub_feature,
    category_id,
    is_new,
    is_ua,
    country
),
material_dim as (
  select
    material_id,
    max(nvl(material_name, '未知')) as material_name,
    max(nvl(url, '未知')) as url,
    max(nvl(module, '未知')) as module
  from
    stat_material.material_adz_beidou_stat_info
  where
    date_p = ${date_p}
    and material_id is not null
    and material_id <> ''
  group by
    material_id
),
category_dim as (
  select
    nvl(category_id, '未知') as category_id,
    max(nvl(category_name, '未知')) as category_name
  from
    stat_material.material_adz_beidou_stat_info
  where
    date_p = ${date_p}
  group by
    nvl(category_id, '未知')
  union all
  select
   distinct '整体' as category_id,
    '整体' as category_name
   from
    stat_material.material_adz_beidou_stat_info
  where
    date_p = ${date_p}
)

insert overwrite table stat_material.material_adz_beidou_stat_data partition (date_p = ${date_p})
select
  a.material_id,
  a.os_type,
  a.feature,
  a.sub_feature,
  case
    when a.material_id = '整体' then '整体'
    else coalesce(b.material_name, '未知')
  end as material_name,
  a.category_id,
  coalesce(c.category_name, '整体') as category_name,
  case
    when a.material_id = '整体' then '整体'
    else coalesce(b.url, '未知')
  end as url,
  a.is_new,
  a.is_ua,
  a.country,
  case
    when a.material_id = '整体' then '图片编辑器'
    else coalesce(b.module, '未知')
  end as module,
  a.exp_uv,
  a.click_uv,
  a.use_uv,
  a.save_uv,
  a.exp_pv,
  a.click_pv,
  a.use_pv,
  a.save_pv,
  a.sub_pv,
  a.sub_uv,
  a.sub_pay_uv,
  a.paid_ord_amt
from
  (
    select
      *
    from
      agg_wide
  ) a
  left join (
    select
      *
    from
      material_dim
  ) b on a.material_id = b.material_id
  left join(
    select
      *
    from
      category_dim
  ) c on a.category_id = c.category_id;
