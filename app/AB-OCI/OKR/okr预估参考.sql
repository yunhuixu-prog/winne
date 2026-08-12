-- 收入（暂时没用上）
with sub as
(
    select 'no_refund' type,pay_date,substr(create_time,1,8) create_date
         ,case when country_name in ('美国','巴西','英国','墨西哥','西班牙','加拿大','澳大利亚') then country_name
          else '其他'
          end country
         ,days,os_type,pay_status
         ,ord_amt,ord_before_amt
         ,ord_amt_usd,round(case when ord_amt=0 then 0 else ord_amt_usd*ord_before_amt/ord_amt end,3) ord_before_amt_usd
         ,cur_pay_stage,cur_pay_withhold_stage,order_type,gid,period_type
    from stat_vip.paid_oda_vip_all_order
    WHERE date_p=20260408
        and pay_date <= 20260331
        and substr(create_time,1,8)<=20260331
        and app_id_p IN (7329803307041000000)
        and commodity_id_P not in (-1)

    union all

    select 'refund' type,substr(refund_time,1,8) pay_date,substr(create_time,1,8) create_date
         ,case when country_name in ('美国','巴西','英国','墨西哥','西班牙','加拿大','澳大利亚') then country_name
          else '其他'
          end country
         ,days,os_type,pay_status
         ,-refund_amt ord_amt,-refund_before_amt ord_before_amt
         ,-refund_amt_usd ord_amt_usd,-round(case when refund_amt=0 then 0 else refund_amt_usd*refund_before_amt/refund_amt end,3) ord_before_amt_usd
         ,cur_pay_stage,cur_pay_withhold_stage,order_type,gid,period_type
    from stat_vip.paid_oda_vip_all_order
    WHERE date_p=20260408
        and pay_date <= 20260331
        and substr(create_time,1,8)<=20260331
        and app_id_p IN (7329803307041000000)
        and commodity_id_P not in (-1)
        and pay_status=6
)

select substr(pay_date,1,6) months
        ,'整体' country
--         ,sum(case when type='no_refund' then ord_amt else 0 end) gmv_rmb
--         ,sum(case when type='no_refund' then ord_before_amt else 0 end) gmv_rmb_before
--         ,sum(ord_amt) gmv_no_refund_rmb,sum(ord_before_amt) gmv_no_refund_rmb_before
--         ,sum(case when type='no_refund' then ord_amt_usd else 0 end) as gmv_day    -- 毛利
--         ,sum(case when type='refund' then ord_amt_usd else 0 end) as refund_gmv_day     -- 退款
        ,sum(ord_amt_usd) gmv_no_refund_day    -- 毛利(剔除退款)
        ,sum(ord_before_amt_usd) gmv_no_refund_day_before    -- 收入(剔除退款)
--         ,count(distinct case when type='no_refund' and cur_pay_stage=1 then gid else null end) as new_member           -- 新增会员（含免费试用)
--         ,count(distinct case when type='no_refund' and cur_pay_stage=1 and cur_pay_withhold_stage=0 and order_type=2 then gid else null end) as trial_member           -- 新增试用会员
        ,count(distinct case when type='no_refund' and cur_pay_withhold_stage=1 then gid else null end) as new_pay_member   -- 新增付费会员
        ,sum(case when type='no_refund' and cur_pay_withhold_stage=1 then ord_before_amt_usd else null end) new_gmv_before
        ,count(distinct case when type='no_refund' and cur_pay_withhold_stage=1 and period_type='年' then gid else null end) as new_year_pay_member   -- 新增年付费会员
        ,sum(case when type='no_refund' and cur_pay_withhold_stage=1 and period_type='年' then ord_before_amt_usd else null end) new_year_gmv_before
        ,count(distinct case when type='no_refund' and cur_pay_withhold_stage=1 and period_type='月' then gid else null end) as new_month_pay_member   -- 新增月付费会员
        ,sum(case when type='no_refund' and cur_pay_withhold_stage=1 and period_type='月' then ord_before_amt_usd else null end) new_month_gmv_before

        ,count(distinct case when type='no_refund' and cur_pay_withhold_stage>=2 then gid else null end) as  renew_member   -- 续费会员数
        ,sum(case when type='no_refund' and cur_pay_withhold_stage>=2 then ord_before_amt_usd else null end) renew_gmv_before
        ,count(distinct case when type='no_refund' and cur_pay_withhold_stage>=2 and period_type='年' then gid else null end) as renew_year_pay_member   -- 新增年付费会员
        ,sum(case when type='no_refund' and cur_pay_withhold_stage>=2 and period_type='年' then ord_before_amt_usd else null end) renew_year_gmv_before
        ,count(distinct case when type='no_refund' and cur_pay_withhold_stage>=2 and period_type='月' then gid else null end) as renew_month_pay_member   -- 新增月付费会员
        ,sum(case when type='no_refund' and cur_pay_withhold_stage>=2 and period_type='月' then ord_before_amt_usd else null end) renew_month_gmv_before

        ,count(distinct case when type='no_refund' and cur_pay_withhold_stage>=1 then gid else null end) as  pay_member   -- 付费会员数

from sub
where pay_date between 20250101 AND 20260331
-- where create_date<=pay_date
group by substr(pay_date,1,6)

union all

select substr(pay_date,1,6) months
        ,country
--         ,sum(case when type='no_refund' then ord_amt else 0 end) gmv_rmb
--         ,sum(case when type='no_refund' then ord_before_amt else 0 end) gmv_rmb_before
--         ,sum(ord_amt) gmv_no_refund_rmb,sum(ord_before_amt) gmv_no_refund_rmb_before
--         ,sum(case when type='no_refund' then ord_amt_usd else 0 end) as gmv_day    -- 毛利
--         ,sum(case when type='refund' then ord_amt_usd else 0 end) as refund_gmv_day     -- 退款
        ,sum(ord_amt_usd) gmv_no_refund_day    -- 毛利(剔除退款)
        ,sum(ord_before_amt_usd) gmv_no_refund_day_before    -- 收入(剔除退款)
--         ,count(distinct case when type='no_refund' and cur_pay_stage=1 then gid else null end) as new_member           -- 新增会员（含免费试用)
--         ,count(distinct case when type='no_refund' and cur_pay_stage=1 and cur_pay_withhold_stage=0 and order_type=2 then gid else null end) as trial_member           -- 新增试用会员
        ,count(distinct case when type='no_refund' and cur_pay_withhold_stage=1 then gid else null end) as new_pay_member   -- 新增付费会员
        ,sum(case when type='no_refund' and cur_pay_withhold_stage=1 then ord_before_amt_usd else null end) new_gmv_before
        ,count(distinct case when type='no_refund' and cur_pay_withhold_stage=1 and period_type='年' then gid else null end) as new_year_pay_member   -- 新增年付费会员
        ,sum(case when type='no_refund' and cur_pay_withhold_stage=1 and period_type='年' then ord_before_amt_usd else null end) new_year_gmv_before
        ,count(distinct case when type='no_refund' and cur_pay_withhold_stage=1 and period_type='月' then gid else null end) as new_month_pay_member   -- 新增月付费会员
        ,sum(case when type='no_refund' and cur_pay_withhold_stage=1 and period_type='月' then ord_before_amt_usd else null end) new_month_gmv_before

        ,count(distinct case when type='no_refund' and cur_pay_withhold_stage>=2 then gid else null end) as  renew_member   -- 续费会员数
        ,sum(case when type='no_refund' and cur_pay_withhold_stage>=2 then ord_before_amt_usd else null end) renew_gmv_before
        ,count(distinct case when type='no_refund' and cur_pay_withhold_stage>=2 and period_type='年' then gid else null end) as renew_year_pay_member   -- 新增年付费会员
        ,sum(case when type='no_refund' and cur_pay_withhold_stage>=2 and period_type='年' then ord_before_amt_usd else null end) renew_year_gmv_before
        ,count(distinct case when type='no_refund' and cur_pay_withhold_stage>=2 and period_type='月' then gid else null end) as renew_month_pay_member   -- 新增月付费会员
        ,sum(case when type='no_refund' and cur_pay_withhold_stage>=2 and period_type='月' then ord_before_amt_usd else null end) renew_month_gmv_before

        ,count(distinct case when type='no_refund' and cur_pay_withhold_stage>=1 then gid else null end) as  pay_member   -- 付费会员数

from sub
where pay_date between 20250101 AND 20260331
-- where create_date<=pay_date
group by substr(pay_date,1,6),country

;
