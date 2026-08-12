SET hive.exec.dynamic.partition.mode=nonstrict;
insert overwrite table stat_ab.filing_anz_sub_source_event_show PARTITION(date_p)

select * from stat_ab.filing_mnz_sub_source_event_whole_level
where date_p between ${start_time} and ${end_time}

union all

select * from stat_ab.filing_mnz_sub_source_event_sku_level
where date_p between ${start_time} and ${end_time}

union all

select * from stat_ab.filing_mnz_sub_source_event_detail_level
where date_p between ${start_time} and ${end_time}

-- union all
--
-- select * from stat_ab.filing_mnz_sub_source_event_second_level
-- where date_p between ${start_time} and ${end_time}
--
-- union all
--
-- select * from stat_ab.filing_mnz_sub_source_event_third_level
-- where date_p between ${start_time} and ${end_time}
--
-- union all
-- select * from stat_ab.filing_mnz_sub_source_event_fourth_level
--
;