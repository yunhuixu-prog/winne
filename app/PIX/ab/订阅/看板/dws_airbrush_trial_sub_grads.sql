DECLARE
  start INT64 DEFAULT 0;
DELETE
FROM
  `airbrush-1324.stat.dws_airbrush_trial_sub_grads`
WHERE
  event_date BETWEEN DATE_SUB('{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=0)).strftime("%Y-%m-%d") }}',INTERVAL 14 day)
  AND '{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=0)).strftime("%Y-%m-%d") }}';
INSERT INTO
  `airbrush-1324.stat.dws_airbrush_trial_sub_grads`
  --一级订阅来源
SELECT
  event_date,
  user_pseudo_id,
  payment_price_usd,
  event_name,
  country
  -- ***重要注意，每个新增的 source_module 都必须归属于一个一级来源 ,未被分配的都是 Else
  ,
  CASE
    WHEN source_module='p_ads' OR (source_module='p_edit' AND source_00 IN('remove_watermark', 'f_acne')) OR (source_00 IN('f_remove_ads', 'f_ads_remove'))THEN 'Ads'
    WHEN source_module = 'p_edit' THEN 'Edit'
    WHEN source_module = 'p_camera' THEN 'Camera'
    WHEN source_module = 'p_video' THEN 'Video'
    --WHEN source_module = 'p_activity' THEN 'Activity'
    WHEN source_module = 'AR' THEN 'AR'
    WHEN (source_module = 'p_homepage' AND source_00 IN ('ai_avatar', 'ai_headshot', 'ai_portraits', 'ai_preset', 'ai_yearbook', 'ai_newyear', 'ai_pet', 'ai_wonka') OR (source_module = 'AIGC') OR (source_module = 'p_credit' AND source_00 NOT IN('history', 'setting', 'profile')) ) THEN 'AIGC'
    WHEN source_module in('push','p_activity') OR (source_module ='p_homepage' AND source_00 IN('hbr','hpp')) THEN 'Operations'
    WHEN source_module ='p_homepage' THEN 'Else'
    -- WHEN source_module = 'push' THEN 'Else'
    ELSE 'Else'
END
  FIRST,
  'A'second,
  'A'third,
  'A'fourth,
  sale_status,
  duration,
  platform,
  app_version,
  is_new,
  is_ua,
  'First Source' category
FROM
  `airbrush-1324.stat.dws_airbrush_trial_sub`
WHERE
  source_module IS NOT NULL
  AND source_module != 'all'
  AND source_00 IS NOT NULL
  AND source_00 NOT IN ('font',
    'template',
    'f_teeth',
    'all')
  -- and source_11 = 'all'
  AND source_00 != '-'
  AND event_date >= DATE_SUB('{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=0)).strftime("%Y-%m-%d") }}',INTERVAL 14 day)
  AND event_date <= '{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=0)).strftime("%Y-%m-%d") }}'
UNION ALL
  --二级订阅来源
SELECT
  event_date,
  user_pseudo_id,
  payment_price_usd,
  event_name,
  country
  -- ***重要注意，每个新增的 source_module 都必须归属于一个一级来源 ,未被分配的都是 Else
  ,
  CASE
    WHEN source_module='p_ads' OR (source_module='p_edit' AND source_00 IN('remove_watermark', 'f_acne')) OR (source_00 IN('f_remove_ads', 'f_ads_remove'))THEN 'Ads'
    WHEN source_module = 'p_edit' THEN 'Edit'
    WHEN source_module = 'p_camera' THEN 'Camera'
    WHEN source_module = 'p_video' THEN 'Video'
   -- WHEN source_module = 'p_activity' THEN 'Activity'
    WHEN source_module = 'AR' THEN 'AR'
    WHEN (source_module = 'p_homepage' AND source_00 IN ('ai_avatar', 'ai_headshot', 'ai_portraits', 'ai_preset', 'ai_yearbook', 'ai_newyear', 'ai_pet', 'ai_wonka') OR (source_module = 'AIGC') OR (source_module = 'p_credit' AND source_00 NOT IN('history', 'setting', 'profile')) ) THEN 'AIGC'
    WHEN source_module in('push','p_activity') OR (source_module ='p_homepage' AND source_00 IN('hbr','hpp')) THEN 'Operations'
    WHEN source_module ='p_homepage' THEN 'Else'
   -- WHEN source_module = 'push' THEN 'Else'
    ELSE 'Else'
END
  FIRST
  -- 需要重新梳理为second source 的 source_00 都写一遍，无需重新归属层级的直接写source_00
  ,
  CASE
    WHEN source_module = 'p_edit' AND source_00 IN ('f_remover', 'f_eraser', 'f_relight', 'f_adjust', 'f_bokeh', 'f_blur', 'f_stamp', 'f_ai_repair', 'f_ai_replace', 'f_ai_expand', 'f_ai_toning','f_crop', 'f_colors'--已经没了，不知道放哪里，就这里吧
    ) THEN 'Edit'
    WHEN source_module = 'p_edit'
  AND source_00 IN ('f_ai_retouch',
    'f_beautify_auto',
    'f_facial_reshape',
    'f_face',
    'f_skin_tone',
    'f_smooth',
    'f_firm',
    'f_wrinkle',
    'f_foundation',
    'f_concealer',
    'f_highlighter',
    'f_brighten',
    'f_details',
    'f_matte',
    'f_texture',
    'f_reshape',
    'f_resize',
    'f_stretch',
    'f_hair_dye',
    'f_hairline',
    'f_bangs',
    'f_hairstyles',
    'f_glitter',
    'f_align',
    'f_contour',
    'f_muscle',
    'f_body',
    'face_fix',
    'f_volume',
    'f_hair_texture',
    'f_glowup') THEN 'Retouch'
    WHEN source_module = 'p_edit' AND source_00 IN('f_makeup', 'f_makeup_set_mylook', 'f_filter', 'f_filters', 'f_background', 'f_preset', 'f_effects', 'f_sparkle', 'f_text', 'f_expression', 'f_ai_image','f_ai_tattoo') THEN 'Material'
    WHEN source_00 IN('f_kit') THEN 'My Kit'
    WHEN source_00 IN('f_remove_ads', 'f_ads_remove') THEN source_module
    WHEN source_module = 'push' THEN 'Push'
    WHEN source_module = 'p_activity' THEN 'Activity'
    WHEN source_module='p_homepage' and source_00='hbr' THEN 'Homepage Banner'
    WHEN source_module='p_homepage' and source_00='hpp' THEN 'Homepage Popup'
    WHEN source_module = 'p_camera' AND source_00 IN('f_beautify_auto') THEN 'f_magic'
    WHEN source_module = 'p_settings' THEN 'Setting'
  -- 当source_00 为空时，取 source_module 比如deeplink 的source00 为空
    WHEN source_00 IS NULL THEN source_module
    ELSE source_00
END
  second,
  'A'third,
  'A'fourth,
  sale_status,
  duration,
  platform,
  app_version,
  is_new,
  is_ua,
  'Second Source' category
FROM
  `airbrush-1324.stat.dws_airbrush_trial_sub`
WHERE
  source_module IS NOT NULL
  AND source_module != 'all'
  AND source_00 IS NOT NULL
  AND source_00 NOT IN ('font',
    'template',
    'f_teeth',
    'all')
  -- and source_11 = 'all'
  AND event_date >= DATE_SUB('{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=0)).strftime("%Y-%m-%d") }}',INTERVAL 14 day)
  AND event_date <= '{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=0)).strftime("%Y-%m-%d") }}'
UNION ALL
  --三级订阅来源
SELECT
  event_date,
  user_pseudo_id,
  payment_price_usd,
  event_name,
  country
  -- ***重要注意，每个新增的 source_module 都必须归属于一个一级来源 ,未被分配的都是 Else
  ,
  CASE
    WHEN source_module='p_ads' OR (source_module='p_edit' AND source_00 IN('remove_watermark', 'f_acne')) OR (source_00 IN('f_remove_ads', 'f_ads_remove'))THEN 'Ads'
    WHEN source_module = 'p_edit' THEN 'Edit'
    WHEN source_module = 'p_camera' THEN 'Camera'
    WHEN source_module = 'p_video' THEN 'Video'
  --  WHEN source_module = 'p_activity' THEN 'Activity'
    WHEN source_module = 'AR' THEN 'AR'
    WHEN (source_module = 'p_homepage' AND source_00 IN ('ai_avatar', 'ai_headshot', 'ai_portraits', 'ai_preset', 'ai_yearbook', 'ai_newyear', 'ai_pet', 'ai_wonka') OR (source_module = 'AIGC') OR (source_module = 'p_credit' AND source_00 NOT IN('history', 'setting', 'profile')) ) THEN 'AIGC'
    WHEN source_module in('push','p_activity') OR (source_module ='p_homepage' AND source_00 IN('hbr','hpp'))THEN 'Operations'
    WHEN source_module ='p_homepage' THEN 'Else'
   -- WHEN source_module = 'push' THEN 'Else'
    ELSE 'Else'
END
  FIRST
  -- 需要重新梳理为second source 的 source_00 都写一遍，无需重新归属层级的直接写source_00
  ,
  CASE
    WHEN source_module = 'p_edit' AND source_00 IN ('f_remover', 'f_eraser', 'f_relight', 'f_adjust', 'f_bokeh', 'f_blur', 'f_stamp', 'f_ai_repair', 'f_ai_replace', 'f_ai_expand', 'f_ai_toning', 'f_crop','f_colors'--已经没了，不知道放哪里，就这里吧
    ) THEN 'Edit'
    WHEN source_module = 'p_edit'
  AND source_00 IN ('f_ai_retouch',
    'f_beautify_auto',
    'f_facial_reshape',
    'f_face',
    'f_skin_tone',
    'f_smooth',
    'f_firm',
    'f_wrinkle',
    'f_foundation',
    'f_concealer',
    'f_highlighter',
    'f_brighten',
    'f_details',
    'f_matte',
    'f_texture',
    'f_reshape',
    'f_resize',
    'f_stretch',
    'f_hair_dye',
    'f_hairline',
    'f_bangs',
    'f_hairstyles',
    'f_glitter',
    'f_align',
    'f_contour',
    'f_muscle',
    'f_body',
    'face_fix',
    'f_volume',
    'f_hair_texture',
    'f_glowup') THEN 'Retouch'
    WHEN source_module = 'p_edit' AND source_00 IN('f_makeup', 'f_makeup_set_mylook', 'f_filter', 'f_filters', 'f_background', 'f_preset', 'f_effects', 'f_sparkle', 'f_text', 'f_expression', 'f_ai_image','f_ai_tattoo') THEN 'Material'
    WHEN source_00 IN('f_kit') THEN 'My Kit'
    WHEN source_00 IN('f_remove_ads', 'f_ads_remove') THEN source_module
    WHEN source_module = 'push' THEN 'Push'
    WHEN source_module = 'p_activity' THEN 'Activity'
    WHEN source_module='p_homepage' and source_00 ='hbr' THEN 'Homepage Banner'
    WHEN source_module='p_homepage' and source_00 ='hpp' THEN 'Homepage Popup'
    WHEN source_module = 'p_camera' AND source_00 IN('f_beautify_auto') THEN 'f_magic'
    WHEN source_module = 'p_settings' THEN 'Setting'
  -- 当source_00 为空时，取 source_module 比如deeplink 的source00 为空
    WHEN source_00 IS NULL THEN source_module
    ELSE source_00
END
  second
  --
  ,
  CASE
    WHEN source_module = 'p_edit' AND source_00 IN (--'f_beautify_auto',--'f_facial_reshape','f_face','f_remover','f_eraser'
    'f_ai_retouch', 'f_relight', 'f_adjust', 'f_bokeh', 'f_blur', 'f_glitter', 'f_colors', 'f_stamp',  'f_reshape', 'f_resize', 'f_muscle', 'f_body', 'face_fix', 'f_clarity', 'f_ai_repair', 'f_ai_replace', 'f_ai_expand', 'f_stretch', 'f_crop','f_kit', 'f_preset','f_glowup')  --preset又回到编辑器里了
  --and source_11 = 'all'  retouch四级来源串到了三级，去掉这个限制
  THEN source_00
  when source_module = 'p_edit'  and source_00 IN('f_ai_toning') then 'f_adjust'
  --改名的在这里
    WHEN source_module='p_edit'
  AND source_00 IN('f_beautify_auto') THEN 'f_magic'
    WHEN source_module='p_edit' AND source_00 IN('f_facial_reshape', 'f_face') THEN 'f_face'
    WHEN source_module='p_edit'
    WHEN source_module='p_edit'
  AND source_00 IN('f_remover',
    'f_eraser') THEN 'f_eraser'
    WHEN source_module='p_edit' AND source_00 IN('f_smooth','f_contour', 'f_foundation', 'f_concealer', 'f_firm', 'f_wrinkle', 'f_skin_tone', 'f_details', 'f_highlighter', 'f_brighten', 'f_matte') THEN 'skin'
    WHEN source_module='p_edit'
  AND source_00 IN('f_texture')
  AND source_11 NOT IN('oil_control',
    'smooth',
    'shiny') THEN 'skin'
    WHEN source_module='p_edit' AND source_00='f_align' THEN 'teeth'
    WHEN source_module='p_edit'
  AND source_00 IN('f_hair_dye',
    'f_hairstyles',
    'f_hairline',
    'f_bangs',
    'f_volume',
    'f_hair_texture') THEN 'hair'
    WHEN source_module='p_edit' AND source_00 IN('f_texture') AND source_11 IN('oil_control', 'smooth', 'shiny') THEN 'hair'
  -- 一级edit 二级素材 如下
    WHEN source_module = 'p_edit'
  AND source_00 IN('f_makeup_set_mylook',
    'f_makeup') THEN 'makeup'
    WHEN source_00 IN('f_background') THEN 'background'
    WHEN source_00 IN('f_sparkle',
    'f_effects') THEN 'effects'
    WHEN source_00 = 'f_expression' THEN 'expression'
    WHEN source_00 = 'f_ai_image' THEN 'ai_image'
    WHEN source_module = 'p_edit' AND source_00 IN('f_filter', 'f_filters') THEN 'filters'
    WHEN source_00 IN('f_text') THEN 'text'
    WHEN source_00 IN('f_ai_tattoo') THEN 'ai_tattoo'
    WHEN source_00 IN('p_onboarding', 'hpp', 'hbr', 'hpbs', 'home_sub_banner', 'hpbl', 'hpr', 'shortcuts',/* 'f_facial_reshape', 'f_face',*/ 'ai_preset', 'ai_newyear', 'ai_pet', 'ai_wonka') AND source_11 <>'all' THEN source_11
    WHEN source_module IN ('AIGC',
    'p_credit',
    'p_camera') THEN source_11
    WHEN source_module in('push','p_activity') THEN source_00
    WHEN source_module = 'p_settings' THEN source_00
    WHEN source_module = 'AR' THEN source_11
    ELSE NULL
END
  third,
  'A'fourth,
  sale_status,
  duration,
  platform,
  app_version,
  is_new,
  is_ua,
  'Third Source' category
FROM
  `airbrush-1324.stat.dws_airbrush_trial_sub`
WHERE
  source_module IS NOT NULL
  AND source_module != 'all'
  AND source_00 IS NOT NULL
  AND source_00 NOT IN ('font',
    'template',
    'f_teeth',
    'all')
  AND event_date >= DATE_SUB('{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=0)).strftime("%Y-%m-%d") }}',INTERVAL 14 day)
  AND event_date <= '{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=0)).strftime("%Y-%m-%d") }}'
UNION ALL
  -- --四级订阅来源
SELECT
  event_date,
  user_pseudo_id,
  payment_price_usd,
  event_name,
  country
  -- ***重要注意，每个新增的 source_module 都必须归属于一个一级来源 ,未被分配的都是 Else
  ,
  CASE
    WHEN source_module='p_ads' OR (source_module='p_edit' AND source_00 IN('remove_watermark', 'f_acne')) OR (source_00 IN('f_remove_ads', 'f_ads_remove'))THEN 'Ads'
    WHEN source_module = 'p_edit' THEN 'Edit'
    WHEN source_module = 'p_camera' THEN 'Camera'
    WHEN source_module = 'p_video' THEN 'Video'
   -- WHEN source_module = 'p_activity' THEN 'Activity'
    WHEN source_module = 'AR' THEN 'AR'
    WHEN (source_module = 'p_homepage' AND source_00 IN ('ai_avatar', 'ai_headshot', 'ai_portraits', 'ai_preset', 'ai_yearbook', 'ai_newyear', 'ai_pet', 'ai_wonka') OR (source_module = 'AIGC') OR (source_module = 'p_credit' AND source_00 NOT IN('history', 'setting', 'profile')) ) THEN 'AIGC'
    WHEN source_module in('push','p_activity') OR (source_module ='p_homepage' AND source_00 IN('hbr','hpp')) THEN 'Operations'
    WHEN source_module ='p_homepage' THEN 'Else'
    --WHEN source_module = 'push' THEN 'Else'
    ELSE 'Else'
END
  FIRST
  -- 需要重新梳理为second source 的 source_00 都写一遍，无需重新归属层级的直接写source_00
  ,
  CASE
    WHEN source_module = 'p_edit' AND source_00 IN ('f_remover', 'f_eraser', 'f_relight','f_adjust', 'f_bokeh', 'f_blur', 'f_stamp', 'f_ai_repair', 'f_ai_replace', 'f_ai_expand', 'f_ai_toning', 'f_crop','f_colors'--已经没了，不知道放哪里，就这里吧
    ) THEN 'Edit'
    WHEN source_module = 'p_edit'
  AND source_00 IN ('f_ai_retouch',
    'f_beautify_auto',
    'f_facial_reshape',
    'f_face',
    'f_skin_tone',
    'f_smooth',
    'f_firm',
    'f_wrinkle',
    'f_foundation',
    'f_concealer',
    'f_highlighter',
    'f_brighten',
    'f_details',
    'f_matte',
    'f_texture',
    'f_reshape',
    'f_resize',
    'f_stretch',
    'f_hair_dye',
    'f_hairline',
    'f_bangs',
    'f_hairstyles',
    'f_glitter',
    'f_align',
    'f_contour',
    'f_muscle',
    'f_body',
    'face_fix',
    'f_volume',
    'f_hair_texture',
    'f_glowup') THEN 'Retouch'
    WHEN source_module = 'p_edit' AND source_00 IN('f_makeup', 'f_makeup_set_mylook', 'f_filter', 'f_filters', 'f_background', 'f_preset', 'f_effects', 'f_sparkle', 'f_text', 'f_expression', 'f_ai_image','f_ai_tattoo') THEN 'Material'
    WHEN source_00 IN('f_kit') THEN 'My Kit'
    WHEN source_00 IN('f_remove_ads', 'f_ads_remove') THEN source_module
    WHEN source_module = 'push' THEN 'Push'
    WHEN source_module = 'p_activity' THEN 'Activity'
    WHEN source_module='p_homepage' and source_00 ='hbr' THEN 'Homepage Banner'
    WHEN source_module='p_homepage' and source_00 ='hpp' THEN 'Homepage Popup'
    WHEN source_module = 'p_camera' AND source_00 IN('f_beautify_auto') THEN 'f_magic'
    WHEN source_module = 'p_settings' THEN 'Setting'
  -- 当source_00 为空时，取 source_module 比如deeplink 的source00 为空
    WHEN source_00 IS NULL THEN source_module
    ELSE source_00
END
  second
  --
  ,
  CASE
    WHEN source_module = 'p_edit' AND source_00 IN (--'f_beautify_auto',--'f_facial_reshape','f_face','f_remover','f_eraser'
    'f_ai_retouch', 'f_relight','f_adjust', 'f_bokeh', 'f_blur', 'f_glitter', 'f_colors', 'f_stamp', 'f_reshape', 'f_resize',  'f_muscle', 'f_body', 'face_fix', 'f_clarity', 'f_ai_repair', 'f_ai_replace', 'f_ai_expand', 'f_stretch', 'f_crop', 'f_kit', 'f_preset','f_glowup')  --preset又回到编辑器里了
  --and source_11 = 'all'  retouch四级来源串到了三级，去掉这个限制
  THEN source_00
  WHEN source_module = 'p_edit' AND source_00 IN('f_ai_toning') then 'f_adjust'
  --改名的在这里
    WHEN source_module='p_edit'
  AND source_00 IN('f_beautify_auto') THEN 'f_magic'
    WHEN source_module='p_edit' AND source_00 IN('f_facial_reshape', 'f_face') THEN 'f_face'
    WHEN source_module='p_edit'
  AND source_00 IN('f_remover',
    'f_eraser') THEN 'f_eraser'
    WHEN source_module='p_edit' AND source_00 IN('f_smooth',  'f_contour','f_foundation', 'f_concealer', 'f_firm', 'f_wrinkle', 'f_skin_tone', 'f_details', 'f_highlighter', 'f_brighten', 'f_matte') THEN 'skin'
    WHEN source_module='p_edit'
  AND source_00 IN('f_texture')
  AND source_11 NOT IN('oil_control',
    'smooth',
    'shiny') THEN 'skin'
    WHEN source_module='p_edit' AND source_00='f_align' THEN 'teeth'
    WHEN source_module='p_edit'
  AND source_00 IN('f_hair_dye',
    'f_hairstyles',
    'f_hairline',
    'f_bangs',
    'f_volume',
    'f_hair_texture') THEN 'hair'
    WHEN source_module='p_edit' AND source_00 IN('f_texture') AND source_11 IN('oil_control', 'smooth', 'shiny') THEN 'hair'
  -- 一级edit 二级素材 如下
    WHEN source_module = 'p_edit'
  AND source_00 IN('f_makeup_set_mylook',
    'f_makeup') THEN 'makeup'
    WHEN source_00 IN('f_background') THEN 'background'
    WHEN source_00 IN('f_sparkle',
    'f_effects') THEN 'effects'
    WHEN source_00 = 'f_expression' THEN 'expression'
    WHEN source_00 = 'f_ai_image' THEN 'ai_image'
    WHEN source_module = 'p_edit' AND source_00 IN('f_filter', 'f_filters') THEN 'filters'
    WHEN source_00 IN('f_text') THEN 'text'
    WHEN source_00 IN('f_ai_tattoo') then 'ai_tattoo'
    WHEN source_00 IN('p_onboarding', 'hpp', 'hbr', 'hpbs', 'home_sub_banner', 'hpbl', 'hpr', 'shortcuts',/* 'f_facial_reshape', 'f_face',*/ 'ai_preset', 'ai_newyear', 'ai_pet', 'ai_wonka') AND source_11 <>'all' THEN source_11
    WHEN source_module IN ('AIGC',
    'p_credit',
    'p_camera') THEN source_11
    WHEN source_module in('push','p_activity') THEN source_00
    WHEN source_module = 'p_settings' THEN source_00
    WHEN source_module = 'AR' THEN source_11
    ELSE NULL
END
  third,
  CASE
    WHEN source_11 LIKE 'AB_MKS_%' THEN 'MKS'
    WHEN source_11 LIKE '%LIP%' THEN 'LIP'
    WHEN source_11 LIKE '%BLU%' THEN 'BLU'
    WHEN source_11 LIKE '%CON%' THEN 'CON'
    WHEN source_11 LIKE '%EYB%' THEN 'EYB'
    WHEN source_11 LIKE '%EYL%' THEN 'EYL'
    WHEN source_11 LIKE '%EYN%' THEN 'EYN'
    WHEN source_11 LIKE '%EYS%' THEN 'EYS'
    WHEN source_11 LIKE '%PUP%' THEN 'PUP'
    WHEN source_00 = 'f_makeup_set_mylook' THEN 'set_mylook'
    WHEN source_module='p_edit'
  AND source_11 ='smth' THEN 'smooth'
    WHEN source_module='p_edit' AND source_11 ='dkcircl' THEN 'dark circles'
    WHEN source_module='p_edit'
  AND source_11 ='wht' THEN 'whiten'
    WHEN source_module='p_edit' AND source_11 ='brt' THEN 'brighten'
    WHEN source_module='p_edit'
  AND source_11 ='skn' THEN 'skin tone'
    WHEN source_module='p_edit' AND source_11 ='elg' THEN 'enlarge'
    WHEN source_module='p_edit'
  AND source_00 IN('f_ai_retouch',
    'f_makeup',
    'f_background',
    'f_filter',
    'f_filters',
    'f_sparkle',
    'f_preset',
    'f_effects',
    'f_body',
    'f_muscle',
    'f_reshape',
    'f_beautify_auto','f_glowup','f_facial_reshape', 'f_face','f_relight','f_adjust','f_crop','f_ai_tattoo') THEN source_11
    WHEN source_module = 'p_edit' AND source_00 IN('f_smooth','f_contour', --'f_foundation','f_concealer','f_firm','f_wrinkle',
    'f_texture', 'f_skin_tone', 'f_details', --'f_highlighter','f_brighten',
    'f_matte', 'f_align', 'f_hair_dye', 'f_hairline', 'f_hairstyles', 'f_bangs', 'f_volume','f_ai_toning') THEN source_00
    WHEN source_module in('p_activity')  THEN source_11
    WHEN source_module='p_edit' AND source_11 IN ('face_width', 'chin', 'nose_size', 'lip_size', 'contouring', 'red_eyes', 'f_beautify_auto_ext', 'f_smooth_presets',
    --'curtain_bangs', 'tilted_frisette','air_bangs','long_hair',
    'font', 'template', 'cheek', 'forehead', 'nose', 'eye', 'eyebrow', 'chin', 'lip',
    --'Cheeks', 'cheeks', 'forehead', 'Forehead', 'nose', 'Nose', 'Eyes', 'eyes', 'eyebrows', 'Eyebrows', 'chin', 'Chin', 'lips', 'Lips',
    'ai', 'passersby',--'classic',
    'face', 'nose', 'jaw' )THEN LOWER(source_11)
  --改名的
    WHEN source_module = 'p_edit'
  AND source_00='f_hair_texture' THEN 'f_texture'
    WHEN source_module = 'p_edit' AND source_00 IN('f_highlighter', 'f_brighten') THEN 'f_brighten'
    WHEN source_module = 'p_edit'
  AND source_00 IN('f_foundation',
    'f_concealer') THEN 'f_concealer'
    WHEN source_module = 'p_edit' AND source_00 IN('f_firm', 'f_wrinkle') THEN 'f_wrinkle'
    WHEN source_module='p_edit'
  AND source_11 IN ('classic',
    'spot_remover') THEN 'spot_remover'
    ELSE NULL
END
  AS fourth,
  sale_status,
  duration,
  platform,
  app_version,
  is_new,
  is_ua,
  'Fourth Source' category
FROM
  `airbrush-1324.stat.dws_airbrush_trial_sub`
WHERE
  source_module IS NOT NULL
  AND source_module != 'all'
  AND source_00 IS NOT NULL
  AND source_00 NOT IN ('font',
    'template',
    'f_teeth',
    'all')
  AND event_date >= DATE_SUB('{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=0)).strftime("%Y-%m-%d") }}',INTERVAL 14 day)
  AND event_date <= '{{ (execution_date + macros.timedelta(hours=8) - macros.timedelta(days=0)).strftime("%Y-%m-%d") }}'