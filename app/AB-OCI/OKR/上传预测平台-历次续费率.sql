----续费率

select  pay_date
        ,os_type
        ,country_name
        ,t1.period_type period_type
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
        ,count(distinct case when order_by_pay=13 then t3.contract_id else null end) num_12
        ,count(distinct case when order_by_pay=14 then t3.contract_id else null end) num_13
        ,count(distinct case when order_by_pay=15 then t3.contract_id else null end) num_14
        ,count(distinct case when order_by_pay=16 then t3.contract_id else null end) num_15
        ,count(distinct case when order_by_pay=17 then t3.contract_id else null end) num_16
        ,count(distinct case when order_by_pay=18 then t3.contract_id else null end) num_17
        ,count(distinct case when order_by_pay=19 then t3.contract_id else null end) num_18
        ,count(distinct case when order_by_pay=20 then t3.contract_id else null end) num_19
        ,count(distinct case when order_by_pay=21 then t3.contract_id else null end) num_20
        ,count(distinct case when order_by_pay=22 then t3.contract_id else null end) num_21
        ,count(distinct case when order_by_pay=23 then t3.contract_id else null end) num_22
        ,count(distinct case when order_by_pay=24 then t3.contract_id else null end) num_23
        ,count(distinct case when order_by_pay=25 then t3.contract_id else null end) num_24
        ,count(distinct case when order_by_pay=26 then t3.contract_id else null end) num_25
        ,count(distinct case when order_by_pay=27 then t3.contract_id else null end) num_26
        ,count(distinct case when order_by_pay=28 then t3.contract_id else null end) num_27
        ,count(distinct case when order_by_pay=29 then t3.contract_id else null end) num_28
        ,count(distinct case when order_by_pay=30 then t3.contract_id else null end) num_29
        ,count(distinct case when order_by_pay=31 then t3.contract_id else null end) num_30
        ,count(distinct case when order_by_pay=32 then t3.contract_id else null end) num_31
        ,count(distinct case when order_by_pay=33 then t3.contract_id else null end) num_32
        ,count(distinct case when order_by_pay=34 then t3.contract_id else null end) num_33
        ,count(distinct case when order_by_pay=35 then t3.contract_id else null end) num_34
        ,count(distinct case when order_by_pay=36 then t3.contract_id else null end) num_35
        ,count(distinct case when order_by_pay=37 then t3.contract_id else null end) num_36
        ,count(distinct case when order_by_pay=38 then t3.contract_id else null end) num_37
        ,count(distinct case when order_by_pay=39 then t3.contract_id else null end) num_38
        ,count(distinct case when order_by_pay=40 then t3.contract_id else null end) num_39
        ,count(distinct case when order_by_pay=41 then t3.contract_id else null end) num_40
        ,count(distinct case when order_by_pay=42 then t3.contract_id else null end) num_41
        ,count(distinct case when order_by_pay=43 then t3.contract_id else null end) num_42
        ,count(distinct case when order_by_pay=44 then t3.contract_id else null end) num_43
        ,count(distinct case when order_by_pay=45 then t3.contract_id else null end) num_44
        ,count(distinct case when order_by_pay=46 then t3.contract_id else null end) num_45
        ,count(distinct case when order_by_pay=47 then t3.contract_id else null end) num_46
        ,count(distinct case when order_by_pay=48 then t3.contract_id else null end) num_47
        ,count(distinct case when order_by_pay=49 then t3.contract_id else null end) num_48
        ,count(distinct case when order_by_pay=50 then t3.contract_id else null end) num_49
        ,count(distinct case when order_by_pay=51 then t3.contract_id else null end) num_50
        ,count(distinct case when order_by_pay=52 then t3.contract_id else null end) num_51
        ,count(distinct case when order_by_pay=53 then t3.contract_id else null end) num_52
        ,count(distinct case when order_by_pay=54 then t3.contract_id else null end) num_53
        ,count(distinct case when order_by_pay=55 then t3.contract_id else null end) num_54
        ,count(distinct case when order_by_pay=56 then t3.contract_id else null end) num_55
        ,count(distinct case when order_by_pay=57 then t3.contract_id else null end) num_56
        ,count(distinct case when order_by_pay=58 then t3.contract_id else null end) num_57
        ,count(distinct case when order_by_pay=59 then t3.contract_id else null end) num_58
        ,count(distinct case when order_by_pay=60 then t3.contract_id else null end) num_59
from
        (select   contract_id
                    ,device_type as os_type
                    ,case when country_name in ('美国','英国','巴西','墨西哥','西班牙','加拿大','澳大利亚') then country_name
                    else '其他' end as country_name
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
            WHERE date_p=20260517
                    and cur_pay_withhold_stage=1     -- 当前订单代扣期数(不包含试用单)
                    and order_type='2'   -- 订单类型(1:非续期订阅 2:续期订阅 3:消耗品 4:非消耗品)
                    and contract_id<>0   -- 续期型订单的contract_id不等于0
                    and app_id_p in (7329803307041000000)
                    and commodity_id_P not in (-1)
                    and pay_date between 20210101 and 20260517   -- 历史自 2021；上界与 date_p 一致
                    and country_name='美国'
                    and device_type='ios'
                    and period_type='月'
        )t1

left join
        (
            select    contract_id
                    ,cur_pay_withhold_stage order_by_pay
                    ,period_type
            from stat_vip.paid_oda_vip_all_order
            WHERE date_p=20260517
                    and cur_pay_withhold_stage>1
                    and order_type='2'   -- 订单类型(1:非续期订阅 2:续期订阅 3:消耗品 4:非消耗品)
                    and contract_id<>0   -- 续期型订单的contract_id不等于0
                    and app_id_p in (7329803307041000000)
                    and commodity_id_P not in (-1)
        )t3
on t1.contract_id=t3.contract_id and t1.period_type=t3.period_type
group by pay_date,os_type,country_name,t1.period_type

