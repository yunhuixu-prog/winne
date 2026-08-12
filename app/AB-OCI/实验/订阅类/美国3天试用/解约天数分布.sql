-- 美国3天试用实验：实验归因试用单的解约天数分布
-- 引擎：Hive（Presto 对 contract_id 多表关联易失败；不行再切 Hive）
-- 依据：说明/订阅表.sql、同目录 订阅明细.sql、实验/20260717iOS月付实验/解约.sql
-- 人群：实验期内首次进组（29083/29084），进组后归因 sub_suc 且 is_trial=1
-- 解约：stat_vip.paid_oda_vip_tb_contract，contract_status=3，dismiss_date >= 试用归因日
-- 解约天数：meitu_datediff(dismiss_date, 试用归因 date_p)；第 N 天解约 = datediff = N-1（第1天=归因当日）
-- 参数：实验期与 订阅明细.sql 一致；合约快照 date_p 跑数前改为最新分区（当前示例 20260809）

select
    m.date_p date_p
    ,m.os_type os_type
    ,m.code code
    ,m.is_new is_new
    ,m.country country
    ,m.duration duration
    ,count(distinct m.contract_id) contract_cnt
    ,count(distinct case when m.is_paid = 1 then m.contract_id end) paid_contract_cnt
    ,count(distinct case when m.dismiss_date is not null then m.contract_id end) dismiss_contract_cnt
    ,count(distinct case when m.dismiss_days = 0 then m.contract_id end) dismiss_d1_contract_cnt
    ,count(distinct case when m.dismiss_days = 1 then m.contract_id end) dismiss_d2_contract_cnt
    ,count(distinct case when m.dismiss_days = 2 then m.contract_id end) dismiss_d3_contract_cnt
    ,count(distinct case when m.dismiss_days = 3 then m.contract_id end) dismiss_d4_contract_cnt
    ,count(distinct case when m.dismiss_days = 4 then m.contract_id end) dismiss_d5_contract_cnt
    ,count(distinct case when m.dismiss_days = 5 then m.contract_id end) dismiss_d6_contract_cnt
    ,count(distinct case when m.dismiss_days = 6 then m.contract_id end) dismiss_d7_contract_cnt
from (
    select
        a.date_p
        ,a.os_type
        ,case when b.ab_code in ('29083') then '对照组'
            when b.ab_code in ('29084') then '实验组A'
          end code
        ,b.is_new
        ,case when b.country in ('美国') then b.country else '其他' end country
        ,a.duration
        ,a.contract_id
        ,a.is_paid
        ,d.dismiss_date
        ,case
            when d.dismiss_date is null then null
            else meitu_datediff(d.dismiss_date, a.date_p)
          end dismiss_days
    from (
        select
            date_p
            ,case when os_type in ('其他') then 'Android' else os_type end os_type
            ,unix_timestamp(event_time, 'yyyyMMddHHmmss') event_timestamp
            ,gid
            ,duration
            ,cast(contract_id as bigint) contract_id
            ,is_paid
        from stat_ab.filing_onz_sub_source_event_detail
        where date_p between 20260717 and 20260802
            and event_id = 'sub_suc'
            and is_trial = 1
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
            where date_p between 20260717 and 20260802
                and ab_code in ('29083', '29084')
        ) t
        where ranks = 1
    ) b
        on a.gid = b.gid
    left join (
        select
            cast(contract_id as bigint) contract_id
            ,min(cast(dismiss_date as bigint)) dismiss_date
        from stat_vip.paid_oda_vip_tb_contract
        where date_p = 20260809
            and app_id_p not in (-1)
            and commodity_id_p not in (-1)
            and contract_status = 3
            and dismiss_date >= 20260717
        group by cast(contract_id as bigint)
    ) d
        on a.contract_id = d.contract_id
        and d.dismiss_date >= a.date_p
    where b.event_timestamp - 15 <= a.event_timestamp
) m
group by
    m.date_p
    ,m.os_type
    ,m.code
    ,m.is_new
    ,m.country
    ,m.duration

