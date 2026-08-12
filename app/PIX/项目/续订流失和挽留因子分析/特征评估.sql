-- 进入编辑页后，使用了哪个模块，这个模块使用了多少次
select concat(if(pv_tab1_edit_beauty_click > 0, 'beauty,', '')
           , if(pv_tab1_edit_creative_click > 0, 'creative,', '')
           , if(pv_tab1_edit_edit_click > 0, 'edit,', '')
           , if(pv_tab1_edit_filter_click > 0, 'filter,', '')
           , if(pv_tab1_edit_makeup_click > 0, 'makeup,', '')
           , if(pv_tab1_edit_senioredit_click > 0, 'senioredit', '')
       )
--        ,count(1) uv,count(case when is_cancell_future_1>0 then 1 end) cancel_uv
        ,count(1) uv,count(1) u,count(case when sub_7>0 then 1 end) sub_uv
-- from beautyplus-bc0ed.temp.renewal_order_loss_behave
-- where loss_type='loss af 1 day'
--     and pv_tab0_edit_entry>0
from beautyplus-bc0ed.temp.return_sub_behave_part
where pv_tab0_edit_entry>0
group by 1
order by 1

-- 滤镜点击数
select case when pv_tab1_edit_filter_click<=0 then 0
            when pv_tab1_edit_filter_click<=3 then 1
            when pv_tab1_edit_filter_click<=20 then 2
        else 3 end pv_tab1_edit_filter_click
       ,count(1) uv,count(case when is_cancell_future_1>0 then 1 end) cancel_uv
       ,round(count(case when is_cancell_future_1>0 then 1 end)/count(1),2) cancel_ratio
from beautyplus-bc0ed.temp.renewal_order_loss_behave
where loss_type='loss af 1 day'
group by 1
order by 1

-- 使用功能数
select case when function_num<=5 then 1
            when function_num<=10 then 2
            when function_num<=15 then 3
            when function_num<=30 then 4
            when function_num<=40 then 5
            when function_num<=50 then 6
        else 7 end function_num
       ,count(1) uv,count(case when is_cancell_future_1>0 then 1 end) cancel_uv
       ,round(count(case when is_cancell_future_1>0 then 1 end)/count(1),4) cancel_ratio
from beautyplus-bc0ed.temp.renewal_order_loss_behave
where loss_type='loss af 1 day'
group by 1
order by 1

select case when grow_function_num<0 then -1
            when grow_function_num<=3 then 1
            when grow_function_num<=10 then 2
            when grow_function_num<=30 then 3
            when grow_function_num<=50 then 4
        else 5 end grow_function_num
       ,count(1) uv,count(case when is_cancell_future_1>0 then 1 end) cancel_uv
       ,round(count(case when is_cancell_future_1>0 then 1 end)/count(1),4) cancel_ratio
from beautyplus-bc0ed.temp.renewal_order_loss_behave
where loss_type='loss af 1 day'
group by 1
order by 1

select grow_function_num
       ,count(1) uv,count(case when is_cancell_future_1>0 then 1 end) cancel_uv
       ,round(count(case when is_cancell_future_1>0 then 1 end)/count(1),4) cancel_ratio
from beautyplus-bc0ed.temp.renewal_order_loss_behave
where loss_type='loss af 1 day' and function_num between -30 and 30
group by 1
order by 1


-- 进入订阅页
select case when sub_page_enter<=0 then 0
            when sub_page_enter<=1 then 1
            when sub_page_enter<=3 then 2
            when sub_page_enter<=10 then 3
        else 4 end sub_page_enter
       ,count(1) uv,count(case when is_cancell_future_1>0 then 1 end) cancel_uv
       ,round(count(case when is_cancell_future_1>0 then 1 end)/count(1),4) cancel_ratio
from beautyplus-bc0ed.temp.renewal_order_loss_behave
where loss_type='loss af 1 day'
group by 1
order by 1

-- 付费功能/素材点击
select case when pay_function_click_pv<=0 then 0
            when pay_function_click_pv<=1 then 1
            when pay_function_click_pv<=3 then 2
            when pay_function_click_pv<=10 then 3
        else 4 end pay_function_click_pv
       ,count(1) uv,count(case when is_cancell_future_1>0 then 1 end) cancel_uv
       ,round(count(case when is_cancell_future_1>0 then 1 end)/count(1),4) cancel_ratio
from beautyplus-bc0ed.temp.renewal_order_loss_behave
where loss_type='loss af 1 day'
group by 1
order by 1

select case when pay_duffle_click_pv<=0 then 0
            when pay_duffle_click_pv<=10 then 1
            when pay_duffle_click_pv<=50 then 2
            when pay_duffle_click_pv<=100 then 3
        else 4 end pay_function_click_pv
       ,count(1) uv,count(case when is_cancell_future_1>0 then 1 end) cancel_uv
       ,round(count(case when is_cancell_future_1>0 then 1 end)/count(1),4) cancel_ratio
from beautyplus-bc0ed.temp.renewal_order_loss_behave
where loss_type='loss af 1 day'
group by 1
order by 1



-- ab进入编辑页
select concat(if(pv_edit_enter_Filter_all > 0, 'filter,', '')
           , if(pv_edit_enter_Makeup_all > 0, 'makeup,', '')
           , if(pv_edit_enter_Hair_all > 0, 'hair,', '')
           , if(pv_edit_enter_Tools_all > 0, 'tools,', '')
           , if(pv_edit_enter_AI_Style_all > 0, 'ai_style,', '')
           , if(pv_edit_enter_Creative_all > 0, 'creative,', '')
           , if(pv_edit_enter_Presets_all > 0, 'presets,', '')
       ) function
--        ,count(1) uv,count(case when is_cancell_future_1>0 then 1 end) cancel_uv
--        ,round(count(case when is_cancell_future_1>0 then 1 end)/count(1),4) cancel_ratio
        ,count(1) uv,count(1) u,count(case when sub_7>0 then 1 end) sub_uv
-- from airbrush-1324.temp.renewal_order_loss_behave
-- where loss_type='loss af 1 day'
-- and pv_edit_enter_all_all>0
from airbrush-1324.temp.return_sub_behave_part
where pv_edit_enter_all_all>0
group by 1
order by 1
;
select concat(if(pv_edit_enter_Retouch_Reshape > 0, 'reshape,', '')
           , if(pv_edit_enter_Retouch_Smooth > 0, 'smooth,', '')
           , if(pv_edit_enter_Retouch_Magic > 0, 'magic,', '')
           , if(pv_edit_enter_Retouch_Acne > 0, 'acne,', '')
           , if(pv_edit_enter_Retouch_Sculpt > 0, 'sculpt,', '')
           , if(pv_edit_enter_Retouch_SkinTone > 0, 'skintone,', '')
           , if(pv_edit_enter_Retouch_AI_Retouch > 0, 'airetouch,', '')
       ) function
--        ,count(1) uv,count(case when is_cancell_future_1>0 then 1 end) cancel_uv
--        ,round(count(case when is_cancell_future_1>0 then 1 end)/count(1),4) cancel_ratio
        ,count(1) uv,count(1) u,count(case when sub_7>0 then 1 end) sub_uv
-- from airbrush-1324.temp.renewal_order_loss_behave
-- where loss_type='loss af 1 day'
-- and pv_edit_enter_Retouch_all>0
from airbrush-1324.temp.return_sub_behave_part
where pv_edit_enter_Retouch_all>0
group by 1
order by 1
;
-- 分机型
select brand
       ,count(1) uv,count(case when is_cancell_future_1>0 then 1 end) cancel_uv
       ,round(count(case when is_cancell_future_1>0 then 1 end)/count(1),4) cancel_ratio
--         ,count(1) uv,count(1) u,count(case when sub_7>0 then 1 end) sub_uv
from airbrush-1324.temp.renewal_order_loss_behave
where loss_type='loss af 1 day'
-- from airbrush-1324.temp.return_sub_behave_part
group by 1
order by 1
;
-- 分平台
select platform,subscription_period
       ,count(1) uv,count(case when is_cancell_future_1>0 then 1 end) cancel_uv
       ,round(count(case when is_cancell_future_1>0 then 1 end)/count(1),4) cancel_ratio
--         ,count(1) uv,count(1) u,count(case when sub_7>0 then 1 end) sub_uv
from airbrush-1324.temp.renewal_order_loss_behave
where loss_type='loss af 1 day'
-- from airbrush-1324.temp.return_sub_behave_part
group by 1,2
order by 1,2
;


-- 订阅召回
-- 进入订阅页
select case when sub_page_enter<=0 then '0: 0 sub enter'
            when sub_page_enter<=1 then '1: <=1 sub enter'
            when sub_page_enter<=3 then '2: <=3 sub enter'
            when sub_page_enter<=5 then '3: <=5 sub enter'
            when sub_page_enter<=10 then '4: <=10 sub enter'
            when sub_page_enter<=50 then '5: <=50 sub enter'
        else '6: >50 sub enter' end sub_page_enter_type
        ,case when other_sub_page_enter<=0 then '0: 0 other sub enter'
            when other_sub_page_enter<=1 then '1: <=1 other sub enter'
            when other_sub_page_enter<=3 then '2: <=3 other sub enter'
            when other_sub_page_enter<=5 then '3: <=5 other sub enter'
            when other_sub_page_enter<=10 then '4: <=10 other sub enter'
            when other_sub_page_enter<=50 then '5: <=50 other sub enter'
        else '6: >50 other sub enter' end other_sub_page_enter_type
        ,case when force_sub_page_enter<=0 then '0: 0 force sub enter'
            when force_sub_page_enter<=1 then '1: <=1 force sub enter'
            when force_sub_page_enter<=3 then '2: <=3 force sub enter'
            when force_sub_page_enter<=5 then '3: <=5 force sub enter'
            when force_sub_page_enter<=10 then '4: <=10 force sub enter'
            when force_sub_page_enter<=50 then '5: <=50 force sub enter'
        else '6: >50 force sub enter' end force_sub_page_enter_30_type
       ,count(1) uv,count(case when sub_7>0 then 1 end) sub_uv
       ,round(count(case when sub_7>0 then 1 end)/count(1),4) sub_ratio
from beautyplus-bc0ed.temp.return_sub_behave_part
-- from airbrush-1324.temp.return_sub_behave_part
group by 1,2,3
order by 1,2,3
;


-- 首页各模块曝光
select case when homepage_exposure_pv<=0 then '0: 0 home enter'
            when homepage_exposure_pv<=1 then '1: <=1 home enter'
            when homepage_exposure_pv<=3 then '2: <=3 home enter'
            when homepage_exposure_pv<=5 then '3: <=5 home enter'
            when homepage_exposure_pv<=10 then '4: <=10 home enter'
            when homepage_exposure_pv<=50 then '5: <=50 home enter'
        else '6: >50 sub enter' end homepage_exposure_pv
        ,case when homepage_banner_show_pv<=0 then '0: 0 banner show'
            when homepage_banner_show_pv<=1 then '1: <=1 banner show'
            when homepage_banner_show_pv<=3 then '2: <=3 banner show'
            when homepage_banner_show_pv<=5 then '3: <=5 banner show'
            when homepage_banner_show_pv<=10 then '4: <=10 banner show'
            when homepage_banner_show_pv<=50 then '5: <=50 banner show'
        else '6: >50 other sub enter' end homepage_banner_show_pv
        ,case when homepage_topic_show_pv<=0 then '0: 0 topic show'
            when homepage_topic_show_pv<=1 then '1: <=1 topic show'
            when homepage_topic_show_pv<=3 then '2: <=3 topic show'
            when homepage_topic_show_pv<=5 then '3: <=5 topic show'
            when homepage_topic_show_pv<=10 then '4: <=10 topic show'
            when homepage_topic_show_pv<=50 then '5: <=50 topic show'
        else '6: >50 force sub enter' end homepage_topic_show_pv
--        ,count(1) uv,count(case when sub_7>0 then 1 end) sub_uv
--        ,round(count(case when sub_7>0 then 1 end)/count(1),4) sub_ratio
       ,count(1) uv,count(case when is_cancell_future_1>0 then 1 end) cancel_uv
       ,round(count(case when is_cancell_future_1>0 then 1 end)/count(1),4) cancel_ratio
-- from beautyplus-bc0ed.temp.return_sub_behave_part
-- from airbrush-1324.temp.return_sub_behave_part
-- where homepage_exposure_pv>0
from beautyplus-bc0ed.temp.renewal_order_loss_behave
-- from airbrush-1324.temp.renewal_order_loss_behave
where loss_type='loss af 1 day'
    and homepage_exposure_pv>0
group by 1,2,3
order by 1,2,3
;


-- 平均活跃天弹窗次数与订阅率的关系
select
        active_days_7d
        ,case when active_days_7d=0 then '0:no active'
            when pop_exposure/active_days_7d<=0 then '1: 0 pop'
            when pop_exposure/active_days_7d<=1 then '2: 1 pop per active day'
            when pop_exposure/active_days_7d<=3 then '3: 2-3 pop per active day'
            when pop_exposure/active_days_7d<=5 then '4: 4-5 pop per active day'
        else '6: more than 5 pop per active day' end pop_exposure_per_day
--        ,count(1) uv,count(case when sub_7>0 then 1 end) sub_uv
--        ,round(count(case when sub_7>0 then 1 end)/count(1),4) sub_ratio
       ,count(1) uv,count(case when is_cancell_future_1>0 then 1 end) cancel_uv
       ,round(count(case when is_cancell_future_1>0 then 1 end)/count(1),4) cancel_ratio
from beautyplus-bc0ed.temp.renewal_order_loss_behave
-- from airbrush-1324.temp.renewal_order_loss_behave
where loss_type='loss af 1 day'
    and active_days_7d>0
-- from beautyplus-bc0ed.temp.return_sub_behave_part
-- from airbrush-1324.temp.return_sub_behave_part
-- where active_days_7d>0
group by 1,2
order by 1,2
;
select
        case when pop_exposure<=0 then '1: 0 pop'
            when pop_exposure<=1 then '2: 1 pop per week'
            when pop_exposure<=3 then '3: 2-3 pop per week'
            when pop_exposure<=10 then '4: 4-10 pop per week'
        else '6: more than 10 pop per week' end pop_exposure_per_day
--        ,count(1) uv,count(case when sub_7>0 then 1 end) sub_uv
--        ,round(count(case when sub_7>0 then 1 end)/count(1),4) sub_ratio
       ,count(1) uv,count(case when is_cancell_future_1>0 then 1 end) cancel_uv
       ,round(count(case when is_cancell_future_1>0 then 1 end)/count(1),4) cancel_ratio
from beautyplus-bc0ed.temp.renewal_order_loss_behave
-- from airbrush-1324.temp.renewal_order_loss_behave
where loss_type='loss af 1 day'
    and active_days_7d>0
-- from beautyplus-bc0ed.temp.return_sub_behave_part
-- from airbrush-1324.temp.return_sub_behave_part
-- where active_days_7d>0
group by 1
order by 1
;


-- 修图进入到保存率
select
        case when beauty_enter_to_save_ratio<=0.1 then '1: 0 pop'
            when beauty_enter_to_save_ratio<=0.3 then '2: 1 pop per week'
            when beauty_enter_to_save_ratio<=0.5 then '3: 2-3 pop per week'
            when beauty_enter_to_save_ratio<=0.8 then '4: 4-10 pop per week'
        else '6: more than 10 pop per week' end pop_exposure_per_day
--        ,count(1) uv,count(case when sub_7>0 then 1 end) sub_uv
--        ,round(count(case when sub_7>0 then 1 end)/count(1),4) sub_ratio
       ,count(1) uv,count(case when is_cancell_future_1>0 then 1 end) cancel_uv
       ,round(count(case when is_cancell_future_1>0 then 1 end)/count(1),4) cancel_ratio
from beautyplus-bc0ed.temp.renewal_order_loss_behave
where loss_type='loss af 1 day'
    and pv_tab0_edit_entry>0
-- from beautyplus-bc0ed.temp.return_sub_behave_part
-- where pv_tab0_edit_entry>0
-- from airbrush-1324.temp.return_sub_behave_part
-- where pv_edit_enter_all_all>0
group by 1
order by 1
;

-- -- 拼图
-- select
--         case when puzzle_save_pv<=0 then '1: 0 pop'
--             when puzzle_save_pv<=1 then '2: 1 pop per week'
--             when puzzle_save_pv<=3 then '3: 2-3 pop per week'
--             when puzzle_save_pv<=10 then '4: 4-10 pop per week'
--         else '6: more than 10 pop per week' end pop_exposure_per_day
--        ,count(1) uv,count(case when sub_7>0 then 1 end) sub_uv
--        ,round(count(case when sub_7>0 then 1 end)/count(1),4) sub_ratio
-- from beautyplus-bc0ed.temp.return_sub_behave_part
-- -- from airbrush-1324.temp.return_sub_behave_part
-- where active_days_7d>0
-- group by 1
-- order by 1
-- ;



