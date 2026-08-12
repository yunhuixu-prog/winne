-- 进入编辑页后，使用了哪个模块，这个模块使用了多少次
select concat(if(pv_tab1_edit_beauty_click_90 > 0, 'beauty,', '')
           , if(pv_tab1_edit_creative_click_90 > 0, 'creative,', '')
           , if(pv_tab1_edit_edit_click_90 > 0, 'edit,', '')
           , if(pv_tab1_edit_filter_click_90 > 0, 'filter,', '')
           , if(pv_tab1_edit_makeup_click_90 > 0, 'makeup,', '')
           , if(pv_tab1_edit_senioredit_click_90 > 0, 'senioredit', '')
       )
       ,count(1) uv,count(case when sub_365>0 then 1 end) sub_uv
from beautyplus-bc0ed.temp.dws_dz_his_split_final_user_behave_v
where date between '2023-01-01' and '2023-04-30'
and pv_tab0_edit_entry>0
group by 1
order by 1

-- 活跃时长和机型的关系(近7天需活跃，否则都没活跃，看不出来机型会不会影响活跃时长)
select model,phone_price
       ,count(1) uv
       ,count(case when sub_365>0 then 1 end) sub_uv
       ,round(sum(case when active_mins_7d>=0 then active_mins_7d else 0 end)/count(1),2) active_mins_7d_avg
from beautyplus-bc0ed.temp.dws_dz_his_split_final_user_behave
where date between '2023-01-01' and '2023-04-30' and active_mins_7d>0
group by 1,2
having count(1)>100000
order by 3 desc

-- 每天活跃时长和订阅率的关系
select case when active_days_7d=0 then 0
            when active_mins_7d/active_days_7d<=1/6 then 1
            when active_mins_7d/active_days_7d<=1/2 then 2
            when active_mins_7d/active_days_7d<=1 then 3
            when active_mins_7d/active_days_7d<=1.5 then 4
            when active_mins_7d/active_days_7d<=3 then 5
            when active_mins_7d/active_days_7d<=5 then 6
            when active_mins_7d/active_days_7d<=10 then 7
            when active_mins_7d/active_days_7d<=30 then 8
            when active_mins_7d/active_days_7d<=60 then 9
        else 91 end active_mins_per_day
       ,count(1) uv
       ,count(case when sub_365>0 then 1 end) sub_uv
from beautyplus-bc0ed.temp.dws_dz_his_split_final_user_behave
where date between '2023-01-01' and '2023-04-30'
group by 1
order by 1

-- 用户进入订阅页几次后会订阅(包括试用)(近7天)
select sub_page_enter_pv,count(distinct user_pseudo_id) uv,count(distinct case when sub_pv>0 then user_pseudo_id end) sub_uv
from
(
    select a.user_pseudo_id,count(a.event_timestamp) sub_page_enter_pv,count(b.event_timestamp) sub_pv
    from
    (
        SELECT date
            ,user_pseudo_id
            ,event_timestamp
        FROM `beautyplus-bc0ed.sub_dataset.dwd_oda_spm_uuid_five_page_temp`
        WHERE
            date between '2023-01-01' and '2023-04-30' and event_name IN ('page_event') AND cur_page IN ('订阅页','OnboardingPage订阅页')
        group by 1,2,3
    ) a
    left join
    (
        SELECT date
            ,user_pseudo_id
            ,event_timestamp
        FROM `beautyplus-bc0ed.sub_dataset.dwd_oda_spm_uuid_five_page_temp`
        WHERE
            date between '2023-01-01' and '2023-04-30' and event_name IN ('subscription_try_suc')
        group by 1,2,3
    ) b
    on a.user_pseudo_id=b.user_pseudo_id
    where (b.event_timestamp is null or a.event_timestamp<b.event_timestamp) and (b.date is null or a.date between date_sub(b.date, interval 6 day) and b.date)
    group by 1
)
group by 1
order by 1
;
select sub_page_enter_pv,count(distinct user_pseudo_id) sub_uv
from
(
    select a.user_pseudo_id,count(a.event_timestamp) sub_page_enter_pv,count(b.event_timestamp) sub_pv
    from
    (
        SELECT date
            ,user_pseudo_id
            ,event_timestamp
        FROM `beautyplus-bc0ed.sub_dataset.dwd_oda_spm_uuid_five_page_temp`
        WHERE
            date between '2022-12-24' and '2023-04-30' and event_name IN ('page_event') AND cur_page IN ('订阅页','OnboardingPage订阅页')
        group by 1,2,3
    ) a
    left join
    (
        SELECT date
            ,user_pseudo_id
            ,event_timestamp
        FROM `beautyplus-bc0ed.sub_dataset.dwd_oda_spm_uuid_five_page_temp`
        WHERE
            date between '2023-01-01' and '2023-04-30' and event_name IN ('subscription_try_suc')
        group by 1,2,3
    ) b
    on a.user_pseudo_id=b.user_pseudo_id
    where (b.event_timestamp is null or a.event_timestamp<b.event_timestamp) and (b.date is null or a.date between date_sub(b.date, interval 6 day) and b.date)
    group by 1
)
where sub_pv>0
group by 1
order by 1

-- 极端拍照的人数
select case when pv_tab0_edit_entry_30<=0 then 0
            when pv_tab0_edit_entry_30<=1 then 1
            when pv_tab0_edit_entry_30<=3 then 2
            when pv_tab0_edit_entry_30<=5 then 3
            when pv_tab0_edit_entry_30<=10 then 4
            when pv_tab0_edit_entry_30<=15 then 5
            when pv_tab0_edit_entry_30<=30 then 6
            when pv_tab0_edit_entry_30<=60 then 7
        else 8 end pv_tab0_edit_entry_30
       ,case when pv_tab0_selfie_entry_30<=0 then 0
            when pv_tab0_selfie_entry_30<=1 then 1
            when pv_tab0_selfie_entry_30<=3 then 2
            when pv_tab0_selfie_entry_30<=5 then 3
            when pv_tab0_selfie_entry_30<=10 then 4
            when pv_tab0_selfie_entry_30<=15 then 5
            when pv_tab0_selfie_entry_30<=30 then 6
            when pv_tab0_selfie_entry_30<=60 then 7
            when pv_tab0_selfie_entry_30<=100 then 8
        else 9 end pv_tab0_selfie_entry_30
       ,count(1) uv,count(case when sub_365>0 then 1 end) sub_uv
from beautyplus-bc0ed.temp.dws_dz_his_split_final_user_behave_v
where date between '2023-01-01' and '2023-04-30' and (pv_tab0_edit_entry_30>0 or pv_tab0_selfie_entry_30>0)
group by 1,2
order by 1,2

-- 进入拍照页后，使用了哪个模块，这个模块使用了多少次（区分新老用户，没啥差别不区分了）
select concat(if(pv_tab0_shoot_shoot_30 > 0, 'shoot,', '')
           , if(pv_tab1_shoot_filter_shoot_30 > 0, 'filter,', '')
           , if(pv_tab1_shoot_look_shoot_30 > 0, 'look,', '')
           , if(pv_tab1_shoot_makeup_shoot_30 > 0, 'makeup,', '')
           , if(pv_tab1_shoot_ar_shoot_30 > 0, 'ar,', '')
       )
       ,count(1) uv,count(case when sub_365>0 then 1 end) sub_uv
from beautyplus-bc0ed.temp.dws_dz_his_split_final_user_behave_v
where date between '2023-01-01' and '2023-04-30'
and pv_tab0_selfie_entry_30>0 --and install_days_type between 1 and 4
group by 1
order by 1

-- 平均活跃天弹窗次数与订阅率的关系
select
        case when active_days_30=0 then '0: 0 days'
            when active_days_30<=1 then '1: 1 days'
            when active_days_30<=2 then '2: 2 days'
            when active_days_30<=3 then '3: 3 days'
            when active_days_30<=5 then '4: 4-5 days'
            when active_days_30<=10 then '5: 6-10 days'
        else '6: 11- days' end active_days_30_type
        ,case when active_days_30=0 then '0:no active'
            when pop_exposure_30/active_days_30<=0 then '1: 0 pop'
            when pop_exposure_30/active_days_30<=0.5 then '2: less than 0.5 pop per active day'
            when pop_exposure_30/active_days_30<=1 then '3: 0.5-1 pop per active day'
            when pop_exposure_30/active_days_30<=1.5 then '4: 1-1.5 pop per active day'
            when pop_exposure_30/active_days_30<=2 then '5: 1.5-2 pop per active day'
        else '6: more than 2 pop per active day' end pop_exposure_30_per_day
       ,count(1) uv,count(case when sub_365>0 then 1 end) sub_uv
from beautyplus-bc0ed.temp.dws_dz_his_split_final_user_behave_v
where date between '2023-01-01' and '2023-04-30'
and install_days_type between 1 and 4 and active_days_30>0
group by 1,2
order by 1,2
;


-- airbrush
-- 进入编辑页后（默认进入美颜编辑页），使用了哪个模块，这个模块使用了多少次
-- select concat(if(pv_edit_use_Retouch_all_30 > 0, 'retouch,', '')
--            , if(pv_edit_use_Filter_all_30 > 0, 'filter,', '')
--            , if(pv_edit_use_Makeup_all_30 > 0, 'makeup,', '')
--            , if(pv_edit_use_Hair_all_30 > 0, 'hair,', '')
--            , if(pv_edit_use_Tools_all_30 > 0, 'tools,', '')
--            , if(pv_edit_use_AI_Style_all_30 > 0, 'ai_style,', '')
--            , if(pv_edit_use_Creative_all_30 > 0, 'creative,', '')
--            , if(pv_edit_use_Presets_all_30 > 0, 'presets,', '')
--        ) function
--        ,count(1) uv,0 t,count(case when sub_365>0 then 1 end) sub_uv
-- from airbrush-1324.temp.dws_dz_his_split_final_user_behave_v
-- where date between '2023-01-01' and '2023-04-30'
-- and pv_edit_enter_all_all_30>0 --and pv_edit_enter_all_all_30<=100
-- group by 1
-- order by 1
-- ;
select concat(if(pv_edit_enter_Filter_all_30 > 0, 'filter,', '')
           , if(pv_edit_enter_Makeup_all_30 > 0, 'makeup,', '')
           , if(pv_edit_enter_Hair_all_30 > 0, 'hair,', '')
           , if(pv_edit_enter_Tools_all_30 > 0, 'tools,', '')
           , if(pv_edit_enter_AI_Style_all_30 > 0, 'ai_style,', '')
           , if(pv_edit_enter_Creative_all_30 > 0, 'creative,', '')
           , if(pv_edit_enter_Presets_all_30 > 0, 'presets,', '')
       ) function
       ,count(1) uv,0 t,count(case when sub_365>0 then 1 end) sub_uv
from airbrush-1324.temp.dws_dz_his_split_final_user_behave_v
where date between '2023-01-01' and '2023-04-30'
and pv_edit_enter_all_all_30>0 --and pv_edit_enter_all_all_30<=100
group by 1
order by 1
;
select concat(if(pv_edit_enter_Retouch_Reshape > 0, 'reshape,', '')
           , if(pv_edit_enter_Retouch_Smooth > 0, 'smooth,', '')
           , if(pv_edit_enter_Retouch_Magic > 0, 'magic,', '')
           , if(pv_edit_enter_Retouch_Acne > 0, 'acne,', '')
           , if(pv_edit_enter_Retouch_Sculpt > 0, 'sculpt,', '')
           , if(pv_edit_enter_Retouch_SkinTone > 0, 'skintone,', '')
       ) function
       ,count(1) uv,0 t,count(case when sub_365>0 then 1 end) sub_uv
from airbrush-1324.temp.dws_dz_his_split_final_user_behave_v
where date between '2023-01-01' and '2023-04-30'
and pv_edit_enter_Retouch_all>0
group by 1
order by 1
;

-- 进入订阅页次数
-- 进入订阅页中各进入方式的比例
select case when install_days_type between 1 and 4 then 'new' else 'old' end is_new
        ,case when sub_page_enter_30<=1 then '1: <=1 sub enter'
            when sub_page_enter_30<=3 then '2: <=3 sub enter'
            when sub_page_enter_30<=5 then '3: <=5 sub enter'
            when sub_page_enter_30<=10 then '4: <=10 sub enter'
            when sub_page_enter_30<=50 then '5: <=50 sub enter'
        else '6: >50 sub enter' end sub_page_enter_30_type
        ,case when other_sub_page_enter_30<=1 then '1: <=1 other sub enter'
            when other_sub_page_enter_30<=3 then '2: <=3 other sub enter'
            when other_sub_page_enter_30<=5 then '3: <=5 other sub enter'
            when other_sub_page_enter_30<=10 then '4: <=10 other sub enter'
            when other_sub_page_enter_30<=50 then '5: <=50 other sub enter'
        else '6: >50 other sub enter' end other_sub_page_enter_30_type
        ,case when force_sub_page_enter_30<=1 then '1: <=1 force sub enter'
            when force_sub_page_enter_30<=3 then '2: <=3 force sub enter'
            when force_sub_page_enter_30<=5 then '3: <=5 force sub enter'
            when force_sub_page_enter_30<=10 then '4: <=10 force sub enter'
            when force_sub_page_enter_30<=50 then '5: <=50 force sub enter'
        else '6: >50 force sub enter' end force_sub_page_enter_30_type
       ,count(1) uv,count(case when sub_365>0 then 1 end) sub_uv
from airbrush-1324.temp.dws_dz_his_split_final_user_behave_v
where date between '2023-01-01' and '2023-04-30'
and active_days_30>0
group by 1,2,3,4
order by 1,2,3,4
;
select case when install_days_type between 1 and 4 then 'new' else 'old' end is_new
        ,case when sub_page_enter_30<=1 then '1: <=1 sub enter'
            when sub_page_enter_30<=3 then '2: <=3 sub enter'
            when sub_page_enter_30<=5 then '3: <=5 sub enter'
            when sub_page_enter_30<=10 then '4: <=10 sub enter'
            when sub_page_enter_30<=50 then '5: <=50 sub enter'
        else '6: >50 sub enter' end sub_page_enter_30_type
        ,sum(force_sub_page_enter_30)/sum(sub_page_enter_30) force_sub_page_enter_ratio_30
       ,count(1) uv,count(case when sub_365>0 then 1 end) sub_uv
from airbrush-1324.temp.dws_dz_his_split_final_user_behave_v
where date between '2023-01-01' and '2023-04-30'
and active_days_30>0
group by 1
order by 1
;

-- 修图进入到保存率和订阅率的关系
select case when install_days_type between 1 and 4 then 'new' else 'old' end is_new
        ,case when pv_edit_enter_all_all_30<=0 then '0：<=0 edit enter'
            when pv_edit_enter_all_all_30<=1 then '1：<=1 edit enter'
            when pv_edit_enter_all_all_30<=3 then '2：<=3 edit enter'
            when pv_edit_enter_all_all_30<=5 then '3：<=5 edit enter'
            when pv_edit_enter_all_all_30<=10 then '4：<=10 edit enter'
            when pv_edit_enter_all_all_30<=20 then '5：<=20 edit enter'
            when pv_edit_enter_all_all_30<=50 then '6：<=50 edit enter'
            when pv_edit_enter_all_all_30<=100 then '7：<=100 edit enter'
            when pv_edit_enter_all_all_30>100 then '8：>100 edit enter'
        end pv_edit_enter_30_type
        ,case when beauty_enter_to_save_ratio_30<=0.1 then '<=0.1'
            when beauty_enter_to_save_ratio_30<=0.2 then '<=0.2'
            when beauty_enter_to_save_ratio_30<=0.3 then '<=0.3'
            when beauty_enter_to_save_ratio_30<=0.4 then '<=0.4'
            when beauty_enter_to_save_ratio_30<=0.5 then '<=0.5'
            when beauty_enter_to_save_ratio_30<=0.6 then '<=0.6'
            when beauty_enter_to_save_ratio_30<=0.7 then '<=0.7'
            when beauty_enter_to_save_ratio_30<=0.8 then '<=0.8'
            when beauty_enter_to_save_ratio_30<=0.9 then '<=0.9'
            when beauty_enter_to_save_ratio_30<=1 then '<=1'
        end save_ratio_30_type
       ,count(1) uv,count(case when sub_365>0 then 1 end) sub_uv,round(count(case when sub_365>0 then 1 end)/count(1),4) sub_ratio
from airbrush-1324.temp.dws_dz_his_split_final_user_behave_v
where date between '2023-01-01' and '2023-06-30'
and active_days_30>0
group by 1,2,3
order by 1,2,3
;

-- 付费功能点击次数和订阅率的关系
select case when pay_function_click_pv_30<=0 then '0：<=0 click pay function'
            when pay_function_click_pv_30<=1 then '1：<=1 click pay function'
            when pay_function_click_pv_30<=3 then '2：<=3 click pay function'
            when pay_function_click_pv_30<=5 then '3：<=5 click pay function'
            when pay_function_click_pv_30<=10 then '4：<=10 click pay function'
            when pay_function_click_pv_30<=20 then '5：<=20 click pay function'
            when pay_function_click_pv_30<=50 then '6：<=50 click pay function'
            when pay_function_click_pv_30<=100 then '7：<=100 click pay function'
            when pay_function_click_pv_30>100 then '8：>100 click pay function'
        end pv_edit_enter_30_type
       ,count(1) uv,count(case when sub_365>0 then 1 end) sub_uv,round(count(case when sub_365>0 then 1 end)/count(1),4) sub_ratio
from airbrush-1324.temp.dws_dz_his_split_final_user_behave_v
where date between '2023-01-01' and '2023-06-30'
and active_days_30>0
group by 1
order by 1
;







-- 其他查数
-- 进入订阅页几次订阅分布
select *
from
(
    select a.user_pseudo_id,count(a.event_timestamp) sub_page_enter_pv,count(b.event_timestamp) sub_pv
    from
    (
        SELECT date
            ,user_pseudo_id
            ,event_timestamp
        FROM `beautyplus-bc0ed.sub_dataset.dwd_oda_spm_uuid_five_page_temp`
        WHERE
            date between '2022-12-24' and '2023-04-30' and event_name IN ('page_event') AND cur_page IN ('订阅页','OnboardingPage订阅页')
        group by 1,2,3
    ) a
    left join
    (
        SELECT date
            ,user_pseudo_id
            ,event_timestamp
        FROM `beautyplus-bc0ed.sub_dataset.dwd_oda_spm_uuid_five_page_temp`
        WHERE
            date between '2023-01-01' and '2023-04-30' and event_name IN ('subscription_try_suc')
        group by 1,2,3
    ) b
    on a.user_pseudo_id=b.user_pseudo_id
    where (b.event_timestamp is null or a.event_timestamp<b.event_timestamp) and (b.date is null or a.date between date_sub(b.date, interval 6 day) and b.date)
    group by 1
)
where sub_page_enter_pv=1 and sub_pv>0


SELECT date
            ,user_pseudo_id
            ,event_timestamp
            ,event_name
        FROM `beautyplus-bc0ed.sub_dataset.dwd_oda_spm_uuid_five_page_temp`
        WHERE
            date between '2022-12-24' and '2023-04-30'
            and
            (
                (event_name IN ('page_event') AND cur_page IN ('订阅页','OnboardingPage订阅页'))
                or event_name in ('subscription_try_suc','subscription_clk_try')
            )
        and user_pseudo_id='656A4FEF203C469D93D680218F731F69'
order by 3

-- 查看进入自拍和进入修图的数据分布
select case when pv_tab0_edit_entry_30<=0 then 0
            when pv_tab0_edit_entry_30<=1 then 1
            when pv_tab0_edit_entry_30<=3 then 2
            when pv_tab0_edit_entry_30<=5 then 3
            when pv_tab0_edit_entry_30<=10 then 4
            when pv_tab0_edit_entry_30<=15 then 5
            when pv_tab0_edit_entry_30<=30 then 6
            when pv_tab0_edit_entry_30<=60 then 7
        else 8 end pv_tab0_edit_entry_30
       ,count(1) uv,count(case when sub_365>0 then 1 end) sub_uv
from beautyplus-bc0ed.temp.dws_dz_his_split_final_user_behave_v
where date between '2023-01-01' and '2023-04-30'
group by 1
order by 1

select case when pv_tab0_selfie_entry_30<=0 then 0
            when pv_tab0_selfie_entry_30<=1 then 1
            when pv_tab0_selfie_entry_30<=3 then 2
            when pv_tab0_selfie_entry_30<=5 then 3
            when pv_tab0_selfie_entry_30<=10 then 4
            when pv_tab0_selfie_entry_30<=15 then 5
            when pv_tab0_selfie_entry_30<=30 then 6
            when pv_tab0_selfie_entry_30<=60 then 7
            when pv_tab0_selfie_entry_30<=100 then 8
        else 9 end pv_tab0_edit_entry_30
       ,count(1) uv,count(case when sub_365>0 then 1 end) sub_uv
from beautyplus-bc0ed.temp.dws_dz_his_split_final_user_behave_v
where date between '2023-01-01' and '2023-04-30'
group by 1
order by 1


select
avg(pv_edit_enter_Retouch_AI_Retouch) pv_edit_enter_Retouch_AI_Retouch,
avg(pv_edit_enter_Retouch_Acne) pv_edit_enter_Retouch_Acne,
avg(pv_edit_enter_Retouch_Align) pv_edit_enter_Retouch_Align,
avg(pv_edit_enter_Retouch_Brighten) pv_edit_enter_Retouch_Brighten,
avg(pv_edit_enter_Retouch_Contour) pv_edit_enter_Retouch_Contour,
avg(pv_edit_enter_Retouch_DarkCircles) pv_edit_enter_Retouch_DarkCircles,
avg(pv_edit_enter_Retouch_Details) pv_edit_enter_Retouch_Details,
avg(pv_edit_enter_Retouch_Firm) pv_edit_enter_Retouch_Firm,
avg(pv_edit_enter_Retouch_Foundation) pv_edit_enter_Retouch_Foundation,
avg(pv_edit_enter_Retouch_Highlighter) pv_edit_enter_Retouch_Highlighter,
avg(pv_edit_enter_Retouch_Iris) pv_edit_enter_Retouch_Iris,
avg(pv_edit_enter_Retouch_Magic) pv_edit_enter_Retouch_Magic,
avg(pv_edit_enter_Retouch_Matte) pv_edit_enter_Retouch_Matte,
avg(pv_edit_enter_Retouch_Reshape) pv_edit_enter_Retouch_Reshape,
avg(pv_edit_enter_Retouch_Resize) pv_edit_enter_Retouch_Resize,
avg(pv_edit_enter_Retouch_Sculpt) pv_edit_enter_Retouch_Sculpt,
avg(pv_edit_enter_Retouch_SkinTone) pv_edit_enter_Retouch_SkinTone,
avg(pv_edit_enter_Retouch_Smooth) pv_edit_enter_Retouch_Smooth,
avg(pv_edit_enter_Retouch_Texture) pv_edit_enter_Retouch_Texture,
avg(pv_edit_enter_Retouch_Whiten) pv_edit_enter_Retouch_Whiten
from airbrush-1324.temp.dws_dz_his_split_final_user_behave_v
where date between '2023-01-01' and '2023-04-30' and pv_edit_enter_Retouch_all>0


-- 机型价格分布
select case when phone_price<=0 or phone_price is null then '-1:null'
            when phone_price<=800 then '1:(0,800]'
            when phone_price<=1200 then '2:(800,1200]'
            when phone_price<=2000 then '3:(1200,2000]'
            when phone_price<=4000 then '4:(2000,4000]'
            when phone_price<=6000 then '5:(4000,6000]'
            when phone_price<=10000 then '6:(6000,10000]'
        else '7:(10000,)' end phone_price_level
       ,count(1) uv
       ,count(case when sub_365>0 then 1 end) sub_uv
from beautyplus-bc0ed.temp.dws_dz_his_split_final_user_behave
where date between '2023-01-01' and '2023-04-30'
group by 1
order by 1

