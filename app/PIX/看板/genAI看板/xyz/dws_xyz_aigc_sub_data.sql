-- 暂不用
-- drop table if exists `dataintegration-265403.temp.dws_xyz_aigc_sub_data`;
-- create table if not exists `dataintegration-265403.temp.dws_xyz_aigc_sub_data` as

delete from  `dataintegration-265403.temp.dws_xyz_aigc_sub_data`  where date>='{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=14)).strftime("%Y-%m-%d") }}' and date<='{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=0)).strftime("%Y-%m-%d") }}';
insert into `dataintegration-265403.temp.dws_xyz_aigc_sub_data`

with
bp_subscription_pre as
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
            date between '{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=14)).strftime("%Y-%m-%d") }}' and '{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=0)).strftime("%Y-%m-%d") }}'
            and event_name='subscription_try_suc'
            and standard_order_date is not null
    )
    where source2_1 in (select distinct Bp_sub_name from `dataintegration-265403.temp.dwd_da_miniapp_miniapp_name_mapping`)
        or source2_2 in (select distinct Bp_sub_name from `dataintegration-265403.temp.dwd_da_miniapp_miniapp_name_mapping`)
)
,
bp_other_subscription_pre as
(
    select e.*,material_name
    from
    (
        select
            'BeautyPlus' app_name
            ,date
            ,platform
            ,country
            ,cur_page_type
            ,s source_feature_content
            ,user_pseudo_id
            ,original_order_id
            ,sku_type
            ,sku_has_trial
            ,purchase_date
            ,payment_price_usd
        from
            `beautyplus-bc0ed.sub_dataset.ads_spm_trial_subscription_pre_v5_abtest`,unnest(SPLIT(source2, '、')) s
        where
            date between '{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=14)).strftime("%Y-%m-%d") }}' and '{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=0)).strftime("%Y-%m-%d") }}'
            and event_name='subscription_try_suc'
            and standard_order_date is not null
            and (s like '%TEM%' or s like '%STY%')
    ) e
    join (select app,platform,m_id Material_id,start_date,end_date,max(name) material_name
            from `dataintegration-265403.duffle_fin.dmi_da_materials_info_v`
            where (remark in ('AI style') and theme='TEM') or (remark in ('风格化-AIGC') and theme='STY')
            group by 1,2,3,4,5

            union all

            select 'Beauty Plus Cam' app,platform,m_id Material_id,start_date,end_date,max(name) material_name
            from `dataintegration-265403.duffle_fin.dmi_da_materials_info_v`
            where ((remark in ('AI style') and theme='TEM') or (remark in ('风格化-AIGC') and theme='STY')) and app='BeautyPlus' and platform='ANDROID'
            group by 1,2,3,4,5
    ) st
    ON e.app_name = st.app
        AND e.platform = st.platform
        AND e.source_feature_content=st.Material_id
        AND e.date >= st.start_date
        AND e.date < st.end_date
)
,
ab_subscription_pre as
(
    select 'AirBrush' app_name
            ,event_date date
            ,first
            ,second
--             ,third theme -- 主题
            ,REPLACE(third,'_',' ') theme -- 主题
            ,platform
            ,case when is_new='New' then 1 else 0 end is_new
            ,country
            ,is_ua
            ,sub_success_uv,sub_to_paid_uv,sub_to_paid_revenue_sub
    from airbrush-1324.stat.dws_airbrush_trial_sub_grads_view
    where event_date between '{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=14)).strftime("%Y-%m-%d") }}' and '{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=0)).strftime("%Y-%m-%d") }}'
        and fourth='A' and third not in ('A','all','-') and third is not null
--             and second in (select distinct Ab_sub_name from `dataintegration-265403.temp.dwd_da_miniapp_miniapp_name_mapping`)
        and sale_status not in ('credit')
)
,
subscription as
(
    select e.app_name
        ,e.date
        ,e.platform
        ,e.country
        ,e.is_new
        ,e.is_ua is_UA
        ,s.miniapp project_name
        ,'H5' source
        ,sum(sub_success_uv) sub_uv
        ,sum(sub_to_paid_uv) sub_pay_uv
        ,round(sum(sub_to_paid_revenue_sub),2) sub_revenue
    from ab_subscription_pre e
    join (select Ab_sub_name,max(Project) miniapp,max(status) status from `dataintegration-265403.temp.dwd_da_miniapp_miniapp_name_mapping` group by 1) s on e.second=s.Ab_sub_name
    group by 1,2,3,4,5,6,7,8

    union all

    select e.app_name
        ,e.date
        ,e.platform
        ,u.country
        ,u.is_new
        ,u.is_UA
        ,s.miniapp project_name
        ,'H5' source
        ,count(distinct original_order_id) sub_uv
        ,count(distinct case when purchase_date is not null then original_order_id end) sub_pay_uv
        ,round(sum(case when purchase_date is not null then payment_price_usd end),2) sub_revenue
    from bp_subscription_pre e
    left join (select Bp_sub_name,max(Project) miniapp,max(status) status from `dataintegration-265403.temp.dwd_da_miniapp_miniapp_name_mapping` group by 1) s on e.source2=s.Bp_sub_name
    join user_info u on e.user_pseudo_id=u.user_pseudo_id and e.date=u.event_date_hk and e.platform=u.platform and e.app_name=u.app_name
    group by 1,2,3,4,5,6,7,8

    union all

    select e.app_name
        ,e.date
        ,e.platform
        ,u.country
        ,u.is_new
        ,u.is_UA
        ,'AI Filter 1.0' project_name
        ,case when source_feature_content like '%TEM%' then 'Template'
              when source_feature_content like '%STY%' then 'Style' end source
        ,count(distinct original_order_id) sub_uv
        ,count(distinct case when purchase_date is not null then original_order_id end) sub_pay_uv
        ,round(sum(case when purchase_date is not null then payment_price_usd end),2) sub_revenue
    from bp_other_subscription_pre e
    join user_info u on e.user_pseudo_id=u.user_pseudo_id and e.date=u.event_date_hk and e.platform=u.platform and e.app_name=u.app_name
    group by 1,2,3,4,5,6,7,8
)

select app_name,date,platform,country,is_new,is_UA,project_name
        ,sum(sub_uv) sub_uv
        ,sum(sub_pay_uv) sub_pay_uv
        ,sum(sub_revenue) sub_revenue
from subscription
group by 1,2,3,4,5,6,7

