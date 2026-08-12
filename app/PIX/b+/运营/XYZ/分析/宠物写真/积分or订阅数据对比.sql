
DECLARE mDATE_START DATE DEFAULT '2024-10-29';
DECLARE mDATE_END DATE DEFAULT '2024-11-11';

-- drop table if exists `beautyplus-bc0ed.temp.temp_ai_pet_portrait_winni`;
-- create table if not exists `beautyplus-bc0ed.temp.temp_ai_pet_portrait_winni` as

delete from beautyplus-bc0ed.temp.temp_ai_pet_portrait_winni where event_date between mDATE_START and mDATE_END;
insert into beautyplus-bc0ed.temp.temp_ai_pet_portrait_winni

with
event_pre as
(
    select
        event_date
        ,platform
        ,country
        ,event_name
        ,func.getParams(event_params,'lang').string_value lang
        ,func.getParams(event_params,'project').string_value project
        ,func.getParams(event_params,'内容ID').string_value miniapp_content_id
        ,func.getParams(event_params,'page_id').string_value page_id
        ,func.getParams(event_params,'button_type').string_value button_type
        ,func.getParams(event_params,'theme_type').string_value theme_type
        ,func.getParams(event_params,'is_from_push').string_value is_from_push
        ,func.getParams(event_params,'from_page').string_value from_page
        ,func.getParams(event_params,'theme').string_value theme
        ,func.getParams(event_params,'url').string_value url
        ,func.getParams(event_params,'source').string_value source
        ,func.getParams(event_params,'credit_amount').string_value credit_amount
        ,func.getParams(event_params,'order_id').string_value order_id
        ,func.getUserprop(user_properties,'hwgid').string_value hwgid
        ,func.getUserprop(user_properties,'UserPaymentStatus').string_value is_pay
        ,user_pseudo_id
        ,count(1) pv
    from
        `dataintegration-265403.analytics.dwd_dzp_events_function`(cast(mDATE_START as string), cast(mDATE_END as string), 'beautyplus', false)
    where event_name in ('h5_page_event_bd','h5_page_button_clk_bd','h5_credit_consume_bd')
      and func.getParams(event_params,'project').string_value='AI_Pet_Portray'
    group by
        1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20
)
,
-- 取当天进入首页时的订阅状态
user_payment_status as
(
    select event_date,user_pseudo_id,min(case when is_pay in ('Paying') or is_pay is null then is_pay else 'Non-paying' end) is_pay
    from event_pre
    where event_name in ('h5_page_event_bd','h5_page_event') and page_id='home_page_view'
    group by 1,2
)

select
    e.event_date,e.from_page,e.platform,e.event_name,e.page_id,e.button_type
     ,e.theme,e.theme_type,e.source,e.order_id
     ,p.is_pay
     ,e.user_pseudo_id,e.hwgid
     ,sum(pv) pv
from
    event_pre e
join `dataintegration-265403.stat.stat_active_advice_detail_d` b on e.user_pseudo_id=b.user_pseudo_id and b.event_date_hk=event_date
left join user_payment_status p on e.user_pseudo_id=p.user_pseudo_id and p.event_date=e.event_date
where
    hwgid not in ('2612801374','2584503074','2602108161','2588980053','2564483745','2604748400','2605846472','2579895832','2581423417','2562134868','2574054426','2618205088','2576245389','2618941525','2613607104','2563982682','2619999455','2405592903','2602265058','2564972859','2522045495','2603262761','2568172418','2400777855','2550386417','2619110102','2619987882','2612303390','2526100843','2619988205','2576247682','2567417560','2620060278','2578336951','2605846496','2551444229','2621443191')
group by
    1,2,3,4,5,6,7,8,9,10,11,12,13
;

DECLARE mDATE_START DATE DEFAULT '2024-10-29';
DECLARE mDATE_END DATE DEFAULT '2024-11-11';

with
credit as
(
    select
        order_id
        ,credit_num
        ,payment_price_usd
    from
        `beautyplus-bc0ed.dwd.dwd_da_credit_credit_record`
    where
        record_type=2 -- 积分消耗
        and app_name='BeautyPlus'
        and event_date between mDATE_START and mDATE_END
        and credit_num>0
    group by
        1,2,3
)

select
    e.event_date,from_page,e.platform,e.is_pay
    ,case
            when event_name='h5_page_event_bd' and page_id='home_page_view' then '3 进入首页'
            when event_name='h5_page_event_bd' and page_id='pet_page_view' then '4 进入宠物选择页'
            when event_name='h5_page_event_bd' and page_id='guide_page_view' then '5 进入图片提示页'
            when event_name='h5_page_event_bd' and page_id='album_page_view' then '6-1 进入相册页'
            when event_name='h5_page_button_clk_bd' and button_type='upload' then '6-2 上传图片'
            when event_name='h5_page_button_clk_bd' and button_type='generate' then '7-1 点击生成效果'
            when event_name='h5_credit_consume_bd' then '7-1-1 生成任务成功'
            when event_name='h5_page_event_bd' and page_id='generated_page_view' then '8-1 进入生成记录页'

            when event_name='h5_page_button_clk_bd' and button_type='view' then '8-2 点击生成任务'
            when event_name='h5_page_button_clk_bd' and button_type in ('save_all','save','save_video') then '9 保存图片/视频'
            else event_name
            end ch_event_name
    -- ,page_id
    -- ,button_type
    -- ,theme
    ,count(distinct e.user_pseudo_id) uv
    ,sum(pv) pv
    ,0 value
from
    `beautyplus-bc0ed.temp.temp_ai_pet_portrait_winni` e
where event_date between mDATE_START and mDATE_END
group by
    1,2,3,4,5

union all

select
    e.event_date,from_page,e.platform,e.is_pay
    ,'7-1-2 积分消耗成功（不包括限免）' ch_event_name
    ,count(distinct e.user_pseudo_id) uv
    ,sum(pv) pv
    ,round(sum(payment_price_usd),2) value
from
    `beautyplus-bc0ed.temp.temp_ai_pet_portrait_winni` e,unnest(split(order_id,',')) k
    join credit c on k=c.order_id
where
    e.event_date between mDATE_START and mDATE_END
    and event_name in ('h5_credit_consume_bd')
group by
    1,2,3,4,5

union all

select
    date event_date,'All' from_page,platform,'Non-paying' is_pay
    ,case when event_name='page_event' then '7-2-1 sub_enter'
          when event_name in ('subscription_clk_try') then '7-2-2 sub_click'
    end ch_event_name
    ,count(distinct user_pseudo_id) uv
    ,count(1) pv
    ,0 value
from
    `beautyplus-bc0ed.sub_dataset.ads_spm_trial_subscription_pre_v5_abtest`
where
    date between mDATE_START and mDATE_END
    and event_name in ('page_event','subscription_clk_try')
    and source2='AI Pet Portraits'
group by 1,2,3,4,5

union all

select
    date event_date,'All' from_page,platform,'Non-paying' is_pay
    ,'7-2-3 sub_suc' ch_event_name
    ,count(distinct user_pseudo_id) uv
    ,count(1) pv
    ,0 value
from
    `beautyplus-bc0ed.sub_dataset.ads_spm_trial_subscription_pre_v5_abtest`
where
    date between mDATE_START and mDATE_END
    and event_name='subscription_try_suc'
    and standard_order_date is not null
    and source2='AI Pet Portraits'
group by 1,2,3,4,5

union all

select
    date event_date,'All' from_page,platform,'Non-paying' is_pay
    ,'7-2-4 sub_to_paid' ch_event_name
    ,count(distinct user_pseudo_id) uv
    ,count(1) pv
    ,round(sum(payment_price_usd),2) value
from
    `beautyplus-bc0ed.sub_dataset.ads_spm_trial_subscription_pre_v5_abtest`
where
    date between mDATE_START and mDATE_END
    and event_name='subscription_try_suc'
    and standard_order_date is not null
     and purchase_date is not null
    and source2='AI Pet Portraits'
group by 1,2,3,4,5



