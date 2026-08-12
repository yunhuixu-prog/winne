-- 试用后功能使用数
SELECT user_type
    ,enter_func_num_type
    ,use_func_num_type
    ,save_func_num_type
    ,enter_mix_func_num_type

    -- ,enter_sub_func_num_type
    -- ,enter_vip_sub_func_num_type

    -- ,enter_vip_all_func_num_type
    -- ,round(sum(trial_uv)/count(distinct date_p),0) trial_uv
    -- ,round(sum(paid_uv)/count(distinct date_p),0) paid_uv
    ,sum(trial_uv) trial_uv
    ,sum(paid_uv) paid_uv
    ,sum(retention_1_uv) retention_1_uv
FROM (
    SELECT 
        a.date_p,a.user_type
        ,case when dismiss_days=0 then 1 
              when dismiss_days>=1 then 0
        else null end is_dismiss_today
        -- ,case when enter_func_num<=1 then '1:1个' 
        --       when enter_func_num<=3 then '2:2-3个' 
        --       when enter_func_num<=5 then '3:4-5个' 
        --       when enter_func_num<=10 then '4:6-10个' 
        --       when enter_func_num<=15 then '5:11-15个' 
        --       else '6:16个以上' 
        --       end enter_func_num_type
        ,case when coalesce(enter_func_num, 0)<=10 then coalesce(enter_func_num, 0) else 999 end enter_func_num_type
        ,case when coalesce(use_func_num, 0)<=5 then coalesce(use_func_num, 0) else 999 end use_func_num_type
        ,case when coalesce(save_func_num, 0)<=5 then coalesce(save_func_num, 0) else 999 end save_func_num_type
        ,case when coalesce(enter_mix_func_num, 0)<=3 then coalesce(enter_mix_func_num, 0) else 999 end enter_mix_func_num_type

        -- ,case when coalesce(enter_sub_func_num, 0)<=10 then coalesce(enter_sub_func_num, 0) else 999 end enter_sub_func_num_type
        -- ,case when coalesce(enter_vip_sub_func_num, 0)<=5 then coalesce(enter_vip_sub_func_num, 0) else 999 end enter_vip_sub_func_num_type

        -- ,case when coalesce(enter_vip_func_num, 0)+coalesce(enter_vip_sub_func_num, 0)<=10 then coalesce(enter_vip_func_num, 0)+coalesce(enter_vip_sub_func_num, 0) else 999 end enter_vip_all_func_num_type
        ,count(distinct a.gid) trial_uv 
        ,count(distinct case when is_paid=1 then a.gid end) paid_uv
        ,count(distinct case when act.gid is not null then a.gid end) retention_1_uv
        
    FROM (
        select * 
        from stat_ab.filing_odz_trial_users_info_temp 
        where date_p between ${start_date} and ${end_date}
            and user_type in ('3天内新用户', '历史未订阅老用户')
        ) a
    LEFT JOIN (
        -- 试用当日进入/使用/保存的功能 list（逗号分隔）
        SELECT
            f.date_p
            ,f.gid
            ,count(distinct case when f.level='2' and enter_pv > 0 then f.function_1 end) enter_func_num
            ,count(distinct case when f.level='2' and use_pv > 0 then f.function_1 end) use_func_num
            ,count(distinct case when f.level='2' and save_pv > 0 then f.function_1 end) save_func_num

            ,count(distinct case when f.level='2' and enter_pv > 0 and pay_type='付费' then f.function_1 end) enter_vip_func_num
            ,count(distinct case when f.level='2' and use_pv > 0 and pay_type='付费' then f.function_1 end) use_vip_func_num
            ,count(distinct case when f.level='2' and save_pv > 0 and pay_type='付费' then f.function_1 end) save_vip_func_num

            ,count(distinct case when f.level='2' and enter_pv > 0 and pay_type in ('付费', '混合') then f.function_1 end) enter_mix_func_num
            ,count(distinct case when f.level='2' and use_pv > 0 and pay_type in ('付费', '混合') then f.function_1 end) use_mix_func_num
            ,count(distinct case when f.level='2' and save_pv > 0 and pay_type in ('付费', '混合') then f.function_1 end) save_mix_func_num

            -- ,count(distinct case when f.level='3' and enter_pv > 0 then f.function_2 end) enter_sub_func_num
            -- ,count(distinct case when f.level='3' and use_pv > 0 then f.function_2 end) use_sub_func_num
            -- ,count(distinct case when f.level='3' and save_pv > 0 then f.function_2 end) save_sub_func_num

            -- ,count(distinct case when f.level='3' and enter_pv > 0 and pay_type='付费' then f.function_2 end) enter_vip_sub_func_num
            -- ,count(distinct case when f.level='3' and use_pv > 0 and pay_type='付费' then f.function_2 end) use_vip_sub_func_num
            -- ,count(distinct case when f.level='3' and save_pv > 0 and pay_type='付费' then f.function_2 end) save_vip_sub_func_num
        FROM (
            SELECT date_p, gid
                ,'2' level
                ,case when sub_func_level2_name in ('Smooth','Acne','Concealer','Brighten','Skin Tone','Dark Circles','Details','Eye Brighten','Texture','Matte','Contour','Wrinkle') then 'Skin' 
                    else sub_func_level2_name 
                end function_1
                ,'' function_2
                ,SUM(case when event_type='进入' then cnt end) enter_pv
                ,SUM(case when event_type='打勾' then cnt end) use_pv
                ,SUM(case when event_type='保存' then cnt end) save_pv
            FROM stat_sdk.airbrush_mdz_tool_behavior_detail
            WHERE date_p between ${start_date} and ${end_date}
                AND model_p IN ('image_edit') -- , 'camera', 'sp_edit', 'H5'
                AND tool_level in ('2')
                AND sub_func_level2_name in (
                    'Adjust','Crop','Eraser','Stamp','Bokeh','Blur','AI Repair','AI Replace','Relight','AI Expand','Prism'
                    ,'AI Retouch','Magic','Face','Glowup','Reshape','Resize','Stretch','Body','Muscle','Face Fix','Expression','Teeth','Makeup','Plump','AI Tattoo','Glitter'
                    ,'Filters','Hair','Preset','Effects','AI Image','Background','Text'
                    ,'Smooth','Acne','Concealer','Brighten','Skin Tone','Dark Circles','Details','Eye Brighten','Texture','Matte','Contour','Wrinkle')
            GROUP BY date_p, gid
                ,case when sub_func_level2_name in ('Smooth','Acne','Concealer','Brighten','Skin Tone','Dark Circles','Details','Eye Brighten','Texture','Matte','Contour','Wrinkle') then 'Skin' 
                    else sub_func_level2_name 
                end
            
            -- union all 

            -- SELECT date_p, gid
            --     ,'3' level
            --     ,'Skin' function_1
            --     ,sub_func_level2_name function_2
            --     ,SUM(case when event_type='进入' then cnt end) enter_pv
            --     ,SUM(case when event_type='打勾' then cnt end) use_pv
            --     ,SUM(case when event_type='保存' then cnt end) save_pv
            -- FROM stat_sdk.airbrush_mdz_tool_behavior_detail
            -- WHERE date_p between ${start_date} and ${end_date}
            --     AND model_p IN ('image_edit') -- , 'camera', 'sp_edit', 'H5'
            --     AND tool_level in ('2')
            --     AND sub_func_level2_name in (
            --         'Smooth','Acne','Concealer','Brighten','Skin Tone','Dark Circles','Details','Eye Brighten','Texture','Matte','Contour','Wrinkle')
            -- GROUP BY date_p, gid
            --     , sub_func_level2_name

            -- union all 

            -- SELECT date_p, gid
            --     ,'3' level
            --     ,case when sub_func_level2_name='eraser' then 'Eraser' else sub_func_level2_name end function_1
            --     ,sub_func_level3_name function_2
            --     ,SUM(case when event_type='进入' then cnt end) enter_pv
            --     ,SUM(case when event_type='打勾' then cnt end) use_pv
            --     ,SUM(case when event_type='保存' then cnt end) save_pv
            -- FROM stat_ab.airbrush_mdz_tool_behavior_detail_v2
            -- WHERE date_p between ${start_date} and ${end_date}
            --     AND model_p IN ('image_edit') -- , 'camera', 'sp_edit', 'H5'
            --     AND tool_level in ('3')
            --     AND sub_func_level2_name in ('Face','Body','Magic','eraser','Teeth')
            -- GROUP BY date_p, gid
            --     ,case when sub_func_level2_name='eraser' then 'Eraser' else sub_func_level2_name end
            --     ,sub_func_level3_name
        ) f
        left join (
            select case when sub_function = '' then '2' else '3' end level
                ,`function` function_1,sub_function function_2,pay_type
            from stat_ab.filing_rna_function_pay_type
        ) p
        on f.level = p.level and f.function_1 = p.function_1 and f.function_2 = p.function_2
        GROUP BY f.date_p, f.gid
    ) func
    ON a.gid = func.gid and a.date_p = func.date_p
    left join (
        select distinct final_id as gid, date_p
        from stat_sdk.sdk_odz_active
        where date_p between ${start_date} and ${end_date_a1}
            and app_key_p in ('C851ED7164B6DF0F', '7F7023B6CEC7CDED')
            and os_p is not null
    ) act
    on a.gid = act.gid and meitu_datediff(act.date_p, a.date_p) = 1
    GROUP BY a.date_p
        ,a.user_type
        ,case when dismiss_days=0 then 1 
              when dismiss_days>=1 then 0
        else null end
        -- ,case when enter_func_num<=1 then '1:1个' 
        --       when enter_func_num<=3 then '2:2-3个' 
        --       when enter_func_num<=5 then '3:4-5个' 
        --       when enter_func_num<=10 then '4:6-10个' 
        --       when enter_func_num<=15 then '5:11-15个' 
        --       else '6:16个以上' 
        --       end
        ,case when coalesce(enter_func_num, 0)<=10 then coalesce(enter_func_num, 0) else 999 end
        ,case when coalesce(use_func_num, 0)<=5 then coalesce(use_func_num, 0) else 999 end
        ,case when coalesce(save_func_num, 0)<=5 then coalesce(save_func_num, 0) else 999 end
        ,case when coalesce(enter_mix_func_num, 0)<=3 then coalesce(enter_mix_func_num, 0) else 999 end

        -- ,case when coalesce(enter_sub_func_num, 0)<=10 then coalesce(enter_sub_func_num, 0) else 999 end
        -- ,case when coalesce(enter_vip_sub_func_num, 0)<=5 then coalesce(enter_vip_sub_func_num, 0) else 999 end

        -- ,case when coalesce(enter_vip_func_num, 0)+coalesce(enter_vip_sub_func_num, 0)<=10 then coalesce(enter_vip_func_num, 0)+coalesce(enter_vip_sub_func_num, 0) else 999 end
) t
group by user_type
    ,enter_func_num_type
    ,use_func_num_type
    ,save_func_num_type
    ,enter_mix_func_num_type

    -- ,enter_sub_func_num_type
    -- ,enter_vip_sub_func_num_type

    -- ,enter_vip_all_func_num_type

;


现在有一份表格，目标是提升试用用户的付费转化率，选取了付费转化和非付费转化两群用户代表，并且分为了3天内新用户和历史未订阅老用户，表格说明如下：
date_p日期、user_type用户类型（3天内新用户、历史未订阅老用户）、gid用户id
、first_source试用一级来源、second_source试用二级来源、third_source试用三级来源
、enter_func_list进入功能list、use_func_list打勾功能list、use_func_list保存功能list
、enter_sub_func_list进入子功能list、use_sub_func_list打勾子功能list、save_sub_func_list保存子功能list
、is_paid最终是否付费


-- 试用后功能使用明细
    SELECT 
        a.date_p date_p
        ,user_type
        ,a.gid gid
        ,first_source
        ,second_source
        ,third_source

        ,enter_func_list
        ,use_func_list
        ,save_func_list

        ,enter_sub_func_list
        ,use_sub_func_list
        ,save_sub_func_list

        ,is_paid
        ,case when act.gid is not null then 1 else 0 end is_retention_1
    FROM (
        select distinct date_p,gid,user_type,first_source,second_source,third_source,is_paid
        from stat_ab.filing_odz_trial_users_info_temp 
        where date_p between ${start_date} and ${end_date}
            and is_paid=1 -- and rand()<0.2
            and user_type in ('3天内新用户', '历史未订阅老用户')

        union all

        select distinct date_p,gid,user_type,first_source,second_source,third_source,is_paid
        from stat_ab.filing_odz_trial_users_info_temp 
        where date_p between ${start_date} and ${end_date}
            and is_paid=0 -- and rand()<0.2
            and user_type in ('3天内新用户', '历史未订阅老用户')
        ) a
    LEFT JOIN (
        -- 试用当日进入/使用/保存的功能 list（逗号分隔）
        SELECT
            f.date_p
            ,f.gid
            ,count(distinct case when f.level='2' and enter_pv > 0 then f.function_1 end) enter_func_num
            ,count(distinct case when f.level='2' and use_pv > 0 then f.function_1 end) use_func_num
            ,count(distinct case when f.level='2' and save_pv > 0 then f.function_1 end) save_func_num

            ,concat_ws(',', sort_array(collect_set(case when f.level='2' and enter_pv > 0 then f.function_1 end))) as enter_func_list
            ,concat_ws(',', sort_array(collect_set(case when f.level='2' and use_pv > 0 then f.function_1 end))) as use_func_list
            ,concat_ws(',', sort_array(collect_set(case when f.level='2' and save_pv > 0 then f.function_1 end))) as save_func_list
            -- ,concat_ws(',', sort_array(collect_set(case when f.level='2' and enter_pv > 0 and pay_type='付费' then f.function_1 end))) as enter_vip_func_list
            -- ,concat_ws(',', sort_array(collect_set(case when f.level='2' and use_pv > 0 and pay_type='付费' then f.function_1 end))) as use_vip_func_list
            -- ,concat_ws(',', sort_array(collect_set(case when f.level='2' and save_pv > 0 and pay_type='付费' then f.function_1 end))) as save_vip_func_list
            -- ,concat_ws(',', sort_array(collect_set(case when f.level='2' and enter_pv > 0 and pay_type='混合' then f.function_1 end))) as enter_mix_func_list
            -- ,concat_ws(',', sort_array(collect_set(case when f.level='2' and use_pv > 0 and pay_type='混合' then f.function_1 end))) as use_mix_func_list
            -- ,concat_ws(',', sort_array(collect_set(case when f.level='2' and save_pv > 0 and pay_type='混合' then f.function_1 end))) as save_mix_func_list

            ,count(distinct case when f.level='3' and enter_pv > 0 then f.function_2 end) enter_sub_func_num
            ,count(distinct case when f.level='3' and use_pv > 0 then f.function_2 end) use_sub_func_num
            ,count(distinct case when f.level='3' and save_pv > 0 then f.function_2 end) save_sub_func_num

            ,concat_ws(',', sort_array(collect_set(case when f.level='3' and enter_pv > 0 then f.function_2 end))) as enter_sub_func_list
            ,concat_ws(',', sort_array(collect_set(case when f.level='3' and use_pv > 0 then f.function_2 end))) as use_sub_func_list
            ,concat_ws(',', sort_array(collect_set(case when f.level='3' and save_pv > 0 then f.function_2 end))) as save_sub_func_list
            -- ,concat_ws(',', sort_array(collect_set(case when f.level='3' and enter_pv > 0 and pay_type='付费' then f.function_2 end))) as enter_vip_sub_func_list
            -- ,concat_ws(',', sort_array(collect_set(case when f.level='3' and use_pv > 0 and pay_type='付费' then f.function_2 end))) as use_vip_sub_func_list
            -- ,concat_ws(',', sort_array(collect_set(case when f.level='3' and save_pv > 0 and pay_type='付费' then f.function_2 end))) as save_vip_sub_func_list

        FROM (
            SELECT date_p, gid
                ,'2' level
                ,case when sub_func_level2_name in ('Smooth','Acne','Concealer','Brighten','Skin Tone','Dark Circles','Details','Eye Brighten','Texture','Matte','Contour','Wrinkle') then 'Skin' 
                    else sub_func_level2_name 
                end function_1
                ,'' function_2
                ,SUM(case when event_type='进入' then cnt end) enter_pv
                ,SUM(case when event_type='打勾' then cnt end) use_pv
                ,SUM(case when event_type='保存' then cnt end) save_pv
            FROM stat_sdk.airbrush_mdz_tool_behavior_detail
            WHERE date_p between ${start_date} and ${end_date}
                AND model_p IN ('image_edit') -- , 'camera', 'sp_edit', 'H5'
                AND tool_level in ('2')
                AND sub_func_level2_name in (
                    'Adjust','Crop','Eraser','Stamp','Bokeh','Blur','AI Repair','AI Replace','Relight','AI Expand','Prism'
                    ,'AI Retouch','Magic','Face','Glowup','Reshape','Resize','Stretch','Body','Muscle','Face Fix','Expression','Teeth','Makeup','Plump','AI Tattoo','Glitter'
                    ,'Filters','Hair','Preset','Effects','AI Image','Background','Text'
                    ,'Smooth','Acne','Concealer','Brighten','Skin Tone','Dark Circles','Details','Eye Brighten','Texture','Matte','Contour','Wrinkle')
            GROUP BY date_p, gid
                ,case when sub_func_level2_name in ('Smooth','Acne','Concealer','Brighten','Skin Tone','Dark Circles','Details','Eye Brighten','Texture','Matte','Contour','Wrinkle') then 'Skin' 
                    else sub_func_level2_name 
                end
            
            union all 

            SELECT date_p, gid
                ,'3' level
                ,'Skin' function_1
                ,sub_func_level2_name function_2
                ,SUM(case when event_type='进入' then cnt end) enter_pv
                ,SUM(case when event_type='打勾' then cnt end) use_pv
                ,SUM(case when event_type='保存' then cnt end) save_pv
            FROM stat_sdk.airbrush_mdz_tool_behavior_detail
            WHERE date_p between ${start_date} and ${end_date}
                AND model_p IN ('image_edit') -- , 'camera', 'sp_edit', 'H5'
                AND tool_level in ('2')
                AND sub_func_level2_name in (
                    'Smooth','Acne','Concealer','Brighten','Skin Tone','Dark Circles','Details','Eye Brighten','Texture','Matte','Contour','Wrinkle')
            GROUP BY date_p, gid
                , sub_func_level2_name

            union all 

            SELECT date_p, gid
                ,'3' level
                ,case when sub_func_level2_name='eraser' then 'Eraser' else sub_func_level2_name end function_1
                ,sub_func_level3_name function_2
                ,SUM(case when event_type='进入' then cnt end) enter_pv
                ,SUM(case when event_type='打勾' then cnt end) use_pv
                ,SUM(case when event_type='保存' then cnt end) save_pv
            FROM stat_ab.airbrush_mdz_tool_behavior_detail_v2
            WHERE date_p between ${start_date} and ${end_date}
                AND model_p IN ('image_edit') -- , 'camera', 'sp_edit', 'H5'
                AND tool_level in ('3')
                AND sub_func_level2_name in ('Face','Body','Magic','eraser','Teeth')
            GROUP BY date_p, gid
                ,case when sub_func_level2_name='eraser' then 'Eraser' else sub_func_level2_name end
                ,sub_func_level3_name
        ) f
        left join (
            select case when sub_function = '' then '2' else '3' end level
                ,`function` function_1,sub_function function_2,pay_type
            from stat_ab.filing_rna_function_pay_type
        ) p
        on f.level = p.level and f.function_1 = p.function_1 and f.function_2 = p.function_2
        GROUP BY f.date_p, f.gid
    ) func
    ON a.gid = func.gid and a.date_p = func.date_p
    left join (
        select distinct final_id as gid, date_p
        from stat_sdk.sdk_odz_active
        where date_p between ${start_date} and ${end_date_a1}
            and app_key_p in ('C851ED7164B6DF0F', '7F7023B6CEC7CDED')
            and os_p is not null
    ) act
    on a.gid = act.gid and meitu_datediff(act.date_p, a.date_p) = 1

