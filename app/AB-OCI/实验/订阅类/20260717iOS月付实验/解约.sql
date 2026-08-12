-- iOS月付实验：实验归因订单解约 + 收入跟进
-- 引擎：Hive（Presto 对多表 contract_id 关联易失败；不行再切 presto）
-- 依据：说明/订阅表.sql、看板/订阅权益/明细.sql、专项/复盘/26H1/续订拆解.sql、实验/iOS月付实验/订阅明细.sql
-- 人群：实验期内首次进组用户，进组后归因 sub_suc 订单（contract_id）
-- 解约：paid_oda_vip_tb_contract，contract_status=3，dismiss_date >= 订单日
-- 收入：续费/后续付费用 paid_oda_vip_all_order（summary 表无 contract_id）
--   new_gmv          该笔新增收入（归因单 paid_ord_amt，美元）
--   renew_gmv        后续续费收入（同 contract_id，cur_pay_withhold_stage>=2）
--   after_paid_gmv   后续付费收入（同 gid，pay_date>订单日，含续费及其他付费单，排除本合约首笔付费）
-- 参数：解约/订单快照分区当前 20260726
-- 注意：归因表与订单表 contract_id 类型可能不同，统一 cast 为 bigint

select
    m.date_p date_p
    ,m.os_type os_type
    ,case when m.ab_code in ('29080') then '对照组'
        when m.ab_code in ('29081') then '实验组A'
        when m.ab_code in ('29082') then '实验组B'
      end code
    ,m.is_new is_new
    ,case when m.country in ('巴西','英国','澳大利亚') then m.country else '其他' end country
    ,case when m.sku = 'com.meitu.airbrush.autorenew.vip17' then '分期年卡' else m.duration end duration
    ,count(distinct m.contract_id) sub_suc_cnt
    ,count(distinct case when m.is_paid = 1 then m.contract_id end) paid_cnt
    ,count(distinct case when m.is_trial = 1 then m.contract_id end) trial_cnt
    ,count(distinct case when m.is_dismiss = 1 then m.contract_id end) dismiss_cnt
    ,round(sum(m.new_gmv), 2) new_gmv
    ,round(sum(m.renew_gmv), 2) renew_gmv
    ,round(sum(m.after_paid_gmv), 2) after_paid_gmv
from (
    select
        a.date_p
        ,a.os_type
        ,b.ab_code
        ,b.is_new
        ,b.country
        ,a.sku
        ,a.duration
        ,a.contract_id
        ,max(a.is_paid) is_paid
        ,max(a.is_trial) is_trial
        ,max(case when d.contract_id is not null then 1 else 0 end) is_dismiss
        ,max(case when a.is_paid = 1 then a.paid_ord_amt else 0 end) new_gmv
        ,coalesce(max(r.renew_gmv), 0) renew_gmv
        ,coalesce(sum(o.ord_amt_usd), 0) after_paid_gmv
    from (
        select
            date_p
            ,case when os_type in ('其他') then 'Android' else os_type end os_type
            ,unix_timestamp(event_time, 'yyyyMMddHHmmss') event_timestamp
            ,gid
            ,duration
            ,sku
            ,cast(contract_id as bigint) contract_id
            ,is_paid
            ,is_trial
            ,paid_ord_amt
            ,paid_date
        from stat_ab.filing_onz_sub_source_event_detail
        where date_p between 20260717 and 20260726
            and event_id = 'sub_suc'
            and contract_id is not null
            and cast(contract_id as bigint) <> 0
    ) a
    join (
        select gid, os_type, is_new, ab_code, event_timestamp, date_p, country
        from (
            select
                gid, os_type, is_new, ab_code, event_timestamp, date_p, country
                ,row_number() over (partition by gid order by event_timestamp) as ranks
            from stat_ab.filing_odz_abtest_active_user
            where date_p between 20260717 and 20260726
                and ab_code in ('29080','29081','29082')
        ) t
        where ranks = 1
    ) b
        on a.gid = b.gid
    left join (
        select
            cast(contract_id as bigint) contract_id
            ,cast(dismiss_date as bigint) as dismiss_date
        from stat_vip.paid_oda_vip_tb_contract
        where date_p = 20260726
            and app_id_p not in (-1)
            and commodity_id_p not in (-1)
            and contract_status = 3
            and dismiss_date >= 20260717
        group by cast(contract_id as bigint), cast(dismiss_date as bigint)
    ) d
        on a.contract_id = d.contract_id
        and d.dismiss_date >= a.date_p
    left join (
        -- 同合约后续续费（代扣期数>=2）；用 vip_all_order（summary 无 contract_id）
        select
            cast(contract_id as bigint) contract_id
            ,sum(ord_amt_usd) renew_gmv
        from stat_vip.paid_oda_vip_all_order
        where date_p = 20260726
            and app_id_p in (7329803307041000000)
            and commodity_id_p not in (-1)
            and order_type = '2'
            and pay_date >= 20260717
            and cur_pay_withhold_stage >= 2
            and contract_id <> 0
        group by cast(contract_id as bigint)
    ) r
        on a.contract_id = r.contract_id
    left join (
        -- 同用户后续付费明细（排除本合约首笔付费 stage=1）
        select
            gid
            ,cast(contract_id as bigint) contract_id
            ,cast(pay_date as bigint) pay_date
            ,ord_amt_usd
            ,cur_pay_withhold_stage
        from stat_vip.paid_oda_vip_all_order
        where date_p = 20260726
            and app_id_p in (7329803307041000000)
            and commodity_id_p not in (-1)
            and order_type = '2'
            and pay_date >= 20260717
            and cur_pay_withhold_stage >= 1
            and contract_id <> 0
    ) o
        on a.gid = o.gid
        and o.pay_date > a.date_p
        and (
            o.contract_id <> a.contract_id
            or o.cur_pay_withhold_stage >= 2
        )
    where b.event_timestamp - 15 <= a.event_timestamp
    group by
        a.date_p
        ,a.os_type
        ,b.ab_code
        ,b.is_new
        ,b.country
        ,a.sku
        ,a.duration
        ,a.contract_id
) m
group by
    m.date_p
    ,m.os_type
    ,case when m.ab_code in ('29080') then '对照组'
        when m.ab_code in ('29081') then '实验组A'
        when m.ab_code in ('29082') then '实验组B'
      end
    ,m.is_new
    ,case when m.country in ('巴西','英国','澳大利亚') then m.country else '其他' end
    ,case when m.sku = 'com.meitu.airbrush.autorenew.vip17' then '分期年卡' else m.duration end
