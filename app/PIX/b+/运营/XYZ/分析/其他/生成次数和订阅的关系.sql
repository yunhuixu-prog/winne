drop table if exists `dataintegration-265403.temp.dws_ds_h5_page_xyz_project_pay_level_temp`;
create table if not exists `dataintegration-265403.temp.dws_ds_h5_page_xyz_project_pay_level_temp` as
select app_name
    ,event_date
    ,platform
    ,event_name
    ,`dataintegration-265403.func`.getParams(event_params,'project').string_value as project
    ,`dataintegration-265403.func`.getParams(event_params,'theme').string_value as theme
    ,`dataintegration-265403.func`.getParams(event_params,'theme_type').string_value as theme_type
    ,`dataintegration-265403.func`.getUserprop(user_properties,'UserPaymentStatus').string_value is_vip
    ,user_pseudo_id
from
    `dataintegration-265403.analytics.dwd_dzp_events_function`('2024-07-01', '2024-07-14', 'beautyplus,airbrush', false)
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


with
bp_subscription_pre as
(
    select app_name,date
        ,case when source2_1 in (select distinct Bp_sub_name from `dataintegration-265403.temp.dwd_da_miniapp_miniapp_name_mapping`) then source2_1
            else source2_2
        end project
        ,user_pseudo_id
    from
    (
        select
            'BeautyPlus' app_name
            ,date
            ,platform
            ,country
            ,source1
            ,split(source2,'+')[0] source2_1
            ,if(ARRAY_LENGTH(split(source2,'+'))>=2,split(source2,'+')[1],null) source2_2
            ,user_pseudo_id
            ,original_order_id
            ,purchase_date
            ,payment_price_usd
        from
            `beautyplus-bc0ed.sub_dataset.ads_spm_trial_subscription_pre_v5_abtest`
        where
            date between '2024-07-01' and '2024-07-14'
            and event_name='subscription_try_suc'
            and standard_order_date is not null
    )
    where source2_1 in ('ai_portrait','ai_filter')
        or source2_2 in ('ai_portrait','ai_filter')
    group by 1,2,3,4
)
,
ab_subscription_pre as
(
    select 'AirBrush' app_name,event_date date
        ,case when second='ai_portraits_2' then 'ai_portrait'
        else second
        end project,user_pseudo_id
    from `airbrush-1324.stat.dws_airbrush_trial_sub_grads`
    where event_date >= '2024-07-01'
        and event_date <= '2024-07-14'
        and fourth='A' and third not in ('A','all','-') and third is not null
        and sale_status not in ('credit')
        and event_name = 'sub_suc'
        and second in ('ai_portraits_2','ai_filter')
    group by 1,2,3,4
)

select a.app_name,a.date,a.project,api_call,is_vip
  ,count(1) uv
  ,count(case when b.user_pseudo_id is not null then 1 end) sub_uv
from
(
    select app_name,event_date date,project,user_pseudo_id
        ,case when is_vip in ('Paying') then is_vip else 'Non-paying' end is_vip
        ,count(1) api_call
    from `dataintegration-265403.temp.dws_ds_h5_page_xyz_project_pay_level_temp`
    where project in ('ai_portrait','ai_filter')
    group by 1,2,3,4,5
) a
left join
(
    select app_name,date,project,user_pseudo_id
    from bp_subscription_pre

    union all

    select app_name,date,project,user_pseudo_id
    from ab_subscription_pre
) b
on a.app_name=b.app_name and a.date=b.date and a.project=b.project and a.user_pseudo_id=b.user_pseudo_id
group by 1,2,3,4,5


