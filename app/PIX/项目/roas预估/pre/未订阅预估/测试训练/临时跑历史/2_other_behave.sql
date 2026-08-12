DECLARE mDATE_START DATE DEFAULT PARSE_DATE('%Y-%m-%d', '2023-06-01');
DECLARE mDATE_END DATE DEFAULT PARSE_DATE('%Y-%m-%d', '2023-06-30');
DECLARE mDATE DATE DEFAULT mDATE_START;

WHILE mDATE >= mDATE_START AND mDATE <= mDATE_END DO

delete from beautyplus-bc0ed.temp.dws_dz_roi_predict_user_other_behave where date=mDATE;
insert into beautyplus-bc0ed.temp.dws_dz_roi_predict_user_other_behave

with goal_users as
(
--     select a.Attributed_Touch_Date,s.user_pseudo_id
--     from `dataintegration-265403.roas_dataset.dwd_dz_af_ua_info` a
--     join `dataintegration-265403.stat.stat_active_advice_detail_d` s  -- 后续变为用户id维表，注意时间要不要改
--         on s.app_name=a.App_Name
--           AND s.platform=UPPER(a.Platform)
--           AND s.AppsFlyer_ID=a.AppsFlyer_ID
--           and s.event_date_hk=a.Attributed_Touch_Date
--     where a.App_Name='BeautyPlus' and a.Attributed_Touch_Date<=mDATE
--         and a.Attributed_Touch_Date>=GREATEST(date_sub(mDATE,interval 1 year),'2023-01-01')
--     group by 1,2

    select Attributed_Touch_Date,user_pseudo_id
    from beautyplus-bc0ed.temp.dws_dz_roi_predict_goal_users
    group by 1,2
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
-- beautyplus-bc0ed.temp.dwd_dz_material_events_temp_v，后续改个名字规划一下

pay_duffle as
(
    select user_pseudo_id,pay_duffle_click_pv,free_duffle_click_pv,free_duffle_save_pv
            , IFNULL(pay_duffle_click_pv, 0)-IFNULL(pay_duffle_click_pv_pre, 0) grow_pay_duffle_click_pv
            , IFNULL(free_duffle_click_pv, 0)-IFNULL(free_duffle_click_pv_pre, 0) grow_free_duffle_click_pv
            , IFNULL(free_duffle_save_pv, 0)-IFNULL(free_duffle_save_pv_pre, 0) grow_free_duffle_save_pv
    from
    (
        select user_pseudo_id
                , sum (case when date_p between date_sub(mDATE, interval 6 day) and mDATE
                        and paid_type='1' and event_action in ('click','use') then pv end) pay_duffle_click_pv
                , sum (case when date_p between date_sub(mDATE, interval 13 day) and date_sub(mDATE, interval 7 day)
                        and paid_type='1' and event_action in ('click','use') then pv end) pay_duffle_click_pv_pre
                , sum (case when date_p between date_sub(mDATE, interval 6 day) and mDATE
                        and paid_type='0' and event_action in ('click','use') then pv end) free_duffle_click_pv
                , sum (case when date_p between date_sub(mDATE, interval 13 day) and date_sub(mDATE, interval 7 day)
                        and paid_type='0' and event_action in ('click','use') then pv end) free_duffle_click_pv_pre
                , sum (case when date_p between date_sub(mDATE, interval 6 day) and mDATE
                        and paid_type='0' and event_action in ('save') then pv end) free_duffle_save_pv
                , sum (case when date_p between date_sub(mDATE, interval 13 day) and date_sub(mDATE, interval 7 day)
                        and paid_type='0' and event_action in ('save') then pv end) free_duffle_save_pv_pre
        from beautyplus-bc0ed.temp.dwd_dz_material_events_temp_v
        where date_p between date_sub(mDATE, interval 13 day) and mDATE
        group by 1
    )
)
-- ,
-- -- 素材偏好指标(什么形式还没想好)
-- duffle_style as
-- (
--     select user_pseudo_id,en_dam_tags,en_cms_tags,
--     from beautyplus-bc0ed.temp.dwd_dz_material_events_temp_v
--     where date_p between date_sub(mDATE, interval 6 day) and mDATE
--     group by 1
-- )


select mDATE as date,g.Attributed_Touch_Date,g.user_pseudo_id
    ,c.*except(user_pseudo_id)
    ,p.*except(user_pseudo_id)
--     ,d.*except(user_pseudo_id)
from goal_users g
left join other_behave c
on g.user_pseudo_id=c.user_pseudo_id
left join pay_duffle p
on g.user_pseudo_id=p.user_pseudo_id
-- left join duffle_style d
-- on g.user_pseudo_id=d.user_pseudo_id

;

SET mDATE = DATE_ADD(mDATE, INTERVAL 1 DAY);

END WHILE;