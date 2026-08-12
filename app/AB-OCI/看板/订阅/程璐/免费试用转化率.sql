set hive.new.job.grouping.set.cardinality=1024;
set mapred.max.split.size = 853333;
set hive.query.timeout.seconds=10800;
set mapred.reduce.tasks=500;
insert overwrite table stat_vip.vip_adz_promotionoci PARTITION(date_p=${start_time})
select pay_channel
      ,product_line
      ,product_sub_line
      ,os_type
      ,period_type
      ,country_code
      ,geographic_subdivision_v2
      ,num_7day
      ,num_pay
      ,pay_date
from
(
   select  pay_date
           ,nvl(product_line,'整体') product_line
           ,nvl(product_sub_line,'整体') product_sub_line
           ,nvl(pay_channel,'整体') pay_channel
           ,nvl(geographic_subdivision_v2,'整体') geographic_subdivision_v2
           ,nvl(os_type,'整体') os_type
           ,nvl(period_type,'整体') period_type
           ,nvl(country_code,'整体') country_code
           ,count(distinct t1.contract_id) num_7day
           ,count(distinct t3.contract_id) num_pay
   from
      (
          select   contract_id
                  ,case when os_type='android' and pay_channel='google' then 'google'
                      when os_type in ('android','androidpad') then 'android'
                      when os_type in ('ios','ipad') then 'ios'
                      when os_type is null or os_type='' then '未知'
                      else os_type end as os_type
                  ,product_line
                  ,product_sub_line
                  ,nvl(country_name,'未知') country_code
                  ,period_type
                  ,pay_channel
                  ,pay_date
          from stat_vip.paid_oda_vip_all_order
          WHERE date_p=${now_time}
                and pay_date<=${start_time}
                and app_id_p not in (-1)
                and commodity_id_P not in (-1)
                and cur_pay_withhold_stage=0
                and cur_pay_stage=1
                and order_type=2   -- (1:非续期订阅 2:续期订阅 3:消耗品 4:非消耗品)
                and contract_id<>0  -- 续期型的contract_id非0，这些条件是为了减少数据量，缩短运行时长
      )t1
   left join
      (select sdk_country_name
              ,geographic_subdivision_v2
        from stat_sdk.dim_rna_ip_location
        where date_p=${now_time}
        group by sdk_country_name,geographic_subdivision_v2
      )t22
   on t1.country_code=t22.sdk_country_name
   left join
      (select   contract_id
        from stat_vip.paid_oda_vip_all_order
        WHERE date_p=${now_time}
              and cur_pay_withhold_stage=1   -- 当前订单代扣期数(不包含试用单)
              and commodity_id_P not in (-1)
              and order_type=2   -- (1:非续期订阅 2:续期订阅 3:消耗品 4:非消耗品)
              and contract_id<>0  -- 续期型的contract_id非0，这些条件是为了减少数据量，缩短运行时长
              and app_id_p not in (-1)
      group by  contract_id
      )t3
   on t1.contract_id=t3.contract_id
   group by pay_date,pay_channel,os_type,country_code,geographic_subdivision_v2,period_type,product_line,product_sub_line with cube
)t where pay_date is not null