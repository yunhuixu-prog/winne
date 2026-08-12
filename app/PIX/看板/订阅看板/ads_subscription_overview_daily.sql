SELECT 
  a.event_date AS Date,
  a.DAU,
  a.DNU,
  case --when a.app_name in ('AirVid') then 'AirBrush Video' 
  when a.app_name in ('BeautyPlus Story') then 'Vmake' else a.app_name end  as App,
  --a.app_name as App,
  --a.app_name AS App,
  a.platform AS Platform,
  a.is_ua AS is_UA,
  case when b.fix_firebase_en_name  in ('China') then 'China Mainland' else b.fix_firebase_en_name end as Country,
  a.Valid_trial_users,
  a.Valid_paid_users,
  a.Trial_users,
  a.New_paid_users,
  a.New_paid_revenue,
  a.Renewal_users,
  a.Renewal_revenue,
  a.New_return_users,
  a.New_return_revenue,
  a.Paid_users,
  a.VAS,
  a.CM,
  0 as Vaild_Standard_Paid_Users,
  0 as Vaild_Promotional_Paid_Users,
  0 as Promotional_paid_users,
  0 as Promotional_paid_revenue,
  0 as Trial_to_paid_users,
  0 as Promotional_to_standard_paid_users
FROM
  `dataintegration-265403.subscription.dws_subscription_overview_daily` a
  LEFT JOIN (
  SELECT
    DISTINCT key,
    fix_firebase_en_name
  FROM
    `dataintegration-265403.dmi.dmi_ya_country_code`,
    UNNEST(names) key) b
ON  a.country = b.key
--where a.app_name not like 'com.%' and a.app_name  not in ('Avatoon','ChicCam')
where a.app_name in ('AirVid','Pomelo','AirBrush','BeautyPlus Story','BeautyPlus','PartyNow','VCUS')
and a.event_date between '2020-07-01'and '2021-12-31'

union all 

SELECT 
  a.event_date AS Date,
  a.DAU,
  a.DNU,
  case --when a.app_name in ('AirVid') then 'AirBrush Video' 
  when a.app_name in ('BeautyPlus Story') then 'Vmake' 
  when a.app_name in ('Themeu') then 'ThemeU' 
  else a.app_name end  as App,
  --a.app_name as App,
  --a.app_name AS App,
  a.platform AS Platform,
  a.is_ua AS is_UA,
  case when b.fix_firebase_en_name  in ('China') then 'China Mainland' else b.fix_firebase_en_name end as Country,
  a.Valid_trial_users,
  a.Valid_paid_users,
  a.Trial_users,
  a.New_paid_users-a.New_return_users as New_paid_users,
  a.New_paid_revenue-a.New_return_revenue as New_paid_revenue,
  a.Renewal_users,
  a.Renewal_revenue,
  a.New_return_users,
  a.New_return_revenue,
  a.Paid_users,
  a.VAS,
  a.CM,
  a.Vaild_Standard_Paid_Users,
  a.Vaild_Promotional_Paid_Users,
  a.Promotional_paid_users,
  a.Promotional_paid_revenue,
  a.Trial_to_paid_users,
  a.Promotional_to_standard_paid_users
FROM
  `dataintegration-265403.subscription.dws_subscription_overview_daily_new` a
  LEFT JOIN (
  SELECT
    DISTINCT key,
    fix_firebase_en_name
  FROM
    `dataintegration-265403.dmi.dmi_ya_country_code`,
    UNNEST(names) key) b
ON  a.country = b.key
--where a.app_name not like 'com.%' and a.app_name  not in ('Avatoon','ChicCam')
where a.app_name in ('AirVid','Pomelo','AirBrush','BeautyPlus Story','BeautyPlus','PartyNow','VCUS','PlusMe','Beauty Plus Cam','AirGlow','Beauty Plus Story','Themeu','AirBrush Video')
and a.event_date >= '2022-01-01'