-- 看整体
select a.event_date,a.version_status,a.exposure_uv,a.exposure_pv,a.click_uv,a.click_pv
    ,round(a.click_uv/a.exposure_uv,4) click_ratio_uv
    ,round(a.click_pv/a.exposure_pv,4) click_ratio_pv
    ,round(a.click_pv/a.click_uv,4) click_pvuv
    ,round(time_per,4) time_per
    ,round(num_30s/num,4) stay_ratio_30
    ,round(num_1min/num,4) stay_ratio_60
    ,round(liu_uv_1/b.exposure_uv,4) liu_uv_ratio_1
    ,round(liu_uv_7/b.exposure_uv,4) liu_uv_ratio_7
    ,round(liu_uv_14/b.exposure_uv,4) liu_uv_ratio_14
    ,Sub,sub_success,round(payment_price_usd,2) payment_price_usd
    ,sub_success_no_other,round(payment_price_usd_no_other,2) payment_price_usd_no_other
from 
(
    select event_date
    ,'汇总' version_status
    ,count(distinct case when event_name='homepageappr_bd' then user_pseudo_id end) exposure_uv
    ,sum(case when event_name='homepageappr_bd' then pv end) exposure_pv
    ,count(distinct case when event_name='home_content_clk_bd' then user_pseudo_id end) click_uv
    ,sum(case when event_name='home_content_clk_bd' then pv end) click_pv
    ,count(distinct case when event_name='home_content_show_f_bd' then user_pseudo_id end) content_show_uv
    ,sum(case when event_name='home_content_show_f_bd' then pv end) content_show_pv
    from `beautyplus-bc0ed.content_data.temp_homepage_overall_winni`
    group by 1

    union all  

    select event_date
    ,case when version>='7.7.000' then '>=7.7.000'
            when version<'7.7.000' then '<7.7.000'
        else 'null'
        end version_status
    ,count(distinct case when event_name='homepageappr_bd' then user_pseudo_id end) exposure_uv
    ,sum(case when event_name='homepageappr_bd' then pv end) exposure_pv
    ,count(distinct case when event_name='home_content_clk_bd' then user_pseudo_id end) click_uv
    ,sum(case when event_name='home_content_clk_bd' then pv end) click_pv
    ,count(distinct case when event_name='home_content_show_f_bd' then user_pseudo_id end) content_show_uv
    ,sum(case when event_name='home_content_show_f_bd' then pv end) content_show_pv
    from `beautyplus-bc0ed.content_data.temp_homepage_overall_winni` a
    group by 1,2
) a
left join 
(
    -- 留存
    select event_date
    ,'汇总' version_status
    ,count(distinct a.user_pseudo_id) exposure_uv
    ,count(distinct h.user_pseudo_id) liu_uv_14
    ,count(distinct case when a.event_date>=date_sub(h.event_date_hk,interval 1 day) then h.user_pseudo_id end) liu_uv_1
    ,count(distinct case when a.event_date>=date_sub(h.event_date_hk,interval 7 day) then h.user_pseudo_id end) liu_uv_7
    from `beautyplus-bc0ed.content_data.temp_homepage_overall_winni` a
    left join `dataintegration-265403.stat.stat_active_advice_detail_d` h
    on a.event_date<h.event_date_hk and a.event_date>=date_sub(h.event_date_hk,interval 14 day) and a.user_pseudo_id=h.user_pseudo_id
    where event_name='homepageappr_bd'
    group by 1

    union all 

    select event_date
    ,case when version>='7.7.000' then '>=7.7.000'
            when version<'7.7.000' then '<7.7.000'
        else 'null'
        end version_status
    ,count(distinct a.user_pseudo_id) exposure_uv
    ,count(distinct h.user_pseudo_id) liu_uv_14
    ,count(distinct case when a.event_date>=date_sub(h.event_date_hk,interval 1 day) then h.user_pseudo_id end) liu_uv_1
    ,count(distinct case when a.event_date>=date_sub(h.event_date_hk,interval 7 day) then h.user_pseudo_id end) liu_uv_7
    from `beautyplus-bc0ed.content_data.temp_homepage_overall_winni` a
    left join `dataintegration-265403.stat.stat_active_advice_detail_d` h
    on a.event_date<h.event_date_hk and a.event_date>=date_sub(h.event_date_hk,interval 14 day) and a.user_pseudo_id=h.user_pseudo_id
    where event_name='homepageappr_bd'
    group by 1,2
) b 
on a.event_date=b.event_date and a.version_status=b.version_status
left join 
(
    -- 看停留时长
    select event_date
        ,'汇总' version_status
        ,count(distinct user_pseudo_id) num
        ,count(distinct case when time>=30*1000 then user_pseudo_id end) num_30s
        ,count(distinct case when time>=60*1000 then user_pseudo_id end) num_1min
        ,count(distinct case when time>=3*60*1000 then user_pseudo_id end) num_3min
        ,round(sum(time)/count(distinct user_pseudo_id)/1000,4) time_per
    from 
    (
    select event_date
        ,user_pseudo_id
        ,version
        ,sum(cast(time as int64)*pv) time
    from `beautyplus-bc0ed.content_data.temp_homepage_overall_winni`
    where event_name='home_page_time_bd' --and event_date='2023-11-11'
    group by 1,2,3
    )
    where time is not null and time>0 and time<=24*60*60*1000
    group by 1

    union all 

    select event_date
        ,case when version>='7.7.000' then '>=7.7.000'
                when version<'7.7.000' then '<7.7.000'
            else 'null'
            end version_status
        ,count(distinct user_pseudo_id) num
        ,count(distinct case when time>=30*1000 then user_pseudo_id end) num_30s
        ,count(distinct case when time>=60*1000 then user_pseudo_id end) num_1min
        ,count(distinct case when time>=3*60*1000 then user_pseudo_id end) num_3min
        ,round(sum(time)/count(distinct user_pseudo_id)/1000,4) time_per
    from 
    (
    select event_date
        ,user_pseudo_id
        ,version
        ,sum(cast(time as int64)*pv) time
    from `beautyplus-bc0ed.content_data.temp_homepage_overall_winni`
    where event_name='home_page_time_bd' --and event_date='2023-11-11'
    group by 1,2,3
    )
    where time is not null and time>0 and time<=24*60*60*1000
    group by 1,2
) c
on a.event_date=c.event_date and a.version_status=c.version_status
left join 
(
    -- 订阅2
    select event_date
        ,'汇总' version_status
        ,sum(Sub) Sub
    from `beautyplus-bc0ed.Duffle_dataset.ads_dz_marvel2_home_content` 
    where event_date>='2023-10-01' 
        and level_type='content_id'
        and data_type='uv'
    group by 1
    
    union all 

    select event_date
        ,Version_status version_status
        ,sum(Sub) Sub 
    from `beautyplus-bc0ed.Duffle_dataset.ads_dz_marvel2_home_content` 
    where event_date>='2023-10-01' 
        and level_type='content_id'
        and data_type='uv'
    group by 1,2
) d 
on a.event_date=d.event_date and a.version_status=d.version_status
left join 
(
    -- 订阅1
    select date
        ,'汇总' version_status
        ,sum(case when event_name='Sub success' then uv end) sub_success
        ,sum(case when event_name='Sub success to paid' then payment_price_usd end) payment_price_usd
        ,sum(case when event_name='Sub success' and category2 not in ('HomePage Pop','首页-默认入口') then uv end) sub_success_no_other
        ,sum(case when event_name='Sub success to paid' and category2 not in ('HomePage Pop','首页-默认入口') then payment_price_usd end) payment_price_usd_no_other
    from `beautyplus-bc0ed.sub_dataset.ads_dz_sub_datatype_category2`
    where 
    date>='2023-10-01' 
        and category1='content' 
        and edition='V5.0'
    group by 1 
    
    union all 

    select date
        ,case when version>='7.7.000' then '>=7.7.000'
                when version<'7.7.000' then '<7.7.000'
            else 'null'
            end version_status
        ,sum(case when event_name='Sub success' then uv end) sub_success
        ,sum(case when event_name='Sub success to paid' then payment_price_usd end) payment_price_usd
        ,sum(case when event_name='Sub success' and category2 not in ('HomePage Pop','首页-默认入口') then uv end) sub_success_no_other
        ,sum(case when event_name='Sub success to paid' and category2 not in ('HomePage Pop','首页-默认入口') then payment_price_usd end) payment_price_usd_no_other
    from `beautyplus-bc0ed.sub_dataset.ads_dz_sub_datatype_category2`
    where 
    date>='2023-10-01' 
        and category1='content' 
        and edition='V5.0'
    group by 1,2 
) e 
on a.event_date=e.date and a.version_status=e.version_status
where a.event_date>='2023-10-19' or ( a.event_date<'2023-10-19' and a.version_status in ('<7.7.000','汇总'))
order by 1,2;



-- 看具体内容模块（订阅还是要看一下口径，不能用这个表里的，少了感觉）
select a.event_date
      ,module_type
      ,a.version_status
      ,content_show_uv
      ,content_show_pv
      ,content_click_uv
      ,content_click_pv
      ,Explore,Click,CHeck,Save,Sub
      ,Explore_pv,Click_pv,CHeck_pv,Save_pv,Sub_pv
from 
(
  select event_date
    ,module_type
    ,case when version>='7.7.000' then '>=7.7.000'
        when version<'7.7.000' then '<7.7.000'
    else 'null'
    end version_status
    -- ,module_id
    -- ,content_type
    -- ,content_id
    ,count(distinct case when event_name='home_content_show_f_bd' then user_pseudo_id end) content_show_uv
    ,sum(case when event_name='home_content_show_f_bd' then pv end) content_show_pv
    ,count(distinct case when event_name='home_content_clk_bd' then user_pseudo_id end) content_click_uv
    ,sum(case when event_name='home_content_clk_bd' then pv end) content_click_pv
  from `beautyplus-bc0ed.content_data.temp_homepage_overall_winni`
  where event_name in ('home_content_clk_bd','home_content_show_f_bd')
  group by 1,2,3
) a
left join 
(
  select event_date
    ,if(module='推荐配方入口','推荐配方',module) module
    ,Version_status version_status
    ,sum(Explore) Explore,sum(Click) Click,sum(CHeck) CHeck,sum(Save) Save,sum(Sub) Sub
  from `beautyplus-bc0ed.Duffle_dataset.ads_dz_marvel2_home_content` 
  where event_date>='2023-10-01' 
    and level_type='content_id'
    and data_type='uv'
  group by 1,2,3
) b 
on a.event_date=b.event_date and a.module_type=b.module and a.version_status=b.version_status
left join 
(
  select event_date
    ,if(module='推荐配方入口','推荐配方',module) module
    ,Version_status version_status
    ,sum(Explore) Explore_pv,sum(Click) Click_pv,sum(CHeck) CHeck_pv,sum(Save) Save_pv,sum(Sub) Sub_pv
  from `beautyplus-bc0ed.Duffle_dataset.ads_dz_marvel2_home_content` 
  where event_date>='2023-10-01' 
    and level_type='content_id'
    and data_type='pv'
  group by 1,2,3
) c 
on a.event_date=c.event_date and a.module_type=c.module and a.version_status=b.version_status
where module_type is not null and (a.event_date>='2023-10-19' or ( a.event_date<'2023-10-19' and a.version_status='<7.7.000'))
order by 1,2,3

-- 人均停留时长拉长看看

with event as 
(
  select
    event_date
      ,user_pseudo_id
      ,app_info.version
      ,coalesce(`dataintegration-265403.func`.getParams(event_params,'time').string_value,cast(`dataintegration-265403.func`.getParams(event_params,'time').int_value as string)) time
  from
    `beautyplus-bc0ed.analytics.ods_dz_events_tv`('2023-08-01','2023-11-12')
  where event_name='home_page_time_bd'
)
,
user_info as 
(
    select 
        event_date_hk
        ,app_name
        ,platform
        ,country
        ,user_pseudo_id
        ,max(uuid) uuid
        ,max(is_new) is_new
        ,max(is_UA) is_UA
        ,max(app_version) app_version
    from 
        `dataintegration-265403.stat.stat_active_advice_detail_d`
    where 
        event_date_hk between '2023-08-01' and '2023-11-12'
        and app_name='BeautyPlus'
    group by 1,2,3,4,5
) 

select event_date
        ,'汇总' version_status
        ,count(distinct user_pseudo_id) num
        ,count(distinct case when time>=30*1000 then user_pseudo_id end) num_30s
        ,count(distinct case when time>=60*1000 then user_pseudo_id end) num_1min
        ,count(distinct case when time>=3*60*1000 then user_pseudo_id end) num_3min
        ,round(sum(time)/count(distinct user_pseudo_id)/1000,4) time_per
    from 
    (
    select event_date
        ,a.user_pseudo_id
        ,version
        ,sum(cast(time as int64)) time
    from event a 
    join user_info b on a.user_pseudo_id = b.user_pseudo_id and a.event_date = b.event_date_hk
    group by 1,2,3
    )
    where time is not null and time>0 and time<=24*60*60*1000
    group by 1
    order by 1



-- 分端/国家
select a.event_date,a.version_status,a.platform,a.is_UA,a.is_new,a.region
    ,a.exposure_uv,a.exposure_pv,a.click_uv,a.click_pv
    ,round(a.click_uv/a.exposure_uv,4) click_ratio_uv
    ,round(a.click_pv/a.exposure_pv,4) click_ratio_pv
    ,round(a.click_pv/a.click_uv,4) click_pvuv
    ,round(time_per,4) time_per
    ,round(num_30s/num,4) stay_ratio_30
    ,round(num_1min/num,4) stay_ratio_60
    ,round(liu_uv_1/b.exposure_uv,4) liu_uv_ratio_1
    ,round(liu_uv_7/b.exposure_uv,4) liu_uv_ratio_7
    ,round(liu_uv_14/b.exposure_uv,4) liu_uv_ratio_14
    ,Sub 
from 
(
    select event_date
    ,'汇总' version_status
    ,platform,is_UA,is_new,region
    ,count(distinct case when event_name='homepageappr_bd' then user_pseudo_id end) exposure_uv
    ,sum(case when event_name='homepageappr_bd' then pv end) exposure_pv
    ,count(distinct case when event_name='home_content_clk_bd' then user_pseudo_id end) click_uv
    ,sum(case when event_name='home_content_clk_bd' then pv end) click_pv
    ,count(distinct case when event_name='home_content_show_f_bd' then user_pseudo_id end) content_show_uv
    ,sum(case when event_name='home_content_show_f_bd' then pv end) content_show_pv
    from `beautyplus-bc0ed.content_data.temp_homepage_overall_winni`
    group by 1,2,3,4,5,6

    union all  

    select event_date
    ,case when version>='7.7.000' then '>=7.7.000'
            when version<'7.7.000' then '<7.7.000'
        else 'null'
        end version_status
    ,platform,is_UA,is_new,region
    ,count(distinct case when event_name='homepageappr_bd' then user_pseudo_id end) exposure_uv
    ,sum(case when event_name='homepageappr_bd' then pv end) exposure_pv
    ,count(distinct case when event_name='home_content_clk_bd' then user_pseudo_id end) click_uv
    ,sum(case when event_name='home_content_clk_bd' then pv end) click_pv
    ,count(distinct case when event_name='home_content_show_f_bd' then user_pseudo_id end) content_show_uv
    ,sum(case when event_name='home_content_show_f_bd' then pv end) content_show_pv
    from `beautyplus-bc0ed.content_data.temp_homepage_overall_winni` a
    group by 1,2,3,4,5,6
) a
left join 
(
    -- 留存
    select event_date
    ,'汇总' version_status
    ,a.platform,a.is_UA,a.is_new,a.region
    ,count(distinct a.user_pseudo_id) exposure_uv
    ,count(distinct h.user_pseudo_id) liu_uv_14
    ,count(distinct case when a.event_date>=date_sub(h.event_date_hk,interval 1 day) then h.user_pseudo_id end) liu_uv_1
    ,count(distinct case when a.event_date>=date_sub(h.event_date_hk,interval 7 day) then h.user_pseudo_id end) liu_uv_7
    from `beautyplus-bc0ed.content_data.temp_homepage_overall_winni` a
    left join `dataintegration-265403.stat.stat_active_advice_detail_d` h
    on a.event_date<h.event_date_hk and a.event_date>=date_sub(h.event_date_hk,interval 14 day) and a.user_pseudo_id=h.user_pseudo_id
    where event_name='homepageappr_bd'
    group by 1,2,3,4,5,6

    union all 

    select event_date
    ,case when version>='7.7.000' then '>=7.7.000'
            when version<'7.7.000' then '<7.7.000'
        else 'null'
        end version_status
    ,a.platform,a.is_UA,a.is_new,a.region
    ,count(distinct a.user_pseudo_id) exposure_uv
    ,count(distinct h.user_pseudo_id) liu_uv_14
    ,count(distinct case when a.event_date>=date_sub(h.event_date_hk,interval 1 day) then h.user_pseudo_id end) liu_uv_1
    ,count(distinct case when a.event_date>=date_sub(h.event_date_hk,interval 7 day) then h.user_pseudo_id end) liu_uv_7
    from `beautyplus-bc0ed.content_data.temp_homepage_overall_winni` a
    left join `dataintegration-265403.stat.stat_active_advice_detail_d` h
    on a.event_date<h.event_date_hk and a.event_date>=date_sub(h.event_date_hk,interval 14 day) and a.user_pseudo_id=h.user_pseudo_id
    where event_name='homepageappr_bd'
    group by 1,2,3,4,5,6
) b 
on a.event_date=b.event_date and a.version_status=b.version_status
    and a.platform=b.platform and a.is_UA=b.is_UA and a.is_new=b.is_new and a.region=b.region
left join 
(
    -- 看停留时长
    select event_date
        ,'汇总' version_status
        ,platform,is_UA,is_new,region
        ,count(distinct user_pseudo_id) num
        ,count(distinct case when time>=30*1000 then user_pseudo_id end) num_30s
        ,count(distinct case when time>=60*1000 then user_pseudo_id end) num_1min
        ,count(distinct case when time>=3*60*1000 then user_pseudo_id end) num_3min
        ,round(sum(time)/count(distinct user_pseudo_id)/1000,4) time_per
    from 
    (
    select event_date
        ,user_pseudo_id
        ,version
        ,platform,is_UA,is_new,region
        ,sum(cast(time as int64)*pv) time
    from `beautyplus-bc0ed.content_data.temp_homepage_overall_winni`
    where event_name='home_page_time_bd' --and event_date='2023-11-11'
    group by 1,2,3,4,5,6,7
    )
    where time is not null and time>0 and time<=24*60*60*1000
    group by 1,2,3,4,5,6

    union all 

    select event_date
        ,case when version>='7.7.000' then '>=7.7.000'
                when version<'7.7.000' then '<7.7.000'
            else 'null'
            end version_status
        ,platform,is_UA,is_new,region
        ,count(distinct user_pseudo_id) num
        ,count(distinct case when time>=30*1000 then user_pseudo_id end) num_30s
        ,count(distinct case when time>=60*1000 then user_pseudo_id end) num_1min
        ,count(distinct case when time>=3*60*1000 then user_pseudo_id end) num_3min
        ,round(sum(time)/count(distinct user_pseudo_id)/1000,4) time_per
    from 
    (
    select event_date
        ,user_pseudo_id
        ,version
        ,platform,is_UA,is_new,region
        ,sum(cast(time as int64)*pv) time
    from `beautyplus-bc0ed.content_data.temp_homepage_overall_winni`
    where event_name='home_page_time_bd' --and event_date='2023-11-11'
    group by 1,2,3,4,5,6,7
    )
    where time is not null and time>0 and time<=24*60*60*1000
    group by 1,2,3,4,5,6
) c
on a.event_date=c.event_date and a.version_status=c.version_status
    and a.platform=c.platform and a.is_UA=c.is_UA and a.is_new=c.is_new and a.region=c.region
left join 
(
    -- 订阅2
    select event_date
        ,'汇总' version_status
        ,platform,is_ua is_UA
        ,case when is_new='New_user' then 'New'
              when is_new='Old_user' then 'Old'
        end is_new
        ,case when region='WW' then 'general'
              else region
        end region
        ,sum(Sub) Sub
    from `beautyplus-bc0ed.Duffle_dataset.ads_dz_marvel2_home_content` 
    where event_date>='2023-10-01' 
        and level_type='content_id'
        and data_type='uv'
    group by 1,2,3,4,5,6
    
    union all 

    select event_date
        ,Version_status version_status
        ,platform,is_ua is_UA
        ,case when is_new='New_user' then 'New'
              when is_new='Old_user' then 'Old'
        end is_new
        ,case when region='WW' then 'general'
              else region
        end region
        ,sum(Sub) Sub 
    from `beautyplus-bc0ed.Duffle_dataset.ads_dz_marvel2_home_content` 
    where event_date>='2023-10-01' 
        and level_type='content_id'
        and data_type='uv'
    group by 1,2,3,4,5,6
) d 
on a.event_date=d.event_date and a.version_status=d.version_status 
    and a.platform=d.platform and a.is_UA=d.is_UA and a.is_new=d.is_new and a.region=d.region
where a.event_date>='2023-10-19' or ( a.event_date<'2023-10-19' and a.version_status in ('<7.7.000','汇总'))
order by 1,2,3,4,5,6;


