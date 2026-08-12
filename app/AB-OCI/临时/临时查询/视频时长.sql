SELECT video_time
     ,round(sum(uv)/count(distinct date_p)) uv
     ,round(sum(pv)/count(distinct date_p)) pv
FROM
(
SELECT date_p
        ,case when params['video_time']/1000 <=3 then '1:<=3s'
        	  when params['video_time']/1000 <=5 then '2:3s~5s'
        	  when params['video_time']/1000 <=10 then '3:5s~10s'
        	  when params['video_time']/1000 <=60 then '4:10s~1min'
        	  when params['video_time']/1000 <=60*5 then '5:1min~5min'
        	  when params['video_time']/1000 >60*5 then '6:>5min'
        end video_time
        ,count(distinct gid) uv
        ,count(1) pv
FROM stat_sdk.sdk_odz_source_data
WHERE date_p between 20260224 and 20260323
    AND app_key_p IN ('C851ED7164B6DF0F', '7F7023B6CEC7CDED')
    AND event_id IN  ('video_face_identify_success')
group by date_p,case when params['video_time']/1000 <=3 then '1:<=3s'
        	  when params['video_time']/1000 <=5 then '2:3s~5s'
        	  when params['video_time']/1000 <=10 then '3:5s~10s'
        	  when params['video_time']/1000 <=60 then '4:10s~1min'
        	  when params['video_time']/1000 <=60*5 then '5:1min~5min'
        	  when params['video_time']/1000 >60*5 then '6:>5min'
        end
) t
group by video_time