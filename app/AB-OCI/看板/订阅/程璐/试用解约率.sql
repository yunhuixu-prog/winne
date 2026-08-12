set hive.new.job.grouping.set.cardinality=512;
set mapred.max.split.size = 853333;
set mapred.reduce.tasks=1000;
insert overwrite table stat_vip.vip_ada_trial_contractoci  PARTITION(date_p=${start_time})
SELECT *
from
      (SELECT  date_p  as pay_date
               ,nvl(os_type1,'整体') os_type1
               ,nvl(period_type1,'整体') period_type1
               ,nvl(pay_channel,'整体') pay_channel
               ,nvl(country_code,'整体') country_code
               ,nvl(app_type,'整体') app_type
               ,nvl(geographic_subdivision_v2,'整体') geographic_subdivision_v2
               ,COUNT(distinct new_cnt) new_cnt
               ,COUNT(distinct dismiss_cnt_0) as dismiss_cnt_0
               ,COUNT(distinct dismiss_cnt_1) as dismiss_cnt_1
               ,COUNT(distinct dismiss_cnt_2) as dismiss_cnt_2
               ,COUNT(distinct dismiss_cnt_3) as dismiss_cnt_3
               ,COUNT(distinct dismiss_cnt_4) as dismiss_cnt_4
               ,COUNT(distinct dismiss_cnt_5) as dismiss_cnt_5
               ,COUNT(distinct dismiss_cnt_6) as dismiss_cnt_6
               ,COUNT(distinct dismiss_cnt_7) as dismiss_cnt_7
               ,COUNT(distinct dismiss_cnt_7_all) as dismiss_cnt_7_all
      from
               (select
                      /*+MAPJOIN(s2,s3)*/
                      gid
                      ,date_p
                      ,os_type1
                      ,period_type1
                      ,pay_channel
                      ,country_code
                      ,nvl(geographic_subdivision_v2,'东亚') as geographic_subdivision_v2
                      ,app_type
                      ,s1.out_pay_id
                     ,max( s1.out_pay_id) new_cnt
                     ,max( CASE WHEN meitu_datediff(s2.dismiss_date,s1.date_p) = 0 THEN s2.contract_id end) dismiss_cnt_0
                     ,max( CASE WHEN meitu_datediff(s2.dismiss_date,s1.date_p) = 1 THEN s2.contract_id end) dismiss_cnt_1
                     ,max( CASE WHEN meitu_datediff(s2.dismiss_date,s1.date_p) = 2 THEN s2.contract_id end) dismiss_cnt_2
                     ,max( CASE WHEN meitu_datediff(s2.dismiss_date,s1.date_p) = 3 THEN s2.contract_id end) dismiss_cnt_3
                     ,max( CASE WHEN meitu_datediff(s2.dismiss_date,s1.date_p) = 4 THEN s2.contract_id end) dismiss_cnt_4
                     ,max( CASE WHEN meitu_datediff(s2.dismiss_date,s1.date_p) = 5 THEN s2.contract_id end) dismiss_cnt_5
                     ,max( CASE WHEN meitu_datediff(s2.dismiss_date,s1.date_p) = 6 THEN s2.contract_id end) dismiss_cnt_6
                     ,max( CASE WHEN meitu_datediff(s2.dismiss_date,s1.date_p) = 7 THEN s2.contract_id end) dismiss_cnt_7
                     ,max( CASE WHEN meitu_datediff(s2.dismiss_date,s1.date_p) <= 7 THEN s2.contract_id end) dismiss_cnt_7_all

              FROM
                    (SELECT  pay_date AS date_p
                        ,notify_pay_id as out_pay_id
                        ,case when os_type='android' and pay_channel='google' then 'google'
                              when os_type in ('android','androidpad') then 'android'
                              when os_type in ('ios','ipad') then 'ios'
                              else os_type end as os_type1
                        ,product_sub_line  as app_type
                        ,nvl(country_name,'未知') as country_code
                        ,period_type period_type1
                        ,ord_amt
                        ,gid
                        ,invalid_time
                        ,pay_status
                        ,pay_channel
                    FROM stat_vip.paid_oda_vip_all_order
                    WHERE date_p=${now_time}
                          and pay_date<=${start_time}
                          and app_id_p not in (-1)
                          and commodity_id_P not in (-1)
                          and order_type=2
                          and cur_pay_withhold_stage=0
                     	    and cur_pay_stage=1   -- 当前订单代扣期数(包含试用单)
                          and contract_id<>0
                    ) s1
              LEFT JOIN
                    (SELECT  contract_id
                            ,CAST(dismiss_date AS BIGINT)  as dismiss_date
                    FROM stat_vip.paid_oda_vip_tb_contract
                    WHERE date_p =${now_time}
                          and app_id_p not in(-1)
                          AND dismiss_date<=${start_time}
                          AND contract_status = 3
                          and commodity_id_P not in (-1)
                    group by contract_id,dismiss_date
                    ) s2
              ON s1.out_pay_id = s2.contract_id AND dismiss_date >= date_p
              LEFT JOIN
                    (select sdk_country_name
                          ,geographic_subdivision_v2
                     from stat_sdk.dim_rna_ip_location
                     where date_p=${now_time}
                     group by sdk_country_name,geographic_subdivision_v2
                    ) s3
              on s1.country_code=s3.sdk_country_name
              GROUP BY gid,date_p,os_type1,period_type1,pay_channel,country_code,app_type,nvl(geographic_subdivision_v2,'东亚'),s1.out_pay_id
              )m2
      GROUP BY  date_p,os_type1,period_type1,pay_channel,geographic_subdivision_v2,country_code,app_type with cube
      ) m1
where pay_date is not null
