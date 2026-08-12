-- 首页整体看板
-- drop table if exists `beautyplus-bc0ed.temp.dwd_dz_homepage_overall_behave_pre`;
-- create table if not exists `beautyplus-bc0ed.temp.dwd_dz_homepage_overall_behave_pre` as

delete from beautyplus-bc0ed.temp.dwd_dz_homepage_overall_behave_pre where event_date between '{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=3)).strftime("%Y-%m-%d") }}' and '{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=0)).strftime("%Y-%m-%d") }}';
insert into beautyplus-bc0ed.temp.dwd_dz_homepage_overall_behave_pre
(
    event_date,event_name,user_pseudo_id
    ,version,module_positon,module_type,module_id,content_type,content_id,time,type,pv
    ,country,platform,is_new,is_UA,is_pay
)

with event_pre as
(
  select
    event_date
      ,event_name
      ,user_pseudo_id
      ,app_info.version
      ,geo.country
      ,platform
      ,`dataintegration-265403.func`.getParams(event_params,'模块类型').string_value as module_type
      ,`dataintegration-265403.func`.getParams(event_params,'模块id').string_value as module_id
      ,`dataintegration-265403.func`.getParams(event_params,'内容类型').string_value as content_type
      ,`dataintegration-265403.func`.getParams(event_params,'内容id').string_value as content_id
      ,`dataintegration-265403.func`.getParams(event_params,'type').string_value as type
      ,`dataintegration-265403.func`.getParams(event_params,'source').string_value as source
      ,coalesce(cast(`dataintegration-265403.func`.getParams(event_params,'模块位置').string_value as int64),`dataintegration-265403.func`.getParams(event_params,'模块位置').int_value) module_positon
      ,coalesce(cast(`dataintegration-265403.func`.getParams(event_params,'time').string_value as int64),`dataintegration-265403.func`.getParams(event_params,'time').int_value) time
  from
    `dataintegration-265403.analytics.dwd_dzp_events_function`('{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=3)).strftime("%Y-%m-%d") }}','{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=0)).strftime("%Y-%m-%d") }}', 'beautyplus', false)
  where
    event_name in ('home_content_clk_bd','home_content_show_f_bd','homepageappr_bd','home_page_time_bd','home_clk_selfie_bd','home_clk_beautify_bd','home_clk_edit_bd','tabbar_clk_bd','material_search_button_clk_bd'
                        ,'home_page_pop_appr_bd','home_page_pop_clk_bd') -- 新增首页弹窗曝光点击(点击需要筛掉点X的)
    or
    (
        event_name='page_event' and `dataintegration-265403.func`.getParams(event_params,'source_click_position').string_value='默认入口'
        and `beautyplus-bc0ed.func.decodeSpmNew`(`beautyplus-bc0ed.func.getParams`(event_params,'pre_spm').string_value).page_id='1007'
    ) -- 点击首页默认订阅入口
)
,
user_info as
(
    select
        event_date event_date_hk
        ,platform
--         ,case when country in ('South Korea','Thailand','Japan','United States') then country
--           when country in ('Turkey','Saudi Arabia','Egypt','United Arab Emirates','Lebanon','Kuwait','Qatar','Iran') then 'Middle East'
--           else 'WW'
--         end as country
        ,country
        ,user_pseudo_id
        ,max(case when is_new='New users' then 1 else 0 end) is_new
        ,max(is_UA) is_UA
        ,max(is_pay) is_pay
    from
        `beautyplus-bc0ed.event_dataset_2.dws_dz_active_user_02`
    where
        event_date between '{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=3)).strftime("%Y-%m-%d") }}' and '{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=0)).strftime("%Y-%m-%d") }}'
    group by 1,2,3,4
)

select a.event_date,a.event_name,a.user_pseudo_id
        ,a.version,a.module_positon,a.module_type,a.module_id,a.content_type,a.content_id,a.time,a.type,a.pv
        ,b.country,b.platform,b.is_new,b.is_UA,b.is_pay
from
  (
    select
      event_date
      ,case when event_name='tabbar_clk_bd' and type='camera' then 'home_clk_selfie_bd' else event_name end event_name
      ,module_positon
      ,user_pseudo_id
      ,version
      ,platform
      ,module_type
      ,module_id
      ,content_type
      ,content_id
      ,time
      ,type
      ,count(1) pv
    from
      event_pre
    where
        case when event_name in ('home_page_time_bd') then time is not null and time>0 and time<=24*60*60*1000
         when event_name in ('material_search_button_clk_bd') then source='home_page_search'
         when event_name in ('tabbar_clk_bd') then type in ('me','miniapp','discover','camera')
         when event_name in ('home_page_pop_clk_bd') then type in ('try_it')
        else 1=1
        end
    group by 1,2,3,4,5,6,7,8,9,10,11,12
  ) a
  join user_info b on a.user_pseudo_id = b.user_pseudo_id and a.event_date = b.event_date_hk and a.platform = b.platform








