-- select os_type,code,is_new
--     ,event_id,first_func,second_func
--     ,feature_nums,button_type
--     ,source_0,source_1,devide_num
--     ,sum(uv) uv
-- from (
select
    -- a.date_p,
    a.os_type os_type
    ,case when b.ab_code in ('28947') then '对照组'
        when b.ab_code in ('28948') then '实验组A'
        end code
    ,b.is_new is_new
    ,a.event_id event_id
    ,first_func,second_func,feature_nums,button_type,source_0,source_1
    ,SIZE(SPLIT(COALESCE(source_1,'无'), ',')) devide_num
    ,count(distinct a.gid) uv
from (
    SELECT date_p,event_id
        ,CAST(`time`/1000 AS bigint) event_timestamp
        ,sdk_type os_type,gid
        ,params['first_func'] first_func
        ,params['second_func'] second_func
        ,params['feature_nums'] feature_nums
        ,params['button_type'] button_type
        ,case when params['source_module']='p_edit' and params['source_0'] in ('f_face','f_reshape') then params['source_0'] else 'else' end source_0
        ,case when params['source_module']='p_edit' and params['source_0'] in ('f_face','f_reshape') then params['source_1'] else 'else' end source_1
    FROM stat_sdk.sdk_odz_source_data
    WHERE date_p between 20260519 and 20260623
        AND app_key_p IN ('C851ED7164B6DF0F', '7F7023B6CEC7CDED')
        AND event_id in ('pro_banner_show','pro_banner_click','pro_halfsheet_show','pro_halfsheet_click'
        ,'w_subscription_enter','w_subscription_click','w_subscription_success'
        )
) a
join (
    select *
    from
    (
        select
            fa.gid,fa.os_p os_type,fa.country,fa.is_new
            ,e.ab_code,e.enter_abtest_date,e.event_timestamp
            ,row_number() over(partition by e.gid order by event_timestamp) ranks
        from (
            SELECT
                a.date_p,
                a.os_p,
                c.name AS country,
                a.final_id gid,
                CASE WHEN new_device.final_id IS NOT NULL THEN 'New' ELSE 'Old' END AS is_new
            FROM
            (
                SELECT date_p, os_p, country_id, final_id
                FROM stat_sdk.sdk_odz_active
                WHERE date_p BETWEEN 20260519 and 20260623
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
                WHERE date_p BETWEEN 20260519 and 20260623
                AND app_key_p IN ('C851ED7164B6DF0F', '7F7023B6CEC7CDED')
                AND os_p IS NOT NULL
            )new_device
            ON a.final_id = new_device.final_id AND a.date_p = new_device.date_p
        ) fa
        join (
            SELECT date_p enter_abtest_date
                ,CAST(`time`/1000 AS bigint) event_timestamp
                ,sdk_type os_type,gid
                ,params['current_abcode'] ab_code
            FROM stat_sdk.sdk_odz_source_data
            WHERE date_p between 20260519 and 20260623
                AND app_key_p IN ('C851ED7164B6DF0F', '7F7023B6CEC7CDED')
                AND event_id = 'abcode_enter_test'
                AND params['current_abcode'] in ('28947','28948')
        ) e ON e.gid = fa.gid and e.enter_abtest_date = fa.date_p
        where e.gid is not null
    ) t
    where ranks=1
) b
on a.gid= b.gid
where b.event_timestamp-15 <= a.event_timestamp
    -- and b.enter_abtest_date = a.date_p
group by 
        -- a.date_p,
        a.os_type,case when b.ab_code in ('28947') then '对照组'
        when b.ab_code in ('28948') then '实验组A'
        end
        ,b.is_new
        ,a.event_id,first_func,second_func,feature_nums,button_type,source_0,source_1
        ,SIZE(SPLIT(COALESCE(source_1,'无'), ','))
-- ) t 
-- group by os_type,code,is_new
--     ,event_id,first_func,second_func
--     ,feature_nums,button_type
--     ,source_0,source_1,devide_num