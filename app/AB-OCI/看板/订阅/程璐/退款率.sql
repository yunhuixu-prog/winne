set hive.new.job.grouping.set.cardinality=1024;
set mapred.max.split.size = 853333;
set hive.query.timeout.seconds=10800;
set mapred.reduce.tasks=500;

insert overwrite table stat_vip.vip_ada_subscription_purchase_refund_rateoci

select t1.pay_date as pay_date
      ,t1.product_sub_line as product_sub_line
      ,t1.os_type as os_type
      ,t1.country_code as country_code
      ,t1.geographic_subdivision_v2 as geographic_subdivision_v2
      ,t1.is_subscribe as is_subscribe
      ,t1.period_type as period_type
      ,t1.type as type
      ,t1.if_try as if_try
      ,nvl(round(refund_amt/ord_amt,100),0) refund_rate
      ,nvl(round(refund_oid/all_oid,100),0) refund_oid_rate
      ,refund_amt
      ,refund_oid
      ,ord_amt
      ,all_oid
from
    (select   nvl(pay_date,'整体') as pay_date
              ,nvl(product_sub_line,'整体') as product_sub_line
              ,nvl(os_type,'整体') as os_type
              ,nvl(country_code,'整体') as country_code
              ,nvl(geographic_subdivision_v2,'整体') as geographic_subdivision_v2
              ,nvl(is_subscribe,'整体') as is_subscribe
              ,nvl(period_type,'整体') as period_type
              ,nvl(type,'整体') as type
              ,nvl(if_try,'整体') as if_try
              ,sum(ord_amt) as ord_amt
              ,count(distinct order_id) as all_oid
    from
      (select /*+MAPJOIN(t22)*/
       pay_date
              ,product_sub_line
              ,os_type
              ,country_code
              ,is_subscribe
              ,period_type
              ,type
              ,if_try
              ,ord_amt
              ,order_id
              ,nvl(geographic_subdivision_v2,'东亚') as geographic_subdivision_v2
      from
          (select  pay_date
                  ,product_sub_line
                  ,case when os_type='android' and pay_channel='google' then 'google'
                        when os_type in ('android','androidpad') then 'android'
                        when os_type in ('ios','ipad') then 'ios'
                        else os_type end as os_type
                  ,nvl(country_name,'未知') country_code
                  ,'订阅' as is_subscribe
                  ,period_type
                  ,case when cur_pay_withhold_stage<=1 then '首单' else '续费' end as type
                  ,case when if_try='试用' then '试用' else '非试用' end as  if_try
                  ,ord_amt
                  ,order_id
          from stat_vip.paid_oda_vip_all_order
          where date_p=${now_time}
                and pay_date<=${start_time}
                and app_id_p not in (-1)
                and commodity_id_P not in (-1)
          union all
          select pay_date
                ,product_sub_line
                ,case when os_type='android' and pay_channel='google' then 'google'
                      when os_type in ('android','androidpad') then 'android'
                      when os_type in ('ios','ipad') then 'ios'
                      else os_type end as os_type
                ,nvl(country_name,'未知') country_code
                ,is_subscribe
                ,period_type
                ,'首单' as type
                ,'非试用' as  if_try
                ,ord_amt
                ,order_id
          from stat_vip.paid_oda_all_order_summary
          where app_id_p not in (-1)
                and create_date <=${start_time}
                and pay_date <=${start_time}
                and is_subscribe = '单购'
                and pay_status >= 3 --3已支付，6已退款
          )a
    left join
            (select sdk_country_name
                    ,geographic_subdivision_v2
                from stat_sdk.dim_rna_ip_location
                where date_p=${now_time}
                group by sdk_country_name,geographic_subdivision_v2
            )t22
  on a.country_code=t22.sdk_country_name
      )t11
    group by pay_date,product_sub_line,os_type,country_code,geographic_subdivision_v2,is_subscribe,period_type,type,if_try with cube
    )t1

left join

    (select   nvl(pay_date,'整体') as pay_date
              ,nvl(product_sub_line,'整体') as product_sub_line
              ,nvl(os_type,'整体') as os_type
              ,nvl(country_code,'整体') as country_code
              ,nvl(geographic_subdivision_v2,'整体') as geographic_subdivision_v2
              ,nvl(is_subscribe,'整体') as is_subscribe
              ,nvl(period_type,'整体') period_type
              ,nvl(type,'整体') as type
              ,nvl(if_try,'整体') as if_try
              ,sum(refund_amt) as refund_amt
              ,count(distinct order_id) as refund_oid
    from
      (select pay_date
              ,product_sub_line
              ,os_type
              ,country_code
              ,is_subscribe
              ,period_type
              ,type
              ,if_try
              ,refund_amt
              ,order_id
              ,nvl(geographic_subdivision_v2,'东亚') as geographic_subdivision_v2
      from
       (select  pay_date
              ,product_sub_line
              ,case when os_type='android' and pay_channel='google' then 'google'
                    when os_type in ('android','androidpad') then 'android'
                    when os_type in ('ios','ipad') then 'ios'
                    else os_type end as os_type
              ,nvl(country_name,'未知') country_code
              ,'订阅' as is_subscribe
              ,period_type
              ,case when cur_pay_withhold_stage<=1 then '首单' else '续费' end as type
              ,case when if_try='试用' then '试用' else '非试用' end as  if_try
              ,refund_amt
              ,order_id
       from stat_vip.paid_oda_vip_all_order
       where date_p=${now_time}
             and substr(refund_time,1,8) <=${start_time}
             and app_id_p not in (-1)
             and commodity_id_P not in (-1)
      union all
      select pay_date
            ,product_sub_line
            ,case when os_type='android' and pay_channel='google' then 'google'
                  when os_type in ('android','androidpad') then 'android'
                  when os_type in ('ios','ipad') then 'ios'
                  else os_type end as os_type
            ,nvl(country_name,'未知') country_code
            ,is_subscribe
            ,period_type
            ,'首单' as type
            ,'非试用' as  if_try
            ,refund_amt
            ,order_id
       from stat_vip.paid_oda_all_order_summary
       where app_id_p not in (-1)
             and create_date <=${start_time}
             and refund_date<=${start_time}
             and is_subscribe = '单购'
             and pay_status >= 3 --3已支付，6已退款
       )b
    left join
            (select sdk_country_name
                    ,geographic_subdivision_v2
                from stat_sdk.dim_rna_ip_location
                where date_p=${now_time}
                group by sdk_country_name,geographic_subdivision_v2
            )t23
     on b.country_code=t23.sdk_country_name
      )t12
    group by pay_date,product_sub_line,os_type,country_code,geographic_subdivision_v2,is_subscribe,period_type,type,if_try with cube
    )t2
on t1.pay_date=t2.pay_date and t1.product_sub_line=t2.product_sub_line and t1.os_type=t2.os_type and  t1.is_subscribe=t2.is_subscribe and t1.country_code=t2.country_code
   and t1.geographic_subdivision_v2=t2.geographic_subdivision_v2 and t1.period_type=t2.period_type and t1.type=t2.type and t1.if_try=t2.if_try
where t1.pay_date<>'整体'




