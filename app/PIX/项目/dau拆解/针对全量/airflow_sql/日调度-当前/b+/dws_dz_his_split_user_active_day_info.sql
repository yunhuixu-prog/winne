DECLARE mDATE_START DATE DEFAULT '{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=3)).strftime("%Y-%m-%d") }}';
DECLARE mDATE_END DATE DEFAULT '{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=0)).strftime("%Y-%m-%d") }}';

-- drop table if exists dataintegration-265403.temp.dws_dz_his_split_user_active_day_info;
-- create table dataintegration-265403.temp.dws_dz_his_split_user_active_day_info as

delete from dataintegration-265403.temp.dws_dz_his_split_user_active_day_info where event_date_hk between mDATE_START and mDATE_END;
insert into dataintegration-265403.temp.dws_dz_his_split_user_active_day_info

select a.app_name,a.event_date_hk,a.user_pseudo_id
    ,if(b.holiday_date_timezone is not null,1,0) is_holiday
    ,c.is_weekend
    ,if(c.day_of_week in ('星期五','星期六','星期日'),1,0) is_weekend_include_five
from `dataintegration-265403.stat.stat_active_advice_detail_d` a
left join `dataintegration-265403.view.dim_ya_common_country_holiday` b --- 是否节假日
on a.country=b.country and date(timestamp_sub(timestamp(a.event_date_hk), interval 8 hour), b.timezone)=b.holiday_date_timezone
left join `dataintegration-265403.dim.dim_gs_common_date` c --- 是否周末
on a.event_date_hk=c.event_date
where a.event_date_hk between mDATE_START and mDATE_END
