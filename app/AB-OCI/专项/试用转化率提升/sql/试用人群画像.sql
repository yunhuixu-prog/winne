SET hive.exec.dynamic.partition.mode=nonstrict;
insert overwrite table stat_ab.filing_odz_trial_users_info_temp PARTITION(date_p)

select 
    t.gid
    ,os_type
    ,country
    ,is_new
    ,is_ua
    ,first_source
    ,second_source
    ,third_source
    ,fourth_source
    ,is_paid
    ,devide_trial_to_paid_ord_amt
    ,dismiss_time
    ,dismiss_date
    ,meitu_datediff(dismiss_date,t.date_p) as dismiss_days
    ,active_days_30d
    ,is_subscribed
    ,hist_trial_cnt
    ,hist_pay_cnt
    ,meitu_datediff(t.date_p, l.first_launch_date) first_active_days
    ,trial_time
    ,case when is_new='New' or meitu_datediff(t.date_p, l.first_launch_date)<=3 then '3天内新用户'
          when coalesce(hist_trial_cnt,0)=0 and coalesce(hist_pay_cnt,0)=0 and meitu_datediff(t.date_p, l.first_launch_date)>3 then '历史未订阅老用户'
          when coalesce(hist_pay_cnt,0)>0 then '历史付费过老用户'
          when coalesce(hist_trial_cnt,0)>0 and coalesce(hist_pay_cnt,0)=0 then '历史试用过老用户'
          else '其他'
          end user_type
    ,case when dismiss_time is null then '未解约'
        when cast(dismiss_time as bigint)-UNIX_TIMESTAMP(trial_time, 'yyyyMMddHHmmss')<=60*10 then '10分钟内解约'
        when meitu_datediff(dismiss_date,t.date_p)=0 and cast(dismiss_time as bigint)-UNIX_TIMESTAMP(trial_time, 'yyyyMMddHHmmss')>60*10 then '当天10分钟后解约'
        when meitu_datediff(dismiss_date,t.date_p)>0 then '非当天解约'
        else '其他'
        end dismiss_time_type
    ,case when dismiss_act.gid is not null then 1 else 0 end is_dismiss_day_active
    ,t.date_p
from (
SELECT
        a.gid
        ,a.os_type
        ,a.country
        ,a.is_new
        ,a.is_ua
        ,a.first_source
        ,a.second_source
        ,a.third_source
        ,a.fourth_source
        ,a.is_paid
        ,a.devide_trial_to_paid_ord_amt
        ,MIN(dismiss_time) dismiss_time
        ,MIN(dismiss_date) dismiss_date
        ,coalesce(act30.active_days_30d, 0) AS active_days_30d
        ,MAX(CASE WHEN a.date_p > o.pay_date  and a.date_p <= cast(o.invalid_date as bigint) THEN 1 ELSE 0 END) AS is_subscribed -- 当前是否订阅
        -- 历史订阅
        ,SUM(CASE WHEN o.pay_date < a.date_p AND cur_pay_stage=1 and cur_pay_withhold_stage=0 THEN 1 ELSE 0 END) AS hist_trial_cnt -- 历史试用订阅次数
        ,SUM(CASE WHEN o.pay_date < a.date_p AND cur_pay_withhold_stage>=1 THEN 1 ELSE 0 END) AS hist_pay_cnt -- 历史付费订阅次数
        ,a.event_time trial_time
        ,a.date_p
    FROM (
        SELECT
            date_p
            ,gid
            ,os_type
            ,country
            ,is_new
            ,is_ua
            ,duration
            ,sku
            ,first_source
            ,second_source
            ,third_source
            ,fourth_source
            ,contract_id
            ,is_paid
            ,devide_trial_to_paid_ord_amt
            ,event_time
        FROM stat_ab.filing_onz_sub_source_event_detail_level
        WHERE date_p BETWEEN ${start_date} AND ${end_date}
            AND event_id = 'sub_suc' AND is_trial = 1

        -- SELECT  pay_date AS date_p
        --     ,notify_pay_id as out_pay_id
        --     ,os_type
        --     ,nvl(country_name,'未知') as country
        --     ,get_json_object(big_data,'$.source_module') AS source_module
        --     ,get_json_object(big_data,'$.source_0') AS source_0
        --     ,get_json_object(big_data,'$.source_1') AS source_1
        --     ,ord_amt
        --     ,gid
        --     ,invalid_time
        -- FROM stat_vip.paid_oda_vip_all_order
        -- WHERE date_p=${now_time}
        --         and pay_date BETWEEN ${start_date} AND ${end_date}
        --         and app_id_p not in (-1)
        --         and commodity_id_P not in (-1)
        --         and order_type=2
        --         and cur_pay_withhold_stage=0
        --         and cur_pay_stage=1   -- 当前订单代扣期数(包含试用单)
        --         and contract_id<>0
    ) a
    LEFT JOIN (
        select
            gid
            ,pay_date
            ,invalid_date
            ,period_type
            ,device_type as os_type
            ,nvl(country_name,'未知') country_code
            ,cur_pay_stage
            ,cur_pay_withhold_stage
            ,ord_amt_usd
        from stat_vip.paid_oda_all_order_summary
        where app_id_p IN (7329803307041000000)
            and pay_date <= ${end_date}
            and is_subscribe='订阅'
            and product_sub_line = 'AirBrush'
    ) o
    ON a.gid = o.gid
    left join (
        -- 试用日前30天活跃天数（不含试用当日，对齐精细分层 BETWEEN 1 AND 30）
        select
            t.gid
            ,t.date_p
            ,count(distinct act.date_p) as active_days_30d
        from (
            select distinct gid, date_p
            from stat_ab.filing_onz_sub_source_event_detail_level
            where date_p between ${start_date} and ${end_date}
                and event_id = 'sub_suc'
                and is_trial = 1
        ) t
        inner join (
            select final_id as gid, date_p
            from stat_sdk.sdk_odz_active
            where date_p between ${start_date_m30} and ${end_date}
                and app_key_p in ('C851ED7164B6DF0F', '7F7023B6CEC7CDED')
                and os_p is not null
        ) act
            on t.gid = act.gid
            and meitu_datediff(t.date_p, act.date_p) between 1 and 30
        group by t.gid, t.date_p
    ) act30
    on a.gid = act30.gid and a.date_p = act30.date_p
    LEFT JOIN (
        -- 解约信息
        SELECT  contract_id,dismiss_time
                ,CAST(dismiss_date AS BIGINT)  as dismiss_date
        FROM stat_vip.paid_oda_vip_tb_contract
        WHERE date_p =${now_time}
                and app_id_p not in(-1)
                AND dismiss_date>=${start_date}
                AND contract_status = 3
                and commodity_id_P not in (-1)
        group by contract_id,dismiss_time,dismiss_date
        ) s2
    ON a.contract_id = s2.contract_id AND dismiss_date >= a.date_p
    
    GROUP BY
        a.gid
        ,a.os_type
        ,a.country
        ,a.is_new
        ,a.is_ua
        ,a.first_source
        ,a.second_source
        ,a.third_source
        ,a.fourth_source
        ,a.is_paid
        ,a.devide_trial_to_paid_ord_amt
        ,dismiss_time
        ,dismiss_date
        ,meitu_datediff(s2.dismiss_date,a.date_p)
        ,coalesce(act30.active_days_30d, 0)
        ,a.event_time
        ,a.date_p
) t
left join (
    -- 安装时间
    select
        server_id as gid,min(first_launch_date) as first_launch_date
    from stat_sdk.sdk_oda_all_device_info
    where os_p in ('ios', 'android')
    and app_key_p in (
        '7F7023B6CEC7CDED'                -- Airbrush: Android
        , 'C851ED7164B6DF0F'              -- Airbrush: ios
    )
    and date_p = ${end_date}
    and server_id > 0
    group by server_id
) l 
on t.gid = l.gid
LEFT JOIN (
    -- 解约当天是否活跃：dismiss_date 当日在活跃表有记录
    SELECT final_id AS gid, date_p
    FROM stat_sdk.sdk_odz_active
    WHERE date_p BETWEEN ${start_date} AND ${now_time}
        AND app_key_p IN ('C851ED7164B6DF0F', '7F7023B6CEC7CDED')
        AND os_p IS NOT NULL
    GROUP BY final_id, date_p
) dismiss_act
    ON t.gid = dismiss_act.gid
    AND t.dismiss_date = dismiss_act.date_p

;




SELECT install_days_type,active_days_30d_type,hist_sub_type,source_type
    ,round(sum(trial_uv)/count(distinct date_p),0) trial_uv
    ,round(sum(paid_uv)/count(distinct date_p),0) paid_uv
    ,round(sum(dismiss_0_uv)/count(distinct date_p),0) dismiss_0_uv
    ,round(sum(dismiss_1_uv)/count(distinct date_p),0) dismiss_1_uv
    ,round(sum(dismiss_2_uv)/count(distinct date_p),0) dismiss_2_uv
    ,round(sum(dismiss_3_uv)/count(distinct date_p),0) dismiss_3_uv
    ,round(sum(dismiss_4_uv)/count(distinct date_p),0) dismiss_4_uv
    ,round(sum(dismiss_5_uv)/count(distinct date_p),0) dismiss_5_uv
    ,round(sum(dismiss_6_uv)/count(distinct date_p),0) dismiss_6_uv
    ,round(sum(dismiss_7_uv)/count(distinct date_p),0) dismiss_7_uv
    ,round(sum(dismiss_all_uv)/count(distinct date_p),0) dismiss_all_uv
FROM (
SELECT date_p
    ,case when is_new='New' then '0:新用户'
          when first_active_days<=3 then '1:激活天数小于3天'
          when first_active_days<=30 then '2:老用户激活天数大于3天小于30天'
          when first_active_days<=365 then '3:老用户激活天数大于30天小于365天'
          else '4:老用户激活天数大于365天'
          end install_days_type
    ,case when coalesce(active_days_30d, 0) = 0 then '0:0天'
          when active_days_30d <= 2 then '1:1~2天'
          when active_days_30d <= 7 then '2:3~7天'
          else '3:8~30天'
          end active_days_30d_type
    ,case when hist_pay_cnt>0 then '历史付费过'
          when hist_trial_cnt>0 then '历史试用过'
          else '历史未订阅'
          end hist_sub_type
    ,case when first_source='Else' and second_source in ('Onboarding') then '引导订阅页-新用户'
          when first_source='Else' and second_source in ('Update First Launch') then '引导订阅页-老用户升级'
          when first_source='Edit' and second_source in ('Retouch','Edit','Material') then '编辑器功能'
          else '其他'
          end source_type
    ,count(distinct gid) trial_uv 
    ,count(distinct case when is_paid=1 then gid end) paid_uv 
    ,count(distinct case when dismiss_days=0 then gid end) dismiss_0_uv 
    ,count(distinct case when dismiss_days=1 then gid end) dismiss_1_uv 
    ,count(distinct case when dismiss_days=2 then gid end) dismiss_2_uv 
    ,count(distinct case when dismiss_days=3 then gid end) dismiss_3_uv 
    ,count(distinct case when dismiss_days=4 then gid end) dismiss_4_uv 
    ,count(distinct case when dismiss_days=5 then gid end) dismiss_5_uv 
    ,count(distinct case when dismiss_days=6 then gid end) dismiss_6_uv 
    ,count(distinct case when dismiss_days=7 then gid end) dismiss_7_uv 
    ,count(distinct case when dismiss_days<=7 then gid end) dismiss_all_uv 
FROM stat_ab.filing_odz_trial_users_info_temp t
WHERE date_p between ${start_date} and ${end_date}
group by date_p
    ,case when is_new='New' then '0:新用户'
          when first_active_days<=3 then '1:激活天数小于3天'
          when first_active_days<=30 then '2:老用户激活天数大于3天小于30天'
          when first_active_days<=365 then '3:老用户激活天数大于30天小于365天'
          else '4:老用户激活天数大于365天'
          end
    ,case when coalesce(active_days_30d, 0) = 0 then '0:0天'
          when active_days_30d <= 2 then '1:1~2天'
          when active_days_30d <= 7 then '2:3~7天'
          else '3:8~30天'
          end
    ,case when hist_pay_cnt>0 then '历史付费过'
          when hist_trial_cnt>0 then '历史试用过'
          else '历史未订阅'
          end
    ,case when first_source='Else' and second_source in ('Onboarding') then '引导订阅页-新用户'
          when first_source='Else' and second_source in ('Update First Launch') then '引导订阅页-老用户升级'
          when first_source='Edit' and second_source in ('Retouch','Edit','Material') then '编辑器功能'
          else '其他'
          end
) t
group by install_days_type,active_days_30d_type,hist_sub_type,source_type


;

SELECT 
    user_type
    ,case when cast(dismiss_time as bigint)-UNIX_TIMESTAMP(trial_time, 'yyyyMMddHHmmss')<=60 then '1:1分钟内'
          when cast(dismiss_time as bigint)-UNIX_TIMESTAMP(trial_time, 'yyyyMMddHHmmss')<=60*10 then '2:1分钟~10分钟'
          when cast(dismiss_time as bigint)-UNIX_TIMESTAMP(trial_time, 'yyyyMMddHHmmss')<=60*30 then '3:10分钟~30分钟'
          when cast(dismiss_time as bigint)-UNIX_TIMESTAMP(trial_time, 'yyyyMMddHHmmss')<=60*60 then '4:30分钟~1小时'
          when cast(dismiss_time as bigint)-UNIX_TIMESTAMP(trial_time, 'yyyyMMddHHmmss')>60*60 then '5:大于1小时'
    end dismiss_time_type
    ,case when dismiss_days=0 then '0:0天'
          when dismiss_days=1 then '1:1天'
          when dismiss_days=2 then '2:2天'
          when dismiss_days=3 then '3:3天'
          when dismiss_days=4 then '4:4天'
          when dismiss_days=5 then '5:5天'
          when dismiss_days=6 then '6:6天'
          when dismiss_days=7 then '7:7天'
          when dismiss_days>=8 then '8:大于等于8天'
          end dismiss_days_type
    ,is_dismiss_day_active -- 解约当天是否活跃
    ,count(distinct t.gid) trial_uv 
FROM (
    select * 
    from stat_ab.filing_odz_trial_users_info_temp 
    where date_p between ${start_date} and ${end_date}
        and dismiss_time is not null
    ) t
group by user_type
    ,case when cast(dismiss_time as bigint)-UNIX_TIMESTAMP(trial_time, 'yyyyMMddHHmmss')<=60 then '1:1分钟内'
          when cast(dismiss_time as bigint)-UNIX_TIMESTAMP(trial_time, 'yyyyMMddHHmmss')<=60*10 then '2:1分钟~10分钟'
          when cast(dismiss_time as bigint)-UNIX_TIMESTAMP(trial_time, 'yyyyMMddHHmmss')<=60*30 then '3:10分钟~30分钟'
          when cast(dismiss_time as bigint)-UNIX_TIMESTAMP(trial_time, 'yyyyMMddHHmmss')<=60*60 then '4:30分钟~1小时'
          when cast(dismiss_time as bigint)-UNIX_TIMESTAMP(trial_time, 'yyyyMMddHHmmss')>60*60 then '5:大于1小时'
    end
    ,case when dismiss_days=0 then '0:0天'
          when dismiss_days=1 then '1:1天'
          when dismiss_days=2 then '2:2天'
          when dismiss_days=3 then '3:3天'
          when dismiss_days=4 then '4:4天'
          when dismiss_days=5 then '5:5天'
          when dismiss_days=6 then '6:6天'
          when dismiss_days=7 then '7:7天'
          when dismiss_days>=8 then '8:大于等于8天'
          end
    ,is_dismiss_day_active


