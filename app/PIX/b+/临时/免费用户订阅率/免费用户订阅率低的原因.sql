-- 和ab对比一下
-- 分国家/渠道/平台
select date,App,Platform,is_UA
  ,case when  country in ('Austria', 'Belgium', 'Bulgaria', 'Hungary', 'Germany', 'Greece', 'Denmark', 'Ireland', 'Spain'
                        , 'Italy', 'Cyprus', 'Latvia', 'Lithuania', 'Luxembourg','Malta', 'Netherlands', 'Poland', 'Portugal', 'Romania'
                        , 'Slovakia', 'Slovenia', 'Finland', 'France', 'Croatia' , 'Czechia','Sweden','Estonia'
                        /* 'United Kingdom',*/
                        ) then 'European Union'
        when country in ('Turkey','Saudi Arabia','Egypt','United Arab Emirates','Lebanon','Kuwait','Qatar','Iran') then 'Middle East'
        when country in ('United States','United Kingdom','Japan','Brazil','South Korea','Thailand','Indonesia','India','Bangladesh'
                        ,'Vietnam','Russia','Pakistan','Philippines') then country
        else 'other'
  end country
  ,sum(MAU) mau,sum(coalesce(New_paid_users,0)+coalesce(Promotional_paid_users,0)) free_paying_users
from dataintegration-265403.subscription.dws_subscription_overview_monthly_view
where App in ('AirBrush','BeautyPlus') and date>='2023-09-01' and country not in ('All')
group by 1,2,3,4,5
;
-- 分机型/手机价格
-- 分产品目的
select a.app_name,platform
     ,case when  country in ('Austria', 'Belgium', 'Bulgaria', 'Hungary', 'Germany', 'Greece', 'Denmark', 'Ireland', 'Spain'
                        , 'Italy', 'Cyprus', 'Latvia', 'Lithuania', 'Luxembourg','Malta', 'Netherlands', 'Poland', 'Portugal', 'Romania'
                        , 'Slovakia', 'Slovenia', 'Finland', 'France', 'Croatia' , 'Czechia','Sweden','Estonia'
                        /* 'United Kingdom',*/
                        ) then 'European Union'
        when country in ('Turkey','Saudi Arabia','Egypt','United Arab Emirates','Lebanon','Kuwait','Qatar','Iran') then 'Middle East'
        when country in ('United States','United Kingdom','Japan','Brazil','South Korea','Thailand','Indonesia','India','Bangladesh'
                        ,'Vietnam','Russia','Pakistan','Philippines') then country
        else 'other'
  end country
     ,case when phone_price<=800 then '1:[0,800]'
                 when phone_price<=1000 then '2:(800,1000]'
                 when phone_price<=2500 then '3:(1000,2500]'
                 when phone_price<=5000 then '4:(2500,5000]'
                 when phone_price<=8000 then '5:(5000,8000]'
                 when phone_price<=10000 then '6:(8000,1000]'
                 when phone_price>10000 then '7:(10000,)'
            end phone_price_type
     ,case when active_day <=1 then '1:1'
           when active_day <=2 then '2:2'
           when active_day <=3 then '3:3'
           when active_day <=5 then '4:[4,5]'
           when active_day <=10 then '5:[6,10]'
           when active_day >10 then '6:(10,)'
     end active_day_type
    ,selfie_edit_entry
    ,count(distinct a.user_pseudo_id) mau,count(distinct case when b.uuid is not null then a.uuid end) paying_mau
from
(
    select app_name,user_pseudo_id,uuid
         ,count(distinct date) active_day
         ,max(country) country
         ,max(is_UA) is_UA
         ,max(platform) platform
    from
    (
        select event_date_hk date,app_name,user_pseudo_id,uuid,country,is_UA,platform
        from `dataintegration-265403.stat.stat_active_advice_detail_d`
        where
            event_date_hk between '2024-08-01' and '2024-08-31'
            and app_name in ('BeautyPlus','AirBrush')
    )
    group by 1,2,3
) a
left join
(
    select distinct app_id,uuid
    from `dataintegration-265403.subscription.dwd_trial_subscription_retention_daily_temp`
    where standard_order_date between '2024-08-01' and '2024-08-31'
    and (
        subscription_user_type in ('first_time_subscription','first_time_return_subscription')
        or (offer_method not in ('trial', 'normal')
                    and order_status != 0
                    and subscription_user_type != 'refund')
        )
    and app_id in ('AirBrush','BeautyPlus')
) b
on a.app_name=b.app_id and a.uuid=b.uuid
left join
(
    select 'BeautyPlus' app_name,user_pseudo_id,phone_price
        ,case when coalesce(pv_tab0_edit_entry_30,0)<=0 and coalesce(pv_tab0_selfie_entry_30,0)<=0 then '0:0 edit 0 camera'
            when coalesce(pv_tab0_edit_entry_30,0)<=0 and coalesce(pv_tab0_selfie_entry_30,0)>0 then '1:0 edit >0 camera'
            when coalesce(pv_tab0_edit_entry_30,0)>0 then '2:>0 edit'
        else '异常'
        end selfie_edit_entry
    from beautyplus-bc0ed.temp.dws_dz_his_split_user_behave_t
    where date = '2024-08-31' and last_active_days<=31

    union all

    select 'AirBrush' app_name,user_pseudo_id,phone_price
       ,case when coalesce(`pv_edit_enter-all-all_30`,0)<=0 and coalesce(`pv_camera_enter-all-all_30`,0)<=0 then '0:0 edit 0 camera'
            when coalesce(`pv_edit_enter-all-all_30`,0)<=0 and coalesce(`pv_camera_enter-all-all_30`,0)>0 then '1:0 edit >0 camera'
            when coalesce(`pv_edit_enter-all-all_30`,0)>0 then '2:>0 edit'
        else '异常'
        end selfie_edit_entry
    from airbrush-1324.temp.dws_dz_his_split_user_behave
    where date = '2024-08-31' and last_active_days<=31
) c
on a.app_name=c.app_name and a.user_pseudo_id=c.user_pseudo_id
group by 1,2,3,4,5,6
order by 1,2,3,4,5,6

-- select 'BeautyPlus' app_name
--    ,case when coalesce(pv_tab0_edit_entry_30,0)<=0 then 0
--         when coalesce(pv_tab0_edit_entry_30,0)<=1 then 1
--         when coalesce(pv_tab0_edit_entry_30,0)<=3 then 2
--         when coalesce(pv_tab0_edit_entry_30,0)<=5 then 3
--         when coalesce(pv_tab0_edit_entry_30,0)<=10 then 4
--         when coalesce(pv_tab0_edit_entry_30,0)<=15 then 5
--         when coalesce(pv_tab0_edit_entry_30,0)<=30 then 6
--         when coalesce(pv_tab0_edit_entry_30,0)<=60 then 7
--     else 8 end pv_tab0_edit_entry_30
--    ,case when coalesce(pv_tab0_selfie_entry_30,0)<=0 then 0
--         when coalesce(pv_tab0_selfie_entry_30,0)<=1 then 1
--         when coalesce(pv_tab0_selfie_entry_30,0)<=3 then 2
--         when coalesce(pv_tab0_selfie_entry_30,0)<=5 then 3
--         when coalesce(pv_tab0_selfie_entry_30,0)<=10 then 4
--         when coalesce(pv_tab0_selfie_entry_30,0)<=15 then 5
--         when coalesce(pv_tab0_selfie_entry_30,0)<=30 then 6
--         when coalesce(pv_tab0_selfie_entry_30,0)<=60 then 7
--         when coalesce(pv_tab0_selfie_entry_30,0)<=100 then 8
--     else 9 end pv_tab0_selfie_entry_30
--    ,count(distinct uuid),count(distinct case when sub_365>0 then uuid end)
-- from beautyplus-bc0ed.temp.dws_dz_his_split_final_user_behave
-- where date = '2024-08-31' and last_active_days<=31
-- group by 1,2,3
-- order by 1,2,3

