
-----新增会员日龄
set hive.new.job.grouping.set.cardinality=1024;
set mapred.max.split.size = 853333;
set hive.query.timeout.seconds=10800;
set mapred.reduce.tasks=500;
insert overwrite table stat_vip.vip_ada_middle_activedayoci PARTITION(date_p=${start_time})
select *
from
  (select pay_date
      ,nvl(os_type,'整体') as os_type
      ,nvl(product_line,'整体') as product_line
      ,nvl(product_sub_line,'整体') as product_sub_line
      ,nvl(country_code,'整体') as country_code
      ,nvl(geographic_subdivision_v2,'整体') as geographic_subdivision_v2
      ,nvl(period_type,'整体') as period_type
      ,nvl(diff,'整体') as diff
      ,count(distinct gid) as uv
  from
      (select pay_date
           ,os_type
           ,product_line
           ,product_sub_line
           ,country_code
           ,nvl(geographic_subdivision_v2,'东亚') as geographic_subdivision_v2
           ,period_type
           ,gid
           ,case when meitu_datediff(t1.pay_date, t2.first_launch_date) = 0 then '新增'
                when meitu_datediff(t1.pay_date, t2.first_launch_date) > 0 and meitu_datediff(t1.pay_date, t2.first_launch_date) <= 7 then '7天'
               when meitu_datediff(t1.pay_date, t2.first_launch_date) > 7 and meitu_datediff(t1.pay_date, t2.first_launch_date) <= 30 then '30天'
               when meitu_datediff(t1.pay_date, t2.first_launch_date) > 30 and meitu_datediff(t1.pay_date, t2.first_launch_date) <= 90 then '90天'
               when meitu_datediff(t1.pay_date, t2.first_launch_date) > 90 and meitu_datediff(t1.pay_date, t2.first_launch_date) <= 180 then '180天'
               when meitu_datediff(t1.pay_date, t2.first_launch_date) > 180 and meitu_datediff(t1.pay_date, t2.first_launch_date) <= 365 then '365天'
               when meitu_datediff(t1.pay_date, t2.first_launch_date) > 366 and meitu_datediff(t1.pay_date, t2.first_launch_date) <= 730 then '1-2年'
               when meitu_datediff(t1.pay_date, t2.first_launch_date) > 731 and meitu_datediff(t1.pay_date, t2.first_launch_date) <= 1095 then '2-3年'
               when meitu_datediff(t1.pay_date, t2.first_launch_date) < 0 or first_launch_date is null then '未知'
                   else '3年以上' end diff
      from
          (select os_type
               ,product_line
               ,product_sub_line
               ,country_code
               ,period_type
               ,pay_date
               ,gid
          from
             (select *
                    ,row_number() over(partition by gid,product_sub_line order by pay_date asc) as rn
              from
                (select  case when os_type='android' and pay_channel='google' then 'google'
                               when os_type in ('android','androidpad') then 'android'
                               when os_type in ('ios','ipad') then 'ios'
                               else os_type end as os_type
                        ,product_line
                        ,product_sub_line
                        ,nvl(country_name,'未知') country_code
                        ,period_type
                        ,pay_date
                        ,case when product_sub_line in('AirBrush Studio','AirBrush Web','BeautyPlus Web') then uid
               				  when product_sub_line in('BeautyPlus') and lower(device_type) in ('web') then uid
               					  else gid end as gid
                from stat_vip.paid_oda_vip_all_order
                WHERE date_p=${now_time}
                      and pay_date<=${start_time}
                      and cur_pay_withhold_stage = 1
                      and app_id_p not in (-1)
                      and commodity_id_P not in (-1)
                group by case when os_type='android' and pay_channel='google' then 'google'
                         when os_type in ('android','androidpad') then 'android'
                         when os_type in ('ios','ipad') then 'ios'
                         else os_type end,product_line,product_sub_line,nvl(country_name,'未知')
                         ,period_type
                        ,pay_date
                        ,case when product_sub_line in('AirBrush Studio','AirBrush Web','BeautyPlus Web') then uid
               				  when product_sub_line in('BeautyPlus') and lower(device_type) in ('web') then uid
               					  else gid end
                )b
              )a
          where rn=1
          group by os_type,product_line,product_sub_line,country_code,period_type,pay_date,gid
          )t1
      left join
          (SELECT   case when app_key_p in('C851ED7164B6DF0F', '7F7023B6CEC7CDED') then 'AirBrush'
                        when app_key_p in('F9B069901A7B2E8D', 'C6FF0769324CD2F1') then 'BeautyPlus'
                        else app_key_p end as app_name
                ,server_id
                ,first_launch_date
          FROM  stat_sdk.sdk_oda_all_device_info      -- 活跃设备表
          WHERE app_key_p IN ('C851ED7164B6DF0F', '7F7023B6CEC7CDED','F9B069901A7B2E8D', 'C6FF0769324CD2F1')
                and os_p IN('ios','android')
                and date_p=${now_time}
          GROUP BY case when app_key_p in('C851ED7164B6DF0F', '7F7023B6CEC7CDED') then 'AirBrush'
                        when app_key_p in('F9B069901A7B2E8D', 'C6FF0769324CD2F1') then 'BeautyPlus'
                        else app_key_p end,server_id,first_launch_date
           union all
           SELECT   'AirBrush Studio' as app_name
                ,uid
                ,first_launch_date
          FROM  stat_sdk.dim_oda_pc_device_info_v2       -- 活跃设备表
          WHERE app_key_p in ('C4E808751210527E','B8FD6DF9B9E02ACF')
                and date_p=${now_time}
          GROUP BY uid
                ,first_launch_date
          )t2
      on t1.gid=t2.server_id and lower(t1.product_sub_line)=lower(t2.app_name)
      left join
            (select sdk_country_name
                    ,geographic_subdivision_v2
                from stat_sdk.dim_rna_ip_location
                where date_p=${now_time}
                group by sdk_country_name,geographic_subdivision_v2
            )t22
      on t1.country_code=t22.sdk_country_name
      group by pay_date,os_type,product_line,product_sub_line,country_code,nvl(geographic_subdivision_v2,'东亚'),period_type,gid
           ,case when meitu_datediff(t1.pay_date, t2.first_launch_date) = 0 then '新增'
                   when meitu_datediff(t1.pay_date, t2.first_launch_date) > 0 and meitu_datediff(t1.pay_date, t2.first_launch_date) <= 7 then '7天'
               when meitu_datediff(t1.pay_date, t2.first_launch_date) > 7 and meitu_datediff(t1.pay_date, t2.first_launch_date) <= 30 then '30天'
               when meitu_datediff(t1.pay_date, t2.first_launch_date) > 30 and meitu_datediff(t1.pay_date, t2.first_launch_date) <= 90 then '90天'
               when meitu_datediff(t1.pay_date, t2.first_launch_date) > 90 and meitu_datediff(t1.pay_date, t2.first_launch_date) <= 180 then '180天'
               when meitu_datediff(t1.pay_date, t2.first_launch_date) > 180 and meitu_datediff(t1.pay_date, t2.first_launch_date) <= 365 then '365天'
               when meitu_datediff(t1.pay_date, t2.first_launch_date) > 366 and meitu_datediff(t1.pay_date, t2.first_launch_date) <= 730 then '1-2年'
               when meitu_datediff(t1.pay_date, t2.first_launch_date) > 731 and meitu_datediff(t1.pay_date, t2.first_launch_date) <= 1095 then '2-3年'
               when meitu_datediff(t1.pay_date, t2.first_launch_date) < 0 or first_launch_date is null then '未知'
                   else '3年以上' end

      )t3
  group by pay_date,os_type,product_line,product_sub_line,country_code,geographic_subdivision_v2,period_type,diff with cube
  )t
where pay_date is not null
