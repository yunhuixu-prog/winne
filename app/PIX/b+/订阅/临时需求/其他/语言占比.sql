-- 活跃
select event_date_hk,platform,language,count(distinct user_pseudo_id) active_uv
from `dataintegration-265403.stat.stat_active_advice_detail_d`
where event_date_hk between '2025-04-13' and '2025-04-19' and app_name='BeautyPlus'
group by 1,2,3
;
-- 订阅支付

drop table if exists `dataintegration-265403.temp.winne_sub_pay`;
create table if not exists `dataintegration-265403.temp.winne_sub_pay` as

with temp_output as
(
    SELECT event_date_hk as date,platform,language,language_name,user_pseudo_id,event_name
    from  `dataintegration-265403.analytics.dwd_dzp_events_function`('2025-04-06', '2025-04-12','beautyplus',false)
    where event_name in ('subscription_try_suc') or
        (event_name='page_event'
        and `beautyplus-bc0ed.func.decodeSpmNew`(`beautyplus-bc0ed.func.getParams`(event_params,'cur_spm').string_value).page_id in ('1009','1008_01'))
)

select
    a.*,
    b.uuid as new_uuid
    from temp_output a
    left join `dataintegration-265403.stat.dmi_dz_idmapping` b
    on a.user_pseudo_id = b.key

;

with
final_output_12m as
(
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
       from `dataintegration-265403.temp.winne_sub_pay` f
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
    from `dataintegration-265403.temp.winne_sub_pay` f
    left join `dataintegration-265403.subscription.dwd_dz_sub_union_order` s
    on f.new_uuid = s.uuid   and f.date between date_sub(sub_success_server_date, interval 1 day) and date_add(sub_success_server_date, interval 1 day)  and s.app_name='BeautyPlus'   --and f.sku_id = s.sku
    where  f.event_name in  ('subscription_try_suc')
)

select date,platform,language,language_name
  ,count(distinct case when event_name = 'page_event' then user_pseudo_id end) sub_enter_uv
  ,count(distinct case when event_name = 'subscription_try_suc' and standard_order_date is not null then user_pseudo_id end) sub_uv
  ,count(distinct case when event_name = 'subscription_try_suc' and standard_order_date is not null and purchase_date is not null then user_pseudo_id end) sub_pay_uv
  ,round(sum(case when event_name = 'subscription_try_suc' and standard_order_date is not null and purchase_date is not null then payment_price_usd end),2) sub_pay_revenue
from final_output_12m
group by 1,2,3,4
