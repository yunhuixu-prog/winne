
drop table if exists beautyplus-bc0ed.temp.return_sub_behave_part;
create table beautyplus-bc0ed.temp.return_sub_behave_part as

select *except(uuid,sub_type,bucket,is_active_30,is_edit_selfi_30,is_active_60,is_edit_selfi_60,is_active_90,is_edit_selfi_90)
from beautyplus-bc0ed.temp.dws_dz_his_split_final_user_behave_v
where date between '2024-04-01' and '2024-09-30'
    and is_active_7=1
    and sub_7>0
    and sub_type='sub_his'
    and rand()<least(200000/386412,1)

union all

select *except(uuid,sub_type,bucket,is_active_30,is_edit_selfi_30,is_active_60,is_edit_selfi_60,is_active_90,is_edit_selfi_90)
from beautyplus-bc0ed.temp.dws_dz_his_split_final_user_behave_v
where date between '2024-04-01' and '2024-09-30'
    and is_active_7=1
    and sub_7=0
    and sub_type='sub_his'
    and rand()<least(600000/27329520,1)






drop table if exists airbrush-1324.temp.return_sub_behave_part;
create table airbrush-1324.temp.return_sub_behave_part as

select *except(uuid,sub_type,bucket,is_active_30,is_edit_selfi_30,is_active_60,is_edit_selfi_60,is_active_90,is_edit_selfi_90)
from airbrush-1324.temp.dws_dz_his_split_final_user_behave_v
where date between '2024-04-01' and '2024-09-30'
    and is_active_7=1
    and sub_7>0
    and sub_type='sub_his'
    and rand()<least(200000/657541,1)

union all

select *except(uuid,sub_type,bucket,is_active_30,is_edit_selfi_30,is_active_60,is_edit_selfi_60,is_active_90,is_edit_selfi_90)
from airbrush-1324.temp.dws_dz_his_split_final_user_behave_v
where date between '2024-04-01' and '2024-09-30'
    and is_active_7=1
    and sub_7=0
    and sub_type='sub_his'
    and rand()<least(600000/21072296,1)




