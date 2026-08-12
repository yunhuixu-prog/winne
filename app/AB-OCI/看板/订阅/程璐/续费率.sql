----续费率
set hive.new.job.grouping.set.cardinality=1024;
set mapred.max.split.size = 853333;
set hive.query.timeout.seconds=10800;
set mapred.reduce.tasks=500;
insert overwrite table stat_vip.vip_ada__middle_renewoci PARTITION(date_p=${start_time})
select pay_channel
      ,os_type
      ,country_code
      ,geographic_subdivision_v2
      ,app_type
      ,period_type
      ,num_0
      ,num_1
      ,num_2
      ,num_3
      ,num_4
      ,num_5
      ,num_6
      ,num_7
      ,num_8
      ,num_9
      ,num_10
      ,num_11
      ,pay_date
from
    (
       select  t1.pay_date pay_date
               ,nvl(pay_channel,'整体') pay_channel
               ,nvl(os_type,'整体') os_type
               ,nvl(country_code,'整体') country_code
               ,nvl(geographic_subdivision_v2,'整体') geographic_subdivision_v2
               ,nvl(app_name,'整体') app_type
               ,nvl(t1.period_type,'整体') period_type
               ,count(distinct t1.contract_id) num_0
               ,count(distinct case when order_by_pay=2 then t3.contract_id else null end) num_1
               ,count(distinct case when order_by_pay=3 then t3.contract_id else null end) num_2
               ,count(distinct case when order_by_pay=4 then t3.contract_id else null end) num_3
               ,count(distinct case when order_by_pay=5 then t3.contract_id else null end) num_4
               ,count(distinct case when order_by_pay=6 then t3.contract_id else null end) num_5
               ,count(distinct case when order_by_pay=7 then t3.contract_id else null end) num_6
               ,count(distinct case when order_by_pay=8 then t3.contract_id else null end) num_7
               ,count(distinct case when order_by_pay=9 then t3.contract_id else null end) num_8
               ,count(distinct case when order_by_pay=10 then t3.contract_id else null end) num_9
               ,count(distinct case when order_by_pay=11 then t3.contract_id else null end) num_10
               ,count(distinct case when order_by_pay=12 then t3.contract_id else null end) num_11

       from
               (select contract_id
                      ,os_type
                      ,app_name
                      ,country_code
                      ,nvl(geographic_subdivision_v2,'未知') geographic_subdivision_v2
                      ,period_type
                      ,ord_amt
                      ,pay_date
                      ,gid
                      ,cur_withhold_stage
                      ,cur_pay_withhold_stage
                      ,invalid_time
                      ,pay_status
                      ,pay_channel
                      ,date_p2
                      ,date_p1
                from
                  (select   contract_id
                          ,case when os_type='android' and pay_channel='google' then 'google'
                              when os_type in ('android','androidpad') then 'android'
                              when os_type in ('ios','ipad') then 'ios'
                              else os_type end as os_type
                          ,product_sub_line   as app_name
                          ,nvl(country_name,'未知') country_code
                          ,period_type
                          ,ord_amt
                          ,pay_date
                          ,gid
                          ,cur_pay_stage  as cur_withhold_stage
                          ,cur_pay_withhold_stage
                          ,invalid_time
                          ,pay_status
                          ,pay_channel
                          ,from_unixtime(unix_timestamp(string(pay_date),'yyyyMMdd'),'yyyy-MM-dd') date_p2
                          ,from_unixtime(unix_timestamp(string(date_p),'yyyyMMdd'),'yyyy-MM-dd') date_p1
                  from stat_vip.paid_oda_vip_all_order
                  WHERE date_p=${now_time}
                         and cur_pay_withhold_stage=1     -- 当前订单代扣期数(不包含试用单)
                         and order_type='2'   -- 订单类型(1:非续期订阅 2:续期订阅 3:消耗品 4:非消耗品)
                         and contract_id<>0   -- 续期型订单的contract_id不等于0
                         and app_id_p not in (-1)
                         and commodity_id_P not in (-1)
                  )a
              left join
                (select sdk_country_name
                        ,geographic_subdivision_v2
                    from stat_sdk.dim_rna_ip_location
                    where date_p=${now_time}
                    group by sdk_country_name,geographic_subdivision_v2
                )t22
               on a.country_code=t22.sdk_country_name
               )t1

       left join
               (
                  select    contract_id
                           ,cur_pay_withhold_stage order_by_pay
                           ,period_type
                  from stat_vip.paid_oda_vip_all_order
                  WHERE date_p=${now_time}
                         and cur_pay_withhold_stage>1
                         and order_type='2'   -- 订单类型(1:非续期订阅 2:续期订阅 3:消耗品 4:非消耗品)
                         and contract_id<>0   -- 续期型订单的contract_id不等于0
                         and app_id_p not in (-1)
                         and commodity_id_P not in (-1)
               )t3
       on t1.contract_id=t3.contract_id and t1.period_type=t3.period_type
       group by pay_date,pay_channel,os_type,country_code,app_name,t1.period_type,geographic_subdivision_v2  with cube
    )t
where pay_date is not null