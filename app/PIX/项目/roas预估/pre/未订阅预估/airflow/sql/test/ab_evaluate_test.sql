-- 所有
select 'pre' types,days,num,uv
  ,round(sub_revenue_365,2) sub_revenue_365
  ,round(predict_sub_revenue_365,2) predict_sub_revenue_365
  ,case when sub_revenue_365=0 and predict_sub_revenue_365=0 then 1
        when sub_revenue_365=0 and predict_sub_revenue_365>0 then 0
        else round(predict_sub_revenue_365/sub_revenue_365,4)
  end predict_suc
from
(
  select days,count(1) num,count(distinct user_pseudo_id) uv,sum(sub_revenue_365) sub_revenue_365,sum(predict_sub_revenue_365) predict_sub_revenue_365
--   from airbrush-1324.temp.ads_dz_roi_predict_user_predict_sub_revenue_test
  from airbrush-1324.temp.ads_dz_roi_predict_new_user_predict_sub_revenue_test
--   where Attributed_Touch_Date between '2023-03-15' and '2023-03-21'
  where Attributed_Touch_Date between '2023-03-19' and '2023-03-21'
  group by 1
)
-- order by 1
union all
-- 方法一：超过90天的用户，取前7天的预测结果(后面天数的预估值大大超过真实值，pass)
select '一' types,days,num,uv
  ,round(sub_revenue_365,2) sub_revenue_365
  ,round(predict_sub_revenue_365,2) predict_sub_revenue_365
  ,case when sub_revenue_365=0 and predict_sub_revenue_365=0 then 1
        when sub_revenue_365=0 and predict_sub_revenue_365>0 then 0
        else round(predict_sub_revenue_365/sub_revenue_365,4)
  end predict_suc
from
(
    select days,count(1) num,count(distinct user_pseudo_id) uv,sum(sub_revenue_365) sub_revenue_365,sum(predict_sub_revenue_365) predict_sub_revenue_365
    from
    (
        select a.date,a.Attributed_Touch_Date,a.days,a.user_pseudo_id,a.sub_revenue_365,b.predict_sub_revenue_365
        from
        (
            select date,Attributed_Touch_Date,days,user_pseudo_id,sub_revenue_365
            from airbrush-1324.temp.dws_dz_roi_predict_final_model_input_delete_v
--             where types='ua' and sub_now=0 and days>90 and Attributed_Touch_Date between '2023-03-15' and '2023-03-21'
            where types='new' and sub_now=0 and days>90 and Attributed_Touch_Date between '2023-03-19' and '2023-03-21'
        ) a
        join
        (
            select distinct date,Attributed_Touch_Date,days,user_pseudo_id,sub_revenue_365,predict_sub_revenue_365
--             from airbrush-1324.temp.ads_dz_roi_predict_user_predict_sub_revenue_test
            from airbrush-1324.temp.ads_dz_roi_predict_new_user_predict_sub_revenue_test
--             where days=6 and Attributed_Touch_Date between '2023-03-15' and '2023-03-21'
            where days=6 and Attributed_Touch_Date between '2023-03-19' and '2023-03-21'
        ) b
        on a.Attributed_Touch_Date=b.Attributed_Touch_Date and a.user_pseudo_id=b.user_pseudo_id

        union all

        select date,Attributed_Touch_Date,days,user_pseudo_id,sub_revenue_365,predict_sub_revenue_365
--         from airbrush-1324.temp.ads_dz_roi_predict_user_predict_sub_revenue_test
        from airbrush-1324.temp.ads_dz_roi_predict_new_user_predict_sub_revenue_test
--         where days<=90 and Attributed_Touch_Date between '2023-03-15' and '2023-03-21'
        where days<=90 and Attributed_Touch_Date between '2023-03-19' and '2023-03-21'
    )
    group by 1
)
-- order by 1
union all
-- 方法二：超过90天且近60天无活跃的用户，取前7天的预测结果
select '二' types,days,num,uv
  ,round(sub_revenue_365,2) sub_revenue_365
  ,round(predict_sub_revenue_365,2) predict_sub_revenue_365
  ,case when sub_revenue_365=0 and predict_sub_revenue_365=0 then 1
        when sub_revenue_365=0 and predict_sub_revenue_365>0 then 0
        else round(predict_sub_revenue_365/sub_revenue_365,4)
  end predict_suc
from
(
    select days,count(1) num,count(distinct user_pseudo_id) uv,sum(sub_revenue_365) sub_revenue_365,sum(predict_sub_revenue_365) predict_sub_revenue_365
    from
    (
        select a.date,a.Attributed_Touch_Date,a.days,a.user_pseudo_id,a.sub_revenue_365,b.predict_sub_revenue_365
        from
        (
            select date,Attributed_Touch_Date,days,user_pseudo_id,sub_revenue_365
            from airbrush-1324.temp.dws_dz_roi_predict_final_model_input_delete_v
--             where types='ua' and sub_now=0 and days>90 and last_active_days>60 and Attributed_Touch_Date between '2023-03-15' and '2023-03-21'
            where types='new' and sub_now=0 and days>90 and last_active_days>60 and Attributed_Touch_Date between '2023-03-19' and '2023-03-21'
        ) a
        join
        (
            select distinct date,Attributed_Touch_Date,days,user_pseudo_id,sub_revenue_365,predict_sub_revenue_365
--             from airbrush-1324.temp.ads_dz_roi_predict_user_predict_sub_revenue_test
            from airbrush-1324.temp.ads_dz_roi_predict_new_user_predict_sub_revenue_test
--             where days=6 and Attributed_Touch_Date between '2023-03-15' and '2023-03-21'
            where days=6 and Attributed_Touch_Date between '2023-03-19' and '2023-03-21'
        ) b
        on a.Attributed_Touch_Date=b.Attributed_Touch_Date and a.user_pseudo_id=b.user_pseudo_id

        union all

        select a.date,a.Attributed_Touch_Date,a.days,a.user_pseudo_id,a.sub_revenue_365,b.predict_sub_revenue_365
        from
        (
            select date,Attributed_Touch_Date,days,user_pseudo_id,sub_revenue_365
            from airbrush-1324.temp.dws_dz_roi_predict_final_model_input_delete_v
--             where types='ua' and sub_now=0 and (days<=90 or last_active_days<=60) and Attributed_Touch_Date between '2023-03-15' and '2023-03-21'
            where types='new' and sub_now=0 and days<=90 and last_active_days<=60 and Attributed_Touch_Date between '2023-03-19' and '2023-03-21'
        ) a
        join
        (
            select distinct date,Attributed_Touch_Date,days,user_pseudo_id,sub_revenue_365,predict_sub_revenue_365
--             from airbrush-1324.temp.ads_dz_roi_predict_user_predict_sub_revenue_test
            from airbrush-1324.temp.ads_dz_roi_predict_new_user_predict_sub_revenue_test
--             where Attributed_Touch_Date between '2023-03-15' and '2023-03-21'
            where Attributed_Touch_Date between '2023-03-19' and '2023-03-21'
        ) b
        on a.Attributed_Touch_Date=b.Attributed_Touch_Date and a.user_pseudo_id=b.user_pseudo_id and a.date=b.date
    )
    group by 1
)
-- order by 1
union all
-- 方法三：超过90天且近60天无活跃的用户，取0（目前看就这个靠谱）
select '三' types,days,num,uv
  ,round(sub_revenue_365,2) sub_revenue_365
  ,round(predict_sub_revenue_365,2) predict_sub_revenue_365
  ,case when sub_revenue_365=0 and predict_sub_revenue_365=0 then 1
        when sub_revenue_365=0 and predict_sub_revenue_365>0 then 0
        else round(predict_sub_revenue_365/sub_revenue_365,4)
  end predict_suc
from
(
    select days,count(1) num,count(distinct user_pseudo_id) uv,sum(sub_revenue_365) sub_revenue_365,sum(predict_sub_revenue_365) predict_sub_revenue_365
    from
    (
        select a.date,a.Attributed_Touch_Date,a.days,a.user_pseudo_id,a.sub_revenue_365,0.0 predict_sub_revenue_365
        from
        (
            select date,Attributed_Touch_Date,days,user_pseudo_id,sub_revenue_365
            from airbrush-1324.temp.dws_dz_roi_predict_final_model_input_delete_v
--             where types='ua' and sub_now=0 and days>90 and last_active_days>60 and Attributed_Touch_Date between '2023-03-15' and '2023-03-21'
             where types='new' and sub_now=0 and days>90 and last_active_days>60 and Attributed_Touch_Date between '2023-03-19' and '2023-03-21'
        ) a
        union all

        select a.date,a.Attributed_Touch_Date,a.days,a.user_pseudo_id,a.sub_revenue_365,b.predict_sub_revenue_365
        from
        (
            select date,Attributed_Touch_Date,days,user_pseudo_id,sub_revenue_365
            from airbrush-1324.temp.dws_dz_roi_predict_final_model_input_delete_v
--             where types='ua' and sub_now=0 and (days<=90 or last_active_days<=60) and Attributed_Touch_Date between '2023-03-15' and '2023-03-21'
            where types='new' and sub_now=0 and (days<=90 or last_active_days<=60) and Attributed_Touch_Date between '2023-03-19' and '2023-03-21'
        ) a
        join
        (
            select distinct date,Attributed_Touch_Date,days,user_pseudo_id,sub_revenue_365,predict_sub_revenue_365
--             from airbrush-1324.temp.ads_dz_roi_predict_user_predict_sub_revenue_test
            from airbrush-1324.temp.ads_dz_roi_predict_new_user_predict_sub_revenue_test
--             where Attributed_Touch_Date between '2023-03-15' and '2023-03-21'
            where Attributed_Touch_Date between '2023-03-19' and '2023-03-21'
        ) b
        on a.Attributed_Touch_Date=b.Attributed_Touch_Date and a.user_pseudo_id=b.user_pseudo_id and a.date=b.date
    )
    group by 1
)
-- order by 1

;

-- ua
select 'pre' types,days,num,uv
  ,round(sub_revenue_365,2) sub_revenue_365
  ,round(predict_sub_revenue_365,2) predict_sub_revenue_365
  ,case when sub_revenue_365=0 and predict_sub_revenue_365=0 then 1
        when sub_revenue_365=0 and predict_sub_revenue_365>0 then 0
        else round(predict_sub_revenue_365/sub_revenue_365,4)
  end predict_suc
from
(
  select days,count(1) num,count(distinct user_pseudo_id) uv,sum(sub_revenue_365) sub_revenue_365,sum(predict_sub_revenue_365) predict_sub_revenue_365
  from airbrush-1324.temp.ads_dz_roi_predict_user_predict_sub_revenue_test
  where Attributed_Touch_Date between '2023-03-19' and '2023-03-21'
  group by 1
)
-- order by 1
union all
-- 方法一：超过90天的用户，取前7天的预测结果(后面天数的预估值大大超过真实值，pass)
select '一' types,days,num,uv
  ,round(sub_revenue_365,2) sub_revenue_365
  ,round(predict_sub_revenue_365,2) predict_sub_revenue_365
  ,case when sub_revenue_365=0 and predict_sub_revenue_365=0 then 1
        when sub_revenue_365=0 and predict_sub_revenue_365>0 then 0
        else round(predict_sub_revenue_365/sub_revenue_365,4)
  end predict_suc
from
(
    select days,count(1) num,count(distinct user_pseudo_id) uv,sum(sub_revenue_365) sub_revenue_365,sum(predict_sub_revenue_365) predict_sub_revenue_365
    from
    (
        select a.date,a.Attributed_Touch_Date,a.days,a.user_pseudo_id,a.sub_revenue_365,b.predict_sub_revenue_365
        from
        (
            select date,Attributed_Touch_Date,days,user_pseudo_id,sub_revenue_365
            from airbrush-1324.temp.dws_dz_roi_predict_final_model_input_delete_v
            where types='ua' and sub_now=0 and days>90 and Attributed_Touch_Date between '2023-03-19' and '2023-03-21'
        ) a
        join
        (
            select distinct date,Attributed_Touch_Date,days,user_pseudo_id,sub_revenue_365,predict_sub_revenue_365
            from airbrush-1324.temp.ads_dz_roi_predict_user_predict_sub_revenue_test
            where days=6 and Attributed_Touch_Date between '2023-03-19' and '2023-03-21'
        ) b
        on a.Attributed_Touch_Date=b.Attributed_Touch_Date and a.user_pseudo_id=b.user_pseudo_id

        union all

        select date,Attributed_Touch_Date,days,user_pseudo_id,sub_revenue_365,predict_sub_revenue_365
        from airbrush-1324.temp.ads_dz_roi_predict_user_predict_sub_revenue_test
        where days<=90 and Attributed_Touch_Date between '2023-03-19' and '2023-03-21'
    )
    group by 1
)
-- order by 1
union all
-- 方法二：超过90天且近60天无活跃的用户，取前7天的预测结果
select '二' types,days,num,uv
  ,round(sub_revenue_365,2) sub_revenue_365
  ,round(predict_sub_revenue_365,2) predict_sub_revenue_365
  ,case when sub_revenue_365=0 and predict_sub_revenue_365=0 then 1
        when sub_revenue_365=0 and predict_sub_revenue_365>0 then 0
        else round(predict_sub_revenue_365/sub_revenue_365,4)
  end predict_suc
from
(
    select days,count(1) num,count(distinct user_pseudo_id) uv,sum(sub_revenue_365) sub_revenue_365,sum(predict_sub_revenue_365) predict_sub_revenue_365
    from
    (
        select a.date,a.Attributed_Touch_Date,a.days,a.user_pseudo_id,a.sub_revenue_365,b.predict_sub_revenue_365
        from
        (
            select date,Attributed_Touch_Date,days,user_pseudo_id,sub_revenue_365
            from airbrush-1324.temp.dws_dz_roi_predict_final_model_input_delete_v
            where types='ua' and sub_now=0 and days>90 and last_active_days>60 and Attributed_Touch_Date between '2023-03-19' and '2023-03-21'
        ) a
        join
        (
            select distinct date,Attributed_Touch_Date,days,user_pseudo_id,sub_revenue_365,predict_sub_revenue_365
            from airbrush-1324.temp.ads_dz_roi_predict_user_predict_sub_revenue_test
            where days=6 and Attributed_Touch_Date between '2023-03-19' and '2023-03-21'
        ) b
        on a.Attributed_Touch_Date=b.Attributed_Touch_Date and a.user_pseudo_id=b.user_pseudo_id

        union all

        select a.date,a.Attributed_Touch_Date,a.days,a.user_pseudo_id,a.sub_revenue_365,b.predict_sub_revenue_365
        from
        (
            select date,Attributed_Touch_Date,days,user_pseudo_id,sub_revenue_365
            from airbrush-1324.temp.dws_dz_roi_predict_final_model_input_delete_v
            where types='ua' and sub_now=0 and (days<=90 or last_active_days<=60) and Attributed_Touch_Date between '2023-03-19' and '2023-03-21'
        ) a
        join
        (
            select distinct date,Attributed_Touch_Date,days,user_pseudo_id,sub_revenue_365,predict_sub_revenue_365
            from airbrush-1324.temp.ads_dz_roi_predict_user_predict_sub_revenue_test
            where Attributed_Touch_Date between '2023-03-19' and '2023-03-21'
        ) b
        on a.Attributed_Touch_Date=b.Attributed_Touch_Date and a.user_pseudo_id=b.user_pseudo_id and a.date=b.date
    )
    group by 1
)
-- order by 1
union all
-- 方法三：超过90天且近60天无活跃的用户，取0（目前看就这个靠谱）
select '三' types,days,num,uv
  ,round(sub_revenue_365,2) sub_revenue_365
  ,round(predict_sub_revenue_365,2) predict_sub_revenue_365
  ,case when sub_revenue_365=0 and predict_sub_revenue_365=0 then 1
        when sub_revenue_365=0 and predict_sub_revenue_365>0 then 0
        else round(predict_sub_revenue_365/sub_revenue_365,4)
  end predict_suc
from
(
    select days,count(1) num,count(distinct user_pseudo_id) uv,sum(sub_revenue_365) sub_revenue_365,sum(predict_sub_revenue_365) predict_sub_revenue_365
    from
    (
        select a.date,a.Attributed_Touch_Date,a.days,a.user_pseudo_id,a.sub_revenue_365,0.0 predict_sub_revenue_365
        from
        (
            select date,Attributed_Touch_Date,days,user_pseudo_id,sub_revenue_365
            from airbrush-1324.temp.dws_dz_roi_predict_final_model_input_delete_v
            where types='ua' and sub_now=0 and days>90 and last_active_days>60 and Attributed_Touch_Date between '2023-03-19' and '2023-03-21'
        ) a
        union all

        select a.date,a.Attributed_Touch_Date,a.days,a.user_pseudo_id,a.sub_revenue_365,b.predict_sub_revenue_365
        from
        (
            select date,Attributed_Touch_Date,days,user_pseudo_id,sub_revenue_365
            from airbrush-1324.temp.dws_dz_roi_predict_final_model_input_delete_v
            where types='ua' and sub_now=0 and (days<=90 or last_active_days<=60) and Attributed_Touch_Date between '2023-03-19' and '2023-03-21'
        ) a
        join
        (
            select distinct date,Attributed_Touch_Date,days,user_pseudo_id,sub_revenue_365,predict_sub_revenue_365
            from airbrush-1324.temp.ads_dz_roi_predict_user_predict_sub_revenue_test
            where Attributed_Touch_Date between '2023-03-19' and '2023-03-21'
        ) b
        on a.Attributed_Touch_Date=b.Attributed_Touch_Date and a.user_pseudo_id=b.user_pseudo_id and a.date=b.date
    )
    group by 1
)
-- order by 1

;



select *
from airbrush-1324.temp.dws_dz_roi_predict_final_model_input_delete_v
where types='ua' and sub_now=0 and (days<=90 or last_active_days<=60) and Attributed_Touch_Date between '2023-03-15' and '2023-03-21'
and user_pseudo_id='14804D6FC6AF4D539F303B494FB03422'

-- 看一下目前预测的值和之前比有没有大的变化，就还挺大的。。。会不会加入了什么偏见啊
select 'real' typse,days,sum(predict_sub_revenue_365)/count(1)
from airbrush-1324.temp.ads_dz_roi_predict_user_predict_sub_revenue
where days between 0 and 6
-- where Attributed_Touch_Date<='2023-12-01'
group by 1,2

union all

select 'pre' typse,days,sum(sub_revenue_365)/count(1)
from airbrush-1324.temp.ads_dz_roi_predict_user_predict_sub_revenue_test
where days between 0 and 6
group by 1,2


-- 新用户和ua的差别（ua购买更快，new要更多关注后续的购买。）
select types,days,count(distinct case when sub_now>0 then user_pseudo_id end)
                      /count(distinct case when sub_365>0 then user_pseudo_id end)
        ,sum(sub_revenue_now)/sum(sub_revenue_365)
-- select Attributed_Touch_Date,count(distinct date)
from airbrush-1324.temp.dws_dz_roi_predict_final_model_input
group by 1,2
order by 2,1


-- 核查一下test和predict预测的是不是一样的

select
--        a.Attributed_Touch_Date,a.date,
       count(1),sum(a.predict_sub_revenue_365) a,sum(b.predict_sub_revenue_365) b
from airbrush-1324.temp.ads_dz_roi_predict_user_predict_sub_revenue a
join airbrush-1324.temp.ads_dz_roi_predict_user_predict_sub_revenue_test b
on a.Attributed_Touch_Date=b.Attributed_Touch_Date and a.date=b.date and a.user_pseudo_id=b.user_pseudo_id
-- group by 1,2


-- new的真实会少一点，因为部分用户未预测
select
--         a.Attributed_Touch_Date,a.date,
        count(1),sum(a.predict_sub_revenue_365) a,sum(b.predict_sub_revenue_365) b
from airbrush-1324.temp.ads_dz_roi_predict_new_user_predict_sub_revenue a
join airbrush-1324.temp.ads_dz_roi_predict_new_user_predict_sub_revenue_test b
on a.Attributed_Touch_Date=b.Attributed_Touch_Date and a.date=b.date and a.user_pseudo_id=b.user_pseudo_id
-- group by 1,2

select distinct date from airbrush-1324.temp.ads_dz_roi_predict_user_predict_sub_revenue
select distinct date from airbrush-1324.temp.ads_dz_roi_predict_new_user_predict_sub_revenue
