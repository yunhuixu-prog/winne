-- iOS14.5以上渠道数据
delete from  `dataintegration-265403.roas_dataset_v4.ads_da_ua_roas_only_IOS14` where 1=1;
insert into  `dataintegration-265403.roas_dataset_v4.ads_da_ua_roas_only_IOS14`
/*drop table `dataintegration-265403.roas_dataset_v4.ads_da_ua_roas_only_IOS14`; -- 表名替换【原表】
create table `dataintegration-265403.roas_dataset_v4.ads_da_ua_roas_only_IOS14`-- 表名替换【原表】
partition by Date as  -- 注意,partition by 后的日期必须为日期类型,如果之前是字符串的类型,需要转成日期类型后进行分区,发生字段类型变更需要同步修改引用的调度或者表报
*/
with ska as
(
    select
        --a.app_id as af_app_id
        --,b.app_id
        -- case when b.app_name_en in ('Vmake') then 'BeautyPlus Story' else b.app_name_en end as app
        b.app_name_en app
        ,b.app_platform as platform
        ,case when a.media_source in ('facebook') then 'Facebook Ads' else a.media_source end as media_source
        ,a.ad_network_campaign_name as campaign_name
        ,date as install_date
        ,sum(a.amount) as amount
        ,sum(a.install_uv) as install_uv
        ,sum(a.install_first_time_sub_uv) as install_first_time_sub_uv
    from
        (select
            app_id,
            DATE(install_date) as date ,
            --DATE( DATETIME(timestamp)) as date ,
            media_source,
            ad_network_campaign_name,
            0 as amount,
            count(1) as install_uv,
            0 as install_first_time_sub_uv,
        from
            `dataintegration-265403.biglake.stage_dz_appsflyer_ska_install`
        group by
            1,2,3,4
        union all
        select
            app_id
            ,DATE(install_date) as date
            --,DATE( DATETIME(timestamp)) as date
            ,media_source
            ,ad_network_campaign_name
            ,0 as amount
            ,0 as install_uv
            ,count  (case   when app_id in ('id622434129') and event_name in ('subscription_year') then 1 --B+IOS
                            when app_id in ('id998411110') and event_name in ('sub_success_annual') then 1 --AB IOS
                            when app_id in ('id1445969821') and event_name in ('Sub_Yearly','Sub_Monthly','Sub_Weekly') then 1 --VCUS IOS
                            when app_id in ('id1592035837') and event_name in ('Sub_Yearly','Sub_Monthly','Sub_Weekly') then 1 --BV IOS
                    end ) install_first_time_sub_uv
        from
            `dataintegration-265403.biglake.stage_dh_appsflyer_inappevents`
        group by
            1,2,3,4
        ) a
    left join `dataintegration-265403.dmi.dim_sz_app_id_rel_v` b on a.app_id=b.rel
where
    b.app_name_en in ('AirBrush','BeautyPlus','BeautyPlus Video','VCUS','AirBrush Video','SnapID') -- vcusAPP >> BeautyPlus Story >> BeautyPlus Video >> Vmake >> BeautyPlus Video
    and b.app_platform in ('IOS')
    and ((a.media_source in ('facebook','bytedanceglobal_int','Facebook Ads','tiktokglobal_int') and UPPER(a.ad_network_campaign_name) LIKE '%IOS14%') or a.media_source in ('yoke_int') )
    and a.date >= '2022-08-01'
group by
    1,2,3,4,5
)
,
cost as
(
    select
        case when product='BeautyPlus Story' then 'BeautyPlus Video' else product end as app -- vcusAPP >> BeautyPlus Story >> BeautyPlus Video >> Vmake >> BeautyPlus Video
        ,upper(Trim(Platform)) as platform
        ,media_source
        ,campaign_name
        ,date as install_date
        ,sum(amount_spent_usd) as amount
        ,0 as install_uv
        ,0 as install_first_time_sub_uv
    from
        `finance-268602.roi_dataset.dws_dz_campgain_info`
    where
        product in ('AirBrush','BeautyPlus','VCUS','BeautyPlus Story','AirBrush Video','SnapID')
        and UPPER(platform) in ('IOS')
        and (( media_source in ('facebook','bytedanceglobal_int','Facebook Ads') and UPPER(campaign_name) LIKE '%IOS14%') or media_source in ('yoke_int') ) -- tiktokglobal_int成本不计入，合并在别的渠道
        --and media_source in ('Facebook Ads','bytedanceglobal_int','yoke_int')
        --and UPPER(campaign_name) LIKE '%IOS14%'
        and date >= '2022-08-01'
    group by
        1,2,3,4,5
)

select
    'Daily Report V5' as data
    ,g.app as App_Name
    ,g.platform as Platform
    ,g.media_source as Media_Source
    ,g.campaign_name as Campaign
    ,g.install_date as   Date
    ,sum(g.amount) as amount
    ,sum(g.install_uv) as install_uv
    ,sum(g.install_first_time_sub_uv) as install_first_time_sub_uv
from
    (select * from ska
    union all
    select * from cost
    ) g
group by
    1,2,3,4,5,6

