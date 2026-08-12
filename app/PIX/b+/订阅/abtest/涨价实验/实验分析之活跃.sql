-- 比较
select date
   ,case when date between date_sub('2024-08-02',interval 13 day) and '2024-08-02' then 'pre-14days'
                 when date between '2024-08-03' and '2024-08-30' then 'ing-28days'
                 when date between '2024-08-31' and '2024-09-13' then 'af-14days'
    end date_type
    ,subscription_period
    ,case when by_period<0 or by_period is null then '0:unknown'
          when by_period=0 then '1:1期'
          when subscription_period='1-year' and by_period=1 then '2:2期'
          when subscription_period='1-year' and by_period>1 then '3:大于3期'

          when subscription_period='1-month' and by_period between 1 and 3 then '2:2-4期'
          when subscription_period='1-month' and by_period between 4 and 11 then '3:5-12期'
          when subscription_period='1-month' and by_period>11 then '4:大于12期'
    end by_period
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
    ,count(distinct original_order_id) vpu
    ,count(distinct case when is_active = 1 then original_order_id end) active_uv
from beautyplus-bc0ed.temp.sku_order_id_refund_renewal_data
where date >= date_sub('2024-08-02',interval 13 day) and date<='2024-09-13'
    and subscription_period in ('1-year','1-month')
    and platform='IOS'
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
group by 1,2,3,4,5,6
order by 1,2,3,4,5,6
;
