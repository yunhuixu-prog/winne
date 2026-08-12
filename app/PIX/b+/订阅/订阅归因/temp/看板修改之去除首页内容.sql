
select *
from beautyplus-bc0ed.sub_dataset.ads_spm_trial_subscription_pre_v5_abtest,unnest(agg) u
WHERE date between '2024-12-01' and '2025-01-15'
    and event_name in ('subscription_try_suc')
    and standard_order_date is not null
    and u.category2='首页-默认入口'

-- 首页订阅类运营报的什么：source_feature_content 为 null，source_click_source 为 内容。。。看下有没有别的内容了，怎么区分呢
-- 首页topbanner报的：source_feature_content、source_click_source 均为null
select source_feature_content,source_click_position,pre_page,count(1)
FROM `beautyplus-bc0ed.sub_dataset.dwd_oda_spm_uuid_five_page_temp` a
where date between '2024-12-01' and '2025-01-15'
--     and (pre_page_content='BP_POP_00001631' or dpre_page_content='BP_POP_00001631' or ddpre_page_content='BP_POP_00001631' or dddpre_page_content='BP_POP_00001631')
    and (pre_page_content='BP_TB_00000018' or dpre_page_content='BP_TB_00000018' or ddpre_page_content='BP_TB_00000018' or dddpre_page_content='BP_TB_00000018')
    and event_name in ('subscription_try_suc')
group by 1,2,3

-- 验数
select coalesce(a.date,b.date) date
    ,coalesce(a.event_name,b.event_name) event_name
    ,coalesce(a.category1,b.category1) category1
    ,coalesce(a.category2,b.category2) category2
    ,a.pv pv_ad,a.uv uv_ad,a.bookings bookings_ad
    ,b.pv,b.uv,b.bookings
from
(
    select date,event_name,u.category1,u.category2
        ,count(1) pv,count(distinct user_pseudo_id) uv
        ,round(sum(source_amount_proportion*payment_price_usd),2) bookings
    from `beautyplus-bc0ed.temp.temp_ads_spm_trial_subscription_pre_v5_abtest`,unnest(agg) u
    where date>='2025-02-01'
    group by 1,2,3,4
) a
full join
(
    select date,event_name,u.category1,u.category2
        ,count(1) pv,count(distinct user_pseudo_id) uv
        ,round(sum(source_amount_proportion*payment_price_usd),2) bookings
    from `beautyplus-bc0ed.sub_dataset.ads_spm_trial_subscription_pre_v5_abtest`,unnest(agg) u
    where date>='2025-02-01'
    group by 1,2,3,4
) b
on a.date=b.date and a.event_name=b.event_name and a.category1=b.category1 and a.category2=b.category2


select *
from `beautyplus-bc0ed.temp.temp_ads_spm_trial_subscription_pre_v5_abtest`,unnest(agg) u
where date>='2025-02-01'
    and u.category1='else'
    -- and u.category2='首页-默认入口'
    and u.category2 like '%BP_TEM%'


select *
from `beautyplus-bc0ed.temp.temp_ads_spm_trial_subscription_pre_v5_abtest`,unnest(agg) u
where date>='2025-02-01'
    and u.category2='首页-其他内容'



-- 验收
select coalesce(a.date,b.date) date,coalesce(a.event_name,b.event_name) event_name
    ,a.uv uv_1
    ,a.bookings bookings_1
    ,b.uv uv_2
    ,b.bookings bookings_2
from
(
    select date,event_name,sum(payment_price_usd) bookings,sum(uv) uv
    from `beautyplus-bc0ed.view.ads_dz_sub_no_content_category2`
    where edition='event' and date>='2025-01-01'
    group by 1,2
) a
full join
(
    select date,event_name,sum(payment_price_usd) bookings,sum(uv) uv
    from `beautyplus-bc0ed.sub_dataset.ads_dz_sub_datatype_event`
    where edition='V5.0' and date>='2025-01-01'
    group by 1,2
) b
on a.date=b.date and a.event_name=b.event_name


-- 每一层都能对上
select *
from `beautyplus-bc0ed.sub_dataset.dwd_oda_spm_uuid_five_page_temp`
where date='2025-01-01'
    and event_name IN ('subscription_try_suc')
    and array_length(SPLIT(source_feature_content, '、'))>1
limit 10

select *
from `beautyplus-bc0ed.sub_dataset.ads_spm_trial_subscription_pre_v5_abtest`
where date='2025-01-01'
    and event_name IN ('subscription_try_suc')
    and uuid='51461A1106B049A286392B610D388696'
    and event_timestamp=1735744047117002

-- 是否有分配比例对不上的(temp有对不上的，因为根据source_feature_content区分比例，但最后按照首页来的)
select *
from `beautyplus-bc0ed.sub_dataset.ads_spm_trial_subscription_pre_v5_abtest`
-- from `beautyplus-bc0ed.sub_dataset.ads_spm_trial_subscription_pre_v5_temp`
where date='2025-01-01'
    and event_name IN ('subscription_try_suc')
    and source_amount_proportion*array_length(SPLIT(source2, '、'))!=1


select data_type
    ,round(sum(share_revenue),2) share_revenue
--     ,round(sum(source_amount_proportion),2) share_revenue
    ,round(sum(payment_price_usd),2) revenue
-- from `beautyplus-bc0ed.subscription.ads_dzp_subscription_spm_trial_subscription_v5_abtest`
from `beautyplus-bc0ed.sub_dataset.ads_spm_trial_subscription_v5_temp`
-- from `beautyplus-bc0ed.temp.temp_ads_spm_trial_subscription_v5_abtest`
where date='2025-02-01' and event_name in ('sub_to_paid')
group by 1
order by 1




