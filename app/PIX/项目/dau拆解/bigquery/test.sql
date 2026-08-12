
DECLARE columns STRING DEFAULT '';
DECLARE query_template STRING;
DECLARE final_query STRING;

-- 获取表的所有列名和数据类型
SET columns = (
  SELECT STRING_AGG(
    -- 对每种数据类型使用不同的默认值
    CASE data_type WHEN 'STRING' THEN FORMAT('IFNULL(%s, "") %s', column_name, column_name)
                   WHEN 'INT64' THEN FORMAT('IFNULL(%s, -1) %s', column_name, column_name)
                   WHEN 'FLOAT64' THEN FORMAT('IFNULL(%s, -1.0) %s', column_name, column_name)
                   -- 添加更多数据类型的处理方式...
                   ELSE column_name END,
    ', '
  )
  FROM `beautyplus-bc0ed.temp.INFORMATION_SCHEMA.COLUMNS`
  WHERE table_name = 'dws_dz_his_split_final_user_behave_v'
);

-- 训练数据集
-- 创建SQL查询模板
SET query_template = '''
SELECT %s
FROM `beautyplus-bc0ed.temp.dws_dz_his_split_final_user_behave_v`
where date between "2023-01-01" and "2023-04-30" and sub_type = "else" and install_days_type between 3 and 4 and is_active_7 = 1 and is_edit_selfi_7 = 1
and (case when sub_365>0 then 1=1 when sub_365=0 then rand()<0.8 end)
''';

-- 插入列名来完成查询
SET final_query = FORMAT(query_template, columns);

-- 执行最终的查询来创建一个新的表或物化视图

EXECUTE IMMEDIATE final_query;
-- 放入 表 beautyplus-bc0ed.temp.dws_dz_his_split_user_behave_bq_train_test


-- 测试数据集
SET query_template = '''
SELECT %s
FROM `beautyplus-bc0ed.temp.dws_dz_his_split_final_user_behave_v`
where date = "2023-05-01" and sub_type = "else" and install_days_type between 3 and 4 and is_active_7 = 1 and is_edit_selfi_7 = 1
limit 1000000
''';

-- 插入列名来完成查询
SET final_query = FORMAT(query_template, columns);

-- 执行最终的查询来创建一个新的表或物化视图

EXECUTE IMMEDIATE final_query;
-- 放入 表 beautyplus-bc0ed.temp.dws_dz_his_split_user_behave_bq_predict_test



-- 模型训练
CREATE OR REPLACE MODEL `temp.test_model`
OPTIONS (model_type='BOOSTED_TREE_CLASSIFIER',
          input_label_cols=['sub_365']) AS
SELECT *except(date,sub_90,uuid,sub_type,bucket,sub_365),if(sub_365>0,1,0) sub_365 FROM `beautyplus-bc0ed.temp.dws_dz_his_split_user_behave_bq_train_test`
where date between '2023-01-01' and '2023-04-30'
limit 800000
;
CREATE OR REPLACE MODEL `temp.test_logistic`
OPTIONS (model_type='LOGISTIC_REG',
          input_label_cols=['sub_365']) AS
SELECT *except(date,sub_90,uuid,sub_type,bucket,sub_365),if(sub_365>0,1,0) sub_365 FROM `beautyplus-bc0ed.temp.dws_dz_his_split_user_behave_bq_train_test`
where date between '2023-01-01' and '2023-04-30'
limit 800000
;
CREATE OR REPLACE MODEL `temp.test_dnn`
OPTIONS (model_type='DNN_CLASSIFIER',
          input_label_cols=['sub_365']) AS
SELECT *except(date,sub_90,uuid,sub_type,bucket,sub_365),if(sub_365>0,1,0) sub_365 FROM `beautyplus-bc0ed.temp.dws_dz_his_split_user_behave_bq_train_test`
where date between '2023-01-01' and '2023-04-30'
limit 800000
;
-- 模型预测(F1:0.07)
-- test_logistic(F1:0.046)
-- test_dnn(F1:0.06)
SELECT * FROM
-- ML.PREDICT (
ML.EVALUATE(
        MODEL `temp.test_model`,
        (
            SELECT *except(date,sub_90,uuid,sub_type,bucket,sub_365),if(sub_365>0,1,0) sub_365
            FROM `beautyplus-bc0ed.temp.dws_dz_his_split_user_behave_bq_predict_test`
            where date = '2023-05-01'
            limit 1000000
        )
)

