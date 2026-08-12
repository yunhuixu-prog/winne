DECLARE mDATE_START DATE DEFAULT '{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=3)).strftime("%Y-%m-%d") }}';
DECLARE mDATE_END DATE DEFAULT '{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=0)).strftime("%Y-%m-%d") }}';

-- drop table if exists beautyplus-bc0ed.temp.dws_dz_dau_split_and_roas_final_user_behave;
-- create table beautyplus-bc0ed.temp.dws_dz_dau_split_and_roas_final_user_behave as


delete from beautyplus-bc0ed.temp.dws_dz_dau_split_and_roas_final_user_behave where date between mDATE_START and mDATE_END;
insert into beautyplus-bc0ed.temp.dws_dz_dau_split_and_roas_final_user_behave

select distinct a.*
from
(
    select *
    from beautyplus-bc0ed.temp.dws_dz_his_split_final_user_behave
    where date between mDATE_START and mDATE_END
) a
left join
(
    select *
    from dataintegration-265403.roas.dws_dzp_roas_goal_user_sub_uuid
    where date between mDATE_START and mDATE_END and app_name='BeautyPlus'
--         -- 如果需要单独对7天后搭建个模型的话
--         and date between Attributed_Touch_Date and date_add(Attributed_Touch_Date,interval 7 day)
) b
on a.uuid=b.uuid and a.date=b.date
-- 仅预测当前未订阅付费的用户，包含dau及过去一年的投放用户
where a.is_current_pay=0
    and (
            a.last_active_days=0
            or
            (b.uuid is not null and (b.days<=60 or a.last_active_days<=30))
        )
