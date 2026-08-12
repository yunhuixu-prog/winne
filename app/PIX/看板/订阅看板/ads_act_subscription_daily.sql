SELECT
  a.event_date as Date,
  case --when a.app_name in ('AirVid') then 'AirBrush Video' 
  when a.app_name in ('BeautyPlus Story') then 'Vmake' else a.app_name end  as App,
  --a.app_name as App,
  '' as SKU_type,
  case when a.user_type=1 then 'New users'
  when a.user_type=2 then 'Low active users'
  when a.user_type=3 then 'Middle active users'
  when a.user_type=4 then 'High active users'
  /*when a.user_type=5 then 'Retain users'
  when a.user_type=5 then 'Retain users'
  when a.user_type=6 then 'Churn users'*/
  end as User_type,
  a.is_ua as is_UA,
  case when b.fix_firebase_en_name  in ('China') then 'China Mainland' else b.fix_firebase_en_name end as Country,
  a.platform as Platform,
  a.Active_users,
  --a.Trial_users,
  a.Trial_Active_users as Trial_active_users,
  a.Paid_Active_users as Paid_active_users,
  0 as Active_Vaild_Standard_Paid_Users,
  0 as Active_Vaild_Promotional_Paid_Users
FROM
  `dataintegration-265403.subscription.dws_act_subscription_daily` a
    LEFT JOIN (
  SELECT
    DISTINCT key,
    fix_firebase_en_name
  FROM
    `dataintegration-265403.dmi.dmi_ya_country_code`,
    UNNEST(names) key) b
ON  a.country = b.key
--where a.app_name not like 'com.%'
where a.app_name in ('AirVid','Pomelo','AirBrush','BeautyPlus Story','BeautyPlus','PartyNow','VCUS')
and a.event_date<'2022-01-01'

union all

SELECT
  a.event_date as Date,
  case --when a.app_name in ('AirVid') then 'AirBrush Video' 
  when a.app_name in ('BeautyPlus Story') then 'Vmake' when a.app_name in ('Themeu') then 'ThemeU' else a.app_name end  as App,
  --a.app_name as App,
  '' as SKU_type,
  case when a.User_type=1 then 'New users'
  when a.User_type=2 then 'Low active users'
  when a.User_type=3 then 'Middle active users'
  when a.User_type=4 then 'High active users'
  /*when a.User_type=5 then 'Retain users'
  when a.User_type=5 then 'Retain users'
  when a.User_type=6 then 'Churn users'*/
  end as User_type,
  a.is_ua as is_UA,
  case when b.fix_firebase_en_name  in ('China') then 'China Mainland' else b.fix_firebase_en_name end as Country,
  a.platform as Platform,
  a.DAU as Active_users,
  --a.Trial_users,
  a.Active_valid_trial_users as Trial_active_users,
  a.Active_valid_paid_users as Paid_active_users,
  Active_Vaild_Standard_Paid_Users,
  Active_Vaild_Promotional_Paid_Users
FROM
   `dataintegration-265403.subscription.dws_act_subscription_daily_new` a
    LEFT JOIN (
  SELECT
    DISTINCT key,
    fix_firebase_en_name
  FROM
    `dataintegration-265403.dmi.dmi_ya_country_code`,
    UNNEST(names) key) b
ON  a.country = b.key
--where a.app_name not like 'com.%'
where a.app_name in ('AirVid','Pomelo','AirBrush','BeautyPlus Story','BeautyPlus','PartyNow','VCUS','PlusMe','Beauty Plus Cam','AirGlow','Themeu','AirBrush Video')
and a.event_date>='2022-01-01'