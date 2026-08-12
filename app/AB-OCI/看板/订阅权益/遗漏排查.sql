-- 层级表
select source_module,s_0,s_1,count(1)
from stat_ab.filing_onz_sub_source_event_detail_level
where date_p between 20260101 and 20260210 and event_id='sub_enter' and first_source='未知'
group by source_module,s_0,s_1
;
select *
from stat_ab.filing_onz_sub_source_event_detail_level
where date_p between 20260101 and 20260210 and event_id='sub_enter' and first_source='未知'
and source_module='p_edit' and s_0='ai_filter'
