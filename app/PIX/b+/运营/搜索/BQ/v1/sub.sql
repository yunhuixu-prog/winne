

select date_p,count(distinct user_pseudo_id),count(distinct case when paid14>0 then user_pseudo_id end)
from
     `dataintegration-265403.duffle.dwd_dz_material_events_sub2paid` a,unnest(material_info) k
where
     app_code = 'BP'
   and date_p between '2024-01-01' and '2024-01-10'
   and event_name = 'subscription_try_suc' and k.material_type in ('BP_cat_TEM_SCH','BP_cat_STI_SCH')
group by 1
order by 1




with search_sub_event as
(
    select
        event_date
        ,event_timestamp
        ,event_name
        ,`dataintegration-265403.func`.getParams(event_params,'mids_material_tag').string_value mids_material_tag
        ,`dataintegration-265403.func`.getParams(event_params,'order_id').string_value order_id
        ,user_pseudo_id
        ,country
        ,platform
        ,version
    from
        `dataintegration-265403.analytics.dwd_dzp_events_function`('2024-01-01','2024-01-10','beautyplus',true)
    where version>='7.6.030'
        and event_name='subscription_try_suc'
        and `dataintegration-265403.func`.getParams(event_params,'mids_material_tag').string_value in ('BP_cat_TEM_SCH','BP_cat_STI_SCH')
)
,
user_info as
(
    select distinct
        event_date_hk
        ,platform
        ,user_pseudo_id
    from
        `dataintegration-265403.stat.stat_active_advice_detail_d`
    where
        event_date_hk between date'2024-01-01'
        and '2024-01-10'
        and app_name='BeautyPlus'
)
,
sub_detail as
(
    select s.*,e.original_order_id,e.purchase_date,e.payment_price_usd
    from search_sub_event s
    join
    (
        select
            date
            ,platform
            ,country
            ,cur_page_type
            ,source1
            ,source2
            ,k.category1
            ,k.category2 -- miniapp project
            -- ,k.category3_mid
            -- ,k.category3_cid
            -- ,k.category3_feature_content
            -- ,k.category3_id
            ,user_pseudo_id
            ,original_order_id
            ,order_id
            ,sku_type
            ,sku_has_trial
            ,purchase_date
            ,payment_price_usd
        from
            `beautyplus-bc0ed.sub_dataset.ads_spm_trial_subscription_pre_v5_abtest` ,unnest(agg) k
        where
            date between '2024-01-01' and '2024-01-10'
            and event_name='subscription_try_suc'
            and standard_order_date is not null
    ) e
    on s.order_id=e.order_id
)

select event_date,count(distinct original_order_id) sub_uv,count(distinct t.user_pseudo_id) sub_uv1
        ,count(distinct case when purchase_date is not null then original_order_id end) sub_pay_uv
        ,round(sum(case when purchase_date is not null then payment_price_usd end),2) sub_revenue
from sub_detail t
join user_info i on t.event_date = i.event_date_hk and t.user_pseudo_id = i.user_pseudo_id and t.platform = i.platform
group by 1
order by 1
;


select date_p,count(distinct user_pseudo_id),count(distinct case when paid14>0 then user_pseudo_id end)
from
     `dataintegration-265403.duffle.dwd_dz_material_events_sub2paid` a,unnest(material_info) k
where
     app_code = 'BP'
   and date_p between '2024-01-01' and '2024-01-10'
   and event_name = 'subscription_try_suc' and k.material_type in ('BP_cat_TEM_SCH','BP_cat_STI_SCH')
group by 1
order by 1

