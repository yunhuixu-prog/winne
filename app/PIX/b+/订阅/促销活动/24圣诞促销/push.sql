-- 基本source_feature_content和source_click_position都是空的
-- 打开push后的第一次订阅事件（由于打开push一定会进入订阅页，但不一定会订阅点击，所以订阅点击需要根据source来源排除）
drop table if exists `dataintegration-265403.temp.christmas_push_sub_data_temp`;
create table if not exists `dataintegration-265403.temp.christmas_push_sub_data_temp` as

select *
from
(
    select (b.event_timestamp-a.event_timestamp)/1000000 timediff
        ,row_number() over(partition by a.push_id,b.user_pseudo_id,b.event_name order by b.event_timestamp) ranks
        ,a.event_date,a.event_timestamp event_timestamp_open,a.user_pseudo_id,a.platform,a.country,a.push_id
        ,b.event_timestamp event_timestamp_sub
        ,event_name,source1,source2,category1,category2,standard_order_date,purchase_date,source_amount_proportion,payment_price_usd
    from
    (
        select event_date,event_timestamp,user_pseudo_id,platform,country
             ,split(`dataintegration-265403.func`.getParams(event_params,'label').string_value,'%')[0] push_id
        from `dataintegration-265403.analytics.dwd_dzp_events_function`('2024-12-22', '2024-12-27', 'BeautyPlus', false)
        where event_name = 'notification_open'
            and (`dataintegration-265403.func`.getParams(event_params,'label').string_value like '%PUSH_98%'
                or `dataintegration-265403.func`.getParams(event_params,'label').string_value like '%PUSH_99%'
                or `dataintegration-265403.func`.getParams(event_params,'label').string_value like '%PUSH_100%'
                or `dataintegration-265403.func`.getParams(event_params,'label').string_value like '%PUSH_101%'
                or `dataintegration-265403.func`.getParams(event_params,'label').string_value like '%PUSH_102%'
                )
    ) a
    left join
    (
--         select event_date,event_timestamp,user_pseudo_id
--              ,`dataintegration-265403.func`.getParams(event_params,'source_click_position').string_value source_click_position
--              ,`dataintegration-265403.func`.getParams(event_params,'source_feature_content').string_value source_feature_content
--              ,`dataintegration-265403.func`.getParams(event_params,'pre_spm').string_value pre_spm
--         from `dataintegration-265403.analytics.dwd_dzp_events_function`('2024-12-02', '2024-12-02', 'BeautyPlus', false)
--         where event_name = 'page_event'
--             and `beautyplus-bc0ed.func.decodeSpmNew`(`beautyplus-bc0ed.func.getParams`(event_params,'cur_spm').string_value).page_id='1009'

        select date,event_timestamp,event_name,user_pseudo_id,source1,source2,a.category1,a.category2,standard_order_date,purchase_date,source_amount_proportion,payment_price_usd
        from `beautyplus-bc0ed.sub_dataset.ads_spm_trial_subscription_pre_v5_temp`,unnest(agg) a
        where date>='2024-12-22'
    ) b
    on b.event_timestamp-a.event_timestamp>=0 and b.event_timestamp-a.event_timestamp<=3600000000 and a.user_pseudo_id=b.user_pseudo_id
)
where ranks=1



