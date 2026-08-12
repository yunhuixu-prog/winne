select
app_name,date
, case
when country in
('United Kingdom','United States','Bangladesh','Brazil','Indonesia','Iran','Japan','Others'
,'Pakistan','Philippines','Singapore', 'South Korea','Thailand','Turkey','Vietnam') then country
when country in (
'Australia','Canada','Malaysia','Singapore','Nigeria','South Africa','New Zealand','Pakistan','India','Ghana'
,'Jamaica','Tanzania','Sri Lanka','Cyprus','Malta','Kenya','Maldives','Zambia','Fiji','Trinidad & Tobago','Bangladesh'
,'Uganda','Bahamas','Seychelles','Mozambique','Mauritius','Namibia','Botswana','Sierra Leone','Barbados','Rwanda'
,'St. Lucia','Vanuatu','Cameroon','Brunei','Papua New Guinea','Guyana','Malawi','Antigua & Barbuda','Gambia'
,'St. Kitts & Nevis','Belize','Samoa','Grenada','St. Vincent & Grenadines','Dominica','Eswatini','Lesotho'
,'Solomon Islands','Tonga','Nauru','Kiribati') then '英联邦国家（除英国、图瓦卢）'
when country in (
'Russia','Spain','Germany','Ukraine','Italy','Switzerland','France','Netherlands','Sweden','Portugal','Ireland'
,'Greece','Poland','Romania','Norway','Hungary','Denmark','Serbia','Austria','Finland','Belgium','Slovakia'
,'Croatia','Czechia','Belarus','Lithuania','Bulgaria','Latvia','Slovenia','Malta','Moldova','Estonia','Iceland'
,'Montenegro','Luxembourg','Albania','Monaco','San Marino','Andorra','Liechtenstein'
) then '欧洲国家（除英国、梵蒂冈、波斯尼亚和黑塞哥维那、北马其顿）'
else 'Others'
end country_name
,sum(valid_paying_users)/sum(dau) valid_paying_rate
,sum(dau) mau
,sum(valid_paying_users)valid_paying_users
from `dataintegration-265403.revenue.ads_dz_pix_revenue_report_view`
where
report ='monthly'
and date >='2025-01-01'
and app_name = 'AirBrush'
group by 1,2,3