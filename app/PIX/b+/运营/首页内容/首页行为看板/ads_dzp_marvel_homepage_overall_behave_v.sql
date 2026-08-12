-- `beautyplus-bc0ed.temp.ads_dzp_marvel_homepage_overall_behave_v`

select event_date,platform,country,is_new,is_UA,is_pay,version
        ,'selfie' module,exposure_uv,click_uv
        ,null content_show_uv
        ,null content_show_pv
        ,selfie_click_uv content_click_uv
        ,selfie_click_pv content_click_pv
from `beautyplus-bc0ed.marvel.ads_dzp_marvel_homepage_overall_behave`

union all

select event_date,platform,country,is_new,is_UA,is_pay,version
        ,'edit' module,exposure_uv,click_uv
        ,null content_show_uv
        ,null content_show_pv
        ,edit_click_uv content_click_uv
        ,edit_click_pv content_click_pv
from `beautyplus-bc0ed.marvel.ads_dzp_marvel_homepage_overall_behave`

union all

select event_date,platform,country,is_new,is_UA,is_pay,version
        ,'search' module,exposure_uv,click_uv
        ,null content_show_uv
        ,null content_show_pv
        ,homepage_search_click_uv content_click_uv
        ,homepage_search_click_pv content_click_pv
from `beautyplus-bc0ed.marvel.ads_dzp_marvel_homepage_overall_behave`

union all

select event_date,platform,country,is_new,is_UA,is_pay,version
        ,'bottom tab' module,exposure_uv,click_uv
        ,null content_show_uv
        ,null content_show_pv
        ,tab_click_uv content_click_uv
        ,tab_click_pv content_click_pv
from `beautyplus-bc0ed.marvel.ads_dzp_marvel_homepage_overall_behave`

union all

select event_date,platform,country,is_new,is_UA,is_pay,version
        ,'sub button' module,exposure_uv,click_uv
        ,null content_show_uv
        ,null content_show_pv
        ,vip_click_uv content_click_uv
        ,vip_click_pv content_click_pv
from `beautyplus-bc0ed.marvel.ads_dzp_marvel_homepage_overall_behave`

union all

select event_date,platform,country,is_new,is_UA,is_pay,version
        ,'pop' module,exposure_uv,click_uv
        ,null content_show_uv
        ,null content_show_pv
        ,pop_click_uv content_click_uv
        ,pop_click_pv content_click_pv
from `beautyplus-bc0ed.marvel.ads_dzp_marvel_homepage_overall_behave`

union all

select event_date,platform,country,is_new,is_UA,is_pay,version
        ,'topbar' module,exposure_uv,click_uv
        ,feature_content_show_uv content_show_uv
        ,feature_content_show_pv content_show_pv
        ,feature_content_click_uv content_click_uv
        ,feature_content_click_pv content_click_pv
from `beautyplus-bc0ed.marvel.ads_dzp_marvel_homepage_overall_behave`

union all

select event_date,platform,country,is_new,is_UA,is_pay,version
        ,'banner' module,exposure_uv,click_uv
        ,banner_content_show_uv content_show_uv
        ,banner_content_show_pv content_show_pv
        ,banner_content_click_uv content_click_uv
        ,banner_content_click_pv content_click_pv
from `beautyplus-bc0ed.marvel.ads_dzp_marvel_homepage_overall_behave`

union all

select event_date,platform,country,is_new,is_UA,is_pay,version
        ,'recommend' module,exposure_uv,click_uv
        ,reconmend_content_show_uv content_show_uv
        ,reconmend_content_show_pv content_show_pv
        ,reconmend_content_click_uv content_click_uv
        ,reconmend_content_click_pv content_click_pv
from `beautyplus-bc0ed.marvel.ads_dzp_marvel_homepage_overall_behave`

union all

select event_date,platform,country,is_new,is_UA,is_pay,version
        ,'topic' module,exposure_uv,click_uv
        ,topic_content_show_uv content_show_uv
        ,topic_content_show_pv content_show_pv
        ,topic_content_click_uv content_click_uv
        ,topic_content_click_pv content_click_pv
from `beautyplus-bc0ed.marvel.ads_dzp_marvel_homepage_overall_behave`

union all

select event_date,platform,country,is_new,is_UA,is_pay,version
        ,'miniapp' module,exposure_uv,click_uv
        ,miniapp_content_show_uv content_show_uv
        ,miniapp_content_show_pv content_show_pv
        ,miniapp_content_click_uv content_click_uv
        ,miniapp_content_click_pv content_click_pv
from `beautyplus-bc0ed.marvel.ads_dzp_marvel_homepage_overall_behave`

union all

select event_date,platform,country,is_new,is_UA,is_pay,version
        ,'topbanner' module,exposure_uv,click_uv
        ,topbanner_content_show_uv content_show_uv
        ,topbanner_content_show_pv content_show_pv
        ,topbanner_content_click_uv content_click_uv
        ,topbanner_content_click_pv content_click_pv
from `beautyplus-bc0ed.marvel.ads_dzp_marvel_homepage_overall_behave`

union all

select event_date,platform,country,is_new,is_UA,is_pay,version
        ,'xyz' module,exposure_uv,click_uv
        ,xyz_content_show_uv content_show_uv
        ,xyz_content_show_pv content_show_pv
        ,xyz_content_click_uv content_click_uv
        ,xyz_content_click_pv content_click_pv
from `beautyplus-bc0ed.marvel.ads_dzp_marvel_homepage_overall_behave`
