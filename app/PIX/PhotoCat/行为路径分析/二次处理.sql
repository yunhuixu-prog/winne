
with behavior_unnest as
(
    select event_date,user_pseudo_id,event_ad,offset + 1 AS event_order
    from
    (
        select e.event_date,e.user_pseudo_id,seq_has_times,seq
             ,replace(
                replace(
                    replace(
                        replace(
                            replace(
                                replace(
                                    replace(
                                        replace(
                                            replace(seq, 'beauty_appr_edit_clk,beautifysave', '点击功能到功能保存')
                                        ,'beauty_tag,click_delete,delete_sub_imp', '标记删除订阅页曝光')
                                    , 'beauty_tag,click_delete', '标记删除')
                                , 'click_delete,delete_sub_imp', '点击删除到订阅页曝光')
                            , 'beauty_appr_edit_clk,ai_sub_imp', '点击功能到订阅页曝光')
                        , 'homepage_click_ai,beautifysave', '首页点击ai到功能保存')
                    , 'homepage_click_ai,ai_sub_imp', '首页点击ai到订阅页曝光')
                , 'beauty_tag,beauty_appr_edit_clk', '照片标记和点击功能')
             , 'onboarding_imp,onboarding_sub_imp', 'onboarding到订阅页')

             seq_ad
        from `dataintegration-265403.temp.winne_temp_photocat_user_seq` e
    ) a,unnest(split(seq_ad,',')) as event_ad with offset
)
,group_event as
(
    select event_date,user_pseudo_id,event_ad,event_order
            ,sum(if(event_ad!=coalesce(pre_event_ad,''),1,0)) over(partition by event_date,user_pseudo_id order by event_order) group_event_rank
    from
    (
        select event_date,user_pseudo_id,event_ad,event_order
    --          ,row_number() over(partition by event_date,user_pseudo_id order by event_timestamp) event_rank
             ,lag(event_ad) over(partition by event_date,user_pseudo_id order by event_order) pre_event_ad
        from behavior_unnest
--         where user_pseudo_id='7759387390884A3CB99133190763DADA'
    )
)
,
user_behavior_seq as
(
    select event_date,user_pseudo_id,group_event_rank,event_ad
         ,count(1) nums
    from group_event
    group by 1,2,3,4
)
,
seq_final as
(
    select event_date,user_pseudo_id
    --         ,STRING_AGG(case when nums=1 then event_ad
    --               when nums>1 then concat(event_ad,'*',cast(nums as string))
    --         end,',' order by group_event_rank) seq_ad_has_times
            ,STRING_AGG(event_ad,',' order by group_event_rank) seq_ad
    from user_behavior_seq
    -- where group_event_rank<=10
    group by 1,2
)

select seq_ad,count(distinct e.user_pseudo_id) uv
from seq_final e
join `dataintegration-265403.stat.stat_active_advice_detail_d` u
on e.user_pseudo_id=u.user_pseudo_id and e.event_date=u.event_date_hk
where u.is_new=1
group by 1
order by 2 desc


