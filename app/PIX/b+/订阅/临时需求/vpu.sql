-- 当前订阅数/退订数
DECLARE mDATE_START DATE DEFAULT '2020-11-20';
DECLARE mDATE_END DATE DEFAULT '2020-12-20';

DECLARE mDATE DATE DEFAULT mDATE_START;

WHILE mDATE >= mDATE_START AND mDATE <= mDATE_END DO

delete from beautyplus-bc0ed.temp.winne_vpu where date = mDATE;
insert into beautyplus-bc0ed.temp.winne_vpu

-- DECLARE mDATE DATE DEFAULT '2020-11-20';
-- drop table if exists beautyplus-bc0ed.temp.winne_vpu;
-- create table beautyplus-bc0ed.temp.winne_vpu as

select
    distinct mDATE date,a.original_order_id,a.uuid
            ,a.standard_order_date,a.standard_order_expire_date
            ,a.platform,a.subscription_period,a.sku,a.country
    from `dataintegration-265403.subscription.dwd_trial_subscription_retention_daily_temp` a
    where order_status in (1,2)
        and app_id='BeautyPlus'
        and subscription_period in ('6-month','1-month','3-month','1-week','1-year')
        and offer_method = 'normal'
        and standard_order_date<=mDATE
        and (standard_order_expire_date>=mDATE or subscription_period ='lifetime')
;
SET mDATE = DATE_ADD(mDATE, INTERVAL 1 DAY);

END WHILE;



