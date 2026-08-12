-- 回填最近7天订阅付费数据，并在原明细表内统一清洗维度字段。
-- material_id 不改成“整体”，避免和后续 cube 汇总层混淆。
-- 后续 UV 去重节点可直接读取 stat_material.material_adz_beidou_stat_info。

set hive.exec.dynamic.partition.mode=nonstrict;
set hive.exec.dynamic.partition=true;

with order_table as (
  select
    os_type,
    country,
    gid,
    exploded_material_id as material_id,
    paid_ord_amt,
    order_id,
    pay_date
  from (
    select
      case
        when t1.os_type = 'android' then 'android'
        when t1.os_type = 'ios' then 'ios'
        when t1.os_type is null or t1.os_type = '' then '未知'
        else '其他'
      end as os_type,
      case
        when t1.country in ('美国', '英国', '巴西', '加拿大', '澳大利亚', '墨西哥', '西班牙') then t1.country
        when t1.country is null or t1.country = '' then '未知'
        else '其他'
      end as country,
      t1.pay_date,
      t1.pay_time,
      t1.mids_material_id,
      t1.contract_id,
      t2.order_id,
      t1.gid,
      t1.third_product_id as sku,
      case
        when t1.cur_pay_withhold_stage = 1 then t1.pay_date
        when t1.cur_pay_withhold_stage = 0 and t2.contract_id is not null then t2.pay_date
      end as paid_date,
      case
        when t1.cur_pay_withhold_stage = 1
          or (t1.cur_pay_withhold_stage = 0 and t2.contract_id is not null)
        then 1
        else 0
      end as is_paid,
      case
        when t1.cur_pay_withhold_stage = 1 then t1.ord_amt
        when t1.cur_pay_withhold_stage = 0 and t2.contract_id is not null then t2.ord_amt
        else 0
      end as paid_ord_amt
    from (
      select
        contract_id,
        gid,
        os_type,
        country_name as country,
        period_type,
        pay_date,
        pay_time,
        cur_pay_withhold_stage,
        ord_amt_usd as ord_amt,
        round(ord_amt_usd * ord_before_amt / ord_amt, 3) as ord_before_amt,
        third_product_id,
        get_json_object(big_data, '$.source_module') as source_module,
        get_json_object(big_data, '$.source_0') as source_0,
        get_json_object(big_data, '$.source_1') as source_1,
        get_json_object(big_data, '$.mids_material_id') as mids_material_id,
        get_json_object(big_data, '$.mids_category_id') as mids_category_id
      from stat_vip.paid_oda_vip_all_order
      where date_p = ${now_time}
        and pay_date >= ${date_p_7}
        and pay_date <= ${date_p}
        and app_id_p in (7329803307041000000)
        and commodity_id_p not in (-1)
        and cur_pay_stage = 1
        and order_type = 2
        and contract_id <> 0
    ) t1
    left join (
      select
        order_id,
        contract_id,
        min(pay_date) as pay_date,
        max(ord_amt_usd) as ord_amt,
        max(round(ord_amt_usd * ord_before_amt / ord_amt, 3)) as ord_before_amt
      from stat_vip.paid_oda_vip_all_order
      where date_p = ${now_time}
        and cur_pay_withhold_stage = 1
        and commodity_id_p not in (-1)
        and order_type = 2
        and contract_id <> 0
        and app_id_p in (7329803307041000000)
      group by
        contract_id,
        order_id
    ) t2
      on t1.contract_id = t2.contract_id
  ) a
  lateral view explode(split(mids_material_id, ',')) t as exploded_material_id
  where order_id is not null
    and exploded_material_id is not null
    and exploded_material_id <> ''
)
insert overwrite table stat_material.material_adz_beidou_stat_info partition (date_p)
select
  a.material_id,
  a.os_type,
  a.feature,
  a.sub_feature,
  a.material_name,
  a.category_id,
  a.category_name,
  a.url,
  a.is_new,
  a.is_ua,
  a.country_id,
  a.country,
  a.module,
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
  b.gid as sub_pay_uv,
  b.paid_ord_amt as paid_ord_amt,
  a.date_p
from (
  select
    material_id,
    case
      when os_type is null or os_type = '' then '未知'
      else os_type
    end as os_type,
    case
      when feature is null or feature = '' then '未知'
      else feature
    end as feature,
    case
      when sub_feature is null or sub_feature = '' then '未知'
      else sub_feature
    end as sub_feature,
    case
      when material_name is null or material_name = '' then '未知'
      else material_name
    end as material_name,
    case
      when category_id is null or category_id = '' then '未知'
      else category_id
    end as category_id,
    case
      when category_name is null or category_name = '' then '未知'
      else category_name
    end as category_name,
    case
      when url is null or url = '' then '未知'
      else url
    end as url,
    case
      when is_new is null or is_new = '' then '未知'
      else is_new
    end as is_new,
    case
      when is_ua is null or is_ua = '' then '未知'
      else is_ua
    end as is_ua,
    case
      when country_id is null or country_id = '' then '未知'
      else country_id
    end as country_id,
    case
      when country in ('美国', '英国', '巴西', '加拿大', '澳大利亚', '墨西哥', '西班牙') then country
      when country is null or country = '' then '未知'
      else '其他'
    end as country,
    case
      when module is null or module = '' then '未知'
      else module
    end as module,
    exp_uv,
    click_uv,
    use_uv,
    save_uv,
    cast(coalesce(exp_pv, 0) as bigint) as exp_pv,
    cast(coalesce(click_pv, 0) as bigint) as click_pv,
    cast(coalesce(use_pv, 0) as bigint) as use_pv,
    cast(coalesce(save_pv, 0) as bigint) as save_pv,
    cast(coalesce(sub_pv, 0) as bigint) as sub_pv,
    sub_uv,
    sub_pay_uv,
    paid_ord_amt,
    date_p
  from stat_material.material_adz_beidou_stat_info
  where date_p >= ${date_p_7}
    and date_p <= ${date_p}
) a
left join (
  select
    os_type,
    country,
    material_id,
    gid,
    pay_date,
    sum(paid_ord_amt) as paid_ord_amt
  from order_table
  where paid_ord_amt > 0
    and order_id is not null
    and pay_date >= ${date_p_7}
    and pay_date <= ${date_p}
  group by
    os_type,
    country,
    material_id,
    gid,
    pay_date
) b
  on a.sub_uv = b.gid
 and a.material_id = b.material_id
 and a.os_type = b.os_type
 and a.country = b.country
 and a.date_p = b.pay_date;