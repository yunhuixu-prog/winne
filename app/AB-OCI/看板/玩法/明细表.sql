set hive.exec.dynamic.partition.mode=nonstrict;
set hive.exec.max.dynamic.partitions =500;
set hive.exec.max.dynamic.partitions.pernode=500;

WITH
event_pre AS
(
    SELECT date_p,DATE_FORMAT(FROM_UNIXTIME(CAST(`time`/1000 AS bigint)), 'yyyyMMddHHmmss') event_time
        ,event_id
        ,sdk_type os_type,gid,app_version
        ,params['position'] position
        ,params['func'] func
        ,params['project'] project
        ,params['first_func'] first_func
        ,params['is_create_task'] is_create_task
        ,params['pic_num'] pic_num
        ,params['photo_num'] photo_num
        ,params['button_type'] button_type
        ,params['material_type'] material_type
        ,params['prf_material_type'] prf_material_type
        ,params['material_id'] material_id
        ,params['category_id'] category_id
        ,params['theme'] theme
        ,params['source_module'] source_module
        ,params['source_module'] source_module
        ,params['source_0'] source_0
        ,params['source_1'] source_1
        ,params['mids_material_id'] mids_material_id
        ,params['mids_category_id'] mids_category_id
    FROM stat_sdk.sdk_odz_source_data
    WHERE date_p between ${start_time} and ${end_time}
        AND app_key_p IN ('C851ED7164B6DF0F', '7F7023B6CEC7CDED')
        AND (event_id IN  ('homepage_func_show','homepage_func_click'
                        ,'h5_page_visit','h5_page_button_clk','h5_home_content_show_f','h5_home_content_clk_f'
                        ,'ai_func_delivery','w_subscription_success','save_share'
                        ,'first_func_enter','material_exposure','material_click','edit_save')
        AND app_version>='7.22.0'
)
,event AS
(
    SELECT
    FROM event_pre
    where case when event_id in ('homepage_func_show','homepage_func_click') then position in ('AI Image','AI Portraits')
               when event_id in ('h5_page_visit') then project in ('ai_filter','ai_portrait')
               when event_id in ('first_func_enter') then first_func = 'ai_image'
               when event_id in ('ai_func_delivery') then first_func in ('ai_filter','ai_portrait') and is_create_task='1'
               when event_id in ('h5_page_button_clk') then project in ('ai_filter','ai_portrait') and button_type in ('save')
               when event_id in ('edit_save') then prf_material_type like '%ai_image%'
               when event_id in ('w_subscription_success') then source_module='AIGC' and (source_0 like '%ai_filter%' or source_0 like '%ai_portrait%')
               when event_id in ('save_share') then function in ('ai_filter','ai_portrait')
               when event_id in ('h5_home_content_show_f','h5_home_content_clk_f') then project in ('ai_filter','ai_portrait')
               when event_id in ('material_exposure','material_click') then material_type='ai_image'
)
,dau AS
(
    SELECT
        a.date_p,
        case
            when a.os_p='ios' then 'iOS'
            when a.os_p='android' then 'Android'
        end os_type,
        a.final_id gid,
        max(c.name) AS country,
        max(a.is_ua) is_ua,
        max(CASE WHEN new_device.final_id IS NOT NULL THEN 'New' ELSE 'Old' END) AS is_new
    FROM
    (
        SELECT date_p, os_p, country_id, final_id, is_ua
        FROM stat_sdk.sdk_odz_active
        WHERE date_p BETWEEN ${start_time} AND ${end_time}
            AND app_key_p IN ('C851ED7164B6DF0F', '7F7023B6CEC7CDED')
            AND os_p IS NOT NULL
    ) a
    LEFT JOIN
    (
        SELECT DISTINCT id, name
        FROM stat_sdk.dim_rna_ip_location
        WHERE level='1' and date_p is not null
    ) c
    ON a.country_id = c.id
    LEFT JOIN
    (
        SELECT final_id, date_p
        FROM stat_sdk.sdk_odz_new_device_info
        WHERE date_p = ${start_time}
            AND app_key_p IN ('C851ED7164B6DF0F', '7F7023B6CEC7CDED')
            AND os_p IS NOT NULL
    ) new_device
    ON a.final_id = new_device.final_id AND a.date_p = new_device.date_p
    group by a.date_p,a.os_p,a.final_id
)
,pay as
(
    select os_type,country,is_new,is_ua,app_version,gid,
         s.source_module,s.source_0,s.source_1,mids_material_id,mids_category_id,
         is_paid,paid_ord_amt,paid_ord_before_amt,
         s_0,s_1,devide_num,devide_paid_ord_amt,devide_paid_ord_before_amt
    from stat_ab.filing_onz_sub_source_event_detail_level
    where date_p BETWEEN ${start_time} AND ${end_time}
        and event_id='sub_suc'
        and source_module='AIGC' and source_0 in ('ai_filter','ai_portrait')
)

insert overwrite table stat_ab.filing_onz_sub_sout_detail PARTITION(date_p)

SELECT
    COALESCE(s.os_type,'未知') AS os_type,
    COALESCE(d.country,'未知') AS country,
    COALESCE(d.is_new,'未知') AS is_new,
    COALESCE(d.is_ua,'未知') AS is_ua,
    s.app_version,s.sale_status,
    s.gid,
    s.event_id,s.duration,s.sku,
    s.source_module,s.source_0,s.source_1,s.mids_material_id,s.mids_category_id,
    null contract_id,null paid_date,null is_paid,null paid_ord_amt,null paid_ord_before_amt,
    null is_direct_paid,null direct_paid_ord_amt,null direct_paid_ord_before_amt,
    null is_trial,null is_trial_to_paid,null trial_to_paid_ord_amt,null trial_to_paid_ord_before_amt,
    CAST(s.event_time AS bigint) event_time,
    d.date_p
FROM (select * from dau) d
join (select * from sub_event) s
on d.date_p=s.date_p and d.os_type=s.os_type and d.gid=s.gid

union all

SELECT
    COALESCE(p.os_type,'未知') AS os_type,
    COALESCE(d.country,'未知') AS country,
    COALESCE(d.is_new,'未知') AS is_new,
    COALESCE(d.is_ua,'未知') AS is_ua,
    null app_version,null sale_status,
    p.gid,
    'sub_suc' event_id,p.period_type duration,p.sku,
    p.source_module,p.source_0,p.source_1,p.mids_material_id,p.mids_category_id,
    p.contract_id,p.paid_date,p.is_paid,p.paid_ord_amt,p.paid_ord_before_amt,
    p.is_direct_paid,p.direct_paid_ord_amt,p.direct_paid_ord_before_amt,
    p.is_trial,p.is_trial_to_paid,p.trial_to_paid_ord_amt,p.trial_to_paid_ord_before_amt,
    p.pay_time event_time,
    p.pay_date date_p
FROM (select * from pay) p
left join (select * from dau) d
on p.pay_date=d.date_p and p.os_type=d.os_type and p.gid=d.gid
;

