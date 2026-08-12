
set hive.new.job.grouping.set.cardinality=222;
set mapred.max.split.size = 853333;
set hive.query.timeout.seconds=10800;
set mapred.reduce.tasks=500;
insert overwrite table stat_vip.vip_adz_middle_income_shareoci PARTITION(date_p=${start_day})
select  nvl(app_type , '整体') as app_type
        ,nvl(country_name, '整体') as country_name
        ,nvl(geographic_subdivision_v2, '整体') as geographic_subdivision_v2
        ,nvl(type, '整体') as type
        ,nvl(pay_channel , '整体') as pay_channel
        ,count(distinct gid) as uv_pay
        ,sum(new_gmv) as new_gmv--毛利
        ,sum(new_gmv_tk) as new_gmv_tk--毛利退款
        ,sum(cn_new_gmv) as cn_new_gmv--毛利china
        ,sum(cn_new_gmv_tk) as cn_new_gmv_tk--毛利退款china

from
--订阅
(select app_type
        ,country_name
        ,type
        ,pay_channel
        ,gid
        ,new_gmv
        ,new_gmv_tk
        ,cn_new_gmv
        ,cn_new_gmv_tk
        ,nvl(geographic_subdivision_v2,'东亚') as geographic_subdivision_v2
  from
    (select  app_type
            ,country_name
            ,type
            ,pay_channel
            ,case when ord_amt>0 then  gid else null end as gid
            ,sum(ord_amt) as new_gmv--毛利
            ,sum(refund_amt) as new_gmv_tk--毛利退款
            ,sum(case when country_name='中国内地' then ord_amt/1.06  else ord_amt end) as cn_new_gmv--毛利china
            ,sum(case when country_name='中国内地' then refund_amt/1.06  else refund_amt end) as cn_new_gmv_tk--毛利退款china
    from
    (SELECT  case when country_name ='中国' then '中国内地'
                    when country_name='未知'  or country_name is null then '未知'
                    else country_name end  as country_name
            ,product_sub_line as app_type
            ,nvl(pay_channel , '未知') as pay_channel
            ,'订阅' as type
            ,case when product_sub_line in('AirBrush Studio','AirBrush Web','BeautyPlus Web') then uid
               				  when product_sub_line in('BeautyPlus') and lower(os_type) in ('web') then uid
               					  else gid end as gid
            ,SUM(case when share_date=${start_day} and busi_type_name = '交易' then share_ord_before_amt else null end)    AS ord_amt
            ,SUM(case when refund_share_date=${start_day}  and  busi_type_name = '退款' then refund_share_before_amt  else null end) AS refund_amt
        FROM stat_vip.paid_mda_analyze_share_detail
        WHERE (share_date=${start_day} or refund_share_date=${start_day})
        GROUP BY  case when country_name ='中国' then '中国内地'
                    when country_name='未知'  or country_name is null then '未知'
                    else country_name end,product_sub_line,nvl(pay_channel , '未知'),case when product_sub_line in('AirBrush Studio','AirBrush Web','BeautyPlus Web') then uid
               				  when product_sub_line in('BeautyPlus') and lower(os_type) in ('web') then uid
               					  else gid end
    union all
    --单购
        select  country_name
                ,app_type
                ,pay_channel
                ,type
                ,case when pay_date=${start_day}    then gid else null end as gid
                ,sum(case when pay_date=${start_day} then ord_before_amt else null end) as ord_amt
                ,sum(case when substr(refund_date, 1, 8) =${start_day} and pay_status in (6, 8) then refund_before_amt else null end) as refund_amt

        from
            (select pay_date
                    ,refund_date
                    ,case when country_name ='中国' then '中国内地'
                        when country_name='未知'  or country_name is null then '未知'
                        else country_name end  as country_name
                    ,product_sub_line as app_type
                    ,case when product_sub_line in('AirBrush Studio','AirBrush Web','BeautyPlus Web') then uid
               				  when product_sub_line in('BeautyPlus') and lower(device_type) in ('web') then uid
               					  else gid end as gid
                    ,ord_before_amt
                    ,pay_status
                    ,'单购' as type
                    ,case when pay_channel is null or pay_channel = '' then '未知'
                        else pay_channel end pay_channel
                    ,refund_before_amt
            from stat_vip.paid_oda_all_order_summary
            where app_id_p not in (-1)
                    and create_date <=${start_day}
                    and pay_date <= ${start_day}
                    and is_subscribe = '单购'
                    and pay_status >= 3 --3已支付，6已退款,2待支付,8部分退款

            ) a
    group by app_type,country_name,type,pay_channel,case when pay_date=${start_day}   then gid else null end
    )t
    group by app_type,country_name,type,pay_channel,case when ord_amt>0 then  gid else null end
    )tt
 left join
    (select sdk_country_name
            ,geographic_subdivision_v2
    from stat_sdk.dim_rna_ip_location
    where date_p=${now_time}
    group by sdk_country_name,geographic_subdivision_v2
    )t22
on tt.country_name=t22.sdk_country_name
)t3
group by app_type,country_name,type,pay_channel,geographic_subdivision_v2 with cube

