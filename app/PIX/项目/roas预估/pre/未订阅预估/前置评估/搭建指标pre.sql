-- 功能指标维表 beautyplus-bc0ed.temp.dmi_da_class_is_pay
-- 素材标签维表 dataintegration-265403.duffle_fin.dmi_da_materials_info_v
-- 功能素材表 `beautyplus-bc0ed.event_dataset_4.dwd_dz_event_group_04`
-- duffle素材表 `dataintegration-265403.duffle.dwd_dz_material_events`
-- 用户维表
-- 用户画像表
-- 其他行为表
    -- AIGC `beautyplus-bc0ed.temp.dws_act_aigc_new`
    -- 弹窗 `beautyplus-bc0ed.content_data.dwd_dz_inapp_pop_event`
    -- 首页 `beautyplus-bc0ed.Duffle_dataset.dwd_home_module_position_new`
    -- 订阅页 `beautyplus-bc0ed.sub_dataset.ads_spm_trial_subscription_pre_v5_temp`
    -- 广告 `dataintegration-265403.dwd.dwd_dzp_advertisement_user_detail`

-- A：需要预测的的用户群体

select count(distinct a.AppsFlyer_ID),count(distinct s.AppsFlyer_ID),count(distinct s.user_pseudo_id),count(distinct s.uuid)
from `dataintegration-265403.roas_dataset.dwd_dz_af_ua_info` a
left join `dataintegration-265403.stat.stat_active_advice_detail_d` s  -- 这个少了很多，挺多关联不上的
    on s.app_name=a.App_Name
      AND s.platform=UPPER(a.Platform)
      AND s.AppsFlyer_ID=a.AppsFlyer_ID
      and s.event_date_hk=a.Attributed_Touch_Date
where a.App_Name='BeautyPlus' and a.Attributed_Touch_Date='2023-01-31'

select if(s.AppsFlyer_ID is null,'null','not null'),count(distinct a.AppsFlyer_ID)
    ,sum(case when b.standard_order_date < date_add(a.Attributed_Touch_Date,interval 1 year) and b.product='subscription' then b.payment_price_usd end)
from `dataintegration-265403.roas_dataset.dwd_dz_af_ua_info` a
left join `dataintegration-265403.stat.stat_active_advice_detail_d` s  -- 这个少了很多，挺多关联不上的
    on s.app_name=a.App_Name
      AND s.platform=UPPER(a.Platform)
      AND s.AppsFlyer_ID=a.AppsFlyer_ID
      and s.event_date_hk=a.Attributed_Touch_Date
join dataintegration-265403.temp.temp_roi_predict_sub_lable_pre b
        on b.app_id=a.App_Name
          AND b.platform=UPPER(a.Platform)
          AND b.AppsFlyer_ID=a.AppsFlyer_ID
where a.App_Name='BeautyPlus' and a.Attributed_Touch_Date='2023-01-31'
group by 1

with goal_users as
(
    select a.App_Name,UPPER(a.Platform) Platform,a.Attributed_Touch_Date,a.AppsFlyer_ID,s.user_pseudo_id,s.uuid
        ,max(case when country in ('United States','Japan','United Kingdom','South Korea','Thailand') then country else 'else' end) region  -- 换成全量表后可以再决定需不需要
    from `dataintegration-265403.roas_dataset.dwd_dz_af_ua_info` a
    join `dataintegration-265403.stat.stat_active_advice_detail_d` s  -- 后续变为用户id维表，注意时间要不要改
        on s.app_name=a.App_Name
          AND s.platform=UPPER(a.Platform)
          AND s.AppsFlyer_ID=a.AppsFlyer_ID
          and s.event_date_hk=a.Attributed_Touch_Date
    where a.App_Name='BeautyPlus' and a.Attributed_Touch_Date<='2024-01-31'
        and a.Attributed_Touch_Date>='2023-01-31'
    group by 1,2,3,4,5,6
)

    select a.Attributed_Touch_Date
--          ,a.AppsFlyer_ID
--          ,a.user_pseudo_id
        ,IFNULL(round(sum(case when b.standard_order_date < date_add(a.Attributed_Touch_Date,interval 1 year) and b.product='subscription' then b.payment_price_usd end),2),0.0) sub_revenue_365
    from goal_users a
    left join dataintegration-265403.temp.temp_roi_predict_sub_lable_pre b
        on b.app_id=a.App_Name
          AND b.platform=a.Platform
          AND b.AppsFlyer_ID=a.AppsFlyer_ID
          and b.uuid=a.uuid
    group by 1

-- B：核心行为指标

-- 如果缺失值过多，看看是哪些行为
select a.module,a.class,a.function,a.action,a.mark,count(distinct a.user_pseudo_id) uv,sum(a.pv) pv
from `beautyplus-bc0ed.event_dataset_4.dwd_dz_event_group_04` a
left join beautyplus-bc0ed.temp.dmi_da_class_is_pay b
on cast(a.mark as string)=b.mark0 and a.module=b.module0 and IFNULL(a.class,'-')=IFNULL(b.class0,'-') and IFNULL(a.function,'-')=IFNULL(b.fucntion0,'-')
where event_date between '2024-01-18' and '2024-01-31' and a.mark in (0,1,2)
and b.module0 is null
group by 1,2,3,4,5
order by 5,1,2,3,4


-- 选取目标行为指标，看各个行为指标分布情况
with behave_pre as
(
select a.mark, a.module, a.class, a.function
    , case when a.mark=0 and a.module ='修图' and a.event_name_cn='修图编辑页展示' then '进入'
            when a.mark=0 and a.module ='修图' and a.event_name_cn='修图保存' then '保存'
            when a.mark=0 and a.module ='修图' and a.event_name_cn='开始拼图点击' then '拼图点击'
            when a.mark=0 and a.module ='修图' and a.event_name_cn='拼图保存' then '拼图保存'
            when a.mark=0 and a.module ='拍摄' and a.event_name_cn='照片拍摄' then '拍摄'
            when a.mark=0 and a.module ='拍摄' and a.event_name_cn='照片保存' then '保存'
            when a.mark=0 and a.module ='电影' and a.event_name_cn='电影拍摄' then '拍摄'
            when a.mark=0 and a.module ='电影' and a.event_name_cn='电影保存' then '保存'
            when a.mark=0 and a.module ='自拍' and a.event_name_cn='自拍页展现' then '进入'
            when a.mark=0 and a.module ='视频' and a.event_name_cn='视频拍摄完成' then '拍摄'
            when a.mark=0 and a.module ='视频' and a.event_name_cn='视频保存' then '保存'
            else a.action
      end action
    , a.user_pseudo_id
    , a.pv
    , b.mark mark_c, b.module module_c, b.class class_c, b.function function_c, b.is_pay, b.is_function
from `beautyplus-bc0ed.event_dataset_4.dwd_dz_event_group_04` a
left join beautyplus-bc0ed.temp.dmi_da_class_is_pay b
on cast(a.mark as string)=b.mark0 and a.module=b.module0 and IFNULL(a.class,'-')=IFNULL(b.class0,'-') and IFNULL(a.function,'-')=IFNULL(b.fucntion0,'-')
where event_date between '2024-01-18' and '2024-01-31' and a.mark in (0, 1, 2)
)

select mark_c,module_c,class_c,function_c,action,count(distinct user_pseudo_id) uv,sum(pv) pv
from behave_pre
where mark_c is not null
group by 1,2,3,4,5
order by 1,2,3,4,5


-- 行为指标列名
with behave_pre as
(
select a.mark, a.module, a.class, a.function
    , case when a.mark=0 and a.module ='修图' and a.event_name_cn='修图编辑页展示' then '进入'
            when a.mark=0 and a.module ='修图' and a.event_name_cn='修图保存' then '保存'
            when a.mark=0 and a.module ='修图' and a.event_name_cn='开始拼图点击' then '拼图点击'
            when a.mark=0 and a.module ='修图' and a.event_name_cn='拼图保存' then '拼图保存'
            when a.mark=0 and a.module ='拍摄' and a.event_name_cn='照片拍摄' then '拍摄'
            when a.mark=0 and a.module ='拍摄' and a.event_name_cn='照片保存' then '保存'
            when a.mark=0 and a.module ='电影' and a.event_name_cn='电影拍摄' then '拍摄'
            when a.mark=0 and a.module ='电影' and a.event_name_cn='电影保存' then '保存'
            when a.mark=0 and a.module ='自拍' and a.event_name_cn='自拍页展现' then '进入'
            when a.mark=0 and a.module ='视频' and a.event_name_cn='视频拍摄完成' then '拍摄'
            when a.mark=0 and a.module ='视频' and a.event_name_cn='视频保存' then '保存'
            else a.action
      end action
    , a.user_pseudo_id
    , a.pv
    , b.mark mark_c, b.module module_c, b.class class_c, b.function function_c, b.is_pay, b.is_function
from `beautyplus-bc0ed.event_dataset_4.dwd_dz_event_group_04` a
left join beautyplus-bc0ed.temp.dmi_da_class_is_pay b
on cast(a.mark as string)=b.mark0 and a.module=b.module0 and IFNULL(a.class,'-')=IFNULL(b.class0,'-') and IFNULL(a.function,'-')=IFNULL(b.fucntion0,'-')
where event_date between '2024-01-18' and '2024-01-31' and a.mark in (0, 1, 2)
)

select distinct concat(mark_c,'级tab-',IFNULL(module_c,''),'-',IFNULL(class_c,''),'-',IFNULL(function_c,''),'-',action)
from behave_pre
where mark_c is not null and action in ('点击','进入','保存','拍摄')
order by 1


-- 统计指标用户使用素材/功能种类分布情况
with behave_pre as
(
select a.mark, a.module, a.class, a.function
    , case when a.mark=0 and a.module ='修图' and a.event_name_cn='修图编辑页展示' then '进入'
            when a.mark=0 and a.module ='修图' and a.event_name_cn='修图保存' then '保存'
            when a.mark=0 and a.module ='修图' and a.event_name_cn='开始拼图点击' then '拼图点击'
            when a.mark=0 and a.module ='修图' and a.event_name_cn='拼图保存' then '拼图保存'
            when a.mark=0 and a.module ='拍摄' and a.event_name_cn='照片拍摄' then '拍摄'
            when a.mark=0 and a.module ='拍摄' and a.event_name_cn='照片保存' then '保存'
            when a.mark=0 and a.module ='电影' and a.event_name_cn='电影拍摄' then '拍摄'
            when a.mark=0 and a.module ='电影' and a.event_name_cn='电影保存' then '保存'
            when a.mark=0 and a.module ='自拍' and a.event_name_cn='自拍页展现' then '进入'
            when a.mark=0 and a.module ='视频' and a.event_name_cn='视频拍摄完成' then '拍摄'
            when a.mark=0 and a.module ='视频' and a.event_name_cn='视频保存' then '保存'
            else a.action
      end action
    , a.user_pseudo_id
    , a.pv
    , b.mark mark_c, b.module module_c, b.class class_c, b.function function_c, b.is_pay, b.is_function
from `beautyplus-bc0ed.event_dataset_4.dwd_dz_event_group_04` a
left join beautyplus-bc0ed.temp.dmi_da_class_is_pay b
on cast(a.mark as string)=b.mark0 and a.module=b.module0 and IFNULL(a.class,'-')=IFNULL(b.class0,'-') and IFNULL(a.function,'-')=IFNULL(b.fucntion0,'-')
where event_date between '2024-01-18' and '2024-01-31' and a.mark in (0, 1, 2)
)

select function_num,count(distinct user_pseudo_id) user_num
from
(
    select user_pseudo_id,count(distinct function) function_num
    from behave_pre
    where mark=2 and action in ('点击','拍摄')
    group by 1
)
group by 1
order by 1


-- 检验
select count(1),count(distinct concat(user_pseudo_id,cast(Attributed_Touch_Date as string)))
from  beautyplus-bc0ed.temp.dws_dz_roi_predict_user_other_behave
where Attributed_Touch_Date='2023-01-31' and date='2024-01-31'

