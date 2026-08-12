insert overwrite table stat_aigc.cost_adz_aigc_inner_and_out_cost_d partition (date_p = ${date_p})

SELECT
  app_name_cn,
  cost_type,
  algo_provider,
  func_name,
  func_effect,
  country_name,
  req_num,
  req_time,
  cost,
  model_name

from
  (
    SELECT

      nvl(cost_type, "整体") cost_type,
      nvl(algo_provider, "整体") algo_provider,
      nvl(func_name, "整体") func_name,
      nvl(country_name, "整体") country_name,
      count(DISTINCT a.order_id) req_num,
      sum(a.req_time) req_time,
      sum(a.cost) cost,
      nvl(app_name_cn, "整体") app_name_cn,
      nvl(func_effect, "整体") func_effect,
      nvl(model_name, "整体" ) model_name
    from
      (
        selECT
          COALESCE(a.cost_type, "未知") cost_type,
          COALESCE(a.algo_provider, "未知") algo_provider,

          case when a.country_name in (
              '中国',
              '泰国',
              '中国台湾',
              '印度尼西亚',
              '越南',
              '马来西亚',
              '印度',
              '美国',
              '缅甸',
              '日本',
              '菲律宾',
              '巴基斯坦',
              '巴西',
              '柬埔寨',
              '老挝',
              '韩国',
              '新加坡',
              '英国'

           ) then a.country_name
           when a.country_name is not null then "其他国家"
           else "未知"
          end  country_name,
          COALESCE(COALESCE(a.func_name, a.func_id), "未定义功能") func_name,
          COALESCE(a.app_name_cn, "未知") app_name_cn,
          a.order_id,
          sum(a.req_time) req_time,
          sum(a.cost) cost,
          COALESCE( func_effect, "未知" ) func_effect,
          COALESCE( model_name ,  "未知" ) model_name
        from
          (

            selECT
              cost_type,
              algo_provider,
              country_name,
              func_name,
              func_id,
              os_type,
              app_name_cn,
              order_id,
              uid,
              req_time,
              cost,
              country_type,
              time_hour,
              time_minute,
              date_p,
              func_effect,
              model_name
            from
              stat_aigc.cost_odz_aigc_cost_detail_d
            where
              date_p = ${date_p}
          ) a
        group by
          COALESCE(a.cost_type, "未知"),
          COALESCE(a.algo_provider, "未知"),
           case when a.country_name in (
              '中国',
              '泰国',
              '中国台湾',
              '印度尼西亚',
              '越南',
              '马来西亚',
              '印度',
              '美国',
              '缅甸',
              '日本',
              '菲律宾',
              '巴基斯坦',
              '巴西',
              '柬埔寨',
              '老挝',
              '韩国',
              '新加坡',
              '英国'

           ) then a.country_name
           when a.country_name is not null then "其他国家"
           else "未知"
          end  ,
          COALESCE(COALESCE(a.func_name, a.func_id), "未定义功能"),
          COALESCE(a.os_type, "未知"),
          COALESCE(a.app_name_cn, "未知"),
          a.order_id,
          COALESCE( func_effect, "未知" ),
          COALESCE( model_name ,  "未知" )


      ) a
    group by
      cost_type,
      algo_provider,
      country_name,
      func_name,
      app_name_cn,
      func_effect,
      model_name

      with cube
  ) a