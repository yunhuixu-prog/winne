with source_data as (
  select
    /*+ broadcast (d,e,g) */
    a.country_id,
    os_type,
    material_type,
    a.material_id,
    a.category_id,
    order_id,
    a.gid,
    event_type,
    case
      when b.gid is not null then '新用户'
      else '老用户'
    end as is_new,
    c.is_ua,
    category_name,
    material_name,
    url,
    case
      when g.country is not null then g.country
      when a.country_id = '未知' then '未知'
      when a.country_id = '其他' then '其他'
      else '其他'
    end as country,
    count(1) as cnt
  from
    (
      SELECT
        country_id,
        os_type,
        t_type.val AS material_type,
        t_id.val AS material_id,
        regexp_replace(t_id.val, '^AB_', '') as AB_material_id,
        t_cat.val AS category_id,
        order_id,
        gid,
        event_type
      FROM
        (
          select
            case
              when country_id in (
                '10038',
                '10100',
                '10052',
                '10209',
                '10212',
                '10139',
                '10112'
              ) then country_id
              when country_id is null then '未知'
              else '其他'
            end country_id,
            os_type,
            params ['material_type'] material_type,
            params ['material_id'] material_id,
            params ['category_id'] category_id,
            params ['order_id'] order_id,
            gid,
            '曝光' as event_type
          from
            stat_sdk.sdk_odz_source_data
          WHERE
            date_p = ${date_p}
            and app_key_p IN ('C851ED7164B6DF0F', '7F7023B6CEC7CDED')
            and event_id = 'material_exposure'
            and params ['module'] = 'edit'
            and params ['material_id'] is not null
          union ALL
          select
            case
              when country_id in (
                '10038',
                '10100',
                '10052',
                '10209',
                '10212',
                '10139',
                '10112'
              ) then country_id
              when country_id is null then '未知'
              else '其他'
            end country_id,
            os_type,
            params ['material_type'] material_type,
            params ['material_id'] material_id,
            params ['category_id'] category_id,
            params ['order_id'] order_id,
            gid,
            '点击' as event_type
          from
            stat_sdk.sdk_odz_source_data
          WHERE
            date_p = ${date_p}
            and app_key_p IN ('C851ED7164B6DF0F', '7F7023B6CEC7CDED')
            and event_id = 'material_click'
            and params ['module'] = 'edit'
            and params ['material_id'] is not null
          union ALL
          select
            case
              when country_id in (
                '10038',
                '10100',
                '10052',
                '10209',
                '10212',
                '10139',
                '10112'
              ) then country_id
              when country_id is null then '未知'
              else '其他'
            end country_id,
            os_type,
            params ['material_type'] material_type,
            params ['mids_material_id'] material_id,
            params ['mids_category_id'] category_id,
            params ['order_id'] order_id,
            gid,
            '使用' as event_type
          from
            stat_sdk.sdk_odz_source_data
          WHERE
            date_p = ${date_p}
            and app_key_p IN ('C851ED7164B6DF0F', '7F7023B6CEC7CDED')
            and event_id = 'material_check'
            and params ['module'] = 'edit'
            and params ['mids_material_id'] is not null
          union all
          SELECT
            case
              when country_id in (
                '10038',
                '10100',
                '10052',
                '10209',
                '10212',
                '10139',
                '10112'
              ) then country_id
              when country_id is null then '未知'
              else '其他'
            end country_id,
            os_type,
            nvl(
              nullif(params ['prf_material_type'], ''),
              params ['prf_second_func']
            ) as material_type,
            params ['mids_material_id'] as material_id,
            params ['mids_category_id'] as category_id,
            params ['order_id'] as order_id,
            gid,
            '保存' as event_type
          FROM
            stat_sdk.sdk_odz_source_data
          WHERE
            date_p = ${date_p}
            AND app_key_p IN ('C851ED7164B6DF0F', '7F7023B6CEC7CDED')
            AND event_id = 'edit_save'
            and params ['mids_material_id'] is not null
        ) t LATERAL VIEW POSEXPLODE(split(material_id, ',')) t_id AS pos_id,
        val LATERAL VIEW POSEXPLODE(split(material_type, ',')) t_type AS pos_type,
        val LATERAL VIEW POSEXPLODE(split(category_id, ',')) t_cat AS pos_cat,
        val
      WHERE
        t_id.pos_id = t_type.pos_type
        AND t_id.pos_id = t_cat.pos_cat
      union all
      SELECT
        country_id,
        os_type,
        t_type.val AS material_type,
        t_id.val AS material_id,
        regexp_replace(t_id.val, '^AB_', '') as AB_material_id,
        t_cat.val AS category_id,
        order_id,
        gid,
        event_type
      FROM
        (
          select
            case
              when country_id in (
                '10038',
                '10100',
                '10052',
                '10209',
                '10212',
                '10139',
                '10112'
              ) then country_id
              when country_id is null then '未知'
              else '其他'
            end country_id,
            os_type,
            replace(params ['source_0'], 'f_', '') material_type,
            params ['mids_material_id'] as material_id,
            params ['mids_category_id'] category_id,
            params ['order_id'] order_id,
            gid,
            '订阅' as event_type
          from
            stat_sdk.sdk_odz_source_data
          WHERE
            date_p = ${date_p}
            and app_key_p IN ('C851ED7164B6DF0F', '7F7023B6CEC7CDED')
            and event_id = 'w_subscription_success'
            and params ['mids_material_id'] is not null
            and params ['source_0'] like 'f_%'
        ) t LATERAL VIEW POSEXPLODE(split(material_id, ',')) t_id AS pos_id,
        val LATERAL VIEW POSEXPLODE(split(material_type, ',')) t_type AS pos_type,
        val LATERAL VIEW POSEXPLODE(split(category_id, ',')) t_cat AS pos_cat,
        val
      WHERE
        t_id.pos_id = t_cat.pos_cat
    ) a
    left join (
      SELECT
        final_id as gid
      FROM
        stat_sdk.sdk_odz_new_device_info
      WHERE
        date_p = ${date_p}
        AND app_key_p IN ('C851ED7164B6DF0F', '7F7023B6CEC7CDED')
        AND os_p IS NOT NULL
      group by
        final_id
    ) b on a.gid = b.gid
    left join (
      SELECT
        final_id as gid,
        max(is_ua) as is_ua
      FROM
        stat_sdk.sdk_odz_active
      WHERE
        date_p = ${date_p}
        AND app_key_p IN ('C851ED7164B6DF0F', '7F7023B6CEC7CDED')
        AND os_p IS NOT NULL
      group by
        final_id
    ) c on a.gid = c.gid
    left join (
      select
        category_id,
        category_name
      from
        stat_material.material_rda_category_name
      where
        date_p = ${now_time}
    ) d on a.category_id = d.category_id
    left join (
      select
        material_id as g_id,
        material_name,
        url,
        date_p
      from
        stat_material.material_rda_material_name
      where
        date_p = ${now_time}
    ) e on a.material_id = e.g_id
   
    LEFT JOIN (
      SELECT
        id AS country_id,
        name AS country
      FROM
        stat_sdk.dim_rna_ip_location
      WHERE
        date_p = ${now_time}
        and level = '1'
      group by
        id,
        name
    ) g ON a.country_id = g.country_id
  group by
    a.country_id,
    os_type,
    material_type,
    a.material_id,
    a.category_id,
    order_id,
    a.gid,
    event_type,
    case
      when b.gid is not null then '新用户'
      else '老用户'
    end,
    c.is_ua,
    category_name,
    material_name,
    url,
    case
      when g.country is not null then g.country
      when a.country_id = '未知' then '未知'
      when a.country_id = '其他' then '其他'
      else '其他'
    end
)
insert
  overwrite table stat_material.material_adz_beidou_stat_info partition (date_p = ${date_p})
select
  a.material_id,
  a.os_type,
  material_type as feature,
  CASE
    WHEN material_type = 'makeup'
    AND substr(cast(a.material_id AS string), 1, 5) = '10008' THEN '套妆'
    WHEN material_type = 'makeup'
    AND substr(cast(a.material_id AS string), 1, 5) = '10009' THEN '眉毛'
    WHEN material_type = 'makeup'
    AND substr(cast(a.material_id AS string), 1, 5) = '10010' THEN '睫毛'
    WHEN material_type = 'makeup'
    AND substr(cast(a.material_id AS string), 1, 5) = '10011' THEN '眼线'
    WHEN material_type = 'makeup'
    AND substr(cast(a.material_id AS string), 1, 5) = '10012' THEN '眼影'
    WHEN material_type = 'makeup'
    AND substr(cast(a.material_id AS string), 1, 5) = '10013' THEN '美瞳'
    WHEN material_type = 'makeup'
    AND substr(cast(a.material_id AS string), 1, 5) = '10014' THEN '腮红'
    WHEN material_type = 'makeup'
    AND substr(cast(a.material_id AS string), 1, 5) = '10015' THEN '口红'
    WHEN material_type = 'makeup'
    AND substr(cast(a.material_id AS string), 1, 5) = '10016' THEN '修容'
    WHEN material_type = 'makeup'
    AND substr(cast(a.material_id AS string), 1, 5) = '10017' THEN '雀斑'
    WHEN material_type = 'text'
    AND cast(a.material_id AS string) LIKE 'AB_FON%' THEN '字体'
    WHEN material_type = 'text'
    AND cast(a.material_id AS string) LIKE 'AB_TEX%' THEN '模板'
    ELSE material_type
  END as sub_feature,
  a.material_name,
  a.category_id,
  a.category_name ,
  a.url ,
  is_new,
  is_ua,
  a.country_id,
  a.country,
  '图片编辑器' as module,
  exp_gid as exp_uv,
  click_gid as click_uv,
  use_gid as use_uv,
  save_gid as save_uv,
  exp_cnt as exp_pv,
  click_cnt as click_pv,
  use_cnt as use_pv,
  save_cnt as save_pv,
  sub_cnt as sub_pv,
  sub_gid as sub_uv,
  -- 订阅数
  '1' as sub_pay_uv,
  -- 订阅转付费数
  0 as paid_ord_amt -- 订阅收入
from
  (
    select
      country_id,
      os_type,
      material_type,
      material_id,
      category_id,
      order_id,
      event_type,
      is_new,
      is_ua,
      category_name,
      material_name,
      country,
      url,
      case
        when event_type = '曝光' then gid
      end as exp_gid,
      case
        when event_type = '点击' then gid
      end as click_gid,
      case
        when event_type = '使用' then gid
      end as use_gid,
      case
        when event_type = '保存' then gid
      end as save_gid,
      case
        when event_type = '订阅' then gid
      end as sub_gid,
      case
        when event_type = '曝光' then cnt
        else 0
      end as exp_cnt,
      case
        when event_type = '点击' then cnt
        else 0
      end as click_cnt,
      case
        when event_type = '使用' then cnt
        else 0
      end as use_cnt,
      case
        when event_type = '保存' then cnt
        else 0
      end as save_cnt,
      case
        when event_type = '订阅' then cnt
        else 0
      end as sub_cnt
    from
      source_data
    where
      event_type in ('曝光', '点击', '使用', '订阅')
    union all
    select
      a.country_id,
      a.os_type,
      a.material_type,
      a.material_id,
      a.category_id,
      a.order_id,
      a.event_type,
      a.is_new,
      a.is_ua,
      a.category_name,
      a.material_name,
      a.country,
      a.url,
      null as exp_gid,
      null as click_gid,
      null as use_gid,
      b.save_gid,
      null as sub_gid,
      0 as exp_cnt,
      0 as click_cnt,
      0 as use_cnt,
      b.save_cnt,
      0 as sub_cnt
    from
      (
        select
          country_id,
          os_type,
          material_type,
          material_id,
          category_id,
          order_id,
          event_type,
          is_new,
          is_ua,
          category_name,
          material_name,
          country,
          url,
          null as exp_gid,
          gid as click_gid,
          null as use_gid,
          null as save_gid,
          null as sub_gid,
          0 as exp_cnt,
          cnt as click_cnt,
          0 as use_cnt,
          0 as save_cnt,
          0 as sub_cnt
        from
          source_data
        where
          event_type = '点击'
      ) a
      left join (
        select
          country_id,
          os_type,
          material_type,
          material_id,
          category_id,
          order_id,
          event_type,
          is_new,
          is_ua,
          category_name,
          material_name,
          country,
          url,
          null as exp_gid,
          null as click_gid,
          null as use_gid,
          gid as save_gid,
          null as sub_gid,
          0 as exp_cnt,
          0 as click_cnt,
          0 as use_cnt,
          cnt as save_cnt,
          0 as sub_cnt
        from
          source_data
        where
          event_type = '保存'
      ) b on a.country_id = b.country_id
      and a.os_type = b.os_type
      and a.material_type = b.material_type
      and a.material_id = b.material_id
      and a.category_id = b.category_id
      and a.country = b.country
      and a.click_gid = b.save_gid
  ) a
  