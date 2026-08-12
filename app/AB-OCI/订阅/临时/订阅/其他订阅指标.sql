
with sub as
(
    select 'no_refund' type,pay_date,substr(create_time,1,8) create_date
         ,country_name
         ,days,os_type,pay_status
         ,ord_amt,ord_before_amt
         ,ord_amt_usd,round(ord_amt_usd*ord_before_amt/ord_amt,3) ord_before_amt_usd
         ,cur_pay_stage,cur_pay_withhold_stage,order_type,gid
    from stat_vip.paid_oda_vip_all_order
    WHERE date_p=20260119
        and pay_date <= 20251231
        and substr(create_time,1,8)<=20251231
        and app_id_p IN (7329803307041000000) -- 另外一个是B+，后面其他都要改
        and commodity_id_P not in (-1)

    union all

    select 'refund' type,substr(refund_time,1,8) pay_date,substr(create_time,1,8) create_date
         ,country_name
         ,days,os_type,pay_status
         ,-refund_amt ord_amt,-refund_before_amt ord_before_amt
         ,-refund_amt_usd ord_amt_usd,-round(refund_amt_usd*refund_before_amt/refund_amt,3) ord_before_amt_usd
         ,cur_pay_stage,cur_pay_withhold_stage,order_type,gid
    from stat_vip.paid_oda_vip_all_order
    WHERE date_p=20260119
        and pay_date <= 20251231
        and substr(create_time,1,8)<=20251231
        and app_id_p IN (7329803307041000000) -- 另外一个是B+，后面其他都要改
        and commodity_id_P not in (-1)
        and pay_status=6
)

select pay_date,
        substr(pay_date,1,6) months
        ,sum(case when type='no_refund' then ord_amt else 0 end) gmv_rmb
        ,sum(case when type='no_refund' then ord_before_amt else 0 end) gmv_rmb_before
        ,sum(ord_amt) gmv_no_refund_rmb,sum(ord_before_amt) gmv_no_refund_rmb_before
        ,sum(case when type='no_refund' then ord_amt_usd else 0 end) as gmv_day    -- 每天收入
        ,sum(case when type='refund' then ord_amt_usd else 0 end) as refund_gmv_day     -- 每天退款
        ,sum(ord_amt_usd) gmv_no_refund_day    -- 每天收入(剔除退款)
        ,count(distinct case when type='no_refund' and cur_pay_stage=1 then gid else null end) as new_member           -- 新增会员（含免费试用)
        ,count(distinct case when type='no_refund' and cur_pay_stage=1 and cur_pay_withhold_stage=0 and order_type=2 then gid else null end) as trial_member           -- 新增试用会员
        ,count(distinct case when type='no_refund' and cur_pay_withhold_stage=1 then gid else null end) as new_pay_member   -- 新增付费会员
        ,count(distinct case when type='no_refund' and cur_pay_withhold_stage>=2 then gid else null end) as  renew_member   -- 续费会员数
        ,count(distinct case when type='no_refund' and cur_pay_withhold_stage>=1 then gid else null end) as  pay_member   -- 付费会员数
        ,sum(case when type='no_refund' and cur_pay_withhold_stage=1 then ord_amt_usd else null end) new_gmv
        ,sum(case when type='no_refund' and cur_pay_withhold_stage=1 then ord_before_amt_usd else null end) new_gmv_before
        ,sum(case when type='no_refund' and cur_pay_withhold_stage>=2 then ord_amt_usd else null end) renew_gmv
        ,sum(case when type='no_refund' and cur_pay_withhold_stage>=2 then ord_before_amt_usd else null end) renew_gmv_before
from sub
where pay_date between 20250101 AND 20251231
-- where create_date<=pay_date
group by pay_date


