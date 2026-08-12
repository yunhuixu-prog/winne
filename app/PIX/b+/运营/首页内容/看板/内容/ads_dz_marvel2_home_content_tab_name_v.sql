-- beautyplus-bc0ed.temp.ads_dz_marvel2_home_content_tab_name_v

select event_date,platform,version,is_UA,is_new,region,tab_name
    ,'uv' data_type
    ,sum(case when event_name in ('home_template_tab_appr_bd') then uv end) tab_exposure
    ,sum(case when event_name in ('home_template_tab_clk_bd') then uv end) tab_click
    ,sum(case when event_name in ('home_template_tab_second_page_appr_bd') then uv end) tab_second_exposure
    ,sum(case when event_name in ('home_content_show_f_bd') then uv end) content_exposure
    ,sum(case when event_name in ('home_content_clk_bd') then uv end) content_click
from beautyplus-bc0ed.temp.ads_dz_marvel2_home_content_tab_name
group by 1,2,3,4,5,6,7,8

union all

select event_date,platform,version,is_UA,is_new,region,tab_name
    ,'pv' data_type
    ,sum(case when event_name in ('home_template_tab_appr_bd') then pv end) tab_exposure
    ,sum(case when event_name in ('home_template_tab_clk_bd') then pv end) tab_click
    ,sum(case when event_name in ('home_template_tab_second_page_appr_bd') then pv end) tab_second_exposure
    ,sum(case when event_name in ('home_content_show_f_bd') then pv end) content_exposure
    ,sum(case when event_name in ('home_content_clk_bd') then pv end) content_click
from beautyplus-bc0ed.temp.ads_dz_marvel2_home_content_tab_name
group by 1,2,3,4,5,6,7,8

