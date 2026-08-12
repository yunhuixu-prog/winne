-- beautyplus-bc0ed.temp.dws_dz_roi_predict_first_week_user_behave
-- -- 初始化
-- DECLARE mDATE DATE DEFAULT '2023-01-01';
-- drop table if exists beautyplus-bc0ed.temp.dws_dz_roi_predict_first_week_user_behave;
-- create table beautyplus-bc0ed.temp.dws_dz_roi_predict_first_week_user_behave as

-- 非初始化
DECLARE mDATE_START DATE DEFAULT '{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=7)).strftime("%Y-%m-%d") }}';
DECLARE mDATE_END DATE DEFAULT '{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=0)).strftime("%Y-%m-%d") }}';
DECLARE mDATE DATE DEFAULT mDATE_START;

WHILE mDATE >= mDATE_START AND mDATE <= mDATE_END DO

delete from beautyplus-bc0ed.temp.dws_dz_roi_predict_first_week_user_behave where date = mDATE;
insert into beautyplus-bc0ed.temp.dws_dz_roi_predict_first_week_user_behave

-- 选择观测投放日期至投放日期一周内
with goal_users as
(
    select types,Attributed_Touch_Date,user_pseudo_id
    from beautyplus-bc0ed.temp.dws_dz_roi_predict_0_goal_users
    where Attributed_Touch_Date between DATE_SUB(mDATE, INTERVAL 6 DAY) and mDATE
    group by 1,2,3
)
,
behave_pre as
(
    select event_date,a.mark, a.module, a.class, a.function
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
    where event_date between date_sub(mDATE,interval 6 day) and mDATE
        and a.mark in (0, 1, 2)
)
,
-- 近7天用户核心行为
core_behave as
(
    SELECT *
    FROM
    (
        SELECT user_pseudo_id, concat(mark_c, '级tab-', IFNULL(module_c, ''), '-', IFNULL(class_c, ''), '-', IFNULL(function_c, ''), '-', action) behave, sum (pv) pv
        FROM
        behave_pre
        WHERE mark_c is not null and action in ('点击', '进入', '保存', '拍摄')
        and event_date between date_sub(mDATE, interval 6 day) and mDATE
        group by 1, 2
    )
    PIVOT
    (
        -- #2 aggregate
        sum (pv) AS pv
        -- #3 pivot_column
        -- 批量获取格式后的behave，参考onenote中的文字批量加上引号方法
        FOR behave in ('0级tab-修图---保存', '0级tab-修图---进入', '0级tab-拍摄---保存', '0级tab-拍摄---拍摄', '0级tab-电影---保存', '0级tab-电影---拍摄', '0级tab-自拍---进入', '0级tab-视频---保存', '0级tab-视频---拍摄', '0级tab-视频编辑---保存', '0级tab-视频编辑---进入', '1级tab-修图-创意--保存', '1级tab-修图-创意--点击', '1级tab-修图-滤镜--保存', '1级tab-修图-滤镜--点击', '1级tab-修图-编辑--保存', '1级tab-修图-编辑--点击', '1级tab-修图-美妆--保存', '1级tab-修图-美妆--点击', '1级tab-修图-美颜--保存', '1级tab-修图-美颜--点击', '1级tab-修图-高级编辑--点击', '1级tab-拍摄-AR--保存', '1级tab-拍摄-AR--拍摄', '1级tab-拍摄-Look--保存', '1级tab-拍摄-Look--拍摄', '1级tab-拍摄-滤镜--保存', '1级tab-拍摄-滤镜--拍摄', '1级tab-拍摄-美妆--保存', '1级tab-拍摄-美妆--拍摄', '1级tab-拍摄-美颜--保存', '2级tab-修图-创意-文字-保存', '2级tab-修图-创意-文字-点击', '2级tab-修图-创意-涂鸦笔-保存', '2级tab-修图-创意-涂鸦笔-点击', '2级tab-修图-创意-背景-保存', '2级tab-修图-创意-背景-点击', '2级tab-修图-创意-贴纸-保存', '2级tab-修图-创意-贴纸-点击', '2级tab-修图-创意-配方-保存', '2级tab-修图-创意-配方-点击', '2级tab-修图-编辑-AI增强-保存', '2级tab-修图-编辑-AI增强-点击', '2级tab-修图-编辑-AI扩展-保存', '2级tab-修图-编辑-AI扩展-点击', '2级tab-修图-编辑-AR-保存', '2级tab-修图-编辑-AR-点击', '2级tab-修图-编辑-分身-保存', '2级tab-修图-编辑-分身-点击', '2级tab-修图-编辑-抠图-保存', '2级tab-修图-编辑-抠图-点击', '2级tab-修图-编辑-构图-保存', '2级tab-修图-编辑-构图-点击', '2级tab-修图-编辑-消除笔-保存', '2级tab-修图-编辑-消除笔-点击', '2级tab-修图-编辑-照片修复-保存', '2级tab-修图-编辑-照片修复-点击', '2级tab-修图-编辑-色散-保存', '2级tab-修图-编辑-色散-点击', '2级tab-修图-编辑-虚化-保存', '2级tab-修图-编辑-虚化-点击', '2级tab-修图-编辑-调整-点击', '2级tab-修图-编辑-风格化-保存', '2级tab-修图-编辑-风格化-点击', '2级tab-修图-编辑-马赛克-保存', '2级tab-修图-编辑-马赛克-点击', '2级tab-修图-美颜-AI美颜-保存', '2级tab-修图-美颜-AI美颜-点击', '2级tab-修图-美颜-一键美颜-保存', '2级tab-修图-美颜-一键美颜-点击', '2级tab-修图-美颜-五官立体-保存', '2级tab-修图-美颜-五官立体-点击', '2级tab-修图-美颜-亮眼-保存', '2级tab-修图-美颜-亮眼-点击', '2级tab-修图-美颜-匀肤-保存', '2级tab-修图-美颜-匀肤-点击', '2级tab-修图-美颜-去油光-保存', '2级tab-修图-美颜-去油光-点击', '2级tab-修图-美颜-塑形-保存', '2级tab-修图-美颜-塑形-点击', '2级tab-修图-美颜-淡化黑眼圈-保存', '2级tab-修图-美颜-淡化黑眼圈-点击', '2级tab-修图-美颜-牙齿矫正-保存', '2级tab-修图-美颜-牙齿矫正-点击', '2级tab-修图-美颜-牙齿美白-保存', '2级tab-修图-美颜-牙齿美白-点击', '2级tab-修图-美颜-瘦脸-保存', '2级tab-修图-美颜-瘦脸-点击', '2级tab-修图-美颜-眼睛放大-保存', '2级tab-修图-美颜-眼睛放大-点击', '2级tab-修图-美颜-磨皮-保存', '2级tab-修图-美颜-磨皮-点击', '2级tab-修图-美颜-祛双下巴-保存', '2级tab-修图-美颜-祛双下巴-点击', '2级tab-修图-美颜-祛痘-保存', '2级tab-修图-美颜-祛痘-点击', '2级tab-修图-美颜-祛皱-保存', '2级tab-修图-美颜-祛皱-点击', '2级tab-修图-美颜-细节-保存', '2级tab-修图-美颜-细节-点击', '2级tab-修图-美颜-缩头-保存', '2级tab-修图-美颜-缩头-点击', '2级tab-修图-美颜-缩小鼻翼-保存', '2级tab-修图-美颜-缩小鼻翼-点击', '2级tab-修图-美颜-美发-保存', '2级tab-修图-美颜-美发-点击', '2级tab-修图-美颜-肤色-保存', '2级tab-修图-美颜-肤色-点击', '2级tab-修图-美颜-表情-保存', '2级tab-修图-美颜-表情-点击', '2级tab-修图-美颜-面部打光-保存', '2级tab-修图-美颜-面部打光-点击', '2级tab-修图-美颜-面部重塑-保存', '2级tab-修图-美颜-面部重塑-点击', '2级tab-拍摄-美妆-修容-保存', '2级tab-拍摄-美妆-修容-拍摄', '2级tab-拍摄-美妆-卧蚕-保存', '2级tab-拍摄-美妆-卧蚕-拍摄', '2级tab-拍摄-美妆-口红-保存', '2级tab-拍摄-美妆-口红-拍摄', '2级tab-拍摄-美妆-染发-保存', '2级tab-拍摄-美妆-染发-拍摄', '2级tab-拍摄-美妆-眉毛-保存', '2级tab-拍摄-美妆-眉毛-拍摄', '2级tab-拍摄-美妆-眼影-保存', '2级tab-拍摄-美妆-眼影-拍摄', '2级tab-拍摄-美妆-睫毛-保存', '2级tab-拍摄-美妆-睫毛-拍摄', '2级tab-拍摄-美妆-美瞳-保存', '2级tab-拍摄-美妆-美瞳-拍摄', '2级tab-拍摄-美妆-腮红-保存', '2级tab-拍摄-美妆-腮红-拍摄', '2级tab-拍摄-美妆-雀斑-保存', '2级tab-拍摄-美妆-雀斑-拍摄', '2级tab-拍摄-美颜-一键美型-保存', '2级tab-拍摄-美颜-亮眼-保存', '2级tab-拍摄-美颜-大眼-保存', '2级tab-拍摄-美颜-柔发-保存', '2级tab-拍摄-美颜-瘦脸-保存', '2级tab-拍摄-美颜-瘦鼻-保存', '2级tab-拍摄-美颜-磨皮-保存', '2级tab-拍摄-美颜-祛斑祛痘-保存', '2级tab-拍摄-美颜-祛法令纹-保存', '2级tab-拍摄-美颜-祛黑眼圈-保存', '2级tab-拍摄-美颜-缩头-保存', '2级tab-拍摄-美颜-美白牙齿-保存', '2级tab-拍摄-美颜-肤色-保存')
    )
)
,
-- 近7天拼图行为
puzzle as
(
    select user_pseudo_id
            , sum (case when action ='拼图点击' then pv end) puzzle_click_pv
            , sum (case when action ='拼图保存' then pv end) puzzle_save_pv
    from behave_pre
    where mark_c is not null
      and action in ('拼图点击', '拼图保存')
      and event_date between date_sub(mDATE, interval 6 day) and mDATE
    group by 1
)
,
-- 近7天付费非付费功能使用情况
pay_function as
(
    select user_pseudo_id,pay_function_click_pv,free_function_click_pv,free_function_save_pv
    from
    (
        select user_pseudo_id
                , sum (case when is_pay ='付费' and action in ('点击', '拍摄') then pv end) pay_function_click_pv
                , sum (case when is_pay ='非付费' and action in ('点击', '拍摄') then pv end) free_function_click_pv
                , sum (case when is_pay ='非付费' and action in ('保存') then pv end) free_function_save_pv
        from behave_pre
        where is_function = '功能'
          and mark=2
          and action in ('点击', '保存', '拍摄')
          and event_date between date_sub(mDATE, interval 6 day) and mDATE
        group by 1
    )
)
,
-- 2级功能使用情况（统计指标）
function_use as
(
    select user_pseudo_id,count(distinct function) function_num
    from behave_pre
    where mark=2 and action in ('点击','拍摄')
        and event_date between date_sub(mDATE, interval 6 day) and mDATE
    group by 1
)
,
other_behave as
(
    select user_pseudo_id
        ,sum(aigc_enter_pv) aigc_enter_pv
        ,sum(aigc_use_pv) aigc_use_pv
        ,sum(aigc_save_pv) aigc_save_pv
        ,sum(pop_exposure) pop_exposure
        ,sum(pop_click) pop_click
        ,sum(content_exposure) content_exposure
        ,sum(content_click) content_click
        ,sum(max_module_positon) max_module_positon
        ,sum(sub_page_enter) sub_page_enter
        ,sum(sub_page_click) sub_page_click
        ,sum(max_impression_pv) max_impression_pv
        ,sum(impression_pv) impression_pv
        ,sum(click_pv) click_pv
    from beautyplus-bc0ed.temp.dws_dz_roi_predict_user_other_behave_pre
    where date between date_sub(mDATE,interval 6 day) and mDATE
    group by 1
)
,
-- 付费素材指标及成长情况
-- beautyplus-bc0ed.temp.dwd_dz_roi_predict_0_material_events_v
pay_duffle as
(
    select user_pseudo_id,pay_duffle_click_pv,free_duffle_click_pv,free_duffle_save_pv
    from
    (
        select user_pseudo_id
                , sum (case when paid_type='1' and event_action in ('click','use') then pv end) pay_duffle_click_pv
                , sum (case when paid_type='0' and event_action in ('click','use') then pv end) free_duffle_click_pv
                , sum (case when paid_type='0' and event_action in ('save') then pv end) free_duffle_save_pv
        from beautyplus-bc0ed.temp.dwd_dz_roi_predict_0_material_events_v
        where date_p between date_sub(mDATE, interval 6 day) and mDATE
        group by 1
    )
)
,
user_profile as
(
    select u.*,g.types,g.Attributed_Touch_Date
    from goal_users g
    join
    (
        select user_pseudo_id,max(active_mins) active_mins,max(active_sessions) active_sessions,max(active_days) active_days
        from
        (
            select user_pseudo_id
    --             ,brand,model
    --             ,DATE_SUB(event_date_hk,last_active_date,DAY) last_active_days
    --             ,last_app_version,active_category
    --             ,life_time_active_days
                ,active_mins_7d active_mins,active_sessions_7d active_sessions,active_days_7d active_days
            from `beautyplus-bc0ed.dim.dim_dzp_portrait_firebase_id_user`
            where mDATE>='2024-01-01' and event_date_hk=mDATE

            union all

            select user_pseudo_id
                ,null active_mins,null active_sessions
                ,count(distinct event_date_hk) active_days
            from `dataintegration-265403.stat.stat_active_advice_detail_d`
            where mDATE<'2024-01-01' and event_date_hk between date_sub(mDATE,interval 6 day) and mDATE
                and app_name='BeautyPlus'
            group by 1
        )
        group by 1
    ) u
    on g.user_pseudo_id=u.user_pseudo_id
)

select cast(mDATE as date) as date,g.types,g.Attributed_Touch_Date,g.user_pseudo_id
    ,u.*except(user_pseudo_id,types,Attributed_Touch_Date)
    ,c.*except(user_pseudo_id)
    ,o.*except(user_pseudo_id)
    ,p.*except(user_pseudo_id)
    ,pf.*except(user_pseudo_id)
    ,pd.*except(user_pseudo_id)
    ,f.function_num
from goal_users g
left join user_profile u
on g.user_pseudo_id=u.user_pseudo_id and g.types=u.types and g.Attributed_Touch_Date=u.Attributed_Touch_Date
left join core_behave c
on g.user_pseudo_id=c.user_pseudo_id
left join other_behave o
on g.user_pseudo_id=o.user_pseudo_id
left join puzzle p
on g.user_pseudo_id=p.user_pseudo_id
left join pay_function pf
on g.user_pseudo_id=pf.user_pseudo_id
left join pay_duffle pd
on g.user_pseudo_id=pd.user_pseudo_id
left join function_use f
on g.user_pseudo_id=f.user_pseudo_id
;

SET mDATE = DATE_ADD(mDATE, INTERVAL 1 DAY);

END WHILE;



