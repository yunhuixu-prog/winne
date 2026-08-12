-- 添加新列
ALTER TABLE beautyplus-bc0ed.temp.dws_dz_his_split_final_user_behave_v2
ADD COLUMN bucket INT64;

-- 更新数据，填充随机数
UPDATE beautyplus-bc0ed.temp.dws_dz_his_split_final_user_behave_v2
SET bucket = CAST(FLOOR(RAND() * 6) AS INT64) where 1=1; -- 创建0到5共6个桶

-- 删除新列
ALTER TABLE beautyplus-bc0ed.temp.dws_dz_his_split_final_user_behave_v2
drop COLUMN bucket;

select bucket,count(1)
from beautyplus-bc0ed.temp.dws_dz_his_split_final_user_behave_v2
where date='2023-03-31'
group by 1