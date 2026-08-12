with user_info as
(
    select
        event_date event_date_hk
        ,platform
        ,country
        ,user_pseudo_id
        ,max(case when is_new='New users' then 1 else 0 end) is_new
        ,max(is_UA) is_UA
        ,max(is_pay) is_pay
    from
        `beautyplus-bc0ed.event_dataset_2.dws_dz_active_user_02`
    where
        -- event_date_hk between date'2023-08-01' and '{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=0)).strftime("%Y-%m-%d") }}'  -- 修改查询的数据时间
        event_date between '{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=3)).strftime("%Y-%m-%d") }}' and '{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=0)).strftime("%Y-%m-%d") }}'
--         and app_name='BeautyPlus'
    group by 1,2,3,4
)
,
subscription_attr_raw as
(
    select
        date
        ,platform
        ,country
        ,cur_page_type
        ,source1
        ,source2
        ,category1
        ,category2 -- miniapp project
        ,coalesce(miniapp,category2) miniapp_name
        ,status
        ,user_pseudo_id
        ,original_order_id
        ,sku_type
        ,sku_has_trial
        ,purchase_date
        ,payment_price_usd
    from
        (select
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
            ,sku_type
            ,sku_has_trial
            ,purchase_date
            ,payment_price_usd
        from
            `beautyplus-bc0ed.sub_dataset.ads_spm_trial_subscription_pre_v5_abtest` ,unnest(agg) k
        where
            -- date between '2023-08-01' and '{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=0)).strftime("%Y-%m-%d") }}'
            -- date between '2023-08-10' and '{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=0)).strftime("%Y-%m-%d") }}'
            date between '{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=3)).strftime("%Y-%m-%d") }}' and '{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=0)).strftime("%Y-%m-%d") }}'
            and k.category1='H5'
            and event_name='subscription_try_suc') e
        left join (select sub_miniapp,max(miniapp) miniapp,max(status) status from `beautyplus-bc0ed.content_data.dwd_da_miniapp_status` group by 1) s on e.category2=s.sub_miniapp

)
,
subscription_attr_result as
(
    select
        date
        ,e.platform
        ,e.country
        ,u.is_new
        ,u.is_UA
        ,u.is_pay
        ,miniapp_name
        ,status
        ,'>=7.6.020' version  -- 首页miniapp曝光点击7.6.020之前没有数，统一只看7.6.020之后的数，订阅底表未区分版本，默认定位7.6.020之后
        ,'All' from_page
        ,count(distinct original_order_id) sub_uv
    from
        subscription_attr_raw e
        join user_info u on e.user_pseudo_id=u.user_pseudo_id and e.date=u.event_date_hk and e.platform=u.platform
    group by
        1,2,3,4,5,6,7,8
)