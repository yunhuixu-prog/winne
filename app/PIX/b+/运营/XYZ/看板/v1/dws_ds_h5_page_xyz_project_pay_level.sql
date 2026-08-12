-- `dataintegration-265403.temp.dws_ds_h5_page_xyz_project_pay_level`
-- miniapp mapping: https://docs.google.com/spreadsheets/d/1J-4FIowZHgFOVUfHR8DyLbpS6yhzaPzOJaUD5Di31G4/edit#gid=1398841059
-- `dataintegration-265403.temp.dwd_da_miniapp_material_id_mapping`
-- `dataintegration-265403.temp.dwd_da_miniapp_miniapp_name_mapping`
-- `dataintegration-265403.temp.dwd_da_miniapp_adj_link_mapping`

drop table if exists `dataintegration-265403.temp.dws_ds_h5_page_xyz_project_pay_level_pre`;
create table if not exists `dataintegration-265403.temp.dws_ds_h5_page_xyz_project_pay_level_pre` as
select app_name
    ,event_date
    ,platform
    ,event_name
    ,`dataintegration-265403.func`.getParams(event_params,'project').string_value as project
    ,`dataintegration-265403.func`.getParams(event_params,'order_id').string_value as order_id
    ,`dataintegration-265403.func`.getParams(event_params,'theme').string_value as theme
    ,`dataintegration-265403.func`.getParams(event_params,'theme_type').string_value as theme_type
    ,`dataintegration-265403.func`.getParams(event_params,'source').string_value as source
    ,coalesce(app_info.version,'unknown') version
    ,coalesce(`dataintegration-265403.func`.getParams(event_params,'from_page').string_value,'unknown') as from_page
    ,`dataintegration-265403.func`.getUserprop(user_properties,'UserPaymentStatus').string_value is_pay
    ,user_pseudo_id
from
    `dataintegration-265403.analytics.dwd_dzp_events_function`('{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=3)).strftime("%Y-%m-%d") }}', '{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=0)).strftime("%Y-%m-%d") }}', 'beautyplus,airbrush,beautypluscam', false)
where (
        event_date<='2024-07-05' and
        (
            event_name in ('h5_credit_consume_bd','h5_credit_consume') --'credit_page_bd','credit_purchase_clk_bd','credit_order_purchase_suc_bd',
            or (event_name in ('h5_page_button_clk_bd','h5_page_button_clk')
                    and `dataintegration-265403.func`.getParams(event_params,'project').string_value='ai_filter'
                    and `dataintegration-265403.func`.getParams(event_params,'button_type').string_value in ('zero_generate','list')
                    and `dataintegration-265403.func`.getParams(event_params,'theme_type').string_value='photo' -- 目前列表页list无video
        --             and `dataintegration-265403.func`.getParams(event_params,'is_bundle').string_value='0'
                    and coalesce(`dataintegration-265403.func`.getParams(event_params,'is_bundle').string_value,cast(`dataintegration-265403.func`.getParams(event_params,'is_bundle').int_value as string))='0'
               )
        )
    )
    or
    (
        event_date>'2024-07-05' and
        (
            (event_name in ('h5_credit_consume_bd', 'h5_credit_consume') and `dataintegration-265403.func`.getParams(event_params,'project').string_value='puriplus')
            or
             (
                 event_name in ('h5_page_button_clk_bd', 'h5_page_button_clk')
                 and `dataintegration-265403.func`.getParams(event_params, 'button_type').string_value in
                    ('zero_generate', 'list', 'generate')
                 and `dataintegration-265403.func`.getParams(event_params,'project').string_value in ('ai_filter','ai_portrait')
             )
        )
    )
;

-- drop table if exists `dataintegration-265403.temp.dws_ds_h5_page_xyz_project_pay_level`;
-- create table if not exists `dataintegration-265403.temp.dws_ds_h5_page_xyz_project_pay_level` as
delete from  `dataintegration-265403.temp.dws_ds_h5_page_xyz_project_pay_level`  where date>='{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=3)).strftime("%Y-%m-%d") }}' and date<='{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=0)).strftime("%Y-%m-%d") }}';
insert into `dataintegration-265403.temp.dws_ds_h5_page_xyz_project_pay_level`
with user_info as
(
    select
        event_date_hk
        ,app_name
        ,platform
        ,country
        ,user_pseudo_id
        ,max(is_new) is_new
        ,max(is_UA) is_UA
    from
        `dataintegration-265403.stat.stat_active_advice_detail_d`
    where
        event_date_hk between '{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=3)).strftime("%Y-%m-%d") }}' and '{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=0)).strftime("%Y-%m-%d") }}'
        and app_name in ('BeautyPlus','AirBrush','Beauty Plus Cam')
    group by 1,2,3,4,5
)
,
credit as
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
        and event_date between '{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=3)).strftime("%Y-%m-%d") }}' and '{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=0)).strftime("%Y-%m-%d") }}'
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
        and event_date between '{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=3)).strftime("%Y-%m-%d") }}' and '{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=0)).strftime("%Y-%m-%d") }}'
    group by
        1,2,3,4
)
,
final_credit_event as
(
select
    a.app_name
    ,a.event_date date
    ,s.miniapp project_name
    ,'all' theme
    ,a.platform
    ,u.is_new
    ,u.is_UA
--     ,a.is_pay
    ,case when a.is_pay in ('Paying') or a.is_pay is null then a.is_pay else 'Non-paying' end is_pay
    ,u.country
    ,count(distinct a.user_pseudo_id) generate_success_uv
    ,sum(a.pv) generate_success_pv
--     ,count(distinct case when event_name in ('h5_credit_consume_bd','h5_credit_consume') then a.user_pseudo_id end) pay_generate_success_uv -- 免费视频也报了积分消耗，且无法区分付费免费无语
--     ,sum(case when event_name in ('h5_credit_consume_bd','h5_credit_consume') then a.pv end) pay_generate_success_pv -- 免费视频也报了积分消耗，且无法区分付费免费无语
    ,count(distinct case when c.order_id is not null then a.user_pseudo_id end) credit_use_uv
    ,sum(case when c.order_id is not null then a.pv end) credit_use_pv
    ,sum(c.credit_num) credit_num
    ,sum(c.payment_price_usd) payment_price_usd
from (select
        app_name
        ,event_date
        ,platform
        ,project
        ,k order_id
        ,is_pay
        ,user_pseudo_id
        ,count(1) as pv
    from
        dataintegration-265403.temp.dws_ds_h5_page_xyz_project_pay_level_pre,unnest(split(coalesce(order_id,''),',')) k
    where
        event_name in ('h5_credit_consume_bd','h5_credit_consume','h5_page_button_clk_bd','h5_page_button_clk')
    group by
        1,2,3,4,5,6,7) a
    join user_info u on a.user_pseudo_id=u.user_pseudo_id and a.event_date=u.event_date_hk and a.platform = u.platform and a.app_name = u.app_name
    left join credit c on a.order_id=c.order_id
    join (select H5_name,max(Project) miniapp,max(Status) status from `dataintegration-265403.temp.dwd_da_miniapp_miniapp_name_mapping` group by 1) s on a.project=s.H5_name
group by
    1,2,3,4,5,6,7,8,9

union all

select
    a.app_name
    ,a.event_date date
    ,s.miniapp project_name
    ,a.theme
    ,a.platform
    ,u.is_new
    ,u.is_UA
--     ,a.is_pay
    ,case when a.is_pay in ('Paying') or a.is_pay is null then a.is_pay else 'Non-paying' end is_pay
    ,u.country
    ,count(distinct a.user_pseudo_id) generate_success_uv
    ,sum(a.pv) generate_success_pv
    ,count(distinct case when c.order_id is not null then a.user_pseudo_id end) credit_use_uv
    ,sum(case when c.order_id is not null then a.pv end) credit_use_pv
    ,sum(c.credit_num) credit_num
    ,sum(c.payment_price_usd) payment_price_usd
from (select
        app_name
        ,event_date
        ,platform
        ,project
        ,theme
        ,k order_id
        ,is_pay
        ,user_pseudo_id
        ,count(1) as pv
    from
        dataintegration-265403.temp.dws_ds_h5_page_xyz_project_pay_level_pre,unnest(split(coalesce(order_id,''),',')) k
    where
        event_name in ('h5_credit_consume_bd','h5_credit_consume','h5_page_button_clk_bd','h5_page_button_clk')
    group by
        1,2,3,4,5,6,7,8) a
    join user_info u on a.user_pseudo_id=u.user_pseudo_id and a.event_date=u.event_date_hk and a.platform = u.platform and a.app_name = u.app_name
    left join credit c on a.order_id=c.order_id
    join (select H5_name,max(Project) miniapp,max(Status) status from `dataintegration-265403.temp.dwd_da_miniapp_miniapp_name_mapping` group by 1) s on a.project=s.H5_name
group by
    1,2,3,4,5,6,7,8,9
)
-- ,
-- final_credit_purpase_event as
-- (
--     select
--         a.app_name
--         ,a.event_date date
--         ,a.platform
--         ,s.miniapp project_name
--         ,'all' theme
--         ,u.is_new
--         ,u.is_UA
-- --         ,a.is_pay
--         ,case when a.is_pay in ('Paying') or a.is_pay is null then a.is_pay else 'Non-paying' end is_pay
--         ,u.country
--         ,count(distinct case when event_name='credit_page_bd' then a.user_pseudo_id end) credit_topup_imp_uv
--         ,count(distinct case when event_name='credit_purchase_clk_bd' then a.user_pseudo_id end) credit_topup_clk_uv
--         ,count(distinct case when event_name='credit_order_purchase_suc_bd' then a.user_pseudo_id end) credit_topup_suc_uv
--         ,sum(case when event_name='credit_page_bd' then a.pv end) credit_topup_imp_pv
--         ,sum(case when event_name='credit_purchase_clk_bd' then a.pv end) credit_topup_clk_pv
--         ,sum(case when event_name='credit_order_purchase_suc_bd' then a.pv end) credit_topup_suc_pv
--     from
--     (
--         select
--             app_name
--             ,event_date
--             ,platform
--             ,event_name
--             ,source
--             ,is_pay
--             ,user_pseudo_id
--             ,count(1) as pv
--         from dataintegration-265403.temp.dws_ds_h5_page_xyz_project_pay_level_pre
--         where event_name in ('credit_page_bd','credit_purchase_clk_bd','credit_order_purchase_suc_bd')
--         group by 1,2,3,4,5,6,7
--     ) a
--     join user_info u on a.user_pseudo_id=u.user_pseudo_id and a.event_date=u.event_date_hk and a.platform = u.platform and a.app_name = u.app_name
--     join (select Bp_sub_name,max(Project) miniapp,max(Status) status from `dataintegration-265403.temp.dwd_da_miniapp_miniapp_name_mapping` group by 1) s on a.source=s.Bp_sub_name
--     group by 1,2,3,4,5,6,7,8,9
--
--     union all
--
--     select
--         a.app_name
--         ,a.event_date date
--         ,a.platform
--         ,s.miniapp project_name
--         ,a.theme
--         ,u.is_new
--         ,u.is_UA
-- --         ,a.is_pay
--         ,case when a.is_pay in ('Paying') or a.is_pay is null then a.is_pay else 'Non-paying' end is_pay
--         ,u.country
--         ,count(distinct case when event_name='credit_page_bd' then a.user_pseudo_id end) credit_topup_imp_uv
--         ,count(distinct case when event_name='credit_purchase_clk_bd' then a.user_pseudo_id end) credit_topup_clk_uv
--         ,count(distinct case when event_name='credit_order_purchase_suc_bd' then a.user_pseudo_id end) credit_topup_suc_uv
--         ,sum(case when event_name='credit_page_bd' then a.pv end) credit_topup_imp_pv
--         ,sum(case when event_name='credit_purchase_clk_bd' then a.pv end) credit_topup_clk_pv
--         ,sum(case when event_name='credit_order_purchase_suc_bd' then a.pv end) credit_topup_suc_pv
--     from
--     (
--         select
--             app_name
--             ,event_date
--             ,platform
--             ,event_name
--             ,source
--             ,theme
--             ,is_pay
--             ,user_pseudo_id
--             ,count(1) as pv
--         from dataintegration-265403.temp.dws_ds_h5_page_xyz_project_pay_level_pre
--         where event_name in ('credit_page_bd','credit_purchase_clk_bd','credit_order_purchase_suc_bd')
--         group by 1,2,3,4,5,6,7,8
--     ) a
--     join user_info u on a.user_pseudo_id=u.user_pseudo_id and a.event_date=u.event_date_hk and a.platform = u.platform and a.app_name = u.app_name
--     join (select Bp_sub_name,max(Project) miniapp,max(Status) status from `dataintegration-265403.temp.dwd_da_miniapp_miniapp_name_mapping` group by 1) s on a.source=s.Bp_sub_name
--     group by 1,2,3,4,5,6,7,8,9
-- )


-- daily+miniapp
select
--     coalesce(e.app_name,c.app_name) app_name
--     ,coalesce(e.date,c.date) date
--     ,coalesce(e.platform,c.platform) platform
--     ,coalesce(e.country,c.country) country
--     ,coalesce(e.is_new,c.is_new) is_new
--     ,coalesce(e.project_name,c.project_name) project_name
--     ,coalesce(e.theme,c.theme) theme
--     ,coalesce(e.is_UA,c.is_UA) is_UA
--     ,coalesce(e.is_pay,c.is_pay) is_pay
    app_name
    ,date
    ,platform
    ,country
    ,is_new
    ,project_name
    ,theme
    ,is_UA
    ,is_pay
    ,generate_success_uv
    ,credit_use_uv
--     ,credit_topup_imp_uv
--     ,credit_topup_clk_uv
--     ,credit_topup_suc_uv

    ,generate_success_pv
    ,credit_use_pv
--     ,credit_topup_imp_pv
--     ,credit_topup_clk_pv
--     ,credit_topup_suc_pv

    ,credit_num
    ,payment_price_usd
from
    final_credit_event e
-- full join final_credit_purpase_event c
-- on e.app_name=c.app_name
--     and e.date=c.date
--     and e.platform=c.platform
--     and e.country=c.country
--     and e.is_new=c.is_new
--     and e.is_UA=c.is_UA
--     and e.is_pay=c.is_pay
--     and e.project_name=c.project_name
--     and e.theme=c.theme

