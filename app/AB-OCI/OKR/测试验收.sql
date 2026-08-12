-- 一个月同时有多个is_ua的比例
select month,count(1) uv,count(case when ua_num>1 then 1 end) uv_multi
		,round(count(case when ua_num>1 then 1 end)/count(1),6) ratio_multi
from
(
	SELECT substr(date_p,1,6) month,final_id,count(distinct is_ua) ua_num
    FROM stat_sdk.sdk_odz_active
    WHERE date_p BETWEEN 20250901 AND 20251231
      AND app_key_p IN ('C851ED7164B6DF0F','7F7023B6CEC7CDED')
      AND os_p is not null
    group by substr(date_p,1,6),final_id
) a
group by month
