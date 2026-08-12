select
    os_type, -- 操作系统

	func_id, -- 功能id
	func_name,func_effect, -- 功能名称、效果
    
    gnum, -- 设备id
	`time`, -- 时间
	order_id, -- 订单id
    task_id, -- 任务id
	req_time, -- 请求时间
	cost, -- 成本
	date_p
from
	-- stat_aigc.cost_odz_aigc_cost_detail_d
    stat_aigc.cost_odz_aigc_cost_detail_d_oci_app
where
	date_p = 20260422
    and app_name_cn='AirBrush'
    and func_name='未定义功能'
limit 100
;

-- 国内北斗
select
	msg_id,task_id,gid
    ,get_json_object(ext, "$.process_stage_info.trace_id" ) trace_id
from
	stat_aigc.cost_adz_aigc_inference_task_overseas
where
	date_p = 20260422
    and app_id = 2000020
    and msg_id  REGEXP "bf2ca92f-d25c-435e-b3cd-83916a8d87fe"
