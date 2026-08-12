
-- 问题用户gid
drop table if exists `beautyplus-bc0ed.temp.dws_problem_gid_temp`;
create table `beautyplus-bc0ed.temp.dws_problem_gid_temp` as
with event as
(
    select
        event_date
        ,platform
        ,timestamp_micros(event_timestamp) times
        ,geo.country
        ,func.getParams(event_params,'lang').string_value lang
        ,func.getParams(event_params,'project').string_value project
        ,func.getUserprop(user_properties,'hwgid').string_value hwgid
        ,user_pseudo_id
    from
        `beautyplus-bc0ed.analytics.ods_dz_events_tv`('2023-10-05', '2023-10-07')
    where
        event_name in ('h5_page_button_clk_bd')
        and func.getParams(event_params,'project').string_value in ('AI_Zodiac_Persona','AI_Image_Photo')
        and func.getParams(event_params,'button_type').string_value='generate'
)

select *
from event
where times between TIMESTAMP("2023-10-05 07:48:00", "Asia/Shanghai") and TIMESTAMP("2023-10-07 09:55:00", "Asia/Shanghai")
order by times;


drop table if exists `beautyplus-bc0ed.temp.dws_problem_gid_credit_topup_temp`;
create table `beautyplus-bc0ed.temp.dws_problem_gid_credit_topup_temp` as
with event as
(
    select
        event_date
        ,timestamp_micros(event_timestamp) times
        ,func.getParams(event_params,'project').string_value project
        ,func.getUserprop(user_properties,'hwgid').string_value hwgid
        ,user_pseudo_id
    from
        `beautyplus-bc0ed.analytics.ods_dz_events_tv`('2023-09-14', '2023-10-07')
    where
        event_name = 'credit_order_purchase_suc_bd'
)

select *
from event
where times <= TIMESTAMP("2023-10-07 09:55:00", "Asia/Shanghai")
;



select m.user_pseudo_id,m.country,m.lang,m.hwgid,m.platform,token from
(
    select user_pseudo_id,country,lang,hwgid,platform
    from `beautyplus-bc0ed.temp.dws_problem_gid_temp` a -- 故障期间点击生成按钮的用户
    group by 1,2,3,4
) m
join
(
    select distinct user_pseudo_id
    from `beautyplus-bc0ed.temp.dws_problem_gid_credit_topup_temp` -- 历史发生过积分订单购买成功事件
) n
on m.user_pseudo_id = n.user_pseudo_id
left join `beautyplus-bc0ed.firestore.dwd_da_install_user` b
on m.user_pseudo_id = b.firebase_id
