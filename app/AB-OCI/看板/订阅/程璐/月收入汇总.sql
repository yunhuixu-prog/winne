
--月

set hive.new.job.grouping.set.cardinality=512;
set mapred.max.split.size = 853333;
set hive.query.timeout.seconds=10800;
set mapred.reduce.tasks=1000;
set spark.dynamicAllocation.minExecutors=5;

insert overwrite table stat_vip.vip_amz_middle_income_monthoci PARTITION(date_p=${start_time})
select  /*+MAPJOIN(t4)*/
		t3.os_type as os_type
     ,t3.product_line as product_line
     ,t3.product_sub_line as product_sub_line
     ,t3.country_code as country_code
     ,t3.geographic_subdivision_v2 as geographic_subdivision_v2
     ,period_type
     ,pay_channel
     ,type
     ,gmv_day
     ,refund_gmv_day
     ,gmv_year
     ,refund_gmv_year
     ,pay_uv_all
     ,gmv_all
     ,new_member
     ,new_pay_member
     ,renew_member
     ,pay_member
     ,valid_menber
     ,valid_menber_mau
     ,mau
     ,t3.ocean_name as ocean_name
from
    (select  nvl(os_type,'整体')  as os_type
            ,'整体' as product_line
            ,nvl(product_sub_line,'整体') as product_sub_line
            ,nvl(country_code,'整体') as country_code
            ,nvl(geographic_subdivision_v2,'整体') as geographic_subdivision_v2
     		,nvl(ocean_name,'整体') as ocean_name
            ,nvl(period_type,'整体') as period_type
            ,nvl(pay_channel,'整体') as pay_channel
            ,nvl(type,'整体') as type
            ,sum(case when pay_date>=${start_time} and pay_date<=${end_time} then ord_amt else 0 end) as gmv_day    -- 每月收入
            ,sum(case when refund_date>=${start_time} and refund_date<=${end_time} and pay_status=6 then refund_amt else 0 end) as refund_gmv_day     -- 每月退款
            ,sum(case when substr(pay_date,1,4)=2025 then ord_amt else 0 end) as gmv_year    -- 202x年累计收入
            ,sum(case when substr(refund_date,1,4)=2025 and pay_status=6 AND refund_date<=${end_time} then refund_amt else 0 end) as refund_gmv_year    -- 202x年累计退款
            ,count(distinct case when ord_amt>0 and cur_pay_withhold_stage>=1 then gid else null end) as pay_uv_all    --历史累计付费会员数（含过期)
            ,sum(ord_amt) as gmv_all   -- 项目累计收入
            ,count(distinct case when cur_withhold_stage=1 and pay_date>=${start_time} and pay_date<=${end_time} then gid else null end) as new_member           -- 月新增会员（含免费试用)
            ,count(distinct case when cur_pay_withhold_stage=1 and pay_date>=${start_time} and pay_date<=${end_time} then gid else null end) as new_pay_member   -- 月新增付费会员
            ,count(distinct case when cur_pay_withhold_stage>=2 and pay_date>=${start_time} and pay_date<=${end_time} then gid else null end) as  renew_member   -- 月续费会员数
            ,count(distinct case when cur_pay_withhold_stage>=1 and pay_date>=${start_time} and pay_date<=${end_time} then gid else null end) as  pay_member   -- 月付费会员数
            ,count(distinct valid_gid) as valid_menber  -- 每月有效付费会员数（付费状态）
            ,count(distinct valid_dau_gid) as valid_menber_mau -- 每月有效付费活跃会员数（付费状态）
    from
          (select  /*+MAPJOIN(t22)*/
           		notify_pay_id
               ,os_type
               ,product_line
               ,product_sub_line
               ,country_code
               ,nvl(geographic_subdivision_v2,'东亚') as geographic_subdivision_v2
           	   ,case when country_code in ('中国','未知') then '中国内地'
                     else '海外' end as ocean_name
               ,period_type
               ,ord_amt
               ,refund_amt
               ,pay_date
               ,gid
               ,cur_withhold_stage
               ,cur_pay_withhold_stage
               ,invalid_date
               ,pay_status
               ,refund_date
               ,pay_channel
               ,type
               ,case when type='订阅' and invalid_date>=${start_time} and cur_pay_withhold_stage>=1 and pay_date<=${end_time} then gid
                   when type='单购'  and cur_pay_withhold_stage>=1 and pay_date>=${start_time} and pay_date<=${end_time} then gid
                   else null end as valid_gid
               ,case when type='订阅' and invalid_date>=${start_time} and cur_pay_withhold_stage>=1 and pay_date<=${end_time} and t2.server_id is not null then gid
                   when type='单购' and cur_pay_withhold_stage>=1 and pay_date>=${start_time} and pay_date<=${end_time} and t2.server_id is not null then gid
                   else null end as valid_dau_gid
            from

              (  select notify_pay_id
                            ,device_type as os_type
                            ,product_line
                            ,product_sub_line
                            ,nvl(country_name,'未知') country_code
                            ,period_type
                            ,ord_amt
                            ,refund_amt
                            ,pay_date
                            ,case when product_sub_line in('AirBrush Studio','AirBrush Web','BeautyPlus Web') then uid
               				  when product_sub_line in('BeautyPlus') and lower(device_type) in ('web') then uid
               					  else gid end as gid
                            ,cur_pay_stage as cur_withhold_stage
                            ,cur_pay_withhold_stage
                            ,invalid_date
                            ,pay_status
                            ,refund_date
                            ,case when pay_channel is null or pay_channel = '' then '未知'
                                  else pay_channel end as pay_channel
                            ,is_subscribe as type
                      from stat_vip.paid_oda_all_order_summary
                      where app_id_p not in (-1)
                            and create_date <=${end_time}
                            and pay_date <=${end_time}
                            and (is_subscribe='订阅' or (is_subscribe='单购' and pay_status>=3))

                  )t1
              left join
                  (SELECT   case when app_key_p in('C851ED7164B6DF0F', '7F7023B6CEC7CDED') then 'AirBrush'
                        when app_key_p in('F9B069901A7B2E8D', 'C6FF0769324CD2F1') then 'BeautyPlus'
                        else app_key_p end as app_name
                   ,server_id
                  FROM stat_sdk.sdk_odz_active      -- 活跃设备表
                  WHERE app_key_p IN ('C851ED7164B6DF0F', '7F7023B6CEC7CDED','F9B069901A7B2E8D', 'C6FF0769324CD2F1')
                        and os_p IN('ios','android')
                        and date_p>=${start_time}
                        and date_p<=${end_time}
                  GROUP BY case when app_key_p in('C851ED7164B6DF0F', '7F7023B6CEC7CDED') then 'AirBrush'
                        when app_key_p in('F9B069901A7B2E8D', 'C6FF0769324CD2F1') then 'BeautyPlus'
                        else app_key_p end,server_id
                union all
               SELECT   'AirBrush Studio' as app_name
                   ,uid
              FROM stat_sdk.dim_oda_pc_device_info_v2      -- 活跃设备表
              WHERE app_key_p in ('C4E808751210527E','B8FD6DF9B9E02ACF')
                    and last_launch_date>=${start_time}
                    and last_launch_date<=${end_time}
                    and date_p=${now_time}
              GROUP BY uid

                  )t2
              ON t1.gid=t2.server_id and lower(t1.product_sub_line)=lower(t2.app_name)
            left join
                  (select sdk_country_name
                        ,geographic_subdivision_v2
                  from stat_sdk.dim_rna_ip_location
                  where date_p=${now_time}
                  group by sdk_country_name,geographic_subdivision_v2
                  )t22
            on t1.country_code=t22.sdk_country_name
            )d
    group by os_type,product_sub_line,country_code,geographic_subdivision_v2,period_type,pay_channel,type,ocean_name  with cube
    )t3
left join
    (select nvl(app_name,'整体') as   app_name
        ,nvl(os_p,'整体') as os_p
        ,nvl(country_name,'整体') as country_name
        ,nvl(geographic_subdivision_v2,'整体') as  geographic_subdivision_v2
     	,nvl(ocean_name,'整体') as  ocean_name
        ,count(distinct server_id) as mau
      from
        (select app_name
            ,os_p
            ,nvl(country_name,'未知') as country_name
            ,nvl(geographic_subdivision_v2,'东亚') as geographic_subdivision_v2
         	,case when country_name in ('中国','未知') or country_name is null then '中国内地'
                     else '海外' end as ocean_name
            ,server_id
         from
            (SELECT   case when app_key_p in('C851ED7164B6DF0F', '7F7023B6CEC7CDED') then 'AirBrush'
                        when app_key_p in('F9B069901A7B2E8D', 'C6FF0769324CD2F1') then 'BeautyPlus'
                        else app_key_p end as app_name
                 ,os_p
                 ,country_id
                 ,server_id
            FROM stat_sdk.sdk_odz_active      -- 活跃设备表
            WHERE app_key_p IN ('C851ED7164B6DF0F', '7F7023B6CEC7CDED','F9B069901A7B2E8D', 'C6FF0769324CD2F1')
                  and os_p IN('ios','android')
                  and date_p>=${start_time}
                  and date_p<=${end_time}
            GROUP BY case when app_key_p in('C851ED7164B6DF0F', '7F7023B6CEC7CDED') then 'AirBrush'
                        when app_key_p in('F9B069901A7B2E8D', 'C6FF0769324CD2F1') then 'BeautyPlus'
                        else app_key_p end,server_id,country_id,os_p
             union all
             SELECT   'AirBrush Studio' as app_name
             		,'pc' as os_p
             		,last_country_id as country_id
                   ,final_id as server_id
              FROM stat_sdk.dim_oda_pc_device_info_v2      -- 活跃设备表
              WHERE app_key_p in ('C4E808751210527E','B8FD6DF9B9E02ACF')
                    and last_launch_date>=${start_time}
             		and last_launch_date<=${end_time}
                    and date_p=${now_time}
              GROUP BY last_country_id,final_id
            )a
           left join
              (SELECT  sdk_country_id
                 ,case when sdk_country_id='10184' then '中国'
                           when sdk_country_id='10239' then '中国香港'
                           when sdk_country_id='10248' then '中国台湾'
                           when sdk_country_id='10257' then '中国澳门'
                           else country_name end as country_name
                      ,geographic_subdivision_v2
             FROM stat_sdk.dim_rna_ip_location
             where date_p=${now_time}
             GROUP BY  sdk_country_id,case when sdk_country_id='10184' then '中国'
                           when sdk_country_id='10239' then '中国香港'
                           when sdk_country_id='10248' then '中国台湾'
                           when sdk_country_id='10257' then '中国澳门'
                           else country_name end,geographic_subdivision_v2

              )b
           on a.country_id=b.sdk_country_id
         )c
      group by app_name,os_p,country_name,geographic_subdivision_v2,ocean_name  with cube
    )t4
ON lower(t3.os_type)=lower(t4.os_p) and lower(t3.product_sub_line)=lower(t4.app_name) and t3.country_code=t4.country_name and t3.geographic_subdivision_v2=t4.geographic_subdivision_v2 and t3.ocean_name =t4.ocean_name


