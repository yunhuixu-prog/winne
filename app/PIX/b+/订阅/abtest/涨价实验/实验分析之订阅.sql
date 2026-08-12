
-- 整体确认下数据跑的对不对
select date
--     case when by_period<0 or by_period is null then '0:unknown'
--           when by_period=0 then '1:1期'
--           when subscription_period='1-year' and by_period=1 then '2:2期'
--           when subscription_period='1-year' and by_period>1 then '3:大于3期'
--
--           when subscription_period='1-month' and by_period between 1 and 3 then '2:2-4期'
--           when subscription_period='1-month' and by_period between 4 and 11 then '3:5-12期'
--           when subscription_period='1-month' and by_period>11 then '4:大于12期'
--     end by_period
    ,count(distinct case when is_refund = 0 then original_order_id end) vpu
    ,count(distinct case when is_cancell = 1 and standard_cancel_date=date then original_order_id end) refund_order_num
    ,count(distinct case when is_cancell = 1 then original_order_id end) refund_status_order_num
    ,count(distinct case when is_expired = 1 then original_order_id end) expired_order_num
    ,count(distinct case when is_expired = 1 and is_renewal = 1 then original_order_id end) renewal_order_num
    ,count(distinct case when is_expired = 1 and is_cancell = 1 then original_order_id end) has_cancelled_expired_order_num
    ,count(distinct case when is_expired = 1 and is_cancell = 1 and is_renewal = 1 then original_order_id end) has_cancelled_renewal_order_num
from beautyplus-bc0ed.temp.sku_order_id_refund_renewal_data
where date >= date_sub('2024-08-02',interval 13 day)
    and platform='IOS'
    and subscription_period in ('1-year','1-month')
--     and is_refund=0 -- 剔除退款的
group by 1
order by 1
;

-- 比较
select date
   ,case when by_period<0 or by_period is null then '0:unknown'
          when by_period=0 then '1:1期'
          when subscription_period='1-year' and by_period=1 then '2:2期'
          when subscription_period='1-year' and by_period>1 then '3:大于3期'

          when subscription_period='1-month' and by_period between 1 and 3 then '2:2-4期'
          when subscription_period='1-month' and by_period between 4 and 11 then '3:5-12期'
          when subscription_period='1-month' and by_period>11 then '4:大于12期'
    end by_period
   ,case when date between date_sub('2024-08-02',interval 13 day) and '2024-08-02' then 'pre-14days'
                 when date between '2024-08-03' and '2024-08-30' then 'ing-28days'
                 when date between '2024-08-31' and '2024-09-13' then 'af-14days'
    end date_type
    ,subscription_period
    ,case when sku in ('com.commsource.BeautyPlus.subscription.1year.fullprice.normal'
                    ,'com.commsource.BeautyPlus.subscription.1year.fullprice.tier1low'
                    ,'com.commsource.BeautyPlus.subscription.1month.fullprice.normal'
                    ,'beautyplus.subs.month1.func00.lev00.ver0'
                    ) then 'normal'
          when sku in ('beautyplus.subs.month12.func00.lev00.ver2'
                    ,'com.commsource.BeautyPlus.subscription.1year.fullprice.resubscribe'
                    ,'beautyplus.subs.month1.func00.lev00.ver4'
                    ,'com.commsource.BeautyPlus.subscription.1month.fullprice.resubscribe'
                    ) then 'resubscribe'
    end user_type
    ,case when sku in ('com.commsource.BeautyPlus.subscription.1year.fullprice.normal'
                    ,'com.commsource.BeautyPlus.subscription.1year.fullprice.resubscribe'
                    ,'com.commsource.BeautyPlus.subscription.1month.fullprice.normal'
                    ,'com.commsource.BeautyPlus.subscription.1month.fullprice.resubscribe'
                    ) then '实验组'
--           when sku in ('com.commsource.BeautyPlus.subscription.1year.fullprice.tier1low'  -- 普通用户
--                     ,'beautyplus.subs.month12.func00.lev00.ver2'  --再订阅用户
--                     ,'beautyplus.subs.month1.func00.lev00.ver0'  -- 普通用户
--                     ,'beautyplus.subs.month1.func00.lev00.ver4'  --再订阅用户
--                     ) then '对照组'
          else '对照组'
    end code
    ,case when country in ('Japan','United States','South Korea','Thailand') then country
           when  country in ('Austria', 'Belgium', 'Bulgaria', 'Hungary', 'Germany', 'Greece', 'Denmark', 'Ireland', 'Spain'
                    , 'Italy', 'Cyprus', 'Latvia', 'Lithuania', 'Luxembourg','Malta', 'Netherlands', 'Poland', 'Portugal', 'Romania'
                    , 'Slovakia', 'Slovenia', 'Finland', 'France', 'Croatia' , 'Czechia','Sweden','Estonia'
                    /* 'United Kingdom',*/
                    ) then 'European Union'
           else 'other'
      end country_label
    ,count(distinct case when is_refund = 0 then original_order_id end) vpu
    ,count(distinct case when is_cancell = 1 and standard_cancel_date=date then original_order_id end) refund_order_num
    ,count(distinct case when is_cancell = 1 then original_order_id end) refund_status_order_num
    ,count(distinct case when is_expired = 1 then original_order_id end) expired_order_num
    ,count(distinct case when is_expired = 1 and is_renewal = 1 then original_order_id end) renewal_order_num
    ,count(distinct case when is_expired = 1 and is_cancell = 1 and is_renewal = 0 then original_order_id end) has_cancelled_expired_order_num
from beautyplus-bc0ed.temp.sku_order_id_refund_renewal_data
where date >= date_sub('2024-08-02',interval 13 day) --and date<='2024-09-13'
    and subscription_period in ('1-year','1-month')
    and platform='IOS'
--     and is_refund=0 -- 剔除退款的
--     and sku in (
--                     'com.commsource.BeautyPlus.subscription.1year.fullprice.tier1low','beautyplus.subs.month12.func00.lev00.ver2',
-- --                     'beautyplus.subs.month12.func00.lev00.ver25','beautyplus.subs.month12.func00.lev00.ver31',
--                     'com.commsource.BeautyPlus.subscription.1year.fullprice.normal','com.commsource.BeautyPlus.subscription.1year.fullprice.resubscribe',
-- --                     'beautyplus.subs.month12.func00.lev00.ver26','beautyplus.subs.month12.func00.lev00.ver32',
--
--                     'beautyplus.subs.month1.func00.lev00.ver0','beautyplus.subs.month1.func00.lev00.ver4',
-- --                     'beautyplus.subs.month12.func00.lev00.ver25','beautyplus.subs.month1.func00.lev00.ver27',
--                     'com.commsource.BeautyPlus.subscription.1month.fullprice.normal','com.commsource.BeautyPlus.subscription.1month.fullprice.resubscribe'
-- --                     'beautyplus.subs.month1.func00.lev00.ver28','beautyplus.subs.month1.func00.lev00.ver34'
--                     )
group by 1,2,3,4,5,6,7
order by 1,2,3,4,5,6,7
;

-- 退订时间（用于分析续订率下降原因）
select date,subscription_period
  ,case when date between date_sub('2024-08-02',interval 13 day) and '2024-08-02' then 'pre-14days'
                 when date between '2024-08-03' and '2024-08-30' then 'ing-28days'
                 when date between '2024-08-31' and '2024-09-13' then 'af-14days'
    end date_type
--   ,case when date between date_sub('2024-08-31',interval 13 day) and '2024-08-31' then 'pre-14days'
--                  when date between '2024-09-01' and '2024-09-14' then 'recent-14days'
--     end date_type
  ,case when sku in ('com.commsource.BeautyPlus.subscription.1year.fullprice.normal'
                    ,'com.commsource.BeautyPlus.subscription.1year.fullprice.resubscribe'
                    ,'com.commsource.BeautyPlus.subscription.1month.fullprice.normal'
                    ,'com.commsource.BeautyPlus.subscription.1month.fullprice.resubscribe'
                    ) then '实验组'
          else '对照组'
    end code
--   ,standard_cancel_date
  ,case when by_period<0 or by_period is null then '0:unknown'
          when by_period=0 then '1:1期'
          when subscription_period='1-year' and by_period=1 then '2:2期'
          when subscription_period='1-year' and by_period>1 then '3:大于2期'

          when subscription_period='1-month' and by_period between 1 and 3 then '2:2-4期'
          when subscription_period='1-month' and by_period between 4 and 11 then '3:5-12期'
          when subscription_period='1-month' and by_period>11 then '4:大于12期'
    end by_period
  ,case
        when is_renewal=1 then '续订'
        when is_refund=1 then '退款'
        when is_cancell=0 or (is_cancell=1 and cancel_end_days<0) then '其他（主要指进入宽限期）'
        when subscription_period = '1-month' and start_cancel_days<=3 then '后台主动取消续订-前3天'
        when subscription_period = '1-month' and cancel_end_days<=7 then '后台主动取消续订-后7天'
        when subscription_period = '1-year' and start_cancel_days<=7 then '后台主动取消续订-前7天'
        when subscription_period = '1-year' and cancel_end_days<=27 then '后台主动取消续订-后27天'
        else '后台主动取消续订-中间天'
  end cancel_period
  ,count(distinct original_order_id) expired_order_num
from
(
    select *
        ,DATE_DIFF(standard_cancel_date, standard_order_date, day) start_cancel_days
        ,DATE_DIFF(standard_order_expire_date, standard_cancel_date, day) cancel_end_days
    from beautyplus-bc0ed.temp.sku_order_id_refund_renewal_data
--     where date between date_sub('2024-08-31',interval 13 day) and '2024-09-14'
    where date >= date_sub('2024-08-02',interval 13 day) --and date<='2024-09-13'
    and subscription_period in ('1-year','1-month')
    and platform='IOS'
    and is_expired=1
)
group by 1,2,3,4,5,6
order by 1,2,3,4,5,6
;
-- -- 退订时间(分天)
-- select
--     case when is_renewal=1 then 'renewal'
--         when is_refund=1 then 'refund'
--         when is_cancell=0 then 'no_cancel'
--         when is_cancell=1 and standard_cancel_date<='2024-08-02' then 'cancel-pre'
--         when is_cancell=1 and standard_cancel_date>'2024-08-02' then concat('cancel-',cast(standard_cancel_date as string))
--     end cancel_date
--   ,subscription_period
-- --   ,case when date between date_sub('2024-08-02',interval 13 day) and '2024-08-02' then 'pre-14days'
-- --                  when date between '2024-08-03' and '2024-08-30' then 'ing-28days'
-- --                  when date between '2024-08-31' and '2024-09-13' then 'af-14days'
-- --     end date_type
--   ,case when date between date_sub('2024-08-31',interval 13 day) and '2024-08-31' then 'pre-14days'
--                  when date between '2024-09-01' and '2024-09-14' then 'recent-14days'
--     end date_type
--   ,case when sku in ('com.commsource.BeautyPlus.subscription.1year.fullprice.normal'
--                     ,'com.commsource.BeautyPlus.subscription.1year.fullprice.resubscribe'
--                     ,'com.commsource.BeautyPlus.subscription.1month.fullprice.normal'
--                     ,'com.commsource.BeautyPlus.subscription.1month.fullprice.resubscribe'
--                     ) then '实验组'
--           else '对照组'
--     end code
--   ,count(distinct original_order_id) expired_order_num
-- from
-- (
--     select *
--         ,DATE_DIFF(standard_cancel_date, standard_order_date, day) start_cancel_days
--         ,DATE_DIFF(standard_order_expire_date, standard_cancel_date, day) cancel_end_days
--     from beautyplus-bc0ed.temp.sku_order_id_refund_renewal_data
--     where date between date_sub('2024-08-31',interval 13 day) and '2024-09-14'
--     and subscription_period in ('1-year','1-month')
--     and platform='IOS'
--     and is_expired=1
-- )
-- group by 1,2,3,4



-- 收入
select subscription_period,sku,standard_order_date
     ,case when standard_order_date between date_sub('2024-08-02',interval 13 day) and '2024-08-02' then 'pre-14days'
                 when standard_order_date between '2024-08-03' and '2024-08-30' then 'ing-28days'
                 when standard_order_date between '2024-08-31' and '2024-09-13' then 'af-14days'
    end date_type
     ,count(distinct original_order_id) order_num
     ,round(sum(payment_price_usd),2) revenue
from `dataintegration-265403.subscription.dwd_trial_subscription_retention_daily_temp`
where order_status in (1,2)
    and standard_order_date between '2024-07-20' and '2024-09-13'
    and app_id='BeautyPlus'
    and subscription_period in ('6-month','1-month','3-month','1-week','1-year')
    and offer_method = 'normal'
            and sku in (
    --                     'com.commsource.BeautyPlus.subscription.1year.fullprice.tier1low','beautyplus.subs.month12.func00.lev00.ver2',
    --                     ,'beautyplus.subs.month12.func00.lev00.ver25','beautyplus.subs.month12.func00.lev00.ver31',
                           'com.commsource.BeautyPlus.subscription.1year.fullprice.normal','com.commsource.BeautyPlus.subscription.1year.fullprice.resubscribe'
    --                     ,'beautyplus.subs.month12.func00.lev00.ver26','beautyplus.subs.month12.func00.lev00.ver32'

    --                     ,'beautyplus.subs.month1.func00.lev00.ver0','beautyplus.subs.month1.func00.lev00.ver4'
    --                     ,'beautyplus.subs.month12.func00.lev00.ver25','beautyplus.subs.month1.func00.lev00.ver27'
                ,          'com.commsource.BeautyPlus.subscription.1month.fullprice.normal','com.commsource.BeautyPlus.subscription.1month.fullprice.resubscribe'
    --                     ,'beautyplus.subs.month1.func00.lev00.ver28','beautyplus.subs.month1.func00.lev00.ver34'
                )
    and order_id not in (select order_id from `dataintegration-265403.subscription.dwd_trial_subscription_retention_daily_temp` where app_id in('BeautyPlus') and order_status in (3))
group by 1,2,3,4
order by 1,2,3,4
