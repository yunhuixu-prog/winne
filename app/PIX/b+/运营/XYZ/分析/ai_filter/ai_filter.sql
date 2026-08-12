-- B+AI

-- 首页miniapp的曝光量
-- 首页miniapp的点击量
-- 进入B+AI首页  home_page_view
-- 点击genetrated_items  genetrated_items
-- 进入生成记录页  generated_page_view
-- 进入好评弹窗  comment_popup_view


-- 付费照片
-- 点击首页照片主题卡片  upload & theme_type='photo' and is_bundle=1
-- 点击列表页照片主题卡片  list & theme_type='photo' and is_bundle=1
-- 进入bundle协议页1(首页点击bundle)  bundle_page_view1
-- 进入bundle协议页2(列表页点击bundle)  bundle_page_view2
-- 点击生成效果  uv generate & theme_type='photo' and is_bundle=1
-- 积分消耗人数&金额 h5_credit_consume_bd & source
-- 点击生成记录页单个item  view & theme_type='photo' and is_bundle=1
-- 进入bundle效果生成后的页面 bundle_make_page_view
-- 进入照片生成结果页 make_page_view
-- 点击保存单张图片或所有图片  save or save all & theme_type='photo'or'image' and is_bundle=1


-- 免费照片
-- 点击首页照片主题卡片  upload & theme_type='photo' and is_bundle=0
-- 进入免费照片协议页  confirm_page_view
-- 点击生成效果  generate & theme_type='photo' and is_bundle=0
-- 进入列表页(免费效果生成页) list_page_view
-- 点击保存单张图片  save & theme_type='photo' and is_bundle=0
-- 点击拼图  collage & theme_type='photo' and is_bundle=0
-- 点击列表页免费效果 list & theme_type='photo' and is_bundle=0


-- 视频
-- 点击视频主题卡片  upload & theme_type='video'
-- 进入video协议页 video_confirm_page_view
-- 点击生成效果  uv generate & theme_type='video'
-- 积分消耗人数&金额 h5_credit_consume_bd & source
-- 点击生成记录页单个item view & theme_type='video'
-- 进入视频效果生成后的页面 video_make_page_view
-- 点击生成页播放按钮 play & theme_type='video'
-- 点击保存视频  save & theme_type='video'



with event as
(
    select
        app_name
        ,event_date
        ,platform
        ,event_timestamp
        ,case when event_name in ('h5_page_event_bd','h5_page_event') then 'h5_page_event_bd'
              when event_name in ('h5_page_button_clk_bd','h5_page_button_clk') then 'h5_page_button_clk_bd'
              when event_name in ('h5_credit_consume_bd','h5_credit_consume') then 'h5_credit_consume_bd'
        end event_name
        ,event_params
        ,user_properties
        ,user_pseudo_id
        ,geo.country
    from
        `dataintegration-265403.analytics.dwd_dzp_events_function`('2024-05-30', '2024-06-12', 'beautyplus,airbrush', false)
    where
        event_name in ('h5_page_event_bd','h5_page_button_clk_bd','h5_credit_consume_bd','h5_page_event','h5_page_button_clk','h5_credit_consume')
)
,
event_pre as
(
    select
        app_name
        ,event_date
        ,platform
        ,country
        ,event_name
        ,func.getParams(event_params,'lang').string_value lang
        ,func.getParams(event_params,'project').string_value project
--         ,func.getParams(event_params,'内容ID').string_value miniapp_content_id
        ,func.getParams(event_params,'page_id').string_value page_id
        ,func.getParams(event_params,'button_type').string_value button_type
--         ,func.getParams(event_params,'is_from_push').string_value is_from_push
        ,func.getParams(event_params,'theme').string_value theme
        ,func.getParams(event_params,'theme_type').string_value theme_type
        ,coalesce(`dataintegration-265403.func`.getParams(event_params,'is_bundle').string_value,cast(`dataintegration-265403.func`.getParams(event_params,'is_bundle').int_value as string)) as is_bundle
        ,coalesce(`dataintegration-265403.func`.getParams(event_params,'is_pay').string_value,cast(`dataintegration-265403.func`.getParams(event_params,'is_pay').int_value as string)) as is_pay
        ,func.getParams(event_params,'source').string_value source
        ,cast(func.getParams(event_params,'credit_amount').string_value as int64) credit_amount
        ,func.getParams(event_params,'order_id').string_value order_id
        ,func.getUserprop(user_properties,'hwgid').string_value hwgid
        ,func.getUserprop(user_properties,'UserPaymentStatus').string_value sub_status
        ,user_pseudo_id
        ,count(1) pv
    from
        event
    where
        case    when event_name in ('h5_page_event_bd','h5_page_button_clk_bd','h5_credit_consume_bd') then func.getParams(event_params,'project').string_value='ai_filter'
                else 1=1
                end
    group by
        1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19
)
,
-- 取当天进入首页时的订阅状态
user_payment_status as
(
    select app_name,event_date,user_pseudo_id,min(case when sub_status in ('Paying') or sub_status is null then sub_status else 'Non-paying' end) sub_status
    from event_pre
    where event_name in ('h5_page_event_bd','h5_page_event') and page_id='home_page_view'
    group by 1,2,3
)

select
    e.app_name
    ,e.event_date
    ,p.sub_status
    ,case   when event_name='h5_page_event_bd' and page_id='home_page_view' then '0-3 进入miniapp首页'
            when event_name='h5_page_button_clk_bd' and button_type='generated_items' then '0-4 点击generated_items'
            when event_name='h5_page_event_bd' and page_id='generated_page_view' then '0-5 进入生成记录页'
            when event_name='h5_page_event_bd' and page_id='comment_popup_view' then '0-6 进入好评弹窗'

            when event_name='h5_page_button_clk_bd' and button_type='upload' and theme_type='photo' and is_bundle='1' then '1-1 点击首页付费包主题卡片'
            when event_name='h5_page_button_clk_bd' and button_type='list' and theme_type='photo' and is_bundle='1' then '1-1 点击列表页付费包主题卡片'
            when event_name='h5_page_event_bd' and page_id='bundle_page_view1' then '1-2 进入bundle协议页1(首页点击bundle)'
            when event_name='h5_page_event_bd' and page_id='bundle_page_view2' then '1-2 进入bundle协议页2(列表页点击bundle)'
            when event_name='h5_page_button_clk_bd' and button_type='zero_generate' and theme_type='photo' and is_bundle='1' then '1-3 订阅用户点击生成-付费包'
            when event_name='h5_page_button_clk_bd' and button_type='non_zero_generate' and theme_type='photo' and is_bundle='1' then '1-3 非订阅用户点击消耗积分生成-付费包'
            when event_name='h5_page_button_clk_bd' and button_type='go_to_sub' and theme_type='photo' and is_bundle='1' then '1-3 非订阅用户点击去订阅免费生成-付费包'
            when event_name='h5_credit_consume_bd' and theme_type='photo' and credit_amount>0 then '1-4 付费积分消耗-付费包'
            when event_name='h5_credit_consume_bd' and theme_type='photo' and credit_amount=0 then '1-4 免费积分消耗-付费包'
            when event_name='h5_page_button_clk_bd' and button_type='view' and theme_type='photo' then '1-5 点击生成记录页单个item-付费包'
            when event_name='h5_page_event_bd' and page_id='bundle_make_page_view' then '1-6 进入bundle效果生成后的页面'
            when event_name='h5_page_event_bd' and page_id='make_page_view' then '1-7 进入照片生成结果页-付费包'
            when event_name='h5_page_button_clk_bd' and (button_type='save' or button_type='save_all') and theme_type='photo' and (is_bundle is null or is_bundle='1') then '1-8 点击保存单张或所有图片-付费照片'
            when event_name='h5_page_button_clk_bd' and button_type='share' and theme_type='photo' and is_bundle='1' then '1-9 点击分享-付费包'

            when event_name='h5_page_button_clk_bd' and button_type='upload' and theme_type='photo' and is_bundle='0' then '2-1 点击首页免费照片主题卡片'
            when event_name='h5_page_event_bd' and page_id='confirm_page_view' and theme_type='photo' then '2-2 进入免费照片协议页'
            when event_name='h5_page_button_clk_bd' and button_type='zero_generate' and theme_type='photo' and is_bundle='0' then '2-3 点击生成-免费照片'
            when event_name='h5_page_event_bd' and page_id='list_page_view' then '2-4 进入免费照片生成页(列表页)'
            when event_name='h5_page_button_clk_bd' and (button_type='save' or button_type='save_all') and theme_type='photo' and is_bundle='0' then '2-5 点击保存图片-免费照片'
            when event_name='h5_page_button_clk_bd' and button_type='collage' and theme_type='photo' and is_bundle='0' then '2-6 点击去拼图-免费照片'
            when event_name='h5_page_button_clk_bd' and button_type='list' and theme_type='photo' and is_bundle='0' then '2-7 点击列表页免费照片主题卡片'
            when event_name='h5_page_button_clk_bd' and button_type='share' and theme_type='photo' and is_bundle='0' then '2-8 点击分享-免费照片'

--             when event_name='h5_page_button_clk_bd' and button_type='upload' and theme_type='video' then '3-1 点击视频主题卡片'
--             when event_name='h5_page_event_bd' and (page_id='video_confirm_page_view' or (page_id='confirm_page_view' and theme_type='video')) then '3-2 进入视频协议页'
--             when event_name='h5_page_button_clk_bd' and button_type='zero_generate' and theme_type='video' then '3-3 订阅用户点击生成付费视频或所有用户点击生成免费视频'
--             when event_name='h5_page_button_clk_bd' and button_type='non_zero_generate' and theme_type='video' then '3-3 非订阅用户点击消耗积分生成-视频'
--             when event_name='h5_page_button_clk_bd' and button_type='go_to_sub' and theme_type='video' then '3-3 非订阅用户点击去订阅免费生成-视频'
--             when event_name='h5_credit_consume_bd' and theme_type='video' and credit_amount>0 then '3-4 付费积分消耗-视频'
--             when event_name='h5_credit_consume_bd' and theme_type='video' and credit_amount=0 then '3-4 免费积分消耗-视频'

            when event_name='h5_page_button_clk_bd' and button_type='upload' and theme_type='video' and (is_pay is null or is_pay='1') then '3-1 点击付费视频主题卡片'
            when event_name='h5_page_event_bd' and page_id='video_confirm_page_view' and theme_type='video' then '3-2 进入付费视频协议页'
            when event_name='h5_page_button_clk_bd' and button_type='zero_generate' and theme_type='video' and (is_pay is null or is_pay='1') then '3-3 订阅用户点击生成-付费视频'
            when event_name='h5_page_button_clk_bd' and button_type='non_zero_generate' and theme_type='video' and (is_pay is null or is_pay='1') then '3-3 非订阅用户点击消耗积分生成-付费视频'
            when event_name='h5_page_button_clk_bd' and button_type='go_to_sub' and theme_type='video' and (is_pay is null or is_pay='1') then '3-3 非订阅用户点击去订阅免费生成-付费视频'
            when event_name='h5_credit_consume_bd' and theme_type='video' and credit_amount>0 then '3-4 付费积分消耗-付费视频'
            when event_name='h5_credit_consume_bd' and theme_type='video' and credit_amount=0 then '3-4 免费积分消耗-付费视频'

            when event_name='h5_page_button_clk_bd' and button_type='upload' and theme_type='video' and is_pay='0' then '4-1 点击免费视频主题卡片'
            when event_name='h5_page_event_bd' and page_id='confirm_page_view' and theme_type='video' then '4-2 进入免费视频协议页'
            when event_name='h5_page_button_clk_bd' and button_type='zero_generate' and theme_type='video' and is_pay='0' then '4-3 点击生成-免费视频'

            when event_name='h5_page_button_clk_bd' and button_type='view' and theme_type='video' then '3/4-5 点击生成记录页单个item-所有视频'
            when event_name='h5_page_button_clk_bd' and button_type='play' and theme_type='video' then '3/4-6 点击播放按钮-所有视频'
            when event_name='h5_page_button_clk_bd' and button_type='edit' and theme_type='video' then '3/4-7 点击跳转到视频编辑器按钮-所有视频'
            when event_name='h5_page_button_clk_bd' and (button_type='save' or button_type='save_all') and theme_type='video' then '3/4-8 点击保存-所有视频'
            when event_name='h5_page_button_clk_bd' and button_type='share' and theme_type='video' then '3/4-9 点击分享-所有视频'

--             when event_name='h5_page_button_clk_bd' and button_type='view' and theme_type='video' and (is_pay is null or is_pay='1') then '3-5 点击生成记录页单个item-付费视频'
--             when event_name='h5_page_button_clk_bd' and button_type='play' and theme_type='video' and (is_pay is null or is_pay='1') then '3-6 点击播放按钮-付费视频'
--             when event_name='h5_page_button_clk_bd' and button_type='edit' and theme_type='video' and (is_pay is null or is_pay='1') then '3-7 点击跳转到视频编辑器按钮-付费视频'
--             when event_name='h5_page_button_clk_bd' and (button_type='save' or button_type='save_all') and theme_type='video' and (is_pay is null or is_pay='1') then '3-8 点击保存付费视频'
--             when event_name='h5_page_button_clk_bd' and button_type='share' and theme_type='video' and (is_pay is null or is_pay='1') then '3-9 点击分享-付费视频'
--

--             when event_name='h5_page_button_clk_bd' and button_type='view' and theme_type='video' and is_pay='0' then '4-5 点击生成记录页单个item-免费视频' -- 没
--             when event_name='h5_page_button_clk_bd' and button_type='play' and theme_type='video' and is_pay='0' then '4-6 点击播放按钮-免费视频' -- 没
--             when event_name='h5_page_button_clk_bd' and button_type='edit' and theme_type='video' and is_pay='0' then '4-7 点击跳转到视频编辑器按钮-免费视频' -- 没
--             when event_name='h5_page_button_clk_bd' and (button_type='save' or button_type='save_all') and theme_type='video' and is_pay='0' then '4-8 点击保存免费视频' -- 没
--             when event_name='h5_page_button_clk_bd' and button_type='share' and theme_type='video' and is_pay='0' then '4-9 点击分享-免费视频'

            else event_name
            end ch_event_name
    ,project
    -- ,page_id
    -- ,button_type
    -- ,theme
    ,count(distinct e.user_pseudo_id) uv
    ,sum(pv) pv
from
    event_pre e
    join `dataintegration-265403.stat.stat_active_advice_detail_d` b on e.user_pseudo_id=b.user_pseudo_id and b.event_date_hk=event_date and e.app_name=b.app_name
    left join user_payment_status p on e.user_pseudo_id=p.user_pseudo_id and p.event_date=e.event_date and e.app_name=p.app_name
where
    hwgid not in ('2612801374','2584503074','2602108161','2588980053','2564483745','2604748400','2605846472','2579895832','2581423417','2562134868','2574054426','2618205088','2576245389','2618941525','2613607104','2563982682','2619999455','2405592903','2602265058','2564972859','2522045495','2603262761','2568172418','2400777855','2550386417','2619110102','2619987882','2612303390','2526100843','2619988205','2576247682','2567417560','2620060278','2578336951','2605846496','2551444229','2621443191','2474249969','2622802284','2597210926')
group by
    1,2,3,4,5
;


-- 积分消耗
--aigc积分
with credit as
(
    select
        app_name
        ,order_id
        ,credit_num
        ,payment_price_usd
    from
        `beautyplus-bc0ed.dwd.dwd_da_credit_credit_record`
    where
        record_type=2 -- 积分消耗
        and app_name='BeautyPlus'
        and event_date>='2024-05-30'
    group by
        1,2,3,4

    union all

    select
        app_name
        ,order_id
        ,credits credit_num
        ,payment_price_usd
    from
        `airbrush-1324.dwd.dwd_da_credit_detail`
    where
        record_type=2 -- 积分消耗
        and app_name in ('AirBrush')
        and event_date>='2024-05-30'
    group by
        1,2,3,4
)
,
event as
(
    select
        app_name
        ,event_date
        ,platform
        ,event_timestamp
        ,event_name
        ,event_params
        ,user_properties
        ,user_pseudo_id
        ,geo.country
    from
        `dataintegration-265403.analytics.dwd_dzp_events_function`('2024-05-30', '2024-06-12', 'beautyplus,airbrush', false)
    where
        event_name in ('h5_credit_consume_bd','h5_credit_consume')
)
,
EVENT1 as
(
    select
        app_name
        ,event_date
        ,func.getParams(event_params,'project').string_value as project
        ,func.getParams(event_params,'lang').string_value lang
        ,func.getParams(event_params,'theme_type').string_value theme_type
        ,func.getParams(event_params,'theme').string_value theme
        ,k order_id
        ,user_pseudo_id
        ,count(1) as pv
    from
        event,unnest(split(func.getParams(event_params,'order_id').string_value,',')) k
    where
        event_name in ('h5_credit_consume_bd','h5_credit_consume')
        and func.getParams(event_params,'project').string_value in ('ai_filter')
    group by
        1,2,3,4,5,6,7,8
)

select
    a.app_name
    ,event_date date
    -- ,case   when project='ai_filter' then 'B+ AI'
    --         else project
    --         end function
    -- ,platform
    -- ,case when is_new=1 then 'New-user' else 'Old-user' end as is_new
    -- ,country
    -- ,is_UA
    -- ,a.user_pseudo_id
    ,count(distinct a.user_pseudo_id) uv
    ,sum(pv) pv
    ,sum(credit_num) credit_num
    ,round(sum(payment_price_usd),2) payment_price_usd
from
    EVENT1 a
    join
    (
      select distinct app_name,event_date_hk,user_pseudo_id
      from `dataintegration-265403.stat.stat_active_advice_detail_d`
      where event_date_hk>='2024-05-30'
    ) b
    on a.user_pseudo_id=b.user_pseudo_id and b.event_date_hk =event_date and a.app_name=b.app_name
    join credit c on a.order_id=c.order_id
group by
    1,2 --,4,5,6,7
order by 1,2
;

select app_name,theme,sum(generate_success_uv) generate_success_uv,sum(credit_use_uv) credit_use_uv
     ,sum(sub_uv) sub_uv,sum(sub_pay_uv) sub_pay_uv,sum(sub_revenue) sub_revenue
from
(
    select app_name
            ,func.getParams(event_params,'theme').string_value theme
--             ,func.getParams(event_params,'theme_type').string_value theme_type
--             ,func.getParams(event_params,'is_bundle').string_value is_bundle
            ,count(distinct user_pseudo_id) generate_success_uv
            ,count(distinct case when cast(func.getParams(event_params,'credit_amount').string_value as int64)>0 then user_pseudo_id end) credit_use_uv
            ,0 sub_uv
            ,0 sub_pay_uv
            ,0 sub_revenue
    from `dataintegration-265403.analytics.dwd_dzp_events_function`('2024-05-30', '2024-06-12', 'beautyplus,airbrush', false)
    where func.getParams(event_params,'project').string_value='ai_filter'
        and (event_name in ('h5_credit_consume_bd', 'h5_credit_consume') or (event_name in ('h5_page_button_clk_bd','h5_page_button_clk')
            and func.getParams(event_params,'button_type').string_value in ('zero_generate','list')
            and func.getParams(event_params,'theme_type').string_value='photo'
--             and func.getParams(event_params,'is_bundle').string_value='0'
            and coalesce(func.getParams(event_params,'is_bundle').string_value,cast(func.getParams(event_params,'is_bundle').int_value as string))='0'
            )
        )
    group by 1,2

    union all

    select 'BeautyPlus' app_name,e.theme
        ,0 generate_success_uv
        ,0 credit_use_uv
        ,count(distinct original_order_id) sub_uv
        ,count(distinct case when purchase_date is not null then original_order_id end) sub_pay_uv
        ,round(sum(case when purchase_date is not null then payment_price_usd end),2) sub_revenue
    from
    (
        select *
            ,case when source2_1 in (select distinct Bp_sub_name from `dataintegration-265403.temp.dwd_da_miniapp_miniapp_name_mapping`) then source2_1
                else source2_2
            end source2
            ,case when source2_1 in (select distinct Bp_sub_name from `dataintegration-265403.temp.dwd_da_miniapp_miniapp_name_mapping`) then source2_2
                else source2_1
            end theme
        from
        (
            select
                'BeautyPlus' app_name
                ,date
                ,platform
                ,country
                ,cur_page_type
                ,source1
                ,split(source2,'+')[0] source2_1
                ,if(ARRAY_LENGTH(split(source2,'+'))>=2,split(source2,'+')[1],null) source2_2
                ,user_pseudo_id
                ,original_order_id
                ,sku_type
                ,sku_has_trial
                ,purchase_date
                ,payment_price_usd
            from
                `beautyplus-bc0ed.sub_dataset.ads_spm_trial_subscription_pre_v5_abtest`
            where
                standard_order_date between '2024-05-30' and '2024-06-12'
                and event_name='subscription_try_suc'
                and standard_order_date is not null
                and source2 like '%ai_filter%'
        )
    ) e
    group by 1,2

    union all

    select 'AirBrush' app_name
    --         ,event_date date
    --         ,second
            ,third theme -- 主题
    --         ,platform
    --         ,case when is_new='New' then 1 else 0 end is_new
    --         ,country
    --         ,is_ua
            ,0 generate_success_uv
            ,0 credit_use_uv
            ,sum(sub_success_uv) sub_uv
            ,sum(sub_to_paid_uv) sub_pay_uv
            ,round(sum(sub_to_paid_revenue_sub),2) sub_revenue
    from airbrush-1324.stat.dws_airbrush_trial_sub_grads_view
    where event_date between '2024-05-30' and '2024-06-12'
        and fourth='A' and third not in ('A','all','-') and third is not null
                and second = 'ai_filter'
        and sale_status not in ('credit')
    group by 1,2
)
group by 1,2



