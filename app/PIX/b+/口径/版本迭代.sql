select * from dataintegration-265403.dwd.dwd_da_common_bever_x113_task
where name='BeautyPlus'
    and cast(release_time as date)>='2022-06-01' and cast(release_time as date)<='2022-08-01'