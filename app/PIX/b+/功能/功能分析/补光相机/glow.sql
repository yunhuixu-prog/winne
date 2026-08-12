
drop table if exists `beautyplus-bc0ed.temp.winne_dwd_glow_cam_behavior`;
create table if not exists `beautyplus-bc0ed.temp.winne_dwd_glow_cam_behavior` as

with event as
(
    select
        event_date
        ,event_timestamp
        ,event_name
        ,`dataintegration-265403.func`.getParams(event_params,'source').string_value source
        ,`dataintegration-265403.func`.getParams(event_params,'module').string_value module
        ,`dataintegration-265403.func`.getParams(event_params,'camera_mode').string_value camera_mode
        ,`dataintegration-265403.func`.getParams(event_params,'category').string_value category
        ,`dataintegration-265403.func`.getParams(event_params,'material_id').string_value material_id
        ,user_pseudo_id
        ,platform
        ,version
    from
        `dataintegration-265403.analytics.dwd_dzp_events_function`('2025-03-02','2025-04-12','beautyplus',false)
    where event_name in ('glow_cam_appr_bd','glow_cam_func_clk_bd','glow_cam_material_clk_bd','glow_cam_save_bd','live_on_clk_bd','selfiepage_enter_album_bd'
                        ,'selfie_appr_bd','selfietakepic_bd','selfiesave_bd'
                        ,'iphone_mode_appr_bd','iphone_mode_save_bd'
                        ,'stamp_cam_appr_bd','stamp_cam_save_bd'
                        ,'movie_appr_bd','movie_takepic_bd','movecheck_save_bd')
)
,
user_info as
(
    select
        event_date_hk
        ,platform
        ,user_pseudo_id
        ,max(is_new) is_new
        ,max(is_UA) is_UA
        ,max(country) country
    from
        `dataintegration-265403.stat.stat_active_advice_detail_d`
    where
        event_date_hk between date'2025-03-02' and '2025-04-12'
        and app_name='BeautyPlus'
    group by 1,2,3
)

select
    t.event_date
    ,t.event_timestamp
    ,t.event_name
    ,t.source
    ,t.module
    ,t.camera_mode
    ,t.category
    ,t.material_id
    ,t.platform platform
    ,t.user_pseudo_id user_pseudo_id
    ,t.version
    ,i.country
    ,i.is_new
    ,i.is_UA
from
    event t
join user_info i on t.event_date = i.event_date_hk and t.user_pseudo_id = i.user_pseudo_id and t.platform = i.platform

;

-- 分模块&整体数据

select a.event_date,a.date_period,b.module,b.source,a.platform,a.country_group,a.is_UA,a.is_new
    ,sum(a.dau) dau
    ,sum(enter_uv) enter_uv
    ,sum(save_uv) save_uv
    ,sum(enter_pv) enter_pv
    ,sum(save_pv) save_pv
from
(
    select event_date_hk event_date
        ,case when event_date_hk between '2025-03-02' and '2025-03-08' then 'Benchmark: 2025.03.02-2025.03.08'
              when event_date_hk between '2025-03-16' and '2025-03-22' then 'Benchmark: 2025.03.16-2025.03.22'
--               when event_date_hk between '2025-03-23' and '2025-03-29' then 'Benchmark: 2025.03.23-2025.03.29'
--               when event_date_hk between '2025-04-06' and '2025-04-12' then 'Benchmark: 2025.04.06-2025.04.12'
        end date_period
        ,platform
        ,case
            when country in ('Japan') then '日本'
            when country in ('South Korea') then '韩国'
            when country in ('United States') then '美国'
            /*欧盟包括27个国家：奥地利，比利时，保加利亚，英国，匈牙利，德国，希腊，丹麦，爱尔兰，西班牙，意大利，塞浦路斯，拉脱维亚，立陶宛
            ，卢森堡，马耳他，荷兰，波兰，葡萄牙，罗马尼亚，斯洛伐克，斯洛文尼亚，芬兰，法国，克罗地亚，捷克共和国，瑞典，爱沙尼亚。 */
            when  country in ('Austria', 'Belgium', 'Bulgaria', 'Hungary', 'Germany', 'Greece', 'Denmark', 'Ireland', 'Spain'
                , 'Italy', 'Cyprus', 'Latvia', 'Lithuania', 'Luxembourg','Malta', 'Netherlands', 'Poland', 'Portugal', 'Romania'
                , 'Slovakia', 'Slovenia', 'Finland', 'France', 'Croatia' , 'Czechia','Sweden','Estonia'
                ,'United Kingdom'
                ) then  '欧盟'
            when country in ('India') then '印度'
            when country in ('Thailand','Indonesia','Vietnam','Malaysia','Philippines','Singapore','Cambodia','Laos') then '东南亚'
            else '其他'
            end country_group
        ,is_UA
        ,is_new
        ,count(distinct user_pseudo_id) dau
    from `dataintegration-265403.stat.stat_active_advice_detail_d`
    where
            (event_date_hk between '2025-03-02' and '2025-03-08'
            or event_date_hk between '2025-03-16' and '2025-03-22'
--             or event_date_hk between '2025-03-23' and '2025-03-29'
--             or event_date_hk between '2025-04-06' and '2025-04-12'
            )
            and app_name='BeautyPlus'
    group by 1,2,3,4,5,6
) a
left join
(
    select event_date
        ,case when event_date between '2025-03-02' and '2025-03-08' then 'Benchmark: 2025.03.02-2025.03.08'
              when event_date between '2025-03-16' and '2025-03-22' then 'Benchmark: 2025.03.16-2025.03.22'
--               when event_date between '2025-03-23' and '2025-03-29' then 'Benchmark: 2025.03.23-2025.03.29'
--               when event_date between '2025-04-06' and '2025-04-12' then 'Benchmark: 2025.04.06-2025.04.12'
        end date_period
        ,case when event_name in ('glow_cam_appr_bd','glow_cam_func_clk_bd','glow_cam_material_clk_bd','glow_cam_save_bd') then 'glow'
              when event_name in ('selfie_appr_bd','selfietakepic_bd','selfiesave_bd') then 'classic'
              when event_name in ('iphone_mode_appr_bd','iphone_mode_save_bd') then 'iphone'
              when event_name in ('stamp_cam_appr_bd','stamp_cam_save_bd') then 'stamp'
              when event_name in ('movie_appr_bd','movie_takepic_bd','movecheck_save_bd') then 'movie'
        end module
        ,'All' source
        ,platform
        ,case
            when country in ('Japan') then '日本'
            when country in ('South Korea') then '韩国'
            when country in ('United States') then '美国'
            /*欧盟包括27个国家：奥地利，比利时，保加利亚，英国，匈牙利，德国，希腊，丹麦，爱尔兰，西班牙，意大利，塞浦路斯，拉脱维亚，立陶宛
            ，卢森堡，马耳他，荷兰，波兰，葡萄牙，罗马尼亚，斯洛伐克，斯洛文尼亚，芬兰，法国，克罗地亚，捷克共和国，瑞典，爱沙尼亚。 */
            when  country in ('Austria', 'Belgium', 'Bulgaria', 'Hungary', 'Germany', 'Greece', 'Denmark', 'Ireland', 'Spain'
                , 'Italy', 'Cyprus', 'Latvia', 'Lithuania', 'Luxembourg','Malta', 'Netherlands', 'Poland', 'Portugal', 'Romania'
                , 'Slovakia', 'Slovenia', 'Finland', 'France', 'Croatia' , 'Czechia','Sweden','Estonia'
                ,'United Kingdom'
                ) then  '欧盟'
            when country in ('India') then '印度'
            when country in ('Thailand','Indonesia','Vietnam','Malaysia','Philippines','Singapore','Cambodia','Laos') then '东南亚'
            else '其他'
            end country_group
        ,is_UA
        ,is_new
        ,count(distinct case when event_name in ('glow_cam_appr_bd','selfie_appr_bd'
                    ,'iphone_mode_appr_bd','stamp_cam_appr_bd','movie_appr_bd') then user_pseudo_id end) enter_uv
        ,count(distinct case when event_name in ('glow_cam_save_bd','selfiesave_bd'
                    ,'iphone_mode_save_bd','stamp_cam_save_bd','movecheck_save_bd') then user_pseudo_id end) save_uv
        ,count(case when event_name in ('glow_cam_appr_bd','selfie_appr_bd'
                    ,'iphone_mode_appr_bd','stamp_cam_appr_bd','movie_appr_bd') then 1 end) enter_pv
        ,count(case when event_name in ('glow_cam_save_bd','selfiesave_bd'
                    ,'iphone_mode_save_bd','stamp_cam_save_bd','movecheck_save_bd') then 1 end) save_pv
    from `beautyplus-bc0ed.temp.winne_dwd_glow_cam_behavior`
    where
            (event_date between '2025-03-02' and '2025-03-08'
            or event_date between '2025-03-16' and '2025-03-22'
--             or event_date between '2025-03-23' and '2025-03-29'
--             or event_date between '2025-04-06' and '2025-04-12'
            )
            and event_name in ('glow_cam_appr_bd','glow_cam_save_bd'
                            ,'selfie_appr_bd','selfiesave_bd'  --,'selfietakepic_bd'
                            ,'iphone_mode_appr_bd','iphone_mode_save_bd'
                            ,'stamp_cam_appr_bd','stamp_cam_save_bd'
                            ,'movie_appr_bd','movecheck_save_bd'  --,'movie_takepic_bd'
                            )
    group by 1,2,3,4,5,6,7,8

    union all

    select event_date
        ,case when event_date between '2025-03-02' and '2025-03-08' then 'Benchmark: 2025.03.02-2025.03.08'
              when event_date between '2025-03-16' and '2025-03-22' then 'Benchmark: 2025.03.16-2025.03.22'
--               when event_date between '2025-03-23' and '2025-03-29' then 'Benchmark: 2025.03.23-2025.03.29'
--               when event_date between '2025-04-06' and '2025-04-12' then 'Benchmark: 2025.04.06-2025.04.12'
        end date_period
        ,case when event_name in ('glow_cam_appr_bd','glow_cam_func_clk_bd','glow_cam_material_clk_bd','glow_cam_save_bd') then 'glow'
              when event_name in ('selfie_appr_bd','selfietakepic_bd','selfiesave_bd') then 'classic'
              when event_name in ('iphone_mode_appr_bd','iphone_mode_save_bd') then 'iphone'
              when event_name in ('stamp_cam_appr_bd','stamp_cam_save_bd') then 'stamp'
              when event_name in ('movie_appr_bd','movie_takepic_bd','movecheck_save_bd') then 'movie'
        end module
        ,source
        ,platform
        ,case
            when country in ('Japan') then '日本'
            when country in ('South Korea') then '韩国'
            when country in ('United States') then '美国'
            /*欧盟包括27个国家：奥地利，比利时，保加利亚，英国，匈牙利，德国，希腊，丹麦，爱尔兰，西班牙，意大利，塞浦路斯，拉脱维亚，立陶宛
            ，卢森堡，马耳他，荷兰，波兰，葡萄牙，罗马尼亚，斯洛伐克，斯洛文尼亚，芬兰，法国，克罗地亚，捷克共和国，瑞典，爱沙尼亚。 */
            when  country in ('Austria', 'Belgium', 'Bulgaria', 'Hungary', 'Germany', 'Greece', 'Denmark', 'Ireland', 'Spain'
                , 'Italy', 'Cyprus', 'Latvia', 'Lithuania', 'Luxembourg','Malta', 'Netherlands', 'Poland', 'Portugal', 'Romania'
                , 'Slovakia', 'Slovenia', 'Finland', 'France', 'Croatia' , 'Czechia','Sweden','Estonia'
                ,'United Kingdom'
                ) then  '欧盟'
            when country in ('India') then '印度'
            when country in ('Thailand','Indonesia','Vietnam','Malaysia','Philippines','Singapore','Cambodia','Laos') then '东南亚'
            else '其他'
            end country_group
        ,is_UA
        ,is_new
        ,count(distinct case when event_name in ('glow_cam_appr_bd','selfie_appr_bd'
                    ,'iphone_mode_appr_bd','stamp_cam_appr_bd','movie_appr_bd') then user_pseudo_id end) enter_uv
        ,count(distinct case when event_name in ('glow_cam_save_bd','selfiesave_bd'
                    ,'iphone_mode_save_bd','stamp_cam_save_bd','movecheck_save_bd') then user_pseudo_id end) save_uv
        ,count(case when event_name in ('glow_cam_appr_bd','selfie_appr_bd'
                    ,'iphone_mode_appr_bd','stamp_cam_appr_bd','movie_appr_bd') then 1 end) enter_pv
        ,count(case when event_name in ('glow_cam_save_bd','selfiesave_bd'
                    ,'iphone_mode_save_bd','stamp_cam_save_bd','movecheck_save_bd') then 1 end) save_pv
    from `beautyplus-bc0ed.temp.winne_dwd_glow_cam_behavior`
    where
            (event_date between '2025-03-02' and '2025-03-08'
            or event_date between '2025-03-16' and '2025-03-22'
--             or event_date between '2025-03-23' and '2025-03-29'
--             or event_date between '2025-04-06' and '2025-04-12'
            )
            and event_name in ('glow_cam_appr_bd','glow_cam_save_bd'
                            ,'selfie_appr_bd','selfiesave_bd'  --,'selfietakepic_bd'
                            ,'iphone_mode_appr_bd','iphone_mode_save_bd'
                            ,'stamp_cam_appr_bd','stamp_cam_save_bd'
                            ,'movie_appr_bd','movecheck_save_bd'  --,'movie_takepic_bd'
                            )
    group by 1,2,3,4,5,6,7,8

    union all

    select event_date
        ,case when event_date between '2025-03-02' and '2025-03-08' then 'Benchmark: 2025.03.02-2025.03.08'
              when event_date between '2025-03-16' and '2025-03-22' then 'Benchmark: 2025.03.16-2025.03.22'
--               when event_date between '2025-03-23' and '2025-03-29' then 'Benchmark: 2025.03.23-2025.03.29'
--               when event_date between '2025-04-06' and '2025-04-12' then 'Benchmark: 2025.04.06-2025.04.12'
        end date_period
        ,'All' module
        ,'All' source
        ,platform
        ,case
            when country in ('Japan') then '日本'
            when country in ('South Korea') then '韩国'
            when country in ('United States') then '美国'
            /*欧盟包括27个国家：奥地利，比利时，保加利亚，英国，匈牙利，德国，希腊，丹麦，爱尔兰，西班牙，意大利，塞浦路斯，拉脱维亚，立陶宛
            ，卢森堡，马耳他，荷兰，波兰，葡萄牙，罗马尼亚，斯洛伐克，斯洛文尼亚，芬兰，法国，克罗地亚，捷克共和国，瑞典，爱沙尼亚。 */
            when  country in ('Austria', 'Belgium', 'Bulgaria', 'Hungary', 'Germany', 'Greece', 'Denmark', 'Ireland', 'Spain'
                , 'Italy', 'Cyprus', 'Latvia', 'Lithuania', 'Luxembourg','Malta', 'Netherlands', 'Poland', 'Portugal', 'Romania'
                , 'Slovakia', 'Slovenia', 'Finland', 'France', 'Croatia' , 'Czechia','Sweden','Estonia'
                ,'United Kingdom'
                ) then  '欧盟'
            when country in ('India') then '印度'
            when country in ('Thailand','Indonesia','Vietnam','Malaysia','Philippines','Singapore','Cambodia','Laos') then '东南亚'
            else '其他'
            end country_group
        ,is_UA
        ,is_new
        ,count(distinct case when event_name in ('glow_cam_appr_bd','selfie_appr_bd'
                    ,'iphone_mode_appr_bd','stamp_cam_appr_bd','movie_appr_bd') then user_pseudo_id end) enter_uv
        ,count(distinct case when event_name in ('glow_cam_save_bd','selfiesave_bd'
                    ,'iphone_mode_save_bd','stamp_cam_save_bd','movecheck_save_bd') then user_pseudo_id end) save_uv
        ,count(case when event_name in ('glow_cam_appr_bd','selfie_appr_bd'
                    ,'iphone_mode_appr_bd','stamp_cam_appr_bd','movie_appr_bd') then 1 end) enter_pv
        ,count(case when event_name in ('glow_cam_save_bd','selfiesave_bd'
                    ,'iphone_mode_save_bd','stamp_cam_save_bd','movecheck_save_bd') then 1 end) save_pv
    from `beautyplus-bc0ed.temp.winne_dwd_glow_cam_behavior`
    where
            (event_date between '2025-03-02' and '2025-03-08'
            or event_date between '2025-03-16' and '2025-03-22'
--             or event_date between '2025-03-23' and '2025-03-29'
--             or event_date between '2025-04-06' and '2025-04-12'
            )
            and event_name in ('glow_cam_appr_bd','glow_cam_save_bd'
                            ,'selfie_appr_bd','selfiesave_bd'  --,'selfietakepic_bd'
                            ,'iphone_mode_appr_bd','iphone_mode_save_bd'
                            ,'stamp_cam_appr_bd','stamp_cam_save_bd'
                            ,'movie_appr_bd','movecheck_save_bd'  --,'movie_takepic_bd'
                            )
    group by 1,2,3,4,5,6,7,8
) b
on a.event_date=b.event_date and a.date_period=b.date_period and a.platform=b.platform and a.country_group=b.country_group and a.is_UA=b.is_UA and a.is_new=b.is_new
group by 1,2,3,4,5,6,7,8


-- 补光相机明细数据

select event_date
    ,case when event_name in ('glow_cam_appr_bd') then 'enter'
          when event_name in ('glow_cam_func_clk_bd','live_on_clk_bd','selfiepage_enter_album_bd') then 'func_clk'
          when event_name in ('glow_cam_material_clk_bd') then 'material_clk'
          when event_name in ('glow_cam_save_bd') then 'save'
    end action
    ,platform
    ,count(distinct user_pseudo_id) uv
    ,count(1) pv
from `beautyplus-bc0ed.temp.winne_dwd_glow_cam_behavior`
where event_date between '2025-03-16' and '2025-03-22'
        and
        (
            event_name in ('glow_cam_appr_bd','glow_cam_func_clk_bd','glow_cam_material_clk_bd','glow_cam_save_bd')
            or (event_name in ('live_on_clk_bd','selfiepage_enter_album_bd') and camera_mode='glow')
        )
group by 1,2,3
;

select a.event_date
     ,count(distinct a.user_pseudo_id) enter_uv
     ,count(distinct b.user_pseudo_id) function_clk_uv
     ,count(distinct c.user_pseudo_id) function_light_clk_uv
     ,count(distinct d.user_pseudo_id) material_clk_uv
     ,count(distinct e.user_pseudo_id) save_uv
     ,count(distinct case when b.user_pseudo_id is null then e.user_pseudo_id end) no_fucntion_clk_save_uv
     ,count(distinct case when b.user_pseudo_id is not null and c.user_pseudo_id is null then e.user_pseudo_id end) no_fucntion_light_clk_save_uv
     ,count(distinct case when c.user_pseudo_id is not null and d.user_pseudo_id is null then e.user_pseudo_id end) no_material_clk_save_uv
     ,count(distinct case when d.user_pseudo_id is not null then e.user_pseudo_id end) whole_and_save_uv
-- select if(b.user_pseudo_id is not null,1,0) b,if(c.user_pseudo_id is not null,1,0) c,if(d.user_pseudo_id is not null,1,0) d,if(e.user_pseudo_id is not null,1,0) e
--     ,count(a.user_pseudo_id)
from
(
    select event_date
        ,user_pseudo_id
        ,count(1) pv
    from `beautyplus-bc0ed.temp.winne_dwd_glow_cam_behavior`
    where event_date between '2025-03-16' and '2025-03-22'
            and event_name in ('glow_cam_appr_bd')
    group by 1,2
) a
left join
(
    select event_date
        ,user_pseudo_id
        ,count(1) pv
    from `beautyplus-bc0ed.temp.winne_dwd_glow_cam_behavior`
    where event_date between '2025-03-16' and '2025-03-22'
            and
            (
                event_name in ('glow_cam_func_clk_bd','glow_cam_material_clk_bd')
                or (event_name in ('live_on_clk_bd','selfiepage_enter_album_bd') and camera_mode='glow')
            )
    group by 1,2
) b
on a.event_date=b.event_date and a.user_pseudo_id=b.user_pseudo_id
left join
(
    select event_date
        ,user_pseudo_id
        ,count(1) pv
    from `beautyplus-bc0ed.temp.winne_dwd_glow_cam_behavior`
    where event_date between '2025-03-16' and '2025-03-22'
            and
            (
                (event_name in ('glow_cam_func_clk_bd') and category='补光灯')
                or event_name in ('glow_cam_material_clk_bd')
            )
    group by 1,2
) c
on a.event_date=c.event_date and a.user_pseudo_id=c.user_pseudo_id
left join
(
    select event_date
        ,user_pseudo_id
        ,count(1) pv
    from `beautyplus-bc0ed.temp.winne_dwd_glow_cam_behavior`
    where event_date between '2025-03-16' and '2025-03-22'
            and event_name in ('glow_cam_material_clk_bd')
    group by 1,2
) d
on a.event_date=d.event_date and a.user_pseudo_id=d.user_pseudo_id
left join
(
    select event_date
        ,user_pseudo_id
        ,count(1) pv
    from `beautyplus-bc0ed.temp.winne_dwd_glow_cam_behavior`
    where event_date between '2025-03-16' and '2025-03-22'
            and event_name in ('glow_cam_save_bd')
    group by 1,2
) e
on a.event_date=e.event_date and a.user_pseudo_id=e.user_pseudo_id
-- group by 1,2,3,4
-- order by 1,2,3,4
group by 1
order by 1
;


-- 使用功能素材明细
select event_date
    ,case when event_name in ('glow_cam_appr_bd') then 'enter'
          when event_name in ('glow_cam_func_clk_bd','live_on_clk_bd','selfiepage_enter_album_bd') then 'func_clk'
          when event_name in ('glow_cam_material_clk_bd') then 'material_clk'
          when event_name in ('glow_cam_save_bd') then 'save'
    end action
    ,case when event_name in ('glow_cam_func_clk_bd','glow_cam_material_clk_bd','glow_cam_save_bd') then category
          when event_name='live_on_clk_bd' then 'live'
          when event_name='selfiepage_enter_album_bd' then 'album'
    end func
    ,material_id material
    ,platform
    ,count(distinct user_pseudo_id) uv
    ,count(1) pv
from `beautyplus-bc0ed.temp.winne_dwd_glow_cam_behavior`
where event_date between '2025-03-16' and '2025-03-22'
        and
        (
            event_name in ('glow_cam_func_clk_bd','glow_cam_material_clk_bd','glow_cam_save_bd')
            or (event_name in ('live_on_clk_bd','selfiepage_enter_album_bd') and camera_mode='glow')
        )
group by 1,2,3,4,5
;



-- 排除打光模式的上涨
select case when event_date between '2025-03-02' and '2025-03-08' then 'Benchmark: 2025.03.02-2025.03.08'
          when event_date between '2025-03-16' and '2025-03-22' then 'Benchmark: 2025.03.16-2025.03.22'
--               when event_date between '2025-03-23' and '2025-03-29' then 'Benchmark: 2025.03.23-2025.03.29'
--               when event_date between '2025-04-06' and '2025-04-12' then 'Benchmark: 2025.04.06-2025.04.12'
    end date_period
    ,count(distinct case when event_name in ('glow_cam_appr_bd','selfie_appr_bd'
                ,'iphone_mode_appr_bd','stamp_cam_appr_bd','movie_appr_bd') then user_pseudo_id end) enter_uv
    ,count(distinct case when event_name in ('selfie_appr_bd'
                ,'iphone_mode_appr_bd','stamp_cam_appr_bd','movie_appr_bd') then user_pseudo_id end) enter_uv_except_glow
from `beautyplus-bc0ed.temp.winne_dwd_glow_cam_behavior`
where
        (event_date between '2025-03-02' and '2025-03-08'
        or event_date between '2025-03-16' and '2025-03-22'
        )
        and event_name in ('glow_cam_appr_bd'
                        ,'selfie_appr_bd'
                        ,'iphone_mode_appr_bd'
                        ,'stamp_cam_appr_bd'
                        ,'movie_appr_bd'
                        )
group by 1


-- 首页入口点击情况
select
        event_date
        ,event_name
        ,`dataintegration-265403.func`.getParams(event_params,'内容类型').string_value content_type
        ,count(distinct user_pseudo_id) uv
        ,count(1) pv
    from
        `dataintegration-265403.analytics.dwd_dzp_events_function`('2025-03-29','2025-03-29','beautyplus',false)
    where event_name in ('home_content_clk_bd')
      and `dataintegration-265403.func`.getParams(event_params,'内容类型').string_value in ('BP_TB_00000044','BP_TB_00000045','ABVC_BP_00000078','BP_KKAA_00000044')
group by 1,2,3


