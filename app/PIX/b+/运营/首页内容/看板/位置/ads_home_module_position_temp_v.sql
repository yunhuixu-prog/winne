-- beautyplus-bc0ed.temp_data.ads_home_module_position_temp_v

select *except(Region)
    ,case when Country in ('South Korea','Thailand','Japan','United States','Indonesia') then Country
--       when Country in ('Turkey','Saudi Arabia','Egypt','United Arab Emirates','Lebanon','Kuwait','Qatar','Iran') then 'Middle East'
      when Country in ('Thailand','Indonesia','Vietnam','Malaysia','Philippines','Singapore','Cambodia','Laos') then 'Southeast Asia'
      else 'WW'
 end as Region
from beautyplus-bc0ed.temp.ads_home_module_position_overall