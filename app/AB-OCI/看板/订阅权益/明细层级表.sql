set hive.exec.dynamic.partition.mode=nonstrict;
set hive.exec.max.dynamic.partitions =500;
set hive.exec.max.dynamic.partitions.pernode=500;

with
sub_event as
(
    select gid,os_type,country,is_new,is_ua,app_version,sale_status,
           case when event_id = 'w_subscription_enter' then 'sub_enter'
               when event_id = 'w_subscription_click' then 'sub_click'
           end event_id,
           duration,sku,
           source_module,source_0,source_1,mids_material_id,mids_category_id,
           contract_id,paid_date,
           is_paid,paid_ord_amt,paid_ord_before_amt,
           is_direct_paid,direct_paid_ord_amt,direct_paid_ord_before_amt,
           is_trial,is_trial_to_paid,trial_to_paid_ord_amt,trial_to_paid_ord_before_amt,
           event_time,date_p
    from stat_ab.filing_onz_sub_source_event_detail
    where date_p between ${start_time} and ${end_time}
        and event_id in ('w_subscription_enter','w_subscription_click')

    union all

    -- 方法一：以订单表为主
    select a.gid,os_type,country,is_new,is_ua,b.app_version,b.sale_status,
           'sub_suc_order' event_id,
           duration,sku,
           source_module,source_0,source_1,mids_material_id,mids_category_id,
           contract_id,paid_date,
           is_paid,paid_ord_amt,paid_ord_before_amt,
           is_direct_paid,direct_paid_ord_amt,direct_paid_ord_before_amt,
           is_trial,is_trial_to_paid,trial_to_paid_ord_amt,trial_to_paid_ord_before_amt,
           event_time,a.date_p
    from
    (
        select *,UNIX_TIMESTAMP(CAST(date_p AS STRING), 'yyyyMMdd') fake_time
        from stat_ab.filing_onz_sub_source_event_detail
        where date_p between ${start_time} and ${end_time}
            and event_id in ('sub_suc')
    ) a
    left join
    (
        select date_p,UNIX_TIMESTAMP(CAST(date_p AS STRING), 'yyyyMMdd') fake_time,gid,max(app_version) app_version,max(sale_status) sale_status
        from stat_ab.filing_onz_sub_source_event_detail
        where date_p between ${start_time} and ${end_time}
--         where date_p between CAST(FROM_UNIXTIME(UNIX_TIMESTAMP(CAST(${start_time} AS STRING), 'yyyyMMdd') - 86400, 'yyyyMMdd') AS BIGINT)
--                     and CAST(FROM_UNIXTIME(UNIX_TIMESTAMP(CAST(${end_time} AS STRING), 'yyyyMMdd') + 86400, 'yyyyMMdd') AS BIGINT)
            and event_id in ('w_subscription_success')
        group by date_p,gid
    ) b
    on a.date_p=b.date_p
--     on (a.fake_time-b.fake_time <= 86400 or a.fake_time-b.fake_time >= -86400)
           and a.gid=b.gid

    union all

    -- 方法二：以事件表为主
    select a.gid,a.os_type,a.country,a.is_new,a.is_ua,a.app_version,a.sale_status,
           'sub_suc' event_id,
           b.duration,b.sku, -- 订阅点击这个走的埋点可能不准，建议只看订阅成功
           a.source_module,a.source_0,a.source_1,a.mids_material_id,a.mids_category_id,
           b.contract_id,b.paid_date,
           b.is_paid,b.paid_ord_amt,b.paid_ord_before_amt,
           b.is_direct_paid,b.direct_paid_ord_amt,b.direct_paid_ord_before_amt,
           b.is_trial,b.is_trial_to_paid,b.trial_to_paid_ord_amt,b.trial_to_paid_ord_before_amt,
           a.event_time,a.date_p
    from
    (
        select gid,os_type,country,is_new,is_ua,app_version,sale_status,
               source_module,source_0,source_1,mids_material_id,mids_category_id,
               event_time,date_p
               ,UNIX_TIMESTAMP(CAST(date_p AS STRING), 'yyyyMMdd') fake_time
        from stat_ab.filing_onz_sub_source_event_detail
        where date_p between ${start_time} and ${end_time}
            and event_id in ('w_subscription_success')
    ) a
    join
    (
        select date_p,gid,duration,sku,
               contract_id,paid_date,
               is_paid,paid_ord_amt,paid_ord_before_amt,
               is_direct_paid,direct_paid_ord_amt,direct_paid_ord_before_amt,
               is_trial,is_trial_to_paid,trial_to_paid_ord_amt,trial_to_paid_ord_before_amt
               ,UNIX_TIMESTAMP(CAST(date_p AS STRING), 'yyyyMMdd') fake_time
        from stat_ab.filing_onz_sub_source_event_detail
        where date_p between ${start_time} and ${end_time}
--         where date_p between CAST(FROM_UNIXTIME(UNIX_TIMESTAMP(CAST(${start_time} AS STRING), 'yyyyMMdd') - 86400, 'yyyyMMdd') AS BIGINT)
--                     and CAST(FROM_UNIXTIME(UNIX_TIMESTAMP(CAST(${end_time} AS STRING), 'yyyyMMdd') + 86400, 'yyyyMMdd') AS BIGINT)
            and event_id in ('sub_suc')
    ) b
    on a.date_p=b.date_p
--     on (a.fake_time-b.fake_time <= 86400 or a.fake_time-b.fake_time >= -86400)
           and a.gid=b.gid
)

insert overwrite table stat_ab.filing_onz_sub_source_event_detail_level PARTITION(date_p)

select os_type,country,is_new,is_ua,app_version,sale_status,gid,
     event_id,
     duration,sku,
     s.source_module,s.source_0,s.source_1,mids_material_id,mids_category_id,
     contract_id,paid_date,
     is_paid,paid_ord_amt,paid_ord_before_amt,
     is_direct_paid,direct_paid_ord_amt,direct_paid_ord_before_amt,
     is_trial,is_trial_to_paid,trial_to_paid_ord_amt,trial_to_paid_ord_before_amt,
     event_time,
     s_0,s_1,devide_num
     ,round(paid_ord_amt/devide_num,4) devide_paid_ord_amt
     ,round(paid_ord_before_amt/devide_num,4) devide_paid_ord_before_amt
     ,round(direct_paid_ord_amt/devide_num,4) devide_direct_paid_ord_amt
     ,round(direct_paid_ord_before_amt/devide_num,4) devide_direct_paid_ord_before_amt
     ,round(trial_to_paid_ord_amt/devide_num,4) devide_trial_to_paid_ord_amt
     ,round(trial_to_paid_ord_before_amt/devide_num,4) devide_trial_to_paid_ord_before_amt

     ,case when m.first_source is not null then m.first_source
           when l1.first_source is not null then l1.first_source
           when m1.first_source is not null then m1.first_source
           when m2.first_source is not null then m2.first_source
     else '未知' end first_source
     ,case when m.second_source is not null then m.second_source
           when l1.second_source is not null then l1.second_source
           when m1.second_source='source_id' then s.s_1
           when m1.second_source is not null then m1.second_source
           when m2.second_source='source_id' then s.s_0
           when m2.second_source is not null then m2.second_source
     else '未知' end second_source
     ,case when m.third_source is not null then m.third_source
           when l1.third_source is not null then l1.third_source
           when m1.third_source='source_id' then s.s_1
           when m1.third_source is not null then m1.third_source
           when m2.third_source='source_id' then s.s_0
           when m2.third_source is not null then m2.third_source
     else '未知' end third_source
     ,case when m.fourth_source is not null then m.fourth_source
           when l1.fourth_source is not null then l1.fourth_source
           when m1.fourth_source='source_id' then s.s_1
           when m1.fourth_source is not null then m1.fourth_source
           when m2.fourth_source='source_id' then s.s_0
           when m2.fourth_source is not null then m2.fourth_source
     else '未知' end fourth_source
     ,s.date_p
from
(
    select
        t.*,
        case when s_0='' or s_0 is null then '无' else s_0 end s_0,
        case when s_1='' or s_1 is null then '无' else s_1 end s_1,
        SIZE(SPLIT(COALESCE(t.source_0,'无'), ','))*SIZE(SPLIT(COALESCE(t.source_1,'无'), ',')) devide_num
    from
    (
        select gid,os_type,country,is_new,is_ua,app_version,sale_status,event_id,
               duration,sku,
               source_module,source_0,
               case when (source_module='p_edit' and source_0 in ('f_makeup','ai_filter','f_ai_retouch')) or (source_module='AIGC' and source_0 in ('ai_filter')) then mids_material_id
               else source_1 end source_1,
               mids_material_id,mids_category_id,
               contract_id,paid_date,
               is_paid,paid_ord_amt,paid_ord_before_amt,
               is_direct_paid,direct_paid_ord_amt,direct_paid_ord_before_amt,
               is_trial,is_trial_to_paid,trial_to_paid_ord_amt,trial_to_paid_ord_before_amt,
               event_time,date_p
        from sub_event
    ) t
    LATERAL VIEW explode(SPLIT(COALESCE(source_0,'无'), ',')) t0 AS s_0
    LATERAL VIEW explode(SPLIT(COALESCE(source_1,'无'), ',')) t1 AS s_1
) s
left join
(
    select source_module
         ,case when source_0='' or source_0 is null then '无' else source_0 end source_0
         ,case when source_1='' or source_1 is null then '无' else source_1 end source_1
         ,coalesce(max(first_source),'') first_source
         ,coalesce(max(second_source),'') second_source
         ,coalesce(max(third_source),'') third_source
         ,coalesce(max(fourth_source),'') fourth_source
    from stat_ab.filing_rna_sub_event_source_mapping
    group by source_module,source_0,source_1
) m
on s.source_module=m.source_module and s.s_0=m.source_0 and s.s_1=m.source_1
left join
(
    select source_module,source_0
         ,coalesce(max(first_source),'') first_source
         ,coalesce(max(second_source),'') second_source
         ,coalesce(max(third_source),'') third_source
         ,coalesce(max(fourth_source),'') fourth_source
    from stat_ab.filing_rna_sub_event_source_mapping
    where source_1='source_id'
    group by source_module,source_0
) m1
on s.source_module=m1.source_module and s.s_0=m1.source_0
left join
(
    select source_module,source_0,SUBSTR(source_1, 6, 3) source_1
         ,coalesce(max(first_source),'') first_source
         ,coalesce(max(second_source),'') second_source
         ,coalesce(max(third_source),'') third_source
         ,coalesce(max(fourth_source),'') fourth_source
    from stat_ab.filing_rna_sub_event_source_mapping
    where source_1 like 'like%'
    group by source_module,source_0,source_1
) l1
on s.source_module=l1.source_module and s.s_0=l1.source_0 and s.s_1 like CONCAT('%',l1.source_1, '%')
left join
(
    select source_module
         ,coalesce(max(first_source),'') first_source
         ,coalesce(max(second_source),'') second_source
         ,coalesce(max(third_source),'') third_source
         ,coalesce(max(fourth_source),'') fourth_source
    from stat_ab.filing_rna_sub_event_source_mapping
    where source_0='source_id'
    group by source_module
) m2
on s.source_module=m2.source_module



