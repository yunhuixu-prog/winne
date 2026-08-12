-- CREATE VIEW dataintegration-265403.view.dws_dz_advertisement_max_dashboard_ads AS
with total as
(
    select
        r.*
        ,a1.retention_user retention_user
        ,a1.active_user active_user
        ,a2.active_user ads_dau
    from
        (select
            'Overview' data
            ,event_date
            ,product_line
            ,app_name
            ,platform
            ,country
            ,'' ad_format
            ,'' ad_unit_name
            ,'' ad_unit_id
            ,'' ad_placement_name

            ,sum(max_revenue) max_revenue
            ,sum(max_impression_pv) max_impression_pv
            ,sum(fill_pv) fill_pv
            ,sum(fail_pv) fail_pv
            ,sum(impression_pv) impression_pv
            ,sum(click_pv) click_pv
        from
            `dataintegration-265403.advertisement.dws_dzp_ad_placement_info`
        group by
            1,2,3,4,5,6,7,8,9,10) r
            left join   (select * from `dataintegration-265403.advertisement.dws_dz_advertisement_max_dashboard_active`
                        where data='DAU') a1 on r.app_name=a1.app_name and r.event_date=a1.event_date and r.platform=a1.platform and r.country=a1.country
            left join   (select * from `dataintegration-265403.advertisement.dws_dz_advertisement_max_dashboard_active`
                        where data='AD DAU') a2 on r.app_name=a2.app_name and r.event_date=a2.event_date and r.platform=a2.platform and r.country=a2.country
)
,
ad_unit as
(
    select
        r.*
        ,null retention_user
        ,null active_user
        ,a1.active_user ads_dau
    from
        (select
            'By Ad Type' data
            ,event_date
            ,product_line
            ,app_name
            ,platform
            ,country
            ,ad_format
            ,ad_unit_name
            ,ad_unit_id
            ,'' ad_placement_name

            ,sum(max_revenue) max_revenue
            ,sum(max_impression_pv) max_impression_pv
            ,sum(fill_pv) fill_pv
            ,sum(fail_pv) fail_pv
            ,sum(impression_pv) impression_pv
            ,sum(click_pv) click_pv
        from
            `dataintegration-265403.advertisement.dws_dzp_ad_placement_info`
        group by
            1,2,3,4,5,6,7,8,9,10) r
            left join   (select * from `dataintegration-265403.advertisement.dws_dz_advertisement_max_dashboard_active`
                        where data='AD Type DAU') a1 on r.app_name=a1.app_name
                                                        and r.event_date=a1.event_date
                                                        and r.platform=a1.platform
                                                        and r.country=a1.country
                                                        and r.ad_format=a1.ad_format
                                                        and r.ad_unit_name=a1.ad_unit_name
                                                        and r.ad_unit_id=a1.ad_unit_id
)
,
ad_placement as
(
    select
        r.*
        ,null retention_user
        ,null active_user
        ,a1.active_user ads_dau
    from
        (select
            'By Ad Placement' data
            ,event_date
            ,product_line
            ,app_name
            ,platform
            ,country
            ,ad_format
            ,ad_unit_name
            ,ad_unit_id
            ,ad_placement_name

            ,sum(max_revenue) max_revenue
            ,sum(max_impression_pv) max_impression_pv
            ,sum(fill_pv) fill_pv
            ,sum(fail_pv) fail_pv
            ,sum(impression_pv) impression_pv
            ,sum(click_pv) click_pv
        from
            `dataintegration-265403.advertisement.dws_dzp_ad_placement_info`
        group by
            1,2,3,4,5,6,7,8,9,10) r
            left join   (select * from `dataintegration-265403.advertisement.dws_dz_advertisement_max_dashboard_active`
                        where data='AD Placement DAU') a1 on r.app_name=a1.app_name
                                                        and r.event_date=a1.event_date
                                                        and r.platform=a1.platform
                                                        and r.country=a1.country
                                                        and r.ad_format=a1.ad_format
                                                        and r.ad_unit_name=a1.ad_unit_name
                                                        and r.ad_unit_id=a1.ad_unit_id
                                                        and r.ad_placement_name=a1.ad_placement_name
)


select * from total
union all
select * from ad_unit
union all
select * from ad_placement