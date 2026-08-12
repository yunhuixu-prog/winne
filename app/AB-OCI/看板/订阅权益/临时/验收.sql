select  contract_id,ord_amt,ord_before_amt
          ,os_type
          ,country_name country
          ,period_type
          ,pay_date
          ,cur_pay_withhold_stage
          ,cur_pay_stage
          ,get_json_object(big_data,'$.source_module') source_module
          ,get_json_object(big_data,'$.source_0') source_0
          ,get_json_object(big_data,'$.source_1') source_1
          ,get_json_object(big_data,'$.mids_material_id') mids_material_id
          ,get_json_object(big_data,'$.mids_category_id') mids_category_id
from stat_vip.paid_oda_vip_all_order
WHERE date_p=${now_time}
      and commodity_id_P not in (-1)
      and order_type=2   -- (1:非续期订阅 2:续期订阅 3:消耗品 4:非消耗品)
      and contract_id<>0  -- 续期型的contract_id非0，这些条件是为了减少数据量，缩短运行时长
      and app_id_p IN (7329803307041000000, 7329803307042000000)
      and contract_id='7396341203581030564'

-- 订阅权益有哪些
select source_module,s_0,s_1,count(1) pv
from stat_ab.filing_onz_sub_source_event_detail_level
where date_p between 20251202 and 20251202 and event_id='sub_enter'
group by source_module,s_0,s_1


-- 订阅权益表有多少对不上
select s.source_module,s.s_0,s.s_1
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
    ,s.pv
from
(
    select
        t.source_module,
        case when s_0='' or s_0 is null then '无' else s_0 end s_0,
        case when s_1='' or s_1 is null then '无' else s_1 end s_1,
        count(1) pv
    from
    (
        select gid,os_type,country,is_new,is_ua,app_version,sale_status,event_id,
               duration,sku,
               source_module,source_0,
               case when source_module='p_edit' and source_0='f_makeup' then mids_material_id
               else source_1 end source_1,
               mids_material_id,mids_category_id,
               contract_id,paid_date,
               is_paid,paid_ord_amt,paid_ord_before_amt,
               is_direct_paid,direct_paid_ord_amt,direct_paid_ord_before_amt,
               is_trial,is_trial_to_paid,trial_to_paid_ord_amt,trial_to_paid_ord_before_amt,
               event_time,date_p
        from stat_ab.filing_onz_sub_source_event_detail
        where date_p=20251215 and event_id='w_subscription_enter'
    ) t
    LATERAL VIEW explode(SPLIT(COALESCE(source_0,'无'), ',')) t0 AS s_0
    LATERAL VIEW explode(SPLIT(COALESCE(source_1,'无'), ',')) t1 AS s_1
    group by source_module,s_0,s_1
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
-- where m.source_module is null
-- and s.s_0 not in ('ai_portraits_2','ai_filter','snap_id','hbr','hpp'
--                                                 ,'f_hairstyles','f_hair_dye','f_hair_texture','f_bangs','f_volume'
--                                                 ,'f_ai_retouch','f_glowup','f_relight')


-- 汇总数据差异
select
    date_p
    ,event_id
    ,count(distinct gid) uv
    ,count(distinct case when is_paid=1 then gid end) pay_uv
    ,sum(case when is_paid=1 then paid_ord_before_amt end) pay_revenue
from
	bigdata_test.test_onz_sub_detail
where
	date_p between 20251102 and 20251202
group by date_p,event_id
;
SELECT date_p,event_id,count(distinct gid) uv,count(1) pv
FROM stat_sdk.sdk_odz_source_data
    WHERE date_p between ${start_time} and ${end_time}
        AND app_key_p IN ('C851ED7164B6DF0F', '7F7023B6CEC7CDED')
        AND event_id IN  ('w_subscription_enter','w_subscription_click','w_subscription_success')
        AND app_version>='7.19.0'
group by date_p,event_id
;
select pay_date,count(distinct gid) uv,count(1) pv
from stat_vip.paid_oda_vip_all_order
WHERE date_p=${now_time}
    and pay_date BETWEEN ${start_time} AND ${end_time}
    and app_id_p IN (7329803307041000000)
    and commodity_id_P not in (-1)
    and cur_pay_withhold_stage=0
    and cur_pay_stage=1
    and order_type=2   -- (1:非续期订阅 2:续期订阅 3:消耗品 4:非消耗品)
    and contract_id<>0
group by pay_date
;
select DATE_FORMAT(FROM_UNIXTIME(pay_time/1000), 'yyyyMMdd') pay_date,
    count(distinct buyer_gid) uv
 -- date_format(from_utc_timestamp(from_unixtime(floor(a.pay_time/1000)),'Asia/Shanghai'),'yyyyMMdd')  AS utc8_date
 FROM stat_vip.paid_sda_vip_tb_order a
    WHERE date_p = ${now_time}
    AND DATE_FORMAT(FROM_UNIXTIME(pay_time/1000), 'yyyyMMdd') between '20251120' and '20251202'
    AND supplier_id = 1 -- 会员中心
    AND order_status > 100 -- 已发货
    AND order_type IN (2) -- 订阅续期1非续期2
    AND sandbox = 0 -- 正常数据
    AND app_id IN (7329803307041000000, 7329803307042000000)
    AND platform in (2,3) -- 3:android 2:ios
    AND promotion_status=2
    -- 删选新订阅中台的数据
--     AND nvl(get_json_object(base_data, '$.migrate_pay'), '') <> 'true'
    AND nvl(get_json_object(base_data, '$.migrate_contract'), '') <> 'true'
    AND nvl(get_json_object(base_data, '$.migrate_order'), '') <> 'true'
    AND oper_system != 0
group by DATE_FORMAT(FROM_UNIXTIME(pay_time/1000), 'yyyyMMdd')
;

-- 匹配不上的
select a.date_p,a.gid,b.date_p date_p_1,b.gid gid_1
from
(
    select distinct date_p,gid
    from bigdata_test.test_onz_sub_detail
    where date_p between 20251102 and 20251202
        and event_id='w_subscription_success'
) a
full join
(
    select distinct date_p,gid
    from bigdata_test.test_onz_sub_detail
    where date_p between 20251102 and 20251202
        and event_id='sub_suc'
) b
on a.date_p=b.date_p and a.gid=b.gid
where a.gid is null or b.gid is null
;


-- 个例差异
2749942927:订单表有事件表无订阅成功事件
2582746635:两个表除时间都能对上 事件表时间比订单表晚8小时
select
    os_type,country,is_new,
	gid,
	event_id,duration,
	source_module,source_0,source_1,mids_material_id,mids_category_id,
	contract_id,
	is_paid,paid_ord_amt,paid_ord_before_amt,
	date_p
from
	stat_ab.filing_onz_sub_source_event_detail
where
	date_p between 20251102 and 20251202
--     and event_id='sub_suc'
    and gid='2582746635'
limit 100
;
SELECT date_p,event_id
        ,DATE_FORMAT(FROM_UNIXTIME(`time`/1000), 'yyyyMMddHHmmss') event_time
        ,gid
        ,params['source_module'] source_module
        ,params['source_0'] source_0
        ,params['source_1'] source_1
        ,params['mids_material_id'] mids_material_id
        ,params['mids_category_id'] mids_category_id
FROM stat_sdk.sdk_odz_source_data
WHERE date_p between 20260101 and 20260101
    AND app_key_p IN ('C851ED7164B6DF0F', '7F7023B6CEC7CDED')
    AND event_id IN  ('w_subscription_success') --'w_subscription_enter','w_subscription_click',
    AND app_version>='7.19.0'
    AND gid='2582746635'
;
select pay_date,pay_time
          ,from_unixtime(unix_timestamp(cast(pay_time as string), 'yyyyMMddHHmmss') + 8*3600,'yyyyMMddHHmmss') AS new_time
          ,gid,cur_pay_withhold_stage,cur_pay_stage
          ,get_json_object(big_data,'$.source_module') source_module
          ,get_json_object(big_data,'$.source_0') source_0
          ,get_json_object(big_data,'$.source_1') source_1
          ,get_json_object(big_data,'$.mids_material_id') mids_material_id
          ,get_json_object(big_data,'$.mids_category_id') mids_category_id
from stat_vip.paid_oda_vip_all_order
WHERE date_p=20260118
    and pay_date BETWEEN 20260101 and 20260101
    and app_id_p IN (7329803307041000000)
    and commodity_id_P not in (-1)
    and order_type=2   -- (1:非续期订阅 2:续期订阅 3:消耗品 4:非消耗品)
    and contract_id<>0
    and gid='2582746635'
;

-- 单用户层级收入加起来对不对
select date_p,gid,max(devide_num) devide_num,max(paid_ord_before_amt),sum(devide_paid_ord_before_amt)
from stat_ab.filing_onz_sub_source_event_detail_level
where date_p between 20251126 and 20251126 and event_id='sub_suc' and devide_num>1
group by date_p,gid
;
select *
from
(
select date_p,gid,max(devide_num) devide_num,max(paid_ord_before_amt) revenue,sum(devide_paid_ord_before_amt) revenue_de
from stat_ab.filing_onz_sub_source_event_detail_level
where date_p between 20251126 and 20251126 and event_id='sub_suc'
group by date_p,gid
) a
where revenue-revenue_de>1 or revenue-revenue_de<-1
;
select *
from stat_ab.filing_onz_sub_source_event_detail
where date_p between 20251126 and 20251126 and event_id in ('sub_suc','w_subscription_success')
and gid='2527695141'   -- 2662090346(5),2511249406,2666301231,2717644633,2527695141(差的最大)
;
SELECT date_p,DATE_FORMAT(FROM_UNIXTIME(CAST(`time`/1000 AS bigint)), 'yyyyMMddHHmmss') event_time
        ,event_id
        ,sdk_type os_type,gid,app_version
        ,params['source_module'] source_module
        ,params['source_0'] source_0
        ,params['source_1'] source_1
        ,params['mids_material_id'] mids_material_id
        ,params['mids_category_id'] mids_category_id
        ,params['SKU'] sku
        ,params['sale_status'] sale_status
    FROM stat_sdk.sdk_odz_source_data
    WHERE date_p between 20251126 and 20251126
        AND app_key_p IN ('C851ED7164B6DF0F', '7F7023B6CEC7CDED')
        AND event_id IN  ('w_subscription_success')
        AND app_version>='7.19.0'
        and gid='2527695141'
;
SELECT *
      FROM stat_sdk.sdk_odz_active
      WHERE date_p BETWEEN 20251126 and 20251126
        AND app_key_p IN ('C851ED7164B6DF0F', '7F7023B6CEC7CDED')
        AND os_p IS NOT NULL
        and final_id='2632232077'

-- 收入汇总差异
select date_p,sum(revenue) revenue,sum(revenue_de) revenue_de
from
(
select date_p,gid,max(devide_num) devide_num,max(paid_ord_before_amt) revenue,sum(devide_paid_ord_before_amt) revenue_de
from stat_ab.filing_onz_sub_source_event_detail_level
where date_p between 20251126 and 20251126 and event_id='sub_suc'
group by date_p,gid
) a
group by date_p
;
select a.event_time,b.event_time
from
(
    select gid,os_type,country,is_new,is_ua,app_version,sale_status,
           source_module,source_0,source_1,mids_material_id,mids_category_id,
           event_time,date_p
    from stat_ab.filing_onz_sub_source_event_detail
    where date_p = 20251126
        and event_id in ('w_subscription_success')
        and gid='2662090346'
) a
join
(
    select date_p,gid,duration,sku,
           contract_id,paid_date,
           is_paid,paid_ord_amt,paid_ord_before_amt,
           is_direct_paid,direct_paid_ord_amt,direct_paid_ord_before_amt,
           is_trial,is_trial_to_paid,trial_to_paid_ord_amt,trial_to_paid_ord_before_amt,event_time
    from stat_ab.filing_onz_sub_source_event_detail
    where date_p = 20251126
        and event_id in ('sub_suc')
        and gid='2662090346'
) b
on a.date_p=b.date_p and a.gid=b.gid

;
-- 最终的汇总表验收

select level,date_p,
        sum(sub_enter_uv) sub_enter_uv,
        sum(sub_click_uv) sub_click_uv,
        sum(sub_suc_uv) sub_suc_uv,
        sum(sub_paid_uv) sub_paid_uv,
        round(sum(sub_paid_ord_amt),2) sub_paid_ord_amt,
        round(sum(sub_paid_ord_before_amt),2) sub_paid_ord_before_amt,
        sum(sub_trial_uv) sub_trial_uv,
        sum(sub_trial_paid_uv) sub_trial_paid_uv,
        round(sum(sub_trial_paid_ord_amt),2) sub_trial_paid_ord_amt,
        round(sum(sub_trial_paid_ord_before_amt),2) sub_trial_paid_ord_before_amt,
        sum(sub_direct_paid_uv) sub_direct_paid_uv,
        round(sum(sub_direct_paid_ord_amt),2) sub_direct_paid_ord_amt,
        round(sum(sub_direct_paid_ord_before_amt),2) sub_direct_paid_ord_before_amt
from stat_ab.filing_anz_sub_source_event_show
where date_p between 20251125 and 20251125
    and os_type='整体'
    and country='整体'
    and is_new='整体'
    and is_ua='整体'
    and app_version='整体'
group by level,date_p

;

select source_module,s_0,s_1,count(1)
from stat_ab.filing_onz_sub_source_event_detail_level
where date_p between 20251214 and 20251214
    and first_source='未知'
group by source_module,s_0,s_1


