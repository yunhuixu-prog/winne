-- 原始表，其实用不到，可以不参考，直接参考成本.sql
select
    "外采" cost_type,
    -- algo_provider,
    get_json_object( x_mtcc_client , "$.function.name" )  function_name , 
    get_json_object(x_mtcc_client, "$.function.effect") func_effect,
    -- get_json_object( x_mtcc_client , "$.country_code" )  country_code , 
    -- COALESCE( get_json_object( x_mtcc_client , "$.order_id" ), trace_id , task_id )  order_id , 
  
    -- get_json_object( x_mtcc_client , "$.os_type" )  os_type , 
    -- get_json_object( x_mtcc_client , "$.app_id" )  app_id , 
  
    -- get_json_object( x_mtcc_client , "$.gnum" )  gnum ,
    -- get_json_object( x_mtcc_client , "$.uid" )  uid ,
  
  
    -- REGEXP_REPLACE (substr(time,1,19),"T","") time,
    -- REGEXP_REPLACE (substr(time,1,13),"-| |T|:","") time_hour,
  
    -- req_time,
	-- COALESCE( cost,0) cost ,
    -- x_mtcc_client mtcc_client,
    -- REGEXP_REPLACE (substr(time,1,16),"-| |T|:","") time_minute,
    -- trace_id task_id,
    -- model model_name,
    -- business_party business_name,
     
    -- COALESCE(input_all_tokens , 0 ) + COALESCE(output_tokens , 0 ) total_tokens,	
    -- COALESCE(input_all_tokens , 0 ) input_all_tokens,			
    -- COALESCE(output_tokens , 0 ) output_all_tokens,		
    -- 0 reasoning_tokens,
    -- case when generation_modality REGEXP "生图" then "图像" 
    --      when generation_modality REGEXP "生视频" then "视频" 
    --      else "未知"
    -- end generation_modality,
    -- time raw_time,
    -- get_json_object(x_mtcc_client, "$.aigc_biz") biz
    count(1)
  
from
	stat_aigc.mpub_odz_aigc_outer_cost_all 
    
where
	date_p between 20260323 and 20260329
	and type_p >= '000' 
    and cost > 0 
    and is_success = "成功"     
    and  get_json_object( x_mtcc_client , "$.app_id" )  = 2000020
group by get_json_object( x_mtcc_client , "$.function.name" ),get_json_object(x_mtcc_client, "$.function.effect")