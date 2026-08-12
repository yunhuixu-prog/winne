-- 示例用户：uuid='300673186'
with choose_function_list as
(
    select module,use_func function,ranks
    from `beautyplus-bc0ed.temp.winne_function_use_for_vip_top_list`
    where ranks<=25
)
,
func_raw as
(
    --关联付费功能
    SELECT
        uuid
        ,case when module in ('拍摄','苹果模式') then '拍摄' else module end module
        ,class
        ,function_en
        ,sum(pv) pv
    FROM `beautyplus-bc0ed.temp.winne_function_use_for_vip`
    where event_date between '2024-11-01' and '2024-11-30'
    group by 1,2,3,4
)
,
func_num as
(
    select
        uuid
        ,count(distinct module) module_num
        ,count(distinct class) class_num
        ,count(distinct function_en) func_num
        ,sum(pv) pv
    from
        func_raw
    group by
        1
)
,
-- 订阅来源：粗略取了1个月前的最后一次订阅来源
sub_function as
(
    select *
    from
    (
        select distinct s.standard_order_date,s.original_order_id,s.order_id,s.new_uuid,s.user_pseudo_id
            ,coalesce(c.en_cn_name,b.english_name,a.category2) sub_source
            ,rank() over(PARTITION by new_uuid order by standard_order_date desc) ranks
        from `beautyplus-bc0ed.sub_dataset.ads_spm_trial_subscription_pre_v5_abtest` s,UNNEST(agg) a
        left join
        (
            select key,max(english_name) english_name
            from `dataintegration-265403.dim.dim_aa_content_dict`
            where key is not null
            group by 1
        ) b
        on a.category2=b.key
        left join
        (
            select distinct subscription_table_name
                ,case when class in ('滤镜','美妆','AR','Look') then class
                      when en_cn_name = 'Filter（滤镜）' then '滤镜'
                    else en_cn_name end en_cn_name
            from `dataintegration-265403.dim.dim_gs_common_dmi_da_func_name_dictionary`
            where subscription_table_name is not null
        ) c
        on b.english_name=c.subscription_table_name
        where date<='2024-10-30'
            and event_name in ('subscription_try_suc') and standard_order_date is not null
    )
    where ranks=1
)
,
renewal as
(
    select
        event_date,
        app_name,
        platform,
        country,
        is_ua,
        subscription_period, -- sku类型:1-year 、1-month 、1-week、 3-month、 6-month
        case when subscription_user_type like '%renewal' then 'renewal' else 'new' end subscription_user_type,
        offer_method, -- 票据优惠类型:normal :标准价,无优惠 trial:免费试用 trial mix pay up front: 免费试用+初次体验价(仅安卓) pay as you go : 随用随付 pay up front : 提前支付
        order_id,
        is_due_1m , --该月是否到期 1 是 0 否
        is_due_to_renewal_subscription_period_1m, -- 该月订单到期且有下笔续订订单(不考虑升降级,含退款) 1 是 0 否
        uuid, --若使用uuid关联其他表，关联条件请带上app_name 和 platform
        original_order_id,
    from
        `dataintegration-265403.dwd.dwd_mzp_subscription_due_order_detail` -- 月到期订单明细,粒度为 event_date(月) * order_id
    where
        event_date = '2024-11-01' --筛选月日期
        and app_name='BeautyPlus'
        and subscription_period in ('1-month')
        and subscription_user_type in ('return_renewal','repeated_renewal')
        and is_due_1m = 1
)
,
--月连续续费6次以上用户
renewal_six as
(
  select uuid
  from
  (
      select uuid,count(distinct month)months
      from
      (
          select uuid,date_trunc(standard_order_date,month)month,
          from `dataintegration-265403.subscription.dwd_trial_subscription_retention_daily_temp`
            where order_status in (1,2)
            and subscription_period in ('1-month')
            and app_id = 'BeautyPlus'
            and subscription_user_type in ('return_renewal','repeated_renewal')
            and standard_order_date < '2024-11-01'
            and standard_order_date >= '2024-05-01'
            group by 1,2
      )
      group by 1
    )
    where months = 6
)

select ranks,module,function
       ,case when func_num <= 3 or func_num is null then '1:1~3'
            when func_num >=4 and func_num <= 7 then '2:4~7'
            when func_num >=8 and func_num <= 11 then '3:8~11'
            when func_num >=12 and func_num <= 15 then '4:12~15'
            when func_num >=16 and func_num <= 19 then '5:16~19'
            when func_num >=20 then '6:20+' else null end vip_func_num
        ,if_use
        ,count(distinct original_order_id) prepared_order
        ,count(distinct if(is_due_to_renewal_subscription_period_1m = 1 ,original_order_id,null)) retention_order
from
(
    select a.ranks,a.module,a.function,original_order_id,is_due_to_renewal_subscription_period_1m,uuid,func_num
        ,max(if(a.function = use_func and a.module=use_module,1,0)) if_use
        ,max(if(a.function = sub_func,1,0)) if_sub
    from
    (
            select r.original_order_id,r.is_due_to_renewal_subscription_period_1m,r.uuid
                 ,h.func_num,c.module use_module,c.function_en use_func,s.sub_source sub_func
            from renewal r  -- 到期月订单
--             join renewal_six f on r.uuid = f.uuid  --连续续费6次
            left join func_num h on r.uuid = h.uuid  --11月使用会员功能数
            left join func_raw c on r.uuid = c.uuid --11月使用具体功能
            left join sub_function s on  r.uuid = s.new_uuid  --订阅归因功能
            group by 1,2,3,4,5,6,7
    )s
    cross join choose_function_list a
    group by 1,2,3,4,5,6,7
)
where if_sub=0
group by 1,2,3,4,5

