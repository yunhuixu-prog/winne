WITH 
indicators_tmp AS (
select product_line 
        ,ocean_name
        ,is_overseas
        ,month
        ,nvl(app_type,'未知') as app_type
                  ,a.app_name as app_name
        ,nvl(period_type,'未知') as period_type  -- 新增字段
                  ,country_name
                  ,country_type
        ,sum(moth_valid_menber ) as moth_valid_menber 
from
    (select      product as product_line 
                ,case when app_type='秀秀粉钻' then '美图秀秀'
                        when app_type='证件照' then '美图证件照'
                        when app_type='秀秀设计室PC端' then '美图设计室pc'
                        when app_type='秀秀设计室Web端' then '美图设计室web'
                        when app_type='秀秀设计室移动端' then '美图设计室-秀秀内嵌'
                        when app_type='海报工厂' then '美图设计室app'
                        else lower(app_type) end  as app_name
                ,ocean_name
                ,'影像产品' as is_overseas
                ,period_type  -- 新增字段
                ,moth_valid_menber 
                ,date_p as month
                ,country_name
                ,country_type
            from stat_meitu.mtxx_amz_mau_vipuser
            where  date_p>=${time_0}  and date_p<=${time_1} 
                and type='订阅'
                and app_type not in('整体')
                and product not in ('整体')
                and os_type IN ('整体')
            union all
            select lower(product_line ) as product_line
                ,lower(product_sub_line)  as app_name
                ,ocean_name
                ,'影像产品' as is_overseas
                ,period_type  -- 新增字段
                ,valid_menber as moth_valid_menber 
                ,date_p   as month
                ,country_name
                ,country_type
            from stat_vip.gry_amz_oversea_vipuser_vp
            where  date_p>=${time_0}  and date_p<=${time_1} 
                and product_line not in ('整体')
                and product_sub_line not in  ('整体')
                             and lower(product_sub_line) not like 'mhc%'
                and os_type IN ('整体')
            union all
            select lower(product_line) as product_line
                ,case when lower(product_sub_line)='airbrush studio' then 'ab studio'
                     when lower(product_sub_line)='snapid' then 'passure'
                     when lower(product_sub_line)='beauty plus cam' then 'beautyplus cam'
                                  when lower(product_sub_line)='airbrush video' then 'airvid'
                           else lower(product_sub_line) end  as app_name
                ,ocean_name
                ,'Pixocial' as is_overseas
                ,period_type as period_type  -- 新增字段
                ,valid_menber
                ,date_p as month
                ,country_code as country_name
                ,geographic_subdivision_v2 as country_type
            from stat_vip.vip_amz_middle_income_month_oci
            where  date_p>=${time_0}  and date_p<=${time_1} 
                and product_line  in ('整体')
                and product_sub_line not in  ('整体')
                and os_type IN ('整体')
                             and pay_channel IN ('整体')
                             and type in('订阅')
    )a
    left join 
    (select lower(app_name) as app_name
            ,app_type
    from  stat_meitu.mtxx_rna_app_type
    group by lower(app_name),app_type
    )b
   on lower(a.app_name)=lower(b.app_name)
   where a.app_name not in ('其他')
   group  by product_line,ocean_name,is_overseas,month,a.app_name,nvl(app_type,'未知'),period_type,country_name,country_type  -- 新增分组字段
),
t1 AS (
    SELECT
        month,
            CASE 
            WHEN lower(app_name) IN ('beautyplus') THEN 'BeautyPlus'
            WHEN lower(app_name) IN ('airbrush') THEN 'AirBrush'
            WHEN lower(product_line) IN ('wink') THEN 'Wink'
            WHEN lower(product_line) IN ('开拍','开拍web')  THEN '开拍'
            WHEN lower(product_line) IN ('美图设计室') THEN '美图设计室'
            WHEN lower(product_line) IN ('秀秀粉钻') THEN '美图秀秀'
            WHEN lower(product_line) IN ('美颜相机') THEN '美颜相机'
            ELSE '其他' 
        END AS product_line,
            CASE 
            WHEN lower(app_name) IN ('beautyplus') THEN 'BeautyPlus'
            WHEN lower(app_name) IN ('airbrush') THEN 'AirBrush'
            WHEN lower(product_line) IN ('wink') THEN 'Wink'
            WHEN lower(product_line) IN ('开拍','开拍web')  THEN '开拍'
            WHEN lower(product_line) IN ('美图设计室') THEN app_name
            WHEN lower(product_line) IN ('秀秀粉钻') THEN '美图秀秀'
            WHEN lower(product_line) IN ('美颜相机') THEN '美颜相机'
            ELSE '其他' 
        END AS sub_product_line,
            app_type,
            is_overseas,
            ocean_name,
        period_type  -- 新增字段
        ,country_name
        ,country_type
            ,sum(moth_valid_menber) as moth_valid_menber
    FROM
        indicators_tmp
    WHERE
        month = ${time_1}   -- 当月分区current("yyyyMM01")
        and not (product_line='BeautyPlus' and is_overseas='影像产品')
    group by month,
            CASE 
            WHEN lower(app_name) IN ('beautyplus') THEN 'BeautyPlus'
            WHEN lower(app_name) IN ('airbrush') THEN 'AirBrush'
            WHEN lower(product_line) IN ('wink') THEN 'Wink'
            WHEN lower(product_line) IN ('开拍','开拍web')  THEN '开拍'
            WHEN lower(product_line) IN ('美图设计室') THEN '美图设计室'
            WHEN lower(product_line) IN ('秀秀粉钻') THEN '美图秀秀'
            WHEN lower(product_line) IN ('美颜相机') THEN '美颜相机'
            ELSE '其他' 
        END,
            CASE 
            WHEN lower(app_name) IN ('beautyplus') THEN 'BeautyPlus'
            WHEN lower(app_name) IN ('airbrush') THEN 'AirBrush'
            WHEN lower(product_line) IN ('wink') THEN 'Wink'
            WHEN lower(product_line) IN ('开拍','开拍web')  THEN '开拍'
            WHEN lower(product_line) IN ('美图设计室') THEN app_name
            WHEN lower(product_line) IN ('秀秀粉钻') THEN '美图秀秀'
            WHEN lower(product_line) IN ('美颜相机') THEN '美颜相机'
            ELSE '其他' 
        END,
            app_type,
            is_overseas,
            ocean_name,
        period_type  -- 新增分组字段
        ,country_name
        ,country_type
),
base_data_tmp AS (
-- 国内影像
select
date_p as month,
ocean_name,
country_name
,country_type,
'影像产品'    as  is_overseas,
-- 和mtxx_rna_app_type官方对齐
case when app_type in ('秀秀粉钻','美图秀秀') then '美图秀秀'
             when app_type='证件照' then '美图证件照'
             when app_type='秀秀设计室PC端' then '美图设计室pc'
             when app_type='秀秀设计室Web端' then '美图设计室web'
             when app_type='秀秀设计室移动端' then '美图设计室-秀秀内嵌'
             when app_type='海报工厂' then '美图设计室app'
             else lower(app_type) end  as app_name,
nvl(period_type,'未知') as  period_type,  -- 新增字段
sum(moth_new_valid_member) as moth_new_valid_member
from
        stat_vip.gry_amz_tmp_new_valid_member
where
        date_p = ${time_1}  -- 当月分区
    and app_type not in ('整体')
group by date_p ,
ocean_name,
case when app_type in ('秀秀粉钻','美图秀秀') then '美图秀秀'
             when app_type='证件照' then '美图证件照'
             when app_type='秀秀设计室PC端' then '美图设计室pc'
             when app_type='秀秀设计室Web端' then '美图设计室web'
             when app_type='秀秀设计室移动端' then '美图设计室-秀秀内嵌'
             when app_type='海报工厂' then '美图设计室app'
             else lower(app_type) end,
period_type  -- 新增分组字段
,country_name,country_type

union all 
-- starii
select
date_p as month,
ocean_name
  ,country_name
      ,country_type,
'影像产品'    as  is_overseas,
lower(app_type) AS app_name,
nvl(period_type,'未知') as  period_type,  -- 新增字段
sum(moth_new_valid_member) as moth_new_valid_member

from
        stat_vip.vip_amz_tmp_new_valid_member_starii 
where
        date_p = ${time_1}  -- 当月分区
    and app_type not in ('整体')
          and lower(app_type) not like 'mhc%'
group by date_p,
ocean_name,
lower(app_type),
period_type  -- 新增分组字段
  ,country_name
      ,country_type 

UNION all 
-- oci
select
date_p as month,
ocean_name
  ,country_name
      ,country_type,
'Pixocial'    as  is_overseas,
lower(app_type) AS app_name,
nvl(period_type,'未知') as  period_type,  -- 新增字段
sum(moth_new_valid_member) as moth_new_valid_member

from
         stat_vip.vip_amz_new_valid_member_oci
where
        date_p = ${time_1}  -- 当月分区
    and app_type not in ('整体')
group by date_p,
ocean_name,
lower(app_type),
period_type  -- 新增分组字段
  ,country_name
      ,country_type 
),
t2 AS 
(
select 
    month,
    CASE 
            WHEN lower(t1.app_name) IN ('beautyplus') THEN 'BeautyPlus'
            WHEN lower(t1.app_name) IN ('airbrush') THEN 'AirBrush'
            WHEN lower(t1.app_name) IN ('wink') THEN 'Wink'
            WHEN lower(t1.app_name) IN ('开拍','开拍web')  THEN '开拍'
            WHEN lower(t1.app_name) IN ('美图设计室pc','美图设计室web','美图设计室-秀秀内嵌','美图设计室app') THEN '美图设计室'
            WHEN lower(t1.app_name) IN ('美图秀秀') THEN '美图秀秀'
            WHEN lower(t1.app_name) IN ('美颜相机') THEN '美颜相机'
            ELSE '其他' 
        END AS product_line,
    CASE 
            WHEN lower(t1.app_name) IN ('beautyplus') THEN 'BeautyPlus'
            WHEN lower(t1.app_name) IN ('airbrush') THEN 'AirBrush'
            WHEN lower(t1.app_name) IN ('wink') THEN 'Wink'
            WHEN lower(t1.app_name) IN ('开拍','开拍web')  THEN '开拍'
            WHEN lower(t1.app_name) IN ('美图设计室pc','美图设计室web','美图设计室-秀秀内嵌','美图设计室app') THEN t1.app_name
            WHEN lower(t1.app_name) IN ('美图秀秀') THEN '美图秀秀'
            WHEN lower(t1.app_name) IN ('美颜相机') THEN '美颜相机'
            ELSE '其他' 
        END AS sub_product_line,
    app_type,
    is_overseas,
    ocean_name,
    period_type,  -- 新增字段
    country_name,
    country_type, 
    sum(moth_new_valid_member) as moth_new_valid_member
from 
(
        select * from base_data_tmp
) t1
left join
          (select lower(app_name) as app_name
                 ,app_type
               from  stat_meitu.mtxx_rna_app_type
               group by lower(app_name),app_type
          )t4 
    on lower(t1.app_name)=t4.app_name
group by  month,
    CASE 
            WHEN lower(t1.app_name) IN ('beautyplus') THEN 'BeautyPlus'
            WHEN lower(t1.app_name) IN ('airbrush') THEN 'AirBrush'
            WHEN lower(t1.app_name) IN ('wink') THEN 'Wink'
            WHEN lower(t1.app_name) IN ('开拍','开拍web')  THEN '开拍'
            WHEN lower(t1.app_name) IN ('美图设计室pc','美图设计室web','美图设计室-秀秀内嵌','美图设计室app') THEN '美图设计室'
            WHEN lower(t1.app_name) IN ('美图秀秀') THEN '美图秀秀'
            WHEN lower(t1.app_name) IN ('美颜相机') THEN '美颜相机'
            ELSE '其他' 
        END,
    CASE 
            WHEN lower(t1.app_name) IN ('beautyplus') THEN 'BeautyPlus'
            WHEN lower(t1.app_name) IN ('airbrush') THEN 'AirBrush'
            WHEN lower(t1.app_name) IN ('wink') THEN 'Wink'
            WHEN lower(t1.app_name) IN ('开拍','开拍web')  THEN '开拍'
            WHEN lower(t1.app_name) IN ('美图设计室pc','美图设计室web','美图设计室-秀秀内嵌','美图设计室app') THEN t1.app_name
            WHEN lower(t1.app_name) IN ('美图秀秀') THEN '美图秀秀'
            WHEN lower(t1.app_name) IN ('美颜相机') THEN '美颜相机'
            ELSE '其他' 
        END ,
    app_type,
    is_overseas,
    ocean_name,
    period_type,  -- 新增分组字段
    country_name,
    country_type
),
-- 第2步：获取上个月的有效会员数
last AS (
    SELECT
        -- 维度列，用于和当月数据关联
        CASE 
            WHEN lower(app_name) IN ('beautyplus') THEN 'BeautyPlus'
            WHEN lower(app_name) IN ('airbrush') THEN 'AirBrush'
            WHEN lower(product_line) IN ('wink') THEN 'Wink'
            WHEN lower(product_line) IN ('开拍','开拍web')  THEN '开拍'
            WHEN lower(product_line) IN ('美图设计室') THEN '美图设计室'
            WHEN lower(product_line) IN ('秀秀粉钻') THEN '美图秀秀'
            WHEN lower(product_line) IN ('美颜相机') THEN '美颜相机'
            ELSE '其他' 
        END AS product_line,
        CASE 
            WHEN lower(app_name) IN ('beautyplus') THEN 'BeautyPlus'
            WHEN lower(app_name) IN ('airbrush') THEN 'AirBrush'
            WHEN lower(product_line) IN ('wink') THEN 'Wink'
            WHEN lower(product_line) IN ('开拍','开拍web')  THEN '开拍'
            WHEN lower(product_line) IN ('美图设计室') THEN app_name
            WHEN lower(product_line) IN ('秀秀粉钻') THEN '美图秀秀'
            WHEN lower(product_line) IN ('美颜相机') THEN '美颜相机'
            ELSE '其他' 
        END AS sub_product_line,
        app_type,
        is_overseas,
        ocean_name,
        period_type,  -- 新增字段
        -- 核心指标：上月有效会员数
        country_name,
        country_type, 
        sum(moth_valid_menber) as last_moth_valid_menber
    FROM
        indicators_tmp
    WHERE
        month = ${time_0} -- 注意：这里是上个月的分区current("yyyyMM01")-2，请根据实际情况修改
        and not (product_line='BeautyPlus' and is_overseas='影像产品')
    group by
        CASE 
            WHEN lower(app_name) IN ('beautyplus') THEN 'BeautyPlus'
            WHEN lower(app_name) IN ('airbrush') THEN 'AirBrush'
            WHEN lower(product_line) IN ('wink') THEN 'Wink'
            WHEN lower(product_line) IN ('开拍','开拍web')  THEN '开拍'
            WHEN lower(product_line) IN ('美图设计室') THEN '美图设计室'
            WHEN lower(product_line) IN ('秀秀粉钻') THEN '美图秀秀'
            WHEN lower(product_line) IN ('美颜相机') THEN '美颜相机'
            ELSE '其他' 
        END,
        CASE 
            WHEN lower(app_name) IN ('beautyplus') THEN 'BeautyPlus'
            WHEN lower(app_name) IN ('airbrush') THEN 'AirBrush'
            WHEN lower(product_line) IN ('wink') THEN 'Wink'
            WHEN lower(product_line) IN ('开拍','开拍web')  THEN '开拍'
            WHEN lower(product_line) IN ('美图设计室') THEN app_name
            WHEN lower(product_line) IN ('秀秀粉钻') THEN '美图秀秀'
            WHEN lower(product_line) IN ('美颜相机') THEN '美颜相机'
            ELSE '其他' 
        END,
        app_type,
        is_overseas,
        ocean_name,
        period_type,  -- 新增分组字段
        country_name,
        country_type 
)

insert overwrite table stat_vip.vip_amz_valid_member_breakdown partition (date_p = ${date_p})
-- 第3步：最终计算（重构为最简单的多路JOIN结构）
SELECT
    t1.month,
    case when lower(t1.sub_product_line)='airvid' then 'airvidnew' else t1.product_line end as product_line, 
    case when lower(t1.sub_product_line)='airvid' then 'airvidnew' else t1.sub_product_line end as sub_product_line,
    t1.app_type,
    t1.is_overseas,
    t1.ocean_name,
    COALESCE(t1.moth_valid_menber, 0) AS moth_valid_menber,          -- 本月有效会员数
    COALESCE(t2.moth_new_valid_member, 0) AS moth_new_valid_member,      -- 本月新增有效会员数
    COALESCE(last.last_moth_valid_menber, 0) AS last_moth_valid_menber,     -- 上月有效会员数

    -- 计算公式1：本月留存会员数(rentention_member)
    (COALESCE(t1.moth_valid_menber, 0) - COALESCE(t2.moth_new_valid_member, 0)) AS rentention_member,

    -- 计算公式2：本月流失会员数(churned_member)
    (COALESCE(last.last_moth_valid_menber, 0) + COALESCE(t2.moth_new_valid_member, 0) - COALESCE(t1.moth_valid_menber, 0)) AS churned_member,

    -- 计算公式3：本月净新增会员数(net_new_member)
    (COALESCE(t2.moth_new_valid_member, 0) - (COALESCE(last.last_moth_valid_menber, 0) + COALESCE(t2.moth_new_valid_member, 0) - COALESCE(t1.moth_valid_menber, 0))) AS net_new_member,

    -- 计算公式4：本月月有效留存率(rentention_rate)
    CASE
        WHEN COALESCE(last.last_moth_valid_menber, 0) > 0 
        THEN (COALESCE(t1.moth_valid_menber, 0) - COALESCE(t2.moth_new_valid_member, 0)) * 1.0 / COALESCE(last.last_moth_valid_menber, 0)
        ELSE 0
    END AS rentention_rate,
    t1.period_type as period_type,  -- 新增字段
    t1.country_name,
    t1.country_type 
FROM 
    t1
LEFT JOIN 
    t2
    ON t1.month = t2.month 
    AND t1.product_line = t2.product_line 
    AND t1.sub_product_line = t2.sub_product_line 
    AND t1.app_type = t2.app_type 
    AND t1.is_overseas = t2.is_overseas 
    AND t1.ocean_name = t2.ocean_name
    AND t1.period_type = t2.period_type  -- 新增关联条件
    and t1.country_name= t2.country_name
    and t1.country_type=t2.country_type
LEFT JOIN 
    last
    ON t1.product_line = last.product_line
    AND t1.sub_product_line = last.sub_product_line
    AND t1.app_type = last.app_type
    AND t1.is_overseas = last.is_overseas
    AND t1.ocean_name = last.ocean_name
    AND t1.period_type = last.period_type  -- 新增关联条件
    and t1.country_name= last.country_name
    and t1.country_type=last.country_type