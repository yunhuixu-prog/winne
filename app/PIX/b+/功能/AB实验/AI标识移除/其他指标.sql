
drop table if exists `beautyplus-bc0ed.temp.winne_abtest_else_function`;
create table `beautyplus-bc0ed.temp.winne_abtest_else_function` as

select
     event_date_hk as date
    ,platform,user_pseudo_id,event_timestamp
    ,event_name
    ,`dataintegration-265403.func`.getParams(event_params,'子功能').string_value sub_function
    ,`dataintegration-265403.func`.getParams(event_params,'美颜素材ID').string_value ai_retouch_material_id
    ,`dataintegration-265403.func`.getParams(event_params,'AI美颜滑竿值').string_value ai_retouch_flur
    ,`dataintegration-265403.func`.getParams(event_params,'是否应用AI仿妆').string_value if_ai_set
    ,`dataintegration-265403.func`.getParams(event_params,'是否应用美发').string_value if_hair
    ,`dataintegration-265403.func`.getParams(event_params,'染发素材ID').string_value hair_dye_material_id
    ,`dataintegration-265403.func`.getParams(event_params,'发型素材ID').string_value hair_style_material_id
    ,`dataintegration-265403.func`.getParams(event_params,'muscle').string_value if_muscle
    ,`dataintegration-265403.func`.getParams(event_params,'是否应用照片修复').string_value if_enhance
    ,func.getUserprop(user_properties,'device_id').string_value as device_id
from `dataintegration-265403.analytics.dwd_dzp_events_function`('2025-03-10', '2025-03-23', 'BeautyPlus', false)
where event_name in ('beauty_appr_beau_clk_bd','beauty_looks_clk_bd','beauty_appr_edit_clk_bd'
                    ,'beautifysave_bd'
                    ,'ai_editor_imp_bd','ai_editor_save_suc_bd','video_repair_imp_bd') -- 最后这个事件就是个壳，还是会跳到编辑页的，可以先不算吧

;


with enter_test as (
    select
        date_p event_date
        ,ab_code abcode
        ,case when ab_code in (11050,11053) then '对照组'
               when ab_code in (11051,11054) then '实验组A'
               when ab_code in (11052,11055) then '实验组B'
        end code
        ,field device_id
        ,country_id
        ,country
        ,case when is_app_new='2' then 'new user' when is_app_new='1' then 'old user' end as is_new
        ,case when app_key in ('F9B069901A7B2E8D') then 'iOS' when app_key in ('C6FF0769324CD2F1') then 'Android' end platform
        ,receive_time as timestamp
    from
        `dataintegration-265403.abtest.abtest_odz_flow` a --2.第一次进入实验用户
        left join   (select
                        event_date
                        ,device_id
                        ,max(country) country
                    from
                        `dataintegration-265403.abtest.stage_aa_meepo_enter_event`
                    group by
                        1,2 ) b on a.date_p = b.event_date and a.field = b.device_id
    where
        date_p between '2025-03-10' and '2025-03-23' -- 结合最新日期选定时间范围，如果数据回收时效高，可能不能看整个周期的留存率
        and cast(ab_code as string) in ('11050','11051','11052','11053','11054','11055')
        and field_type = 3  -- field_type = 1: user_pseudo_id ，2: gid，3：device_id
        and app_key in ('F9B069901A7B2E8D','C6FF0769324CD2F1')
)
,act as (
    select date,user_pseudo_id,device_id,event_timestamp
        ,case when event_name in ('beauty_appr_beau_clk_bd',
                            'beauty_looks_clk_bd',
                            'beauty_appr_edit_clk_bd',
                            'ai_editor_imp_bd') then 'enter'
              when event_name in (
                            'beautifysave_bd'
                            ,'ai_editor_save_suc_bd'
                            ) then  'save'
        end action
        ,case when event_name = 'beauty_appr_beau_clk_bd' and sub_function='Ai美颜' then 'AI Retouch（AI 焕颜）'
              when event_name = 'beauty_appr_beau_clk_bd' and sub_function='美发' then 'Hair（美发）'
              when event_name = 'beauty_appr_beau_clk_bd' and sub_function='增肌' then 'Muscle（AI 增肌）'
              when event_name = 'beauty_looks_clk_bd' and sub_function='AI仿妆' then 'AI Sets（AI 仿妆）'
              when event_name = 'beauty_appr_edit_clk_bd' and sub_function = '照片修复' then 'AI Enhance（AI 增强）'
              when event_name in ('ai_editor_imp_bd','ai_editor_save_suc_bd') then 'Image Quality（画质修复）'
        end function
        ,cast(null as string) sub_function
    from `beautyplus-bc0ed.temp.winne_abtest_else_function`
    where date between '2025-03-10' and '2025-03-23'
        and
        case when event_name in ('ai_editor_imp_bd','ai_editor_save_suc_bd') then 1=1
            when event_name in ('beauty_appr_beau_clk_bd','beauty_looks_clk_bd','beauty_appr_edit_clk_bd')
                then sub_function in ('Ai美颜','美发','增肌','AI仿妆','照片修复')
        else 0=1
        end

    union all

    select date,user_pseudo_id,device_id,event_timestamp
        ,'save' action
        ,'AI Retouch（AI 焕颜）' function
        ,cast(null as string) sub_function
    from `beautyplus-bc0ed.temp.winne_abtest_else_function`
    where date between '2025-03-10' and '2025-03-23'
        and event_name = 'beautifysave_bd'
                and ai_retouch_material_id is not null -- or ai_retouch_flur not in ('0')

    union all

    select date,user_pseudo_id,device_id,event_timestamp
        ,'save' action
        ,'AI Sets（AI 仿妆）' function
        ,cast(null as string) sub_function
    from `beautyplus-bc0ed.temp.winne_abtest_else_function`
    where date between '2025-03-10' and '2025-03-23'
        and event_name = 'beautifysave_bd'
                and if_ai_set is not null

    union all

    select date,user_pseudo_id,device_id,event_timestamp
        ,'save' action
        ,'Hair（美发）' function
        ,cast(null as string) sub_function
    from `beautyplus-bc0ed.temp.winne_abtest_else_function`
    where date between '2025-03-10' and '2025-03-23'
        and event_name = 'beautifysave_bd'
                and if_hair is not null

    union all

    select date,user_pseudo_id,device_id,event_timestamp
        ,'save' action
        ,'Muscle（AI 增肌）' function
        ,cast(null as string) sub_function
    from `beautyplus-bc0ed.temp.winne_abtest_else_function`
    where date between '2025-03-10' and '2025-03-23'
        and event_name = 'beautifysave_bd'
                and if_muscle is not null

    union all

    select date,user_pseudo_id,device_id,event_timestamp
        ,'save' action
        ,'AI Enhance（AI 增强）' function
        ,cast(null as string) sub_function
    from `beautyplus-bc0ed.temp.winne_abtest_else_function`
    where date between '2025-03-10' and '2025-03-23'
        and event_name = 'beautifysave_bd'
                and if_enhance is not null

--     union all
--
--     select date,user_pseudo_id,device_id,event_timestamp
--         ,'save' action
--         ,'Hair（美发）' function
--         ,'Hair-Dye' sub_function
--     from `beautyplus-bc0ed.temp.winne_abtest_else_function`
--     where date between '2025-03-10' and '2025-03-23'
--         and event_name = 'beautifysave_bd'
--                 and hair_dye_material_id is not null
--
--     union all
--
--     select date,user_pseudo_id,device_id,event_timestamp
--         ,'save' action
--         ,'Hair（美发）' function
--         ,'Hair-Style' sub_function
--     from `beautyplus-bc0ed.temp.winne_abtest_else_function`
--     where date between '2025-03-10' and '2025-03-23'
--         and event_name = 'beautifysave_bd'
--                 and hair_style_material_id is not null

    union all
    -- 订阅
    select date,user_pseudo_id,device_id,event_timestamp
        ,'sub' action
        ,case when g.category2 in ('RetouchHD','RET') then 'AI Retouch（AI 焕颜）'
              when g.category2='AI Sets' then 'AI Sets（AI 仿妆）'
              when g.category2 in ('HAD','HRD','Hairline','Hairthickness') then 'Hair（美发）'
              when g.category2='Muscle' then 'Muscle（AI 增肌）'
              when g.category2='PhotoRepair' then 'AI Enhance（AI 增强）'
              when g.category2 like 'ImageQuality%' then 'Image Quality（画质修复）'
        end function
        ,cast(null as string) sub_function
--         ,case when g.category2='HAD' then 'Hair-Dye'
--               when g.category2='HRD' then 'Hair-Style'
--         end sub_function
    from `beautyplus-bc0ed.sub_dataset.ads_spm_trial_subscription_pre_v5_abtest`,unnest(agg) g
    where date between '2025-03-10' and '2025-03-23'
        and (g.category2 in ('RetouchHD','RET','AI Sets','HAD','HRD','Hairline','Hairthickness','Muscle','PhotoRepair')
            or g.category2 like 'ImageQuality%')
        and event_name= 'subscription_try_suc'  and standard_order_date is not null
)
,act_af_ab as (
    select a.*,b.abcode,b.code,b.is_new,b.country,b.platform
    from act a
    join enter_test b on a.device_id= b.device_id
    where a.event_timestamp>=b.timestamp-15000000
)

select a.platform,a.is_new,a.abcode,a.code,a.country_group,b.function
    ,abtest_uv,enter_uv,save_uv,sub_uv,enter_pv,save_pv
from
(
    select
        platform,is_new,abcode,code
        ,case   when country in ('Japan') then '日本'
                when country in ('South Korea') then '韩国'
                /*欧盟包括27个国家：奥地利，比利时，保加利亚，英国，匈牙利，德国，希腊，丹麦，爱尔兰，西班牙，意大利，塞浦路斯，拉脱维亚，立陶宛
                ，卢森堡，马耳他，荷兰，波兰，葡萄牙，罗马尼亚，斯洛伐克，斯洛文尼亚，芬兰，法国，克罗地亚，捷克共和国，瑞典，爱沙尼亚。 */
                when  country in ('United States','Austria', 'Belgium', 'Bulgaria', 'Hungary', 'Germany', 'Greece', 'Denmark', 'Ireland', 'Spain'
                    , 'Italy', 'Cyprus', 'Latvia', 'Lithuania', 'Luxembourg','Malta', 'Netherlands', 'Poland', 'Portugal', 'Romania'
                    , 'Slovakia', 'Slovenia', 'Finland', 'France', 'Croatia' , 'Czechia','Sweden','Estonia'
                    ,'United Kingdom'
                    ) then  '欧美' --'欧盟国家'
                when country in ('India') then '印度'
                when country in ('Thailand','Indonesia','Vietnam','Malaysia','Philippines','Singapore','Cambodia','Laos') then '东南亚'
                else '其他'
                end country_group
        ,count(distinct device_id) abtest_uv
    from enter_test
    group by 1,2,3,4,5
) a
left join
(
    select
        platform,is_new,abcode,code
        ,case   when country in ('Japan') then '日本'
                when country in ('South Korea') then '韩国'
                /*欧盟包括27个国家：奥地利，比利时，保加利亚，英国，匈牙利，德国，希腊，丹麦，爱尔兰，西班牙，意大利，塞浦路斯，拉脱维亚，立陶宛
                ，卢森堡，马耳他，荷兰，波兰，葡萄牙，罗马尼亚，斯洛伐克，斯洛文尼亚，芬兰，法国，克罗地亚，捷克共和国，瑞典，爱沙尼亚。 */
                when  country in ('United States','Austria', 'Belgium', 'Bulgaria', 'Hungary', 'Germany', 'Greece', 'Denmark', 'Ireland', 'Spain'
                    , 'Italy', 'Cyprus', 'Latvia', 'Lithuania', 'Luxembourg','Malta', 'Netherlands', 'Poland', 'Portugal', 'Romania'
                    , 'Slovakia', 'Slovenia', 'Finland', 'France', 'Croatia' , 'Czechia','Sweden','Estonia'
                    ,'United Kingdom'
                    ) then  '欧美' --'欧盟国家'
                when country in ('India') then '印度'
                when country in ('Thailand','Indonesia','Vietnam','Malaysia','Philippines','Singapore','Cambodia','Laos') then '东南亚'
                else '其他'
                end country_group
        ,function --,a.sub_function
        ,count(distinct case when action ='enter' then a.device_id end) enter_uv
        ,count(distinct case when action ='save' then a.device_id end) save_uv
        ,count(distinct case when action ='sub' then a.device_id end) sub_uv

        ,count(case when action ='enter' then 1 end) enter_pv
        ,count(case when action ='save' then 1 end) save_pv

    from act_af_ab a
    group by 1,2,3,4,5,6
) b
on a.platform=b.platform and a.is_new=b.is_new
       and a.abcode=b.abcode and a.code=b.code and a.country_group=b.country_group

;




-- 其他功能的影响
with enter_test as (
    select
        date_p event_date
        ,ab_code abcode
        ,case when ab_code in (11050,11053) then '对照组'
               when ab_code in (11051,11054) then '实验组A'
               when ab_code in (11052,11055) then '实验组B'
        end code
        ,field device_id
        ,country_id
        ,country
        ,case when is_app_new='2' then 'new user' when is_app_new='1' then 'old user' end as is_new
        ,case when app_key in ('F9B069901A7B2E8D') then 'iOS' when app_key in ('C6FF0769324CD2F1') then 'Android' end platform
        ,receive_time as timestamp
    from
        `dataintegration-265403.abtest.abtest_odz_flow` a --2.第一次进入实验用户
        left join   (select
                        event_date
                        ,device_id
                        ,max(country) country
                    from
                        `dataintegration-265403.abtest.stage_aa_meepo_enter_event`
                    group by
                        1,2 ) b on a.date_p = b.event_date and a.field = b.device_id
    where
        date_p between '2025-03-10' and '2025-03-23' -- 结合最新日期选定时间范围，如果数据回收时效高，可能不能看整个周期的留存率
        and cast(ab_code as string) in ('11050','11051','11052','11053','11054','11055')
        and field_type = 3  -- field_type = 1: user_pseudo_id ，2: gid，3：device_id
        and app_key in ('F9B069901A7B2E8D','C6FF0769324CD2F1')
)
,act as (
    select date,user_pseudo_id,device_id,event_timestamp,'enter' action,'Enhance' function
    from `beautyplus-bc0ed.temp.winne_abtest_else_function`
    where date between '2025-03-10' and '2025-03-23'
        and event_name in ('beauty_appr_edit_clk_bd') and sub_function in ('Ai增强')
)
,act_af_ab as (
    select a.*,b.abcode,b.code,b.is_new,b.country,b.platform
    from act a
    join enter_test b on a.device_id= b.device_id
    where a.event_timestamp>=b.timestamp-15000000
)

select a.platform,a.is_new,a.abcode,a.code,a.country_group,b.function
    ,abtest_uv,enter_uv
--     ,save_uv,sub_uv
    ,enter_pv --,save_pv
from
(
    select
        platform,is_new,abcode,code
        ,case   when country in ('Japan') then '日本'
                when country in ('South Korea') then '韩国'
                /*欧盟包括27个国家：奥地利，比利时，保加利亚，英国，匈牙利，德国，希腊，丹麦，爱尔兰，西班牙，意大利，塞浦路斯，拉脱维亚，立陶宛
                ，卢森堡，马耳他，荷兰，波兰，葡萄牙，罗马尼亚，斯洛伐克，斯洛文尼亚，芬兰，法国，克罗地亚，捷克共和国，瑞典，爱沙尼亚。 */
                when  country in ('United States','Austria', 'Belgium', 'Bulgaria', 'Hungary', 'Germany', 'Greece', 'Denmark', 'Ireland', 'Spain'
                    , 'Italy', 'Cyprus', 'Latvia', 'Lithuania', 'Luxembourg','Malta', 'Netherlands', 'Poland', 'Portugal', 'Romania'
                    , 'Slovakia', 'Slovenia', 'Finland', 'France', 'Croatia' , 'Czechia','Sweden','Estonia'
                    ,'United Kingdom'
                    ) then  '欧美' --'欧盟国家'
                when country in ('India') then '印度'
                when country in ('Thailand','Indonesia','Vietnam','Malaysia','Philippines','Singapore','Cambodia','Laos') then '东南亚'
                else '其他'
                end country_group
        ,count(distinct device_id) abtest_uv
    from enter_test
    group by 1,2,3,4,5
) a
left join
(
    select
        platform,is_new,abcode,code
        ,case   when country in ('Japan') then '日本'
                when country in ('South Korea') then '韩国'
                /*欧盟包括27个国家：奥地利，比利时，保加利亚，英国，匈牙利，德国，希腊，丹麦，爱尔兰，西班牙，意大利，塞浦路斯，拉脱维亚，立陶宛
                ，卢森堡，马耳他，荷兰，波兰，葡萄牙，罗马尼亚，斯洛伐克，斯洛文尼亚，芬兰，法国，克罗地亚，捷克共和国，瑞典，爱沙尼亚。 */
                when  country in ('United States','Austria', 'Belgium', 'Bulgaria', 'Hungary', 'Germany', 'Greece', 'Denmark', 'Ireland', 'Spain'
                    , 'Italy', 'Cyprus', 'Latvia', 'Lithuania', 'Luxembourg','Malta', 'Netherlands', 'Poland', 'Portugal', 'Romania'
                    , 'Slovakia', 'Slovenia', 'Finland', 'France', 'Croatia' , 'Czechia','Sweden','Estonia'
                    ,'United Kingdom'
                    ) then  '欧美' --'欧盟国家'
                when country in ('India') then '印度'
                when country in ('Thailand','Indonesia','Vietnam','Malaysia','Philippines','Singapore','Cambodia','Laos') then '东南亚'
                else '其他'
                end country_group
        ,function --,a.sub_function
        ,count(distinct case when action ='enter' then a.device_id end) enter_uv
--         ,count(distinct case when action ='save' then a.device_id end) save_uv
--         ,count(distinct case when action ='sub' then a.device_id end) sub_uv

        ,count(case when action ='enter' then 1 end) enter_pv
--         ,count(case when action ='save' then 1 end) save_pv

    from act_af_ab a
    group by 1,2,3,4,5,6
) b
on a.platform=b.platform and a.is_new=b.is_new
       and a.abcode=b.abcode and a.code=b.code and a.country_group=b.country_group



