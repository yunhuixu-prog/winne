set hive.exec.dynamic.partition.mode=nonstrict;
set hive.exec.max.dynamic.partitions=800;
set hive.exec.max.dynamic.partitions.pernode=800;

INSERT OVERWRITE TABLE stat_ab.filing_ada_money_all_country PARTITION(date_p)

select goal_month,gmv_real_month,pro_month
        ,goal_quar,gmv_real_quar,pro_quar
        ,goal_year,gmv_real_year,pro_year,target_date date_p
from 
(
    select goal_month,gmv_real_month,pro_month
        ,goal_quar,gmv_real_quar,pro_quar
        ,goal_year,gmv_real_year,pro_year
        ,target_date,date_p
    from stat_ab.filing_adz_money_okr_all_country
    where date_p between 20260101 and 20261231
    and date_p between ${start_time} and ${end_time}
) a
join (select max(date_p) date_p from stat_ab.filing_adz_money_okr_all_country 
    where date_p between 20260101 and 20261231
    and date_p between ${start_time} and ${end_time}) t 
on a.date_p=t.date_p