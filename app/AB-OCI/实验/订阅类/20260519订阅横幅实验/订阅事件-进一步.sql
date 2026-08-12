select
    -- a.date_p,
    a.os_type os_type
    ,case when b.ab_code in ('28947') then '对照组'
        when b.ab_code in ('28948') then '实验组A'
        end code
    ,b.is_new is_new
    ,case when b.country in ('美国','巴西','英国') then b.country else '其他' end country
    ,case when source_module='p_edit' and source_0 in ('f_face','f_reshape') then source_0 
          when source_module='p_edit' then 'other_edit'
          else 'else' end source_0
--     ,b.enter_abtest_date
    -- 付费
    ,a.duration duration
    ,if(o.gid is not null,1,0) is_pro_banner_click

    ,count(distinct case when a.event_id='w_subscription_enter' then a.gid end) sub_enter_uv
    ,count(distinct case when a.event_id='w_subscription_click' then a.gid end) sub_click_uv
    ,count(distinct case when a.event_id='sub_suc' then a.gid end) sub_suc_uv
    ,count(distinct case when a.event_id='sub_suc' and a.is_paid=1 then a.gid end) sub_suc_to_paid_uv
    ,round(sum(case when a.event_id='sub_suc' and a.is_paid=1 then a.paid_ord_amt end),2) sub_suc_to_paid_gmv
    ,count(distinct case when a.event_id='edit_save' then a.gid end) save_uv
    ,0 enter_abtest_uv
from (
    select date_p
        ,case when os_type in ('其他') then 'Android'
            else os_type
            end os_type
        ,event_id
        ,unix_timestamp(event_time, 'yyyyMMddHHmmss') event_timestamp -- 1776025242
        ,gid -- ,is_new,is_ua,country
        ,duration,source_module,source_0,source_1
        -- ,mids_material_id,mids_category_id,sku
        ,is_paid,paid_date,paid_ord_amt
    from stat_ab.filing_onz_sub_source_event_detail
    where
        date_p between 20260519 and 20260617
        and event_id in ('w_subscription_enter','w_subscription_click','w_subscription_success','sub_suc')

    union all 

     SELECT date_p
        ,sdk_type os_type
        ,event_id
        ,CAST(`time`/1000 AS bigint) event_timestamp
        ,gid
        ,'无' duration,'无' source_module,'无' source_0,'无' source_1
        ,'无' is_paid,'无' paid_date,'无' paid_ord_amt
    FROM stat_sdk.sdk_odz_source_data
    WHERE date_p between 20260519 and 20260617
        AND app_key_p IN ('C851ED7164B6DF0F', '7F7023B6CEC7CDED')
        AND event_id = 'edit_save'
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
                WHERE date_p BETWEEN 20260519 and 20260617
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
                WHERE date_p BETWEEN 20260519 and 20260617
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
            WHERE date_p between 20260519 and 20260617
                AND app_key_p IN ('C851ED7164B6DF0F', '7F7023B6CEC7CDED')
                AND event_id = 'abcode_enter_test'
                AND params['current_abcode'] in ('28947','28948')
        ) e ON e.gid = fa.gid and e.enter_abtest_date = fa.date_p
        where e.gid is not null
    ) t
    where ranks=1
) b
on a.gid= b.gid
left join (
    SELECT distinct gid
            FROM stat_sdk.sdk_odz_source_data
            WHERE date_p between 20260519 and 20260617
                AND app_key_p IN ('C851ED7164B6DF0F', '7F7023B6CEC7CDED')
                AND event_id = 'pro_banner_click'
) o ON o.gid = a.gid
where b.event_timestamp-15 <= a.event_timestamp
group by a.os_type,case when b.ab_code in ('28947') then '对照组'
        when b.ab_code in ('28948') then '实验组A'
        end,b.is_new,case when b.country in ('美国','巴西','英国') then b.country else '其他' end
        ,a.duration
        -- ,a.date_p
        ,case when source_module='p_edit' and source_0 in ('f_face','f_reshape') then source_0 
          when source_module='p_edit' then 'other_edit'
          else 'else' end
      ,if(o.gid is not null,1,0)

union all

select
    -- a.enter_abtest_date date_p,
    case when a.os_type = 'ios' then 'iOS'
         when a.os_type = 'android' then 'Android'
            end os_type
    ,case when a.ab_code in ('28947') then '对照组'
        when a.ab_code in ('28948') then '实验组A'
        end code
    ,a.is_new is_new
    ,case when a.country in ('美国','巴西','英国') then a.country else '其他' end country
    ,'无' source_0
    -- ,b.enter_abtest_date
    -- 付费
    ,'无' duration
    ,if(o.gid is not null,1,0) is_pro_banner_click
    ,0 sub_enter_uv
    ,0 sub_click_uv
    ,0 sub_suc_uv
    ,0 sub_suc_to_paid_uv
    ,0 sub_suc_to_paid_gmv
    ,0 save_uv
    ,count(distinct a.gid) enter_abtest_uv
from (
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
                WHERE date_p BETWEEN 20260519 and 20260617
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
                WHERE date_p BETWEEN 20260519 and 20260617
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
            WHERE date_p between 20260519 and 20260617
                AND app_key_p IN ('C851ED7164B6DF0F', '7F7023B6CEC7CDED')
                AND event_id = 'abcode_enter_test'
                AND params['current_abcode'] in ('28947','28948')
        ) e ON e.gid = fa.gid and e.enter_abtest_date = fa.date_p
        where e.gid is not null
    ) t
    where ranks=1
) a
left join (
    SELECT distinct gid
            FROM stat_sdk.sdk_odz_source_data
            WHERE date_p between 20260519 and 20260617
                AND app_key_p IN ('C851ED7164B6DF0F', '7F7023B6CEC7CDED')
                AND event_id = 'pro_banner_click'
) o ON o.gid = a.gid
group by case when a.os_type = 'ios' then 'iOS'
         when a.os_type = 'android' then 'Android'
            end
    ,case when a.ab_code in ('28947') then '对照组'
        when a.ab_code in ('28948') then '实验组A'
        end
    ,a.is_new
    ,case when a.country in ('美国','巴西','英国') then a.country else '其他' end
    ,if(o.gid is not null,1,0)
    -- ,a.enter_abtest_date

;


select os_type,code,is_new
    ,country,source_0,duration,is_pro_half_show,second_func,feature_nums
    ,sum(sub_enter_uv) sub_enter_uv
    ,sum(sub_click_uv) sub_click_uv
    ,sum(sub_suc_uv) sub_suc_uv
    ,sum(sub_suc_to_paid_uv) sub_suc_to_paid_uv
    ,sum(sub_suc_to_paid_gmv) sub_suc_to_paid_gmv
    ,sum(enter_abtest_uv) enter_abtest_uv
from (
select
    a.date_p,
    a.os_type os_type
    ,case when b.ab_code in ('28947') then '对照组'
        when b.ab_code in ('28948') then '实验组A'
        end code
    ,b.is_new is_new
    ,case when b.country in ('美国','巴西','英国') then b.country else '其他' end country
    ,case when source_module='p_edit' and source_0 in ('f_face','f_reshape') then source_0 
          when source_module='p_edit' then 'other_edit'
          else 'else' end source_0
--     ,b.enter_abtest_date
    -- 付费
    ,a.duration duration
    ,if(o.gid is not null,1,0) is_pro_half_show
    ,o.second_func second_func
    ,o.feature_nums feature_nums

    ,count(distinct case when a.event_id='w_subscription_enter' then a.gid end) sub_enter_uv
    ,count(distinct case when a.event_id='w_subscription_click' then a.gid end) sub_click_uv
    ,count(distinct case when a.event_id='sub_suc' then a.gid end) sub_suc_uv
    ,count(distinct case when a.event_id='sub_suc' and a.is_paid=1 then a.gid end) sub_suc_to_paid_uv
    ,round(sum(case when a.event_id='sub_suc' and a.is_paid=1 then a.paid_ord_amt end),2) sub_suc_to_paid_gmv
    ,0 enter_abtest_uv
from (
    select date_p
        ,case when os_type in ('其他') then 'Android'
            else os_type
            end os_type
        ,event_id
        ,unix_timestamp(event_time, 'yyyyMMddHHmmss') event_timestamp -- 1776025242
        ,gid,is_new,is_ua,country
        ,duration,source_module,source_0,source_1
        ,mids_material_id,mids_category_id,sku
        ,is_paid,paid_date,paid_ord_amt
    from stat_ab.filing_onz_sub_source_event_detail
    where
        date_p between 20260519 and 20260617
        and event_id in ('w_subscription_enter','w_subscription_click','w_subscription_success','sub_suc')
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
                WHERE date_p BETWEEN 20260519 and 20260617
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
                WHERE date_p BETWEEN 20260519 and 20260617
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
            WHERE date_p between 20260519 and 20260617
                AND app_key_p IN ('C851ED7164B6DF0F', '7F7023B6CEC7CDED')
                AND event_id = 'abcode_enter_test'
                AND params['current_abcode'] in ('28947','28948')
        ) e ON e.gid = fa.gid and e.enter_abtest_date = fa.date_p
        where e.gid is not null
    ) t
    where ranks=1
) b
on a.gid= b.gid
left join (
    SELECT gid,params['second_func'] second_func
        ,max(params['feature_nums']) feature_nums
            FROM stat_sdk.sdk_odz_source_data
            WHERE date_p between 20260519 and 20260617
                AND app_key_p IN ('C851ED7164B6DF0F', '7F7023B6CEC7CDED')
                AND event_id = 'pro_halfsheet_show'
    group by gid,params['second_func']
) o ON o.gid = a.gid
where b.event_timestamp-15 <= a.event_timestamp
group by 
    a.date_p,
    a.os_type,case when b.ab_code in ('28947') then '对照组'
        when b.ab_code in ('28948') then '实验组A'
        end,b.is_new,case when b.country in ('美国','巴西','英国') then b.country else '其他' end
        ,a.duration
        -- ,a.date_p
        ,case when source_module='p_edit' and source_0 in ('f_face','f_reshape') then source_0 
          when source_module='p_edit' then 'other_edit'
          else 'else' end
      ,if(o.gid is not null,1,0)
      ,o.feature_nums
      ,o.second_func
) t 
group by os_type,code,is_new
    ,country,source_0,duration,is_pro_half_show,second_func,feature_nums