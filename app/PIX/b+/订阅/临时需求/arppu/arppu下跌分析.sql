select Date
    ,sum(Paid_users) Paid_users
    ,round(sum(VAS)) Total_revenue
    ,sum(New_paid_users) New_paid_users
    ,sum(Renew_paid_users) Renew_paid_users
    ,sum(Promotional_paid_users) Promotional_paid_users
    ,round(sum(New_paid_revenue)) New_paid_revenue
    ,round(sum(Renew_paid_revenue)) Renew_paid_revenue
    ,round(sum(Promotional_paid_revenue)) Promotional_paid_revenue
from dataintegration-265403.subscription.dws_subscription_overview_monthly_view
where App='BeautyPlus' and Date>='2022-01-01' and country='All'
group by 1
order by 1


--
--
-- select Date,Subscription_Period
--     ,sum(Paid_users) Paid_users
--     ,round(sum(VAS)) Total_revenue
--     ,sum(New_paid_users) New_paid_users
--     ,sum(Renew_paid_users) Renew_paid_users
--     ,sum(Promotional_paid_users) Promotional_paid_users
--     ,round(sum(New_paid_revenue)) New_paid_revenue
--     ,round(sum(Renew_paid_revenue)) Renew_paid_revenue
--     ,round(sum(Promotional_paid_revenue)) Promotional_paid_revenue
-- from dataintegration-265403.subscription.dws_subscription_overview_sku_monthly_view
-- where App='BeautyPlus' and Date>='2022-01-01' and Subscription_Period in ('Monthly','Yearly','Weekly')
-- group by 1,2
-- order by 1,2
--




-- 新增付费分用户类型
select
    DATE_TRUNC(date, MONTH) AS month
    ,event_name
    ,a.platform
    ,case   when sub_user_type='1' then '新用户'
            when sub_user_type='2' then '普通用户'
            when sub_user_type='3' then '耐用型商品单项购买用户'
            when sub_user_type='4' then '再订阅用户'
            when sub_user_type='5' then '试用期用户'
            when sub_user_type='6' then '付费期用户'
            else sub_user_type
            end sub_user_type
    ,case when country in  ('Japan','Thailand','South Korea','United States') then country else 'other countries' end as country
    ,sku_type
    ,sku_has_trial
    ,count(distinct user_pseudo_id) uv
    ,round(sum(payment_price_usd),2) revenue
from
    `beautyplus-bc0ed.sub_dataset.ads_spm_trial_subscription_pre_v5_temp` a
    left join `finance-268602.app_store.dim_da_sku_info_fix_temp2`  s --2022/11/11换成这个表，因为原表的halloween sku信息更改后无法同步
    on  a.sku=s.product_id
        and a.platform=s.platform
        and (s.product_type='subscription'
            and (PARSE_DATE('%Y%m%d', s.start_date)<=DATE(TIMESTAMP(a.date, "Etc/UTC")) and PARSE_DATE('%Y%m%d', s.end_date)>DATE(TIMESTAMP(a.date, "Etc/UTC"))))
where
    date between '2023-01-01' and '2024-10-31'
    and standard_order_date is not null and purchase_date is not null
--     and sub_user_type='4'
group by 1,2,3,4,5,6,7


-- 分订阅归因

--  SELECT
--   DATE_TRUNC(date, MONTH) AS month,
--   platform,
-- --   case when country in  ('Japan','Thailand','South Korea','United States') then country else 'other countries' end as country,
--   sku_type,
--   case when Category1 in ('feature','content') then 'feature+content' else Category1 end Category1,
--   Category2,
--   case when event_name in ('enter_subscription_page') then 'Sub enter'
--        when event_name in ('subscription_clk_try') then 'Sub click'
--        when event_name in ('sub_suc') then 'Sub success'
--        when event_name in ('sub_to_paid') then 'Sub success to paid'
--        when event_name in ('dau') then 'DAU'
--        when event_name in ('trial') then 'Trial uv'
--        when event_name in ('trial_to_paid') then 'Trial to paid uv'
--   end as event_name,
--   sum(uv) uv
-- FROM
--   `beautyplus-bc0ed.sub_dataset.ads_spm_trial_subscription_v5_temp`a
-- left join (select subscription_table_name,max(en_cn_name) en_cn_name from `dataintegration-265403.dim.dim_gs_common_dmi_da_func_name_dictionary` group by 1) b
-- on a.Category2=b.subscription_table_name
-- left join (select subscription_table_name,max(en_cn_name) en_cn_name from `dataintegration-265403.dim.dim_gs_common_dmi_da_func_name_dictionary` group by 1) c
-- on a.Category1_sub=c.subscription_table_name
-- WHERE data_type in ('category2')
--  and REGEXP_CONTAINS(app_version,r'^[0-9]') and app_version not in ('8.5.25.4.52')
--  and sub_user_type='2'
--  and date between '2024-01-01' and '2024-10-31'
--  and platform='IOS'
-- --  and event_name in ('enter_subscription_page','subscription_clk_try','sub_suc','sub_to_paid')
--  and event_name in ('sub_to_paid')
-- group by 1,2,3,4,5,6



SELECT case when month between '2024-02-01' and '2024-04-01' then '2月-4月'
            when month between '2024-08-01' and '2024-10-01' then '8月-10月'
        end months,
        category1,category2,platform,event_name,sub_user_type,
        sum(uv) uv
FROM
(
    select
        DATE_TRUNC(date, MONTH) AS month
        ,event_name
        ,a.platform
        ,case   when sub_user_type='1' then '新用户'
                when sub_user_type='2' then '普通用户'
                when sub_user_type='3' then '耐用型商品单项购买用户'
                when sub_user_type='4' then '再订阅用户'
                when sub_user_type='5' then '试用期用户'
                when sub_user_type='6' then '付费期用户'
                else sub_user_type
                end sub_user_type
        ,case when country in  ('Japan','Thailand','South Korea','United States') then country else 'other countries' end as country
        ,sku_type
        ,sku_has_trial
        ,u.category1
--         ,u.category2
        ,case
          when b.english_name is not null then b.english_name
          else u.category2 end as category2
        ,count(distinct user_pseudo_id) uv
        ,round(sum(payment_price_usd),2) revenue
    from
        `beautyplus-bc0ed.sub_dataset.ads_spm_trial_subscription_pre_v5_abtest` a, unnest(agg) u
        left join `finance-268602.app_store.dim_da_sku_info_fix_temp2`  s --2022/11/11换成这个表，因为原表的halloween sku信息更改后无法同步
        on  a.sku=s.product_id
            and a.platform=s.platform
            and (s.product_type='subscription'
                and (PARSE_DATE('%Y%m%d', s.start_date)<=DATE(TIMESTAMP(a.date, "Etc/UTC")) and PARSE_DATE('%Y%m%d', s.end_date)>DATE(TIMESTAMP(a.date, "Etc/UTC"))))
        left join
          (
            select key,max(category_1) category_1,max(english_name) english_name,max(chinese_name) chinese_name,max(category) category
            from `dataintegration-265403.dim.dim_aa_content_dict`
            where key is not null
            group by 1
          ) b
          on u.category2=b.key
    where
        date between '2024-01-01' and '2024-10-31'
        and standard_order_date is not null and purchase_date is not null
        and sub_user_type='2'
         and a.platform='IOS'
    group by 1,2,3,4,5,6,7,8,9
)
where (month between '2024-02-01' and '2024-04-01' or month between '2024-08-01' and '2024-10-01')
group by 1,2,3,4,5,6














