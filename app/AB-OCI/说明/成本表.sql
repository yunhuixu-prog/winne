-- 成本数据，每一行代表一个AI任务的成本信息
select
	cost_type, -- 自研外采
    -- business_name, -- 业务方
	algo_provider, -- 模型提供商
    model_name, -- 模型名称
	country_name, -- 国家
    os_type, -- 操作系统

	func_id, -- 功能id
	func_name,func_effect, -- 功能名称、效果
    get_json_object(mtcc_client , "$.position.level1" ) level1,
    get_json_object(mtcc_client , "$.position.level2" ) level2,
    
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
	date_p = 20260415 -- 日期
    and app_name_cn='AirBrush' -- 应用，此为必须字段
