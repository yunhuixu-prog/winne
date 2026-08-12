-- dnu
select is_ua,sum(uv)
from (
        select date_p,is_ua,count(distinct gid) uv
        from (
            SELECT
                a.date_p,
                a.os_p,
                a.final_id gid,
          		is_ua
            FROM
            (
                SELECT date_p, os_p, country_id, final_id, is_ua
                FROM stat_sdk.sdk_odz_active
                WHERE date_p BETWEEN 20260301 and 20260331
                    AND app_key_p IN ('C851ED7164B6DF0F', '7F7023B6CEC7CDED')
                    AND os_p IS NOT NULL
            ) a
            JOIN
            (
                SELECT final_id, date_p
                FROM stat_sdk.sdk_odz_new_device_info
                WHERE date_p BETWEEN 20260301 and 20260331
                AND app_key_p IN ('C851ED7164B6DF0F', '7F7023B6CEC7CDED')
                AND os_p IS NOT NULL
            )new_device
            ON a.final_id = new_device.final_id AND a.date_p = new_device.date_p
          ) t
          group by date_p,is_ua) t
          group by is_ua

-- mnu

            SELECT
                a.final_id,count(distinct is_ua) ua_num
                ,max(case when new_device.final_id is not null then 1 else 0 end) is_new
            FROM
            (
                SELECT date_p, os_p, country_id, final_id, is_ua
                FROM stat_sdk.sdk_odz_active
                WHERE date_p BETWEEN 20260301 and 20260331
                    AND app_key_p IN ('C851ED7164B6DF0F', '7F7023B6CEC7CDED')
                    AND os_p IS NOT NULL
            ) a
            left JOIN
            (
                SELECT final_id, date_p
                FROM stat_sdk.sdk_odz_new_device_info
                WHERE date_p BETWEEN 20260301 and 20260331
                AND app_key_p IN ('C851ED7164B6DF0F', '7F7023B6CEC7CDED')
                AND os_p IS NOT NULL
            )new_device
            ON a.final_id = new_device.final_id AND a.date_p = new_device.date_p
            group by a.final_id
            having count(distinct is_ua)>1
            and max(case when new_device.final_id is not null then 1 else 0 end)=1

