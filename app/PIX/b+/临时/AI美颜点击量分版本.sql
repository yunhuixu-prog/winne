



select event_date,version,if(version<'7.6.030','old','new') version_type,event_name,count(distinct user_pseudo_id) uv,count(1) pv
from `dataintegration-265403.analytics.dwd_dzp_events_function`('2024-03-15','2024-03-21','beautyplus',false)
where (event_name = 'beauty_appr_beau_clk_bd'
        and `dataintegration-265403.func`.getParams(event_params,'子功能').string_value ='Ai美颜')
      or event_name in ('aibeauty_requesttime_bd','aibeauty_icon_bd')
group by 1,2,3,4


