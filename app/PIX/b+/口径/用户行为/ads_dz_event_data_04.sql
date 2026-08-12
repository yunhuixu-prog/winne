
--delete from `beautyplus-bc0ed.event_dataset_4.ads_dz_event_data_04` where event_date>='2023-05-25';
delete from `beautyplus-bc0ed.event_dataset_4.ads_dz_event_data_04` where event_date>='{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=3)).strftime("%Y-%m-%d") }}'AND event_date<='{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=0)).strftime("%Y-%m-%d") }}';
insert into `beautyplus-bc0ed.event_dataset_4.ads_dz_event_data_04`
with dws_dz_acitve_user as
(
 select * FROM  `beautyplus-bc0ed.event_dataset_2.dws_dz_active_user_02`
 --where event_date>='2023-05-25'
  where event_date>='{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=3)).strftime("%Y-%m-%d") }}'AND event_date<='{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=0)).strftime("%Y-%m-%d") }}'
 and version>='7.4.000'---add by zxy 2021/07/14
),
dwd_dz_event_group as
(
SELECT event_date, platform, user_pseudo_id, event_name, key_name, value_name, event_name_cn, module, class, function, subfunction, subfunction_a, action, num, mark, pv
FROM `beautyplus-bc0ed.event_dataset_4.dwd_dz_event_group_04`
where event_date>='{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=3)).strftime("%Y-%m-%d") }}'AND event_date<='{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=0)).strftime("%Y-%m-%d") }}'
--where event_date>='2023-05-25'
)
select

m.event_date, m.platform, m.country, m.is_new, m.is_UA, m.user_type, m.is_pay, m.version, m.android_device, m.dau,
m.event_name, m.key as key_name, m.value as value_name, m.event_name_cn, m.module, m.class, m.function, m.subfunction, m.subfunction_a, m.action, m.num,m.mark, n.uv, n.pv
from
(

SELECT
a.event_date, a.platform, a.country, a.is_new, a.is_UA, a.user_type, a.is_pay, a.version, a.android_device,a.dau,
b.event_name,b.key,b.value,b.event_name_cn,b.action,
b.module, b.class, b.FUNCTION, b.subfunction, b.subfunction_a, b.num, b.mark
--n.key_name, n.value_name, n.module, n.class, n.function, n.subfunction, n.subfunction_a, n.action, n.num, n.uv, n.pv
from
    (
    SELECT event_date, platform, country, is_new, is_UA, user_type, is_pay, version, android_device, count(user_pseudo_id) as dau
    FROM dws_dz_acitve_user
    --where event_date>='{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=3)).strftime("%Y-%m-%d") }}'AND event_date<='{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=0)).strftime("%Y-%m-%d") }}'
    group by event_date, platform, country, is_new, is_UA, user_type, is_pay, version,android_device
    )a
    cross join
    (
    SELECT
    concat(event_id,'_bd') as event_name, event_name as event_name_cn, IFNULL(key,'-') as key, IFNULL(value,'-') as value,
     module, class, FUNCTION, subfunction, subfunction_a, IFNULL(action,'-') as action, num, level as mark
    FROM `beautyplus-bc0ed.event_dataset_4.dmi_da_event_04_view`

    )b
)m
 left join
(

select
a.event_date,a.platform,a.event_name,a.key_name,a.value_name,a.event_name_cn,a.module, a.class, a.function, a.subfunction, a.subfunction_a, IFNULL(a.action,'-') as action, a.num,a.mark,
e.country, e.is_new, e.is_UA, e.user_type, e.is_pay, e.version,e.android_device,count(a.user_pseudo_id) as uv,sum(pv) as pv
from dwd_dz_event_group a
 join dws_dz_acitve_user e --版本
on a.event_date=e.event_date and a.platform=e.platform and a.user_pseudo_id=e.user_pseudo_id

 group by
 a.event_date,a.platform,a.event_name,a.key_name,a.value_name,a.event_name_cn,a.module, a.class, a.function, a.subfunction, a.subfunction_a, IFNULL(a.action,'-') ,  a.num,a.mark,
 e.country, e.is_new, e.is_UA, e.user_type, e.is_pay, e.version ,e.android_device

)n
on m.event_date=n.event_date and m.platform=n.platform and  IFNULL(m.country,'-') = IFNULL(n.country,'-') and m.is_new=n.is_new and m.is_UA=n.is_UA
and IFNULL(m.android_device,'-') =IFNULL(n.android_device,'-') and m.user_type=n.user_type and m.is_pay=n.is_pay and m.version=n.version
and m.event_name=n.event_name and m.event_name_cn=n.event_name_cn and m.key=n.key_name and m.value=n.value_name and m.action=n.action
and IFNULL(m.module,'-')=IFNULL(n.module,'-') and IFNULL(m.class,'-')=IFNULL(n.class,'-') and IFNULL(m.FUNCTION,'-')=IFNULL(n.FUNCTION,'-')
and IFNULL(m.subfunction,'-')=IFNULL(n.subfunction,'-') and IFNULL(m.subfunction_a,'-')=IFNULL(n.subfunction_a,'-')
--and m.num=n.num and IFNULL(m.mark,9999)=IFNULL(n.mark,9999)
