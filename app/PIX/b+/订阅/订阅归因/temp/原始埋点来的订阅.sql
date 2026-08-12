drop table if exists `beautyplus-bc0ed.temp.winne_ads_spm_trial_subscription_v5_temp`;
create table `beautyplus-bc0ed.temp.winne_ads_spm_trial_subscription_v5_temp` as

WITH event AS
(
  SELECT
    DISTINCT a.date,
    a.event_name,
    a.platform,
    a.country,
    a.source_feature_content,
    a.source_click_position,
    a.SKU_ID,
    a.app_version,
    a.uuid,
    a.user_pseudo_id,
    a.cur_page,
    a.pre_page,
    a.dpre_page,
    a.ddpre_page,
    a.dddpre_page,
    REPLACE(a.cur_page_content,'-','') AS cur_page_content,
    REPLACE(a.pre_page_content,'-','') AS pre_page_content,
    REPLACE(a.dpre_page_content,'-','') AS dpre_page_content,
    REPLACE(a.ddpre_page_content,'-','') AS ddpre_page_content,
    REPLACE(a.dddpre_page_content,'-','') AS dddpre_page_content,
    a.event_timestamp,
    a.device_id,
    a.sub_user_type,
    a.sku_tag
  FROM
    `beautyplus-bc0ed.sub_dataset.dwd_oda_spm_uuid_five_page_temp` a
  WHERE
    a.date >= '2025-01-01'
    and
    (
        event_name IN ('subscription_try_suc','subscription_clk_try')
        OR (event_name IN ('page_event') AND cur_page IN ('订阅页','OnboardingPage订阅页') )
    )
),
--服务端订阅临时表
final_output_pre as (
 select
        a.*,
        b.uuid as new_uuid
        from event a
        left join `dataintegration-265403.stat.dmi_dz_idmapping` b
        on a.user_pseudo_id = b.key

),
final_output_12m as(

select
    f.* ,sub_success_order_id as original_order_id,
    curr_order_id as order_id,
    sub_success_server_date as standard_order_date,
    sub_success_to_paid_date as purchase_date,
    sub_success_to_paid_order_id as purchase_order_id,
    sub_success_to_paid_revenue as payment_price_usd,
    sub_success_to_standard_paid_revenue,
    Promotional_revenue,
    curr_order_order_expire_date,
    sub_success_offer_type,
    sub_success_to_standard_paid_order_id,
    sub_success_to_standard_paid_sub_type
   from final_output_pre f
   left join `dataintegration-265403.subscription.dwd_dz_sub_union_order` s on f.event_name=s.event_name --此关联无实际效用，只为和union all的字段数对齐
   where  f.event_name not in  ('subscription_try_suc')

union all

select
    f.*, sub_success_order_id as original_order_id,
    curr_order_id as order_id,
    sub_success_server_date as standard_order_date,
    sub_success_to_paid_date as purchase_date,
    sub_success_to_paid_order_id as purchase_order_id,
    sub_success_to_paid_revenue as payment_price_usd,
    sub_success_to_standard_paid_revenue,
    Promotional_revenue,
    curr_order_order_expire_date,
    sub_success_offer_type,
    sub_success_to_standard_paid_order_id,
    sub_success_to_standard_paid_sub_type
from final_output_pre f
left join `dataintegration-265403.subscription.dwd_dz_sub_union_order` s
on f.new_uuid = s.uuid   and f.date between date_sub(sub_success_server_date, interval 1 day) and date_add(sub_success_server_date, interval 1 day)  and s.app_name='BeautyPlus'   --and f.sku_id = s.sku
where  f.event_name in  ('subscription_try_suc')

)
select
    t.date,
    t.app_version,
    t.platform,
    t.country,
    t.event_timestamp,
    t.event_name,
    t.cur_page,
    t.pre_page,
    t.dpre_page,
    t.source_feature_content,
    t.source_click_position,
    t.uuid,
    t.user_pseudo_id,
    t.new_uuid,
    original_order_id,
    order_id,
    standard_order_date,
    purchase_date,
    payment_price_usd,
    sub_user_type
from final_output_12m t
join `dataintegration-265403.stat.stat_active_advice_detail_d`  u
on t.user_pseudo_id=u.user_pseudo_id and t.date=u.event_date_hk and t.platform=u.platform

;

select source_click_position
     ,round(sum(sub_uv)/28,2) sub_uv
     ,round(sum(sub_pay_uv)/28,2) sub_pay_uv
     ,round(sum(sub_bookings)/28,2) sub_bookings
from
(
    select date,source_click_position,count(distinct user_pseudo_id) sub_uv,0 sub_pay_uv,0 sub_bookings
    from `beautyplus-bc0ed.temp.winne_ads_spm_trial_subscription_v5_temp`
    where date between '2025-02-01' and '2025-02-28'
        and event_name in ('subscription_try_suc') and standard_order_date is not null
--         and source_click_position = '默认入口'
--         and (pre_page like '自拍预览页%' or  pre_page like '拍后确认页_拍摄%') -- 自拍页
        and pre_page like '%修图编辑页%' -- 修图页
--         and pre_page not like '%修图编辑页%' and pre_page not like '自拍预览页%' and pre_page not like '拍后确认页_拍摄%'
--             and pre_page not like '拍后确认页_视频%' and pre_page not like '拍后确认页_电影%' and pre_page not like '视频编辑页%' and pre_page not like '批量编辑页%'
    group by 1,2

    union all

    select date,source_click_position,0 sub_uv,count(distinct user_pseudo_id) sub_pay_uv,round(sum(payment_price_usd)) sub_bookings
    from `beautyplus-bc0ed.temp.winne_ads_spm_trial_subscription_v5_temp`
    where date between '2025-02-01' and '2025-02-28'
        and event_name in ('subscription_try_suc') and standard_order_date is not null and purchase_date is not null
--         and source_click_position = '默认入口'
--         and (pre_page like '自拍预览页%' or  pre_page like '拍后确认页_拍摄%') -- 自拍页
        and pre_page like '%修图编辑页%' -- 修图页
--         and pre_page not like '%修图编辑页%' and pre_page not like '自拍预览页%' and pre_page not like '拍后确认页_拍摄%'
--             and pre_page not like '拍后确认页_视频%' and pre_page not like '拍后确认页_电影%' and pre_page not like '视频编辑页%' and pre_page not like '批量编辑页%'
    group by 1,2
)
group by 1
order by 2 desc
