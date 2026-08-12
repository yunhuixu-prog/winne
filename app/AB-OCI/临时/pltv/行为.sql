-- 20251101 20260120 20260126
-- 2695468389, 20251123新增, 20251123 2.495,20260109 3.12
SET hive.exec.dynamic.partition=true;
SET hive.exec.dynamic.partition.mode=nonstrict;

insert overwrite table stat_ab.filing_onz_pltv_goal_user PARTITION(date_p)
SELECT
    t1.os_p,
    t1.is_ua,
    t1.brand,
    t1.device_model,
    t1.channel,
    t1.country,
    t1.gid,
    date_format(from_unixtime(unix_timestamp(CAST(t1.date_p AS STRING), 'yyyyMMdd')),'yyyy-MM-dd') AS st_date,
    t2.offset_days,
    date_add(from_unixtime(unix_timestamp(CAST(t1.date_p AS STRING), 'yyyyMMdd')), t2.offset_days) AS cal_date,
    t1.date_p AS date_p
FROM
(
    SELECT
        a.date_p,
        a.os_p,
        a.is_ua,
        a.brand,
        a.device_model,
        a.channel,
        c.name AS country,
        a.final_id gid
    FROM
    (
        SELECT date_p, final_id
             , MAX(os_p) os_p
             , MAX(country_id) country_id
             , MAX(is_ua) is_ua
             , MAX(brand) brand
             , MAX(device_model) device_model
             , MAX(channel) channel
        FROM stat_sdk.sdk_odz_active
        WHERE date_p BETWEEN ${start_date} AND ${end_date}
            AND app_key_p IN ('C851ED7164B6DF0F', '7F7023B6CEC7CDED')
            AND os_p IS NOT NULL
            AND `source`='gid'
            -- 7.19.0接入统计sdk
            AND (CAST(split(app_version, '\\.')[0] AS INT) > 7
                    OR (
                        CAST(split(app_version, '\\.')[0] AS INT) = 7
                        AND CAST(split(app_version, '\\.')[1] AS INT) >= 19
                    ))
        GROUP BY date_p,final_id
    ) a
    LEFT JOIN
    (
        SELECT DISTINCT id, name
        FROM stat_sdk.dim_rna_ip_location
        WHERE level='1' and date_p is not null
    ) c
    ON a.country_id = c.id
    JOIN
    (
        SELECT DISTINCT final_id, date_p
        FROM stat_sdk.sdk_odz_new_device_info
        WHERE date_p BETWEEN ${start_date} AND ${end_date}
          AND app_key_p IN ('C851ED7164B6DF0F', '7F7023B6CEC7CDED')
          AND os_p IS NOT NULL
    ) new_device
    ON a.final_id = new_device.final_id AND a.date_p = new_device.date_p
) t1
LATERAL VIEW explode(array(0, 1, 2, 3, 4, 5, 6)) t2 AS offset_days

;

SET hive.exec.dynamic.partition=true;
SET hive.exec.dynamic.partition.mode=nonstrict;

with active_day as
(
    SELECT distinct date_p
           ,final_id gid
    FROM stat_sdk.sdk_odz_active
    WHERE date_p between ${start_date} and ${end_date_add_7}
        AND app_key_p IN ('C851ED7164B6DF0F', '7F7023B6CEC7CDED')
        AND os_p IS NOT NULL
)
,
future_now_sub_pay as
(
    select gu.gid
        ,gu.st_date
        ,gu.offset_days
        ,gu.cal_date
        ,sum(case when s.pay_date between gu.st_date and date_add(gu.st_date, 89) then ord_amt_usd end) sub_revenue_90
        ,sum(case when s.pay_date between gu.st_date and date_add(gu.st_date, 6) then ord_amt_usd end) sub_revenue_7
        ,sum(case when s.pay_date between gu.st_date and gu.cal_date then ord_amt_usd end) sub_revenue_now
    from (select * from stat_ab.filing_onz_pltv_goal_user where date_p between ${start_date} and ${end_date}) gu
    left join
    (
        select
             date_format(from_unixtime(unix_timestamp(CAST(pay_date AS STRING), 'yyyyMMdd')),'yyyy-MM-dd') AS pay_date
             ,gid
             ,sum(ord_amt_usd) ord_amt_usd
             ,sum(case when ord_amt=0 then 0 else ord_amt_usd*ord_before_amt/ord_amt end) ord_before_amt_usd
        from stat_vip.paid_oda_vip_all_order
        WHERE date_p=${now_date}
            and pay_date >= ${start_date}
            and app_id_p IN (7329803307041000000)
            and commodity_id_P not in (-1)
        group by pay_date,gid
    ) s
    on gu.gid=s.gid
    group by gu.gid,gu.st_date,gu.offset_days,gu.cal_date
)
,
future_now_ai_cost as
(
    select gu.gid
        ,gu.st_date
        ,gu.offset_days
        ,gu.cal_date
        ,sum(case when s.ai_date between gu.st_date and date_add(gu.st_date, 89) then cost end) cost_revenue_90
        ,sum(case when s.ai_date between gu.st_date and date_add(gu.st_date, 6) then cost end) cost_revenue_7
        ,sum(case when s.ai_date between gu.st_date and gu.cal_date then cost end) cost_revenue_now
    from (select * from stat_ab.filing_onz_pltv_goal_user where date_p between ${start_date} and ${end_date}) gu
    left join
    (
        -- select
        --      date_format(from_unixtime(unix_timestamp(CAST(date_p AS STRING), 'yyyyMMdd')),'yyyy-MM-dd') AS ai_date
        --      ,gid
        --      ,sum(cost) cost
        -- from stat_aigc.cost_odz_dwd_processor_traceid_cost_v2
        -- WHERE date_p between ${start_date} and ${now_date}
        --     and processed_app_id = 2000020
        -- group by date_p,gid

        select date_format(from_unixtime(unix_timestamp(CAST(date_p AS STRING), 'yyyyMMdd')),'yyyy-MM-dd') AS ai_date
             ,gnum as gid
             ,sum(cost) cost
        from
            stat_aigc.cost_odz_aigc_cost_detail_d_oci_app
        where
            date_p between ${start_date} and ${now_date}
            and app_name_cn='AirBrush'
        group by date_p,gnum
    ) s
    on gu.gid=s.gid
    group by gu.gid,gu.st_date,gu.offset_days,gu.cal_date
)
,
edit_behave as
(
    SELECT date_p,gid
        ,sum(case when tool_level='1' and event_type='进入' then cnt end) edit_enter
        ,sum(case when tool_level='1' and event_type='保存' then cnt end) edit_save

        ,sum(case when tool_level='2' and event_type='进入' and sub_func_level2_name='Magic' then cnt end) magic_edit_enter
        ,sum(case when tool_level='2' and event_type='进入' and sub_func_level2_name='Face' then cnt end) face_edit_enter
        ,sum(case when tool_level='2' and event_type='进入' and sub_func_level2_name='Reshape' then cnt end) reshape_edit_enter
        ,sum(case when tool_level='2' and event_type='进入' and sub_func_level2_name='Filters' then cnt end) filters_edit_enter
        ,sum(case when tool_level='2' and event_type='进入' and sub_func_level2_name='Smooth' then cnt end) smooth_edit_enter
        ,sum(case when tool_level='2' and event_type='进入' and sub_func_level2_name='Makeup' then cnt end) makeup_edit_enter
        ,sum(case when tool_level='2' and event_type='进入' and sub_func_level2_name='AI Retouch' then cnt end) ai_retouch_edit_enter
        ,sum(case when tool_level='2' and event_type='进入' and sub_func_level2_name='Acne' then cnt end) acne_edit_enter
        ,sum(case when tool_level='2' and event_type='进入' and sub_func_level2_name='Adjust' then cnt end) adjust_edit_enter
        ,sum(case when tool_level='2' and event_type='进入' and sub_func_level2_name='Skin Tone' then cnt end) skin_tone_edit_enter
        ,sum(case when tool_level='2' and event_type='进入' and sub_func_level2_name='Body' then cnt end) body_edit_enter
        ,sum(case when tool_level='2' and event_type='进入' and sub_func_level2_name='Teeth' then cnt end) teeth_edit_enter
        ,sum(case when tool_level='2' and event_type='进入' and sub_func_level2_name='Resize' then cnt end) resize_edit_enter
        ,sum(case when tool_level='2' and event_type='进入' and sub_func_level2_name='Crop' then cnt end) crop_edit_enter
        ,sum(case when tool_level='2' and event_type='进入' and sub_func_level2_name='Eraser' then cnt end) eraser_edit_enter
        ,sum(case when tool_level='2' and event_type='进入' and sub_func_level2_name='Hair' then cnt end) hair_edit_enter
        ,sum(case when tool_level='2' and event_type='进入' and sub_func_level2_name='Relight' then cnt end) relight_edit_enter

        ,sum(case when tool_level='2' and event_type='打勾' and sub_func_level2_name='Reshape' then cnt end) reshape_edit_use
        ,sum(case when tool_level='2' and event_type='打勾' and sub_func_level2_name='Magic' then cnt end) magic_edit_use
        ,sum(case when tool_level='2' and event_type='打勾' and sub_func_level2_name='Smooth' then cnt end) smooth_edit_use
        ,sum(case when tool_level='2' and event_type='打勾' and sub_func_level2_name='Face' then cnt end) face_edit_use
        ,sum(case when tool_level='2' and event_type='打勾' and sub_func_level2_name='Makeup' then cnt end) makeup_edit_use

        ,sum(case when tool_level='2' and event_type='保存' and sub_func_level2_name='Reshape' then cnt end) reshape_edit_save
        ,sum(case when tool_level='2' and event_type='保存' and sub_func_level2_name='Magic' then cnt end) magic_edit_save
        ,sum(case when tool_level='2' and event_type='保存' and sub_func_level2_name='Smooth' then cnt end) smooth_edit_save
        ,sum(case when tool_level='2' and event_type='保存' and sub_func_level2_name='Face' then cnt end) face_edit_save
        ,sum(case when tool_level='2' and event_type='保存' and sub_func_level2_name='Makeup' then cnt end) makeup_edit_save
        ,count(distinct case when tool_level='2' and event_type='打勾' then sub_func_level2_name end) function_use_num
    FROM stat_sdk.airbrush_mdz_tool_behavior_detail
    WHERE date_p between ${start_date} and ${end_date_add_7}
        AND model_p IN ('image_edit') -- , 'camera', 'sp_edit', 'H5'
        AND tool_level in ('1','2')
    GROUP BY date_p,gid
)
,sub_behave as
(
    select
            date_p,gid
            ,count(case when event_id='w_subscription_enter' then 1 end) sub_enter_pv
            ,count(case when event_id='w_subscription_click' then 1 end) sub_click_pv
            ,count(case when event_id='w_subscription_success' then 1 end) sub_suc_pv
            ,count(case when event_id='w_subscription_enter' and
                (source_module in ('p_onboarding','p_update_first_launch')
                    or source_0 in('hpp','sub_to_guide','new_discount_2023','discount_for_cancel','f_annual_recommend_2021')) then 1 end) force_sub_enter_pv
            ,count(case when event_id='w_subscription_enter' and
                (source_module in ('p_edit')
                    and source_0 not in ('hpp','hbr','sub_to_guide','new_free_saves')) then 1 end) edit_sub_enter_pv
        from stat_ab.filing_onz_sub_source_event_detail
        where date_p between ${start_date} and ${end_date_add_7}
            and event_id in ('w_subscription_enter','w_subscription_click','w_subscription_success')
        group by date_p,gid
)
,other_behave as
(
    select date_p,gid
            ,count(case when event_id in ('popup_show') and params['page_name']='homepage' then 1 end) pop_show_pv
            ,count(case when event_id in ('popup_click') and params['page_name']='homepage' then 1 end) pop_click_pv
            ,count(case when event_id in ('save_share','camera_save_share') then 1 end) share_pv
            ,count(case when event_id in ('ai_func_use_result') then 1 end) ai_pv
    from stat_sdk.sdk_odz_source_data
    where date_p between ${start_date} and ${end_date_add_7}
        and app_key_p IN ('C851ED7164B6DF0F', '7F7023B6CEC7CDED')
        and event_id in ('save_share','camera_save_share','popup_show','popup_click','ai_func_use_result')
    group by date_p,gid
)

insert overwrite table stat_ab.filing_onz_pltv_user_date_out PARTITION(date_p)
select g.os_p,g.is_ua,g.channel,g.brand,g.device_model,g.country
        ,g.gid,g.st_date,g.offset_days,g.cal_date
        ,f.sub_revenue_90,f.sub_revenue_7,f.sub_revenue_now
        ,fa.cost_revenue_90,fa.cost_revenue_7,fa.cost_revenue_now
        ,if(a.gid is null,0,1) is_active
        ,e.edit_enter,e.edit_save
        ,e.magic_edit_enter,e.face_edit_enter,e.reshape_edit_enter,e.filters_edit_enter,e.smooth_edit_enter,e.makeup_edit_enter
        ,e.ai_retouch_edit_enter,e.acne_edit_enter,e.adjust_edit_enter,e.skin_tone_edit_enter,e.body_edit_enter,e.teeth_edit_enter
        ,e.resize_edit_enter,e.crop_edit_enter,e.eraser_edit_enter,e.hair_edit_enter,e.relight_edit_enter
        ,e.reshape_edit_use,e.magic_edit_use,e.smooth_edit_use,e.face_edit_use,e.makeup_edit_use
        ,e.reshape_edit_save,e.magic_edit_save,e.smooth_edit_save,e.face_edit_save,e.makeup_edit_save
        ,e.function_use_num
        ,s.sub_enter_pv,s.sub_click_pv,s.sub_suc_pv,s.force_sub_enter_pv,s.edit_sub_enter_pv
        ,o.pop_show_pv,o.pop_click_pv,o.share_pv,o.ai_pv
        ,g.date_p date_p
from (select * from stat_ab.filing_onz_pltv_goal_user where date_p between ${start_date} and ${end_date}) g
left join (select * from future_now_sub_pay) f
on g.gid=f.gid and g.st_date=f.st_date and g.offset_days=f.offset_days and g.cal_date=f.cal_date
left join (select * from future_now_ai_cost) fa
on g.gid=fa.gid and g.st_date=fa.st_date and g.offset_days=fa.offset_days and g.cal_date=fa.cal_date
left join (select * from active_day) a
on g.gid=a.gid and g.cal_date=date_format(from_unixtime(unix_timestamp(CAST(a.date_p AS STRING), 'yyyyMMdd')),'yyyy-MM-dd')
left join (select * from edit_behave) e
on g.gid=e.gid and g.cal_date=date_format(from_unixtime(unix_timestamp(CAST(e.date_p AS STRING), 'yyyyMMdd')),'yyyy-MM-dd')
left join (select * from sub_behave) s
on g.gid=s.gid and g.cal_date=date_format(from_unixtime(unix_timestamp(CAST(s.date_p AS STRING), 'yyyyMMdd')),'yyyy-MM-dd')
left join (select * from other_behave) o
on g.gid=o.gid and g.cal_date=date_format(from_unixtime(unix_timestamp(CAST(o.date_p AS STRING), 'yyyyMMdd')),'yyyy-MM-dd')

;
select concat(substr(gid,3,20),substr(gid,1,2)) id,offset_days,cal_date
    ,os_p,is_ua,channel,brand,device_model,country
    ,sub_revenue_90,sub_revenue_7,sub_revenue_now
    ,cost_revenue_90,cost_revenue_7,cost_revenue_now
    ,is_active,edit_enter,edit_save
    ,magic_edit_enter,face_edit_enter,reshape_edit_enter,filters_edit_enter,smooth_edit_enter,makeup_edit_enter,ai_retouch_edit_enter,acne_edit_enter,adjust_edit_enter,skin_tone_edit_enter,body_edit_enter,teeth_edit_enter,resize_edit_enter,crop_edit_enter,eraser_edit_enter,hair_edit_enter,relight_edit_enter,reshape_edit_use,magic_edit_use,smooth_edit_use,face_edit_use,makeup_edit_use,reshape_edit_save,magic_edit_save,smooth_edit_save,face_edit_save,makeup_edit_save
    ,function_use_num,sub_enter_pv,sub_click_pv,force_sub_enter_pv,edit_sub_enter_pv
    ,pop_show_pv,pop_click_pv,share_pv,ai_pv
from stat_ab.filing_onz_pltv_user_date_out
where date_p between 20251101 and 20251121 -- 分段导出
order by gid,offset_days
;
select case when sub_revenue_90>0 then 1 else 0 end is_sub,count(distinct gid) uv
from stat_ab.filing_onz_pltv_user_date_out
where date_p between 20251110 and 20251121 -- 分段导出
group by case when sub_revenue_90>0 then 1 else 0 end
;
-- 限制美国
select concat(substr(gid,3,20),substr(gid,1,2)) id,offset_days,cal_date
    ,os_p,is_ua,channel,brand,device_model,country
    ,sub_revenue_90,sub_revenue_7,sub_revenue_now
    ,cost_revenue_90,cost_revenue_7,cost_revenue_now
    ,is_active,edit_enter,edit_save
    ,magic_edit_enter,face_edit_enter,reshape_edit_enter,filters_edit_enter,smooth_edit_enter,makeup_edit_enter,ai_retouch_edit_enter,acne_edit_enter,adjust_edit_enter,skin_tone_edit_enter,body_edit_enter,teeth_edit_enter,resize_edit_enter,crop_edit_enter,eraser_edit_enter,hair_edit_enter,relight_edit_enter,reshape_edit_use,magic_edit_use,smooth_edit_use,face_edit_use,makeup_edit_use,reshape_edit_save,magic_edit_save,smooth_edit_save,face_edit_save,makeup_edit_save
    ,function_use_num,sub_enter_pv,sub_click_pv,force_sub_enter_pv,edit_sub_enter_pv
    ,pop_show_pv,pop_click_pv,share_pv,ai_pv
from stat_ab.filing_onz_pltv_user_date_out
where (date_p between 20251101 and 20251109 or date_p between 20251122 and 20260128) -- 排除上次给的
    and country='美国'
order by gid,offset_days
;
select case when sub_revenue_90>0 then 1 else 0 end is_sub,count(distinct gid) uv
from stat_ab.filing_onz_pltv_user_date_out
where (date_p between 20251101 and 20251109 or date_p between 20251122 and 20260128) -- 排除上次给的
    and country='美国'
group by case when sub_revenue_90>0 then 1 else 0 end
;
-- 正样本
select concat(substr(gid,3,20),substr(gid,1,2)) id,offset_days,cal_date
    ,os_p,is_ua,channel,brand,device_model,country
    ,sub_revenue_90,sub_revenue_7,sub_revenue_now
    ,cost_revenue_90,cost_revenue_7,cost_revenue_now
    ,is_active,edit_enter,edit_save
    ,magic_edit_enter,face_edit_enter,reshape_edit_enter,filters_edit_enter,smooth_edit_enter,makeup_edit_enter,ai_retouch_edit_enter,acne_edit_enter,adjust_edit_enter,skin_tone_edit_enter,body_edit_enter,teeth_edit_enter,resize_edit_enter,crop_edit_enter,eraser_edit_enter,hair_edit_enter,relight_edit_enter,reshape_edit_use,magic_edit_use,smooth_edit_use,face_edit_use,makeup_edit_use,reshape_edit_save,magic_edit_save,smooth_edit_save,face_edit_save,makeup_edit_save
    ,function_use_num,sub_enter_pv,sub_click_pv,force_sub_enter_pv,edit_sub_enter_pv
    ,pop_show_pv,pop_click_pv,share_pv,ai_pv
from stat_ab.filing_onz_pltv_user_date_out
where (date_p between 20251101 and 20251109 or date_p between 20251122 and 20260128) -- 排除上次给的
    and country!='美国'
    and sub_revenue_90>0
order by gid,offset_days