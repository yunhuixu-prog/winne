-- pix（看历史数据）
select 
    EXTRACT(YEAR FROM event_date) year
    ,EXTRACT(MONTH FROM event_date) month
    ,platform,country,is_new
    -- ,is_ua
    ,round(sum(dau)/count(distinct event_date),0) dau
    ,round(sum(sub_enter_uv)/count(distinct event_date),0) sub_enter_uv
    ,round(sum(sub_click_uv)/count(distinct event_date),0) sub_click_uv
    ,round(sum(sub_success_uv)/count(distinct event_date),0) sub_success_uv
    ,round(sum(sub_success_to_paid_uv)/count(distinct event_date),0) sub_success_to_paid_uv
    ,round(sum(sub_success_to_paid_gmv)/count(distinct event_date),0) sub_success_to_paid_gmv
    ,round(sum(sub_trial_uv)/count(distinct event_date),0) sub_trial_uv
    ,round(sum(sub_trial_to_paid_uv)/count(distinct event_date),0) sub_trial_to_paid_uv
    ,round(sum(sub_trial_to_paid_gmv)/count(distinct event_date),0) sub_trial_to_paid_gmv
from (
    select event_date
        ,platform
        ,case when country = 'United States' then '美国'
              when country = 'United Kingdom' then '英国'
              when country = 'Brazil' then '巴西'
              when country = 'Mexico' then '墨西哥'
              when country = 'Spain' then '西班牙'
              when country = 'Canada' then '加拿大'
              when country = 'Australia' then '澳大利亚'
              else '其他' end country
        ,is_new
        -- ,is_ua
        ,count(distinct case when event_name ='DAU' then user_pseudo_id end) dau
        ,count(distinct case when event_name ='w_subscription_enter' then user_pseudo_id end) sub_enter_uv
        ,count(distinct case when event_name ='w_subscription_click' then user_pseudo_id end) sub_click_uv
        ,count(distinct case when event_name ='sub_suc' then user_pseudo_id end) sub_success_uv
        ,count(distinct case when event_name ='sub_to_paid' then user_pseudo_id end) sub_success_to_paid_uv
        ,sum(case when event_name = 'sub_to_paid' then payment_price_usd else 0 end) sub_success_to_paid_gmv

        ,count(distinct case when event_name ='trial' then user_pseudo_id end) sub_trial_uv
        ,count(distinct case when event_name ='trial_to_paid' then user_pseudo_id end) sub_trial_to_paid_uv
        ,sum(case when event_name = 'trial_to_paid' then payment_price_usd else 0 end) sub_trial_to_paid_gmv
    from `airbrush-1324.stat.dws_airbrush_trial_sub`
    where source_module = 'all'
    and event_date between '2025-01-01' and '2026-04-30'
    group by 1,2,3,4
)
group by 1,2,3,4,5
;


-- oci
select
    substr(date_p,1,4) year
    ,substr(date_p,5,2) month
    ,case when platform in ('ios','iOS') then 'IOS'
          when platform in ('android','Android') then 'ANDROID'
    end platform
    ,country
    ,is_new
    ,round(sum(dau)/count(distinct date_p),0) dau
    ,round(sum(sub_enter_uv)/count(distinct date_p),0) sub_enter_uv
    ,round(sum(sub_click_uv)/count(distinct date_p),0) sub_click_uv
    ,round(sum(sub_success_uv)/count(distinct date_p),0) sub_success_uv
    ,round(sum(sub_success_to_paid_uv)/count(distinct date_p),0) sub_success_to_paid_uv
    ,round(sum(sub_success_to_paid_gmv)/count(distinct date_p),0) sub_success_to_paid_gmv
    ,round(sum(sub_trial_uv)/count(distinct date_p),0) sub_trial_uv
    ,round(sum(sub_trial_to_paid_uv)/count(distinct date_p),0) sub_trial_to_paid_uv
    ,round(sum(sub_trial_to_paid_gmv)/count(distinct date_p),0) sub_trial_to_paid_gmv
from (
    select
        date_p,
        os_type platform,
        case when country in ('美国','英国','巴西','墨西哥','西班牙','加拿大','澳大利亚') then country else '其他' end country,
        is_new,
        -- is_ua,duration,sku,first_source,second_source,third_source
        0 dau,
        count(distinct case when event_id='sub_enter' then gid end) sub_enter_uv,
        count(distinct case when event_id='sub_click' then gid end) sub_click_uv,
    --         count(distinct case when event_id='sub_suc_order' then gid end) sub_suc_order_uv,
        count(distinct case when event_id='sub_suc' then gid end) sub_success_uv,
        count(distinct case when event_id='sub_suc' and is_paid=1 then gid end) sub_success_to_paid_uv,
        -- sum(case when event_id='sub_suc' and is_paid=1 then devide_paid_ord_amt end) sub_paid_ord_amt,
        sum(case when event_id='sub_suc' and is_paid=1 then devide_paid_ord_before_amt end) sub_success_to_paid_gmv,
        -- 试用
        count(distinct case when event_id='sub_suc' and is_trial=1 then gid end) sub_trial_uv,
        count(distinct case when event_id='sub_suc' and is_trial=1 and is_paid=1 then gid end) sub_trial_to_paid_uv,
        -- sum(case when event_id='sub_suc' and is_trial=1 and is_paid=1 then devide_trial_to_paid_ord_amt end) sub_trial_paid_ord_amt,
        sum(case when event_id='sub_suc' and is_trial=1 and is_paid=1 then devide_trial_to_paid_ord_before_amt end) sub_trial_to_paid_gmv

    from stat_ab.filing_onz_sub_source_event_detail_level
    where date_p between 20260101 and 20260630
    group by os_type,case when country in ('美国','英国','巴西','墨西哥','西班牙','加拿大','澳大利亚') then country else '其他' end
        ,is_new,date_p
    
    union all

        -- DAU（活跃表）
        select
            a.date_p,
            a.os_p as platform,
            case when c.name in ('美国','英国','巴西','墨西哥','西班牙','加拿大','澳大利亚') then c.name else '其他' end country,
            case when new_device.final_id is not null then 'New' else 'Old' end is_new,
            count(distinct a.final_id) as dau,
            0 as sub_enter_uv,
            0 as sub_click_uv,
            0 as sub_success_uv,
            0 as sub_success_to_paid_uv,
            0 as sub_success_to_paid_gmv,
            0 as sub_trial_uv,
            0 as sub_trial_to_paid_uv,
            0 as sub_trial_to_paid_gmv
        from (
            select date_p, os_p, country_id, final_id
            from stat_sdk.sdk_odz_active
            where date_p between 20260101 and 20260630
                and app_key_p in ('C851ED7164B6DF0F', '7F7023B6CEC7CDED')
                and os_p is not null
        ) a
        left join (
            select distinct id, name
            from stat_sdk.dim_rna_ip_location
            where level='1' and date_p is not null
        ) c on a.country_id = c.id
        left join (
            select final_id, date_p
            from stat_sdk.sdk_odz_new_device_info
            where date_p between 20260101 and 20260630
              and app_key_p in ('C851ED7164B6DF0F', '7F7023B6CEC7CDED')
              and os_p is not null
        ) new_device on a.final_id = new_device.final_id and a.date_p = new_device.date_p
        group by a.date_p, a.os_p,
            case when c.name in ('美国','英国','巴西','墨西哥','西班牙','加拿大','澳大利亚') then c.name else '其他' end,
            case when new_device.final_id is not null then 'New' else 'Old' end
) t
group by substr(date_p,1,4), substr(date_p,5,2)
, case when platform in ('ios','iOS') then 'IOS'
        when platform in ('android','Android') then 'ANDROID'
end
, country, is_new




;

-- 分权益
-- PIX
select EXTRACT(YEAR FROM event_date) year,EXTRACT(MONTH FROM event_date) month
    ,case when first in ('Else','Edit') then first else 'Other' end first
    ,case when (first in ('Edit') and second in ('Retouch','Edit','Material','Hpp','Sub To Guide')) or (first in ('Else') and second in ('Onboarding','Update First Launch','Home Sub Banner','Sub To Guide')) then second else 'Other' end second
    ,case when first in ('Edit') and second in ('Retouch','Edit','Material') then third else 'Other' end third
    ,round(sum(enter_uv)/count(distinct event_date),0) sub_enter_uv
    ,round(sum(click_uv)/count(distinct event_date),0) sub_click_uv
    ,round(sum(sub_success_uv)/count(distinct event_date),0) sub_success_uv
    ,round(sum(sub_to_paid_uv)/count(distinct event_date),0) sub_success_to_paid_uv
    ,round(sum(sub_to_paid_revenue)/count(distinct event_date),0) sub_success_to_paid_gmv
    ,round(sum(trial_uv)/count(distinct event_date),0) sub_trial_uv
    ,round(sum(trial_to_paid_uv)/count(distinct event_date),0) sub_trial_to_paid_uv
from airbrush-1324.stat.dws_airbrush_trial_sub_grads_view
where event_date between '2025-01-01' and '2026-04-30'
    and category='Third Source'
group by 1,2,3,4,5
;

-- OCI
select substr(date_p,1,4) year
        ,substr(date_p,5,2) month
        ,first_source
        ,second_source
        ,third_source
        ,round(sum(sub_enter_uv)/count(distinct date_p),0) sub_enter_uv
        ,round(sum(sub_click_uv)/count(distinct date_p),0) sub_click_uv
        ,round(sum(sub_success_uv)/count(distinct date_p),0) sub_success_uv
        ,round(sum(sub_success_to_paid_uv)/count(distinct date_p),0) sub_success_to_paid_uv
        ,round(sum(sub_success_to_paid_gmv)/count(distinct date_p),0) sub_success_to_paid_gmv
        ,round(sum(sub_trial_uv)/count(distinct date_p),0) sub_trial_uv
        ,round(sum(sub_trial_to_paid_uv)/count(distinct date_p),0) sub_trial_to_paid_uv
from (
    select
        date_p
        ,case when first_source in ('Else','Edit') then first_source else 'Other' end first_source
        ,case when (first_source in ('Edit') and second_source in ('Retouch','Edit','Material','Edit Popup','Sub To Guide')) or (first_source in ('Else') and second_source in ('Onboarding','Update First Launch','Home Sub Banner','Sub To Guide')) then second_source else 'Other' end second_source
        ,case when first_source in ('Edit') and second_source in ('Retouch','Edit','Material') then third_source else 'Other' end third_source
        ,count(distinct case when event_id='sub_enter' then gid end) sub_enter_uv
        ,count(distinct case when event_id='sub_click' then gid end) sub_click_uv
    --         ,count(distinct case when event_id='sub_suc_order' then gid end) sub_suc_order_uv
        ,count(distinct case when event_id='sub_suc' then gid end) sub_success_uv
        ,count(distinct case when event_id='sub_suc' and is_paid=1 then gid end) sub_success_to_paid_uv
        -- ,sum(case when event_id='sub_suc' and is_paid=1 then devide_paid_ord_amt end) sub_paid_ord_amt
        ,sum(case when event_id='sub_suc' and is_paid=1 then devide_paid_ord_before_amt end) sub_success_to_paid_gmv
        -- 试用
        ,count(distinct case when event_id='sub_suc' and is_trial=1 then gid end) sub_trial_uv
        ,count(distinct case when event_id='sub_suc' and is_trial=1 and is_paid=1 then gid end) sub_trial_to_paid_uv
        -- ,sum(case when event_id='sub_suc' and is_trial=1 and is_paid=1 then devide_trial_to_paid_ord_amt end) sub_trial_paid_ord_amt
        ,sum(case when event_id='sub_suc' and is_trial=1 and is_paid=1 then devide_trial_to_paid_ord_before_amt end) sub_trial_to_paid_gmv

    from stat_ab.filing_onz_sub_source_event_detail_level
    where date_p between 20260101 and 20260630
    group by date_p
        ,case when first_source in ('Else','Edit') then first_source else 'Other' end
        ,case when (first_source in ('Edit') and second_source in ('Retouch','Edit','Material','Edit Popup','Sub To Guide')) or (first_source in ('Else') and second_source in ('Onboarding','Update First Launch','Home Sub Banner','Sub To Guide')) then second_source else 'Other' end
        ,case when first_source in ('Edit') and second_source in ('Retouch','Edit','Material') then third_source else 'Other' end
) t
group by substr(date_p,1,4), substr(date_p,5,2),first_source,second_source,third_source


;
-- 新增用户安装天数、历史订阅信息（历史安装数据缺失较多）
select 
    substr(t1.pay_date,1,6) pay_month
    ,t1.country country
    -- ,t1.period_type period_type
    ,case when meitu_datediff(t1.pay_date, t2.first_launch_date) = 0 then '新增'
        when meitu_datediff(t1.pay_date, t2.first_launch_date) > 0 and meitu_datediff(t1.pay_date, t2.first_launch_date) <= 7 then '7天'
        when meitu_datediff(t1.pay_date, t2.first_launch_date) > 7 and meitu_datediff(t1.pay_date, t2.first_launch_date) <= 30 then '30天'
        when meitu_datediff(t1.pay_date, t2.first_launch_date) > 30 and meitu_datediff(t1.pay_date, t2.first_launch_date) <= 90 then '90天'
        when meitu_datediff(t1.pay_date, t2.first_launch_date) > 90 and meitu_datediff(t1.pay_date, t2.first_launch_date) <= 180 then '180天'
        when meitu_datediff(t1.pay_date, t2.first_launch_date) > 180 and meitu_datediff(t1.pay_date, t2.first_launch_date) <= 365 then '365天'
        when meitu_datediff(t1.pay_date, t2.first_launch_date) < 0 or first_launch_date is null then '未知'
            else '1年以上' end launch_days_type
    ,case when coalesce(hist_trial_cnt,0)=0 and coalesce(hist_pay_cnt,0)=0 then '历史未订阅'
          when coalesce(hist_pay_cnt,0)>0 then '历史付费过'
          when coalesce(hist_trial_cnt,0)>0 and coalesce(hist_pay_cnt,0)=0 then '历史仅试用过'
          else '其他'
          end user_type
    ,count(distinct t1.gid) uv
from (
SELECT
        a.gid
        ,a.country
        ,a.period_type
        -- 历史订阅
        ,SUM(CASE WHEN o.pay_date < a.pay_date AND cur_pay_stage=1 and cur_pay_withhold_stage=0 THEN 1 ELSE 0 END) AS hist_trial_cnt -- 历史试用订阅次数
        ,SUM(CASE WHEN o.pay_date < a.pay_date AND cur_pay_withhold_stage>=1 THEN 1 ELSE 0 END) AS hist_pay_cnt -- 历史付费订阅次数
        ,a.pay_date
    FROM (
        select  nvl(country_name,'未知') country
                ,period_type
                ,pay_date
                ,gid
        from stat_vip.paid_oda_vip_all_order
        WHERE date_p=20260630
                and pay_date between 20250101 and 20260630
                and cur_pay_withhold_stage = 1
                and order_type='2'   -- 订单类型(1:非续期订阅 2:续期订阅 3:消耗品 4:非消耗品)
                and contract_id<>0   -- 续期型订单的contract_id不等于0
                and app_id_p in (7329803307041000000)
                and commodity_id_P not in (-1)
    ) a
    LEFT JOIN (
        select  nvl(country_name,'未知') country_code
                ,period_type
                ,pay_date
                ,gid
                ,cur_pay_withhold_stage
                ,cur_pay_stage
        from stat_vip.paid_oda_vip_all_order
        WHERE date_p=20260630
                and pay_date <= 20260630
                and order_type='2'   -- 订单类型(1:非续期订阅 2:续期订阅 3:消耗品 4:非消耗品)
                and contract_id<>0   -- 续期型订单的contract_id不等于0
                and app_id_p in (7329803307041000000)
                and commodity_id_P not in (-1)
    ) o
    ON a.gid = o.gid
    GROUP BY
        a.gid
        ,a.country
        ,a.period_type
        ,a.pay_date
) t1
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
    and date_p = 20260630
    and server_id > 0
    group by server_id
) t2
on t1.gid = t2.gid
where t1.country='美国'
group by substr(t1.pay_date,1,6), t1.country
    -- , t1.period_type
    ,case when meitu_datediff(t1.pay_date, t2.first_launch_date) = 0 then '新增'
        when meitu_datediff(t1.pay_date, t2.first_launch_date) > 0 and meitu_datediff(t1.pay_date, t2.first_launch_date) <= 7 then '7天'
        when meitu_datediff(t1.pay_date, t2.first_launch_date) > 7 and meitu_datediff(t1.pay_date, t2.first_launch_date) <= 30 then '30天'
        when meitu_datediff(t1.pay_date, t2.first_launch_date) > 30 and meitu_datediff(t1.pay_date, t2.first_launch_date) <= 90 then '90天'
        when meitu_datediff(t1.pay_date, t2.first_launch_date) > 90 and meitu_datediff(t1.pay_date, t2.first_launch_date) <= 180 then '180天'
        when meitu_datediff(t1.pay_date, t2.first_launch_date) > 180 and meitu_datediff(t1.pay_date, t2.first_launch_date) <= 365 then '365天'
        when meitu_datediff(t1.pay_date, t2.first_launch_date) < 0 or first_launch_date is null then '未知'
            else '1年以上' end
    ,case when coalesce(hist_trial_cnt,0)=0 and coalesce(hist_pay_cnt,0)=0 then '历史未订阅'
          when coalesce(hist_pay_cnt,0)>0 then '历史付费过'
          when coalesce(hist_trial_cnt,0)>0 and coalesce(hist_pay_cnt,0)=0 then '历史仅试用过'
          else '其他'
          end