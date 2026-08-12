-- select distinct event_action,module,class,function --,template_id
-- select *
-- FROM `devops-325206.bp.dwd_dz_recommand_events_v`
-- where event_date='2024-01-01'
-- limit 10
-- ;

-- select * from devops-325206.stats.project_bp_data_day limit 10

-- 获取列指标
-- SELECT distinct concat(event_action,'-',module,'-',class,'-',function) FROM `devops-325206.bp.dwd_dz_recommand_events_v` WHERE event_date>='2024-01-01'

drop table if exists `beautyplus-bc0ed.temp.recommend_user_behave_list`;
create table `beautyplus-bc0ed.temp.recommend_user_behave_list` as

SELECT * FROM
(
  SELECT concat(event_action,'-',module,'-',class,'-',function) activity,user_pseudo_id,count(1) pv
  FROM
    `devops-325206.bp.dwd_dz_recommand_events_v`
  WHERE event_date between '2024-01-01' and '2024-01-14'
--     and user_pseudo_id='B346D3E1A15B45A2BAB4B9DA1EABE4ED'
  group by 1,2
  -- limit 10
)
PIVOT
(
  -- #2 aggregate
  sum(pv) AS pv
  -- #3 pivot_column
  -- 批量获取格式后的activity，参考onenote中的文字批量加上引号方法
  FOR activity in ("订阅-修图-Edit-马赛克","点击-修图-素材-配方","订阅-修图-Beauty-匀肤","订阅-修图-others-抠图","订阅-修图-Beauty-细节","订阅-修图-others-发际线","订阅-拍摄-Makeup-美瞳","保存-修图-美颜-面部打光","保存-修图-美颜-缩小鼻翼","订阅-修图-Material-背景纹理","订阅-拍摄-Makeup-腮红颜色","订阅-拍摄-Beauty-匀肤","保存-修图-美颜-磨皮","订阅-修图-Beauty-祛痘","订阅-修图-others-AI美颜","订阅-修图-Makeup-睫毛颜色","订阅-拍摄-Makeup-睫毛样式","订阅-拍摄-Edit-AI增强","保存-拍摄-美妆-染发","保存-拍摄-美妆-修容","订阅-修图-others-套装","订阅-拍摄-Edit-色散","订阅-拍摄-others-发际线","订阅-修图-素材-配方","订阅-拍摄-Makeup-修容素材","订阅-拍摄-Makeup-睫毛素材","订阅-修图-Makeup-口红样式","订阅-拍摄-others-AI美颜","订阅-拍摄-Material-文字","订阅-拍摄-Material-字体","保存-修图-美颜-祛痘","订阅-修图-others-美瞳素材","保存-修图-创意-贴纸","保存-修图-美妆-卧蚕","保存-修图-美颜-缩头","保存-修图-美颜-牙齿美白","订阅-修图-Material-风格","订阅-修图-others-风格化","订阅-拍摄-Makeup-眉毛样式","订阅-修图-others-祛法令纹","保存-修图-创意-背景","保存-修图-美妆-修容","订阅-修图-Material-AR","订阅-修图-Material-涂鸦笔","订阅-修图-Edit-消除笔","订阅-拍摄-Material-AR","订阅-拍摄-Makeup-眉毛素材","订阅-修图-Makeup-睫毛样式","订阅-拍摄-Beauty-细节","保存-修图-美妆-睫毛","订阅-修图-others-特效","订阅-修图-Edit-AI增强","订阅-修图-others-AI扩展","订阅-拍摄-others-发缝","订阅-拍摄-others-美妆笔","订阅-修图-others-发型","订阅-拍摄-others-发型","保存-修图-编辑-风格化","订阅-修图-Material-滤镜","订阅-修图-Beauty-淡化黑眼圈","订阅-拍摄-Material-风格","","保存-拍摄-美妆-美瞳","订阅-修图-Edit-照片修复","订阅-修图-others-祛双下巴","订阅-拍摄-Material-配方","订阅-拍摄-Beauty-肤色色号","订阅-拍摄-others-表情","保存-修图-编辑-AR","保存-拍摄-美妆-口红","订阅-修图-others-美妆笔","订阅-修图-others-卧蚕素材","订阅-修图-others-仿妆","订阅-拍摄-others-风格化","订阅-拍摄-Edit-照片修复","订阅-拍摄-others-修容样式","订阅-拍摄-Material-萌奇奇","订阅-拍摄-others-塑形","保存-修图-编辑-消除笔","保存-修图-美颜-亮眼","保存-修图-美颜-瘦脸","保存-修图-美颜-肤色","订阅-修图-Edit-色散","订阅-修图-Edit-虚化","订阅-拍摄-others-柔发","订阅-修图-others-修容样式","订阅-修图-Makeup-染发","订阅-修图-others-表情","订阅-拍摄-Makeup-染发","订阅-拍摄-others-仿妆","保存-修图-美颜-眼睛放大","订阅-修图-Material-电影光斑","订阅-修图-Material-文字","订阅-修图-Material-配方","订阅-修图-Makeup-修容素材","订阅-修图-Makeup-口红素材","订阅-拍摄-Makeup-口红素材","订阅-拍摄-Makeup-口红色号","订阅-拍摄-Material-涂鸦笔","保存-修图-创意-涂鸦笔","保存-修图-美妆-腮红","订阅-拍摄-Beauty-牙齿矫正","订阅-修图-others-发缝","订阅-修图-Material-背景渐变","订阅-拍摄-others-美瞳素材","订阅-拍摄-Material-贴纸","订阅-拍摄-Beauty-面部重塑","保存-修图-美妆-眉毛","订阅-拍摄-others-背景保护","订阅-修图-others-视频防抖","订阅-修图-others-分身","订阅-修图-Makeup-眼影","保存-修图-美妆-染发","保存-修图-美颜-匀肤","保存-修图-美颜-一键美颜","订阅-修图-Beauty-牙齿矫正","订阅-拍摄-others-卧蚕素材","订阅-修图-Makeup-美瞳","订阅-拍摄-Edit-消除笔","保存-修图-编辑-马赛克","保存-修图-美妆-眼影","订阅-拍摄-Material-滤镜","订阅-拍摄-Beauty-淡化黑眼圈","订阅-拍摄-others-抠图","订阅-拍摄-others-面部打光","保存-修图-素材-配方","保存-修图-编辑-虚化","保存-拍摄-美妆-腮红","订阅-拍摄-Beauty-祛皱","订阅-拍摄-Edit-虚化","订阅-拍摄-Material-背景渐变","保存-修图-美妆-美瞳","保存-修图-美颜-牙齿矫正","订阅-修图-Material-萌奇奇","订阅-修图-Beauty-肤色色号","订阅-修图-others-面部打光","保存-修图-创意-文字","保存-拍摄-美妆-眼影","订阅-修图-others-视频修复","订阅-修图-Makeup-腮红颜色","保存-修图-编辑-AI增强","保存-修图-美颜-AI美颜","保存-拍摄-美妆-睫毛","订阅-拍摄-others-特效","订阅-修图-Makeup-口红颜色","订阅-拍摄-others-祛双下巴","保存-修图-美颜-去油光","保存-修图-美颜-五官立体","保存-修图-美颜-面部重塑","保存-拍摄-美妆-眉毛","订阅-拍摄-others-分身","订阅-拍摄-Makeup-睫毛颜色","保存-修图-美妆-口红","保存-拍摄-美妆-卧蚕","订阅-修图-Material-贴纸","订阅-修图-others-雀斑","订阅-拍摄-Makeup-眼影","保存-修图-美颜-祛皱","订阅-修图-others-塑形","订阅-修图-Beauty-祛皱","订阅-修图-Makeup-口红色号","订阅-修图-Makeup-眉毛素材","订阅-修图-Makeup-睫毛素材","订阅-修图-Beauty-面部重塑","订阅-拍摄-Beauty-祛痘","订阅-拍摄-others-雀斑","订阅-修图-Makeup-眉毛样式","保存-修图-编辑-色散","订阅-修图-others-背景保护","保存-修图-美颜-淡化黑眼圈","订阅-拍摄-others-祛法令纹","订阅-拍摄-others-套装","保存-修图-编辑-抠图","保存-修图-美颜-塑形","订阅-修图-others-柔发","订阅-修图-Material-字体","订阅-拍摄-Makeup-口红样式","订阅-拍摄-Makeup-口红颜色","订阅-拍摄-Material-背景纹理","订阅-修图-Beauty-肤色","订阅-拍摄-Edit-马赛克","订阅-修图-Material-动态贴纸")
)
