

    select case when DATE_DIFF(event_date_hk,first_active_date,DAY)+1 <=7 then '1:1-7'
                when DATE_DIFF(event_date_hk,first_active_date,DAY)+1 <=30 then '2:8-30'
                when DATE_DIFF(event_date_hk,first_active_date,DAY)+1 <=90 then '3:31-90'
                when DATE_DIFF(event_date_hk,first_active_date,DAY)+1 <=180 then '4:91-180'
                when DATE_DIFF(event_date_hk,first_active_date,DAY)+1 <=365 then '5:181-365'
                when DATE_DIFF(event_date_hk,first_active_date,DAY)+1 >365 then '6:365+'
            end install_days_type
            ,round(count(1)/count(distinct event_date_hk)) uv
    from `beautyplus-bc0ed.dim.dim_dzp_portrait_firebase_id_user` t1
    where event_date_hk between '2024-05-01' and '2024-05-30'
        and last_active_date=event_date_hk
    group by 1
    order by 1


    select case when DATE_DIFF(event_date_hk,first_active_date,DAY)+1 <=7 then '1:1-7'
                when DATE_DIFF(event_date_hk,first_active_date,DAY)+1 <=30 then '2:8-30'
                when DATE_DIFF(event_date_hk,first_active_date,DAY)+1 <=90 then '3:31-90'
                when DATE_DIFF(event_date_hk,first_active_date,DAY)+1 <=180 then '4:91-180'
                when DATE_DIFF(event_date_hk,first_active_date,DAY)+1 <=365 then '5:181-365'
                when DATE_DIFF(event_date_hk,first_active_date,DAY)+1 >365 then '6:365+'
            end install_days_type
            ,round(count(1)/count(distinct event_date_hk)) uv
    from `beautyplus-bc0ed.dim.dim_dzp_portrait_firebase_id_user` t1
    where event_date_hk = '2024-06-11'
    group by 1
    order by 1