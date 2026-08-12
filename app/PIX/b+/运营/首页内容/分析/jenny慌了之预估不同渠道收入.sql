-- select from_page --,is_pay,version,from_page
--     ,sum(exposure) exposure
--     ,sum(click) click
--     ,sum(visit) visit
--     ,sum(enter_generate_page) enter_generate_page
--     ,sum(generate) generate
--     ,sum(credit_use) credit_use
--     ,sum(credit_num) credit_num
--     ,sum(payment_price_usd) payment_price_usd
-- from `beautyplus-bc0ed.aigc.dws_dzp_aigc_h5_event_miniapp_level_v2`
-- where event_date>='2024-01-01'
-- -- and from_page='All'
-- and data_type='uv' and miniapp_name='AI Pet Portrait'
-- group by 1
-- order by 1;

select case when event_date between '2023-07-01' and '2023-09-30' then '2023Q3'
            when event_date between '2023-10-01' and '2023-12-31' then '2023Q4'
        end quanter
    ,sum(click_miniapp_uv) click_miniapp_uv
    ,sum(click_banner_uv) click_banner_uv
    ,sum(click_popup_uv) click_popup_uv
    ,sum(payment_price_usd)
from `beautyplus-bc0ed.content_data.dws_da_h5_event_miniapp_level`
where event_date between '2023-07-01' and '2023-12-31'
-- and miniapp_name in ('AI Pet Portrait','AI Studio Photo','Zodiac Persona','AI Pair Photo')
group by 1
order by 1




