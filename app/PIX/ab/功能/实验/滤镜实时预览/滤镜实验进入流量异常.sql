-- 滤镜
select sdk_type,abcode,sum(uv) uv
from
(
    SELECT
         date_p,
        params['current_abcode'] abcode,
        sdk_type,
        count(distinct gid) uv
 FROM stat_sdk.sdk_odz_source_data
    WHERE date_p between 20251215 and 20251222
    AND app_key_p IN ('C851ED7164B6DF0F', '7F7023B6CEC7CDED')
    and event_id = 'abcode_enter_test'
        AND params['current_abcode'] IN ('28465','28466','28467')
    and app_version>='7.22.0'
   group by date_p,params['current_abcode'],sdk_type
) a
group by sdk_type,abcode
order by sdk_type,abcode


-- 磨皮
select sdk_type,abcode,sum(uv) uv
from
(
        SELECT
         date_p,
        params['current_abcode'] abcode,
        sdk_type,
        count(distinct gid) uv
 FROM stat_sdk.sdk_odz_source_data
    WHERE date_p between 20251215 and 20251222
    AND app_key_p IN ('C851ED7164B6DF0F', '7F7023B6CEC7CDED')
    and event_id = 'abcode_enter_test'
        AND params['current_abcode'] IN ('28462','28463','28464')
    and app_version>='7.22.5'
   group by date_p,params['current_abcode'],sdk_type
) a
group by sdk_type,abcode
order by sdk_type,abcode