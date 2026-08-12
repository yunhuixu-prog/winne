# import第三方库
import gc
import os
import datetime
import json
from google.oauth2 import service_account
from google.cloud import bigquery
import numpy as np
import pandas as pd
# 数据预处理
from sklearn.preprocessing import LabelEncoder, StandardScaler
from sklearn.model_selection import train_test_split
from sklearn.preprocessing import KBinsDiscretizer
# 模型
# from xgboost import XGBRegressor as XGBR
from xgboost import XGBClassifier as XGBC
from sklearn.pipeline import make_pipeline
from sklearn.ensemble import StackingRegressor, StackingClassifier, RandomForestClassifier
from sklearn.linear_model import LogisticRegression
# from sklearn.linear_model import RidgeCV, LassoCV
# from sklearn.neighbors import KNeighborsRegressor
# from sklearn.svm import LinearSVC

# 模型评估
from sklearn.metrics import roc_auc_score as AUC
from sklearn.metrics import confusion_matrix, precision_score, recall_score, f1_score
from sklearn.metrics import mean_squared_error, r2_score

import sys
from joblib import dump, load


def model_train(d, e_d, sub_type, install_days_type_1, install_days_type_2
                , is_active_7_1, is_active_7_2, is_edit_selfi_7_1, is_edit_selfi_7_2
                , is_active_30_1, is_active_30_2, is_edit_selfi_30_1, is_edit_selfi_30_2
                , is_active_60_1, is_active_60_2, is_edit_selfi_60_1, is_edit_selfi_60_2
                , is_active_90_1, is_active_90_2, is_edit_selfi_90_1, is_edit_selfi_90_2
                , bucket, model_name, input_thred_1, input_thred_2):
    # step1:导入训练数据(取投放日期在一年半-一年的数据)
    client = bigquery.Client()
    query_cnt_1 = """
                select count(1)
                from 
                (
                    select 1
                    from airbrush-1324.temp.dws_dz_his_split_final_user_behave_v
                    where date between DATE_SUB({0}, INTERVAL 366+180+8 DAY) and DATE_SUB({0}, INTERVAL 366+8 DAY)
                        and date>='2023-01-01'
                    -- where date between '2023-01-01' and '2023-04-30'
                        and sub_365>0 
                        and sub_type = {1} 
                        and install_days_type between {2} and {3}
                        and is_active_7 between {4} and {5}
                        and is_edit_selfi_7 between {6} and {7}
                        and is_active_30 between {8} and {9}
                        and is_edit_selfi_30 between {10} and {11}
                        and is_active_60 between {12} and {13}
                        and is_edit_selfi_60 between {14} and {15}
                        and is_active_90 between {16} and {17}
                        and is_edit_selfi_90 between {18} and {19}
                )
                             """.format(e_d, sub_type, install_days_type_1, install_days_type_2
                                        , is_active_7_1, is_active_7_2, is_edit_selfi_7_1, is_edit_selfi_7_2
                                        , is_active_30_1, is_active_30_2, is_edit_selfi_30_1, is_edit_selfi_30_2
                                        , is_active_60_1, is_active_60_2, is_edit_selfi_60_1, is_edit_selfi_60_2
                                        , is_active_90_1, is_active_90_2, is_edit_selfi_90_1, is_edit_selfi_90_2
                                        , bucket)
    cnt_1 = client.query(query_cnt_1).to_dataframe().iloc[0, 0]
    print(f'正样本数量:{cnt_1}')
    query_cnt_2 = """
                select count(1)
                from 
                (
                    select 1
                    from airbrush-1324.temp.dws_dz_his_split_final_user_behave_v
                    where date between DATE_SUB({0}, INTERVAL 366+180+8 DAY) and DATE_SUB({0}, INTERVAL 366+8 DAY)
                        and date>='2023-01-01'
                    -- where date between '2023-01-01' and '2023-04-30'
                        and sub_365=0 
                        and sub_type = {1} 
                        and install_days_type between {2} and {3}
                        and is_active_7 between {4} and {5}
                        and is_edit_selfi_7 between {6} and {7}
                        and is_active_30 between {8} and {9}
                        and is_edit_selfi_30 between {10} and {11}
                        and is_active_60 between {12} and {13}
                        and is_edit_selfi_60 between {14} and {15}
                        and is_active_90 between {16} and {17}
                        and is_edit_selfi_90 between {18} and {19}
                        and bucket = {20}
                )
                                 """.format(e_d, sub_type, install_days_type_1, install_days_type_2
                                            , is_active_7_1, is_active_7_2, is_edit_selfi_7_1, is_edit_selfi_7_2
                                            , is_active_30_1, is_active_30_2, is_edit_selfi_30_1, is_edit_selfi_30_2
                                            , is_active_60_1, is_active_60_2, is_edit_selfi_60_1, is_edit_selfi_60_2
                                            , is_active_90_1, is_active_90_2, is_edit_selfi_90_1, is_edit_selfi_90_2
                                            , bucket)
    cnt_2 = client.query(query_cnt_2).to_dataframe().iloc[0, 0]
    print(f'负样本数量:{cnt_2}')

    query_drop = """ drop table if exists airbrush-1324.temp.dws_dz_his_split_final_user_behave_model """
    drop_job = client.query(query_drop)
    drop_job.result()

    query_create = """
                    create table airbrush-1324.temp.dws_dz_his_split_final_user_behave_model as 

                    select *except(uuid,sub_type,bucket,date)
                    from airbrush-1324.temp.dws_dz_his_split_final_user_behave_v
                    where date between DATE_SUB({0}, INTERVAL 366+180+8 DAY) and DATE_SUB({0}, INTERVAL 366+8 DAY)
                        and date>='2023-01-01'
                    -- where date between '2023-01-01' and '2023-04-30'
                        and sub_365>0
                        and rand()<least({23}/{21},1)
                        and sub_type = {1}
                        and install_days_type between {2} and {3}
                        and is_active_7 between {4} and {5}
                        and is_edit_selfi_7 between {6} and {7}
                        and is_active_30 between {8} and {9}
                        and is_edit_selfi_30 between {10} and {11}
                        and is_active_60 between {12} and {13}
                        and is_edit_selfi_60 between {14} and {15}
                        and is_active_90 between {16} and {17}
                        and is_edit_selfi_90 between {18} and {19}

                    union all

                    select *except(uuid,sub_type,bucket,date)
                    from airbrush-1324.temp.dws_dz_his_split_final_user_behave_v
                    where date between DATE_SUB({0}, INTERVAL 366+180+8 DAY) and DATE_SUB({0}, INTERVAL 366+8 DAY)
                        and date>='2023-01-01'
                    -- where date between '2023-01-01' and '2023-04-30'
                        and sub_365=0
                        and rand()<least({24}/{22},1)
                        and sub_type = {1}
                        and install_days_type between {2} and {3}
                        and is_active_7 between {4} and {5}
                        and is_edit_selfi_7 between {6} and {7}
                        and is_active_30 between {8} and {9}
                        and is_edit_selfi_30 between {10} and {11}
                        and is_active_60 between {12} and {13}
                        and is_edit_selfi_60 between {14} and {15}
                        and is_active_90 between {16} and {17}
                        and is_edit_selfi_90 between {18} and {19}
                        and bucket = {20}
                        """.format(e_d, sub_type, install_days_type_1, install_days_type_2
                                   , is_active_7_1, is_active_7_2, is_edit_selfi_7_1, is_edit_selfi_7_2
                                   , is_active_30_1, is_active_30_2, is_edit_selfi_30_1, is_edit_selfi_30_2
                                   , is_active_60_1, is_active_60_2, is_edit_selfi_60_1, is_edit_selfi_60_2
                                   , is_active_90_1, is_active_90_2, is_edit_selfi_90_1, is_edit_selfi_90_2
                                   , bucket, cnt_1, cnt_2, input_thred_1, input_thred_2)

    if bucket == 1:
        print(f'query:{query_create}')

    create_job = client.query(query_create)
    print("Table created successfully.")
    create_job.result()

    os.system("bash /home/yunhui/ab/load_train_data_ab.sh")

    files = [pos_json for pos_json in os.listdir('/home/yunhui/ab/data/train/train_data_ab/') if
             pos_json.endswith('.json')]
    print(files)

    # 创建一个空的DataFrame用于之后存放数据
    raw_data = pd.DataFrame()
    # 循环读取和合并每个JSON文件
    for file in files:
        file_path = os.path.join('/home/yunhui/ab/data/train/train_data_ab/', file)
        reader = pd.read_json(file_path, chunksize=10000, lines=True)
        batch_num = 0
        for batch_data in reader:
            raw_data = pd.concat([raw_data, batch_data], ignore_index=True)
            batch_num = batch_num + 1
            print(batch_num)
            # if batch_num > 3:
            #     break

    print(f'model input shape:{raw_data.shape}')

    # 数据预处理
    # 舍弃异常样本及列（看一下分布）
    # 预测365收入
    # data_pre = raw_data.loc[:, ['date']]
    raw_data = (raw_data.drop(['sub_7', 'sub_30', 'sub_90'], axis=1))

    # # 数值型特征离散化
    # for i in range(len(numeric_columns)):
    #     kbd = kbds[i]
    #     co = numeric_columns[i]
    #
    #     # 使用fit_transform方法对数据进行拟合并转换
    #     raw_data.loc[raw_data[co].notnull(), [co]] = kbd.transform(raw_data.loc[raw_data[co].notnull(), [co]])

    # 缺失值处理
    for column in raw_data.columns:
        if column == 'sub_365':
            continue
        raw_data.fillna({column: -1}, inplace=True)

    # 特征选择
    column_list = []
    for column in raw_data.columns:
        # if raw_data[column].value_counts().shape[0]<=1:
        #     continue
        if int(install_days_type_2) <= 2:
            if '_30' in column or '_60' in column or '_90' in column:
                continue
            else:
                column_list.append(column)
        elif int(install_days_type_2) <= 4:
            if '_60' in column or '_90' in column:
                continue
            else:
                column_list.append(column)
        elif int(install_days_type_2) <= 5:
            if '_90' in column:
                continue
            else:
                column_list.append(column)
        else:
            column_list.append(column)

    raw_data = raw_data.loc[:, column_list]

    # if int(install_days_type_1)>=7:
    #     column_list = []
    #     for column in raw_data.columns:
    #         if '_30' in column or '_60' in column or '_90' in column:
    #             column_list.append(column)
    #         elif 'pv_tab' in column:
    #             continue
    #         else:
    #             column_list.append(column)
    #     raw_data = raw_data.loc[:, column_list]
    if bucket == 1:
        print(f'select columns:{column_list}')

    # 提炼分类/回归样本
    X_no_sub_now = (raw_data.drop(['sub_365'], axis=1))
    y_no_sub_now = raw_data['sub_365']
    y_no_sub_now = y_no_sub_now.map(lambda x: 1 if x > 0 else 0)

    # 清除内存
    raw_data = pd.DataFrame()
    del raw_data

    print(f'classification model input shape:{X_no_sub_now.shape}')
    print(f'classification model value count:\n{y_no_sub_now.value_counts()}')

    # from imblearn.over_sampling import RandomOverSampler, SMOTE
    # from collections import Counter
    # ros = RandomOverSampler(random_state=0)
    # X_no_sub_now, y_no_sub_now = ros.fit_resample(X_no_sub_now, y_no_sub_now)
    #
    # over_strategy = SMOTE(sampling_strategy=0.5)
    # X_no_sub_now, y_no_sub_now = over_strategy.fit_resample(X_no_sub_now, y_no_sub_now)
    #
    # print(sorted(Counter(y_no_sub_now).items()))

    # 模型训练-分类模型
    xtrain, xtest, ytrain, ytest = train_test_split(X_no_sub_now, y_no_sub_now, train_size=0.70, random_state=23)

    # 清除内存
    X_no_sub_now = pd.DataFrame()
    del X_no_sub_now, y_no_sub_now

    # estimators = [
    #     ('rf', RandomForestClassifier(n_estimators=20, random_state=42, max_depth=25)),
    #     ('xgbc', XGBC(n_estimators=10, random_state=24, max_depth=6, subsample=0.8))
    # ]
    estimators = [
        ('rf', RandomForestClassifier(n_estimators=10, random_state=42)),
        ('xgbc', XGBC(n_estimators=10, random_state=24))
    ]
    stacking = StackingClassifier(
        estimators=estimators, final_estimator=LogisticRegression()
    )
    stacking.fit(xtrain, ytrain)

    # 保存模型到文件
    model_name = model_name + '_bucket_' + str(bucket)
    dump(stacking, '/home/yunhui/ab/model/stacking_' + model_name + '.joblib')

    # 预测和评估
    print("stacking分类器的训练误差:%.3f" % (1 - stacking.score(xtrain, ytrain)))
    print("stacking分类器的测试误差:%.3f" % (1 - stacking.score(xtest, ytest)))

    print("stacking分类器的auc:%.3f" % (AUC(ytrain, stacking.predict_proba(xtrain)[:, 1])))
    print("stacking分类器的auc:%.3f" % (AUC(ytest, stacking.predict_proba(xtest)[:, 1])))

    del xtrain, ytrain, xtest, ytest

    return stacking


def read_data(d, e_d, days, sub_type, install_days_type_1, install_days_type_2
              , is_active_7_1, is_active_7_2, is_edit_selfi_7_1, is_edit_selfi_7_2
              , is_active_30_1, is_active_30_2, is_edit_selfi_30_1, is_edit_selfi_30_2
              , is_active_60_1, is_active_60_2, is_edit_selfi_60_1, is_edit_selfi_60_2
              , is_active_90_1, is_active_90_2, is_edit_selfi_90_1, is_edit_selfi_90_2):
    print('真实样本')
    client = bigquery.Client()
    # 选择投放未满90天的数据
    query_real = """
            select *except(sub_type,bucket)
            from airbrush-1324.temp.dws_dz_his_split_final_user_behave_v
            -- where date = DATE_SUB({0}, INTERVAL {20}+90 DAY)
            where date = {0} and sub_type = {1}
                and install_days_type between {2} and {3}
                and is_active_7 between {4} and {5}
                and is_edit_selfi_7 between {6} and {7}
                and is_active_30 between {8} and {9}
                and is_edit_selfi_30 between {10} and {11}
                and is_active_60 between {12} and {13}
                and is_edit_selfi_60 between {14} and {15}
                and is_active_90 between {16} and {17}
                and is_edit_selfi_90 between {18} and {19}
            limit 200000
                 """.format(e_d, sub_type, install_days_type_1, install_days_type_2
                            , is_active_7_1, is_active_7_2, is_edit_selfi_7_1, is_edit_selfi_7_2
                            , is_active_30_1, is_active_30_2, is_edit_selfi_30_1, is_edit_selfi_30_2
                            , is_active_60_1, is_active_60_2, is_edit_selfi_60_1, is_edit_selfi_60_2
                            , is_active_90_1, is_active_90_2, is_edit_selfi_90_1, is_edit_selfi_90_2
                            , days)

    print(f'query:{query_real}')
    X_no_sub_now_real = client.query(query_real).to_dataframe()

    print(f'predict input shape:{X_no_sub_now_real.shape}')

    if X_no_sub_now_real.shape[0] == 0:
        return X_no_sub_now_real, 0, 0

    # 数据处理
    data_pre_real = X_no_sub_now_real.loc[:, ['date', 'uuid', 'sub_365'
                                                 , 'install_days_type'
                                                 , 'is_active_7', 'is_edit_selfi_7'
                                                 , 'is_active_30', 'is_edit_selfi_30'
                                                 , 'is_active_60', 'is_edit_selfi_60'
                                                 , 'is_active_90', 'is_edit_selfi_90']]
    X_no_sub_now_real = (X_no_sub_now_real.drop(['sub_365', 'sub_7', 'sub_30', 'sub_90', 'date', 'uuid'],
                                                axis=1))

    y_no_sub_now_real = data_pre_real['sub_365']
    y_no_sub_now_real = y_no_sub_now_real.map(lambda x: 1 if x > 0 else 0)

    # # 数值型特征离散化
    # for i in range(len(numeric_columns)):
    #     kbd = kbds[i]
    #     co = numeric_columns[i]
    #
    #     # 使用fit_transform方法对数据进行拟合并转换
    #     X_no_sub_now_real.loc[X_no_sub_now_real[co].notnull(), [co]] = kbd.transform(X_no_sub_now_real.loc[X_no_sub_now_real[co].notnull(), [co]])

    # 缺失值处理
    for column in X_no_sub_now_real.columns:
        X_no_sub_now_real.fillna({column: -1}, inplace=True)

    # 特征选择
    column_list = []
    for column in X_no_sub_now_real.columns:
        if int(install_days_type_2) <= 2:
            if '_30' in column or '_60' in column or '_90' in column:
                continue
            else:
                column_list.append(column)
        elif int(install_days_type_2) <= 4:
            if '_60' in column or '_90' in column:
                continue
            else:
                column_list.append(column)
        elif int(install_days_type_2) <= 5:
            if '_90' in column:
                continue
            else:
                column_list.append(column)
        else:
            column_list.append(column)

    X_no_sub_now_real = X_no_sub_now_real.loc[:, column_list]

    # if int(install_days_type_1) >= 7:
    #     column_list = []
    #     for column in X_no_sub_now_real.columns:
    #         if '_30' in column or '_60' in column or '_90' in column:
    #             column_list.append(column)
    #         elif 'pv_tab' in column:
    #             continue
    #         else:
    #             column_list.append(column)
    #     X_no_sub_now_real = X_no_sub_now_real.loc[:, column_list]

    print(f'classification input shape:{X_no_sub_now_real.shape}')
    return X_no_sub_now_real, y_no_sub_now_real, data_pre_real


def real_predict(X_no_sub_now_real, bucket, model_name):
    # 真实数据预测(拿历史数据预估，仅测试)
    model_name = model_name + '_bucket_' + str(bucket)
    stacking = load('/home/yunhui/ab/model/stacking_' + model_name + '.joblib')
    y_no_sub_now_predit_real = stacking.predict_proba(X_no_sub_now_real)[:, 1]
    return y_no_sub_now_predit_real


def metric_cal(data_pre_real, y_no_sub_now_real, y_no_sub_now_predit_real, e_d, days, sub_type
               , install_days_type_1, install_days_type_2
               , is_active_7_1, is_active_7_2, is_edit_selfi_7_1, is_edit_selfi_7_2
               , is_active_30_1, is_active_30_2, is_edit_selfi_30_1, is_edit_selfi_30_2
               , is_active_60_1, is_active_60_2, is_edit_selfi_60_1, is_edit_selfi_60_2
               , is_active_90_1, is_active_90_2, is_edit_selfi_90_1, is_edit_selfi_90_2):
    # 选定阈值
    f1 = []
    precision = []
    recall = []
    for thred_real in np.arange(0, 1, 0.1):
        precision.append(precision_score(y_no_sub_now_real, y_no_sub_now_predit_real >= thred_real))
        recall.append(recall_score(y_no_sub_now_real, y_no_sub_now_predit_real >= thred_real))
        f1.append(f1_score(y_no_sub_now_real, y_no_sub_now_predit_real >= thred_real))

    print(f'real classification thred choose-f1:{f1}')
    print(f'real classification thred choose-precision:{precision}')
    print(f'real classification thred choose-recall:{recall}')

    # 选定阈值输出分类预测
    max_value = max(f1)
    max_index = f1.index(max_value)
    thred_real = np.arange(0, 1, 0.1)[max_index]
    # thred_real = 0.8
    print(f'real classification thred choose:{thred_real}')

    # 计算查准率
    precision = precision_score(y_no_sub_now_real, y_no_sub_now_predit_real >= thred_real)
    print(f'Precision: {precision:.2f}')

    # 计算查全率
    recall = recall_score(y_no_sub_now_real, y_no_sub_now_predit_real >= thred_real)
    print(f'Recall: {recall:.2f}')

    # 计算F1 Score
    f1 = f1_score(y_no_sub_now_real, y_no_sub_now_predit_real >= thred_real)
    print(f'F1 Score: {f1:.2f}')

    conf_matrix_real = confusion_matrix(y_no_sub_now_real, y_no_sub_now_predit_real >= thred_real)
    print(f'混淆矩阵: \n{conf_matrix_real}')

    # 原数据加入预测数据进行比较
    out_data_real = pd.concat([data_pre_real.loc[:,
                               ['date', 'uuid', 'sub_365'
                                   , 'install_days_type'
                                   , 'is_active_7', 'is_edit_selfi_7'
                                   , 'is_active_30', 'is_edit_selfi_30'
                                   , 'is_active_60', 'is_edit_selfi_60'
                                   , 'is_active_90', 'is_edit_selfi_90']]
                                  , pd.Series(y_no_sub_now_predit_real)
                                  , pd.Series(y_no_sub_now_predit_real >= thred_real)], axis=1)

    out_data_real['sub_type'] = sub_type.strip('\'')
    # out_data_real['install_days_type'] = int(install_days_type)
    # out_data_real['is_active_7'] = int(is_active_7)
    # out_data_real['is_edit_selfi_7'] = int(is_edit_selfi_7)
    # out_data_real['is_active_90'] = int(is_active_90)
    # out_data_real['is_edit_selfi_90'] = int(is_edit_selfi_90)

    # 清除内存
    data_pre_real = pd.DataFrame()
    del data_pre_real, y_no_sub_now_predit_real, y_no_sub_now_real

    out_data_real.columns = ['date', 'uuid', 'sub_365'
        , 'install_days_type'
        , 'is_active_7', 'is_edit_selfi_7'
        , 'is_active_30', 'is_edit_selfi_30'
        , 'is_active_60', 'is_edit_selfi_60'
        , 'is_active_90', 'is_edit_selfi_90'
        , 'predit_sub_365_proba', 'predit_sub_365'
        , 'sub_type']

    # airbrush-1324.temp.ads_dz_his_split_predict_sub_365_test
    table_id_user = 'temp.ads_dz_his_split_predict_sub_365_test'
    credentials_path = os.environ['GOOGLE_APPLICATION_CREDENTIALS']
    credentials = service_account.Credentials.from_service_account_file(credentials_path)

    # 删除观测日期近7天数据
    client = bigquery.Client()
    query_delete = """
                    delete from airbrush-1324.temp.ads_dz_his_split_predict_sub_365_test
                    -- where date = DATE_SUB({0}, INTERVAL {20}+90 DAY)
                    where date = {0} and sub_type = {1}
                        and install_days_type between {2} and {3}
                        and is_active_7 between {4} and {5}
                        and is_edit_selfi_7 between {6} and {7}
                        and is_active_30 between {8} and {9}
                        and is_edit_selfi_30 between {10} and {11}
                        and is_active_60 between {12} and {13}
                        and is_edit_selfi_60 between {14} and {15}
                        and is_active_90 between {16} and {17}
                        and is_edit_selfi_90 between {18} and {19}
                    """.format(e_d, sub_type, install_days_type_1, install_days_type_2
                               , is_active_7_1, is_active_7_2, is_edit_selfi_7_1, is_edit_selfi_7_2
                               , is_active_30_1, is_active_30_2, is_edit_selfi_30_1, is_edit_selfi_30_2
                               , is_active_60_1, is_active_60_2, is_edit_selfi_60_1, is_edit_selfi_60_2
                               , is_active_90_1, is_active_90_2, is_edit_selfi_90_1, is_edit_selfi_90_2, days)
    query_job = client.query(query_delete)
    query_job.result()

    out_data_real.to_gbq(table_id_user, project_id='airbrush-1324', if_exists='append',  # replace
                         table_schema=[{'name': 'date', 'type': 'DATE'},
                                       {'name': 'uuid', 'type': 'STRING'},
                                       {'name': 'sub_365', 'type': 'INT64'},
                                       {'name': 'install_days_type', 'type': 'INT64'},
                                       {'name': 'is_active_7', 'type': 'INT64'},
                                       {'name': 'is_edit_selfi_7', 'type': 'INT64'},
                                       {'name': 'is_active_30', 'type': 'INT64'},
                                       {'name': 'is_edit_selfi_30', 'type': 'INT64'},
                                       {'name': 'is_active_60', 'type': 'INT64'},
                                       {'name': 'is_edit_selfi_60', 'type': 'INT64'},
                                       {'name': 'is_active_90', 'type': 'INT64'},
                                       {'name': 'is_edit_selfi_90', 'type': 'INT64'},
                                       {'name': 'predit_sub_365_proba', 'type': 'FLOAT'},
                                       {'name': 'predit_sub_365', 'type': 'INT64'},
                                       {'name': 'sub_type', 'type': 'STRING'}
                                       ]
                         , credentials=credentials)

    # 清除内存
    out_data_real = pd.DataFrame()
    del out_data_real


def bagging_final_res(res, stra='mean'):
    """res:[]"""
    res = np.array(res)
    if stra == "mean":
        return res.mean(axis=0)
    elif stra == "max":
        return res.max(axis=0)


if __name__ == '__main__':
    # train
    # d = (kwargs['execution_date'] + datetime.timedelta(hours=8) - datetime.timedelta(days=0)).strftime("%Y-%m-%d")

    # d = '2023-03-31'
    # e_d = '\'' + d + '\''
    # install_days_type = 1
    # sub_type = '\'' + 'else' + '\''

    d = sys.argv[1]
    e_d = '\'' + d + '\''
    sub_type = '\'' + sys.argv[2] + '\''
    install_days_type_1 = sys.argv[3]
    install_days_type_2 = sys.argv[4]

    is_active_7 = sys.argv[5]
    is_edit_selfi_7 = sys.argv[6]

    is_active_30 = sys.argv[7]
    is_edit_selfi_30 = sys.argv[8]

    is_active_60 = sys.argv[9]
    is_edit_selfi_60 = sys.argv[10]

    is_active_90 = sys.argv[11]
    is_edit_selfi_90 = sys.argv[12]

    input_thred_1 = sys.argv[13]
    input_thred_2 = sys.argv[14]
    train_bucket = int(sys.argv[15])

    if is_active_7 != 'all':
        is_active_7_1 = is_active_7
        is_active_7_2 = is_active_7
    else:
        is_active_7_1 = 0
        is_active_7_2 = 1

    if is_edit_selfi_7 != 'all':
        is_edit_selfi_7_1 = is_edit_selfi_7
        is_edit_selfi_7_2 = is_edit_selfi_7
    else:
        is_edit_selfi_7_1 = 0
        is_edit_selfi_7_2 = 1

    if is_active_30 != 'all':
        is_active_30_1 = is_active_30
        is_active_30_2 = is_active_30
    else:
        is_active_30_1 = 0
        is_active_30_2 = 1

    if is_edit_selfi_30 != 'all':
        is_edit_selfi_30_1 = is_edit_selfi_30
        is_edit_selfi_30_2 = is_edit_selfi_30
    else:
        is_edit_selfi_30_1 = 0
        is_edit_selfi_30_2 = 1

    if is_active_60 != 'all':
        is_active_60_1 = is_active_60
        is_active_60_2 = is_active_60
    else:
        is_active_60_1 = 0
        is_active_60_2 = 1

    if is_edit_selfi_60 != 'all':
        is_edit_selfi_60_1 = is_edit_selfi_60
        is_edit_selfi_60_2 = is_edit_selfi_60
    else:
        is_edit_selfi_60_1 = 0
        is_edit_selfi_60_2 = 1

    if is_active_90 != 'all':
        is_active_90_1 = is_active_90
        is_active_90_2 = is_active_90
    else:
        is_active_90_1 = 0
        is_active_90_2 = 1

    if is_edit_selfi_90 != 'all':
        is_edit_selfi_90_1 = is_edit_selfi_90
        is_edit_selfi_90_2 = is_edit_selfi_90
    else:
        is_edit_selfi_90_1 = 0
        is_edit_selfi_90_2 = 1

    # # 输入参数修正
    # if int(install_days_type) <= 2:
    #     is_active_7 = '1'
    #     is_active_90 = '1'
    #     is_edit_selfi_90 = is_edit_selfi_7
    # elif int(install_days_type) <= 6:
    #     is_active_90 = '1'
    #
    # if is_edit_selfi_7 == '1':
    #     is_active_7 = '1'
    #     is_edit_selfi_90 = '1'
    # if is_active_7 == '1':
    #     is_active_90 = '1'

    model_name = (sys.argv[2] + '_' + sys.argv[3] + '_' + sys.argv[4] + '_' + sys.argv[5] + '_' + sys.argv[6]
                  + '_' + sys.argv[7] + '_' + sys.argv[8] + '_' + sys.argv[9] + '_' + sys.argv[10] + '_' + sys.argv[
                      11] + '_' + sys.argv[12])

    print('--------------------------------------------------------------------------------')
    print(f'date:{e_d}')
    print(f'sub_type:{sub_type}')
    print(f'install_days_type_1:{install_days_type_1}')
    print(f'install_days_type_2:{install_days_type_2}')
    print(f'is_active_7:{is_active_7}')
    print(f'is_edit_selfi_7:{is_edit_selfi_7}')
    print(f'is_active_30:{is_active_30}')
    print(f'is_edit_selfi_30:{is_edit_selfi_30}')
    print(f'is_active_60:{is_active_60}')
    print(f'is_edit_selfi_60:{is_edit_selfi_60}')
    print(f'is_active_90:{is_active_90}')
    print(f'is_edit_selfi_90:{is_edit_selfi_90}')
    print(f'input_thred_1:{input_thred_1}')
    print(f'input_thred_2:{input_thred_2}')
    print(f'train_bucket:{train_bucket}')

    # numeric_columns, kbds = data_discretizer(d, e_d, install_days_type, sub_type, 0)
    # models = []

    for i in range(1, train_bucket):
        # stacking = model_train(d, e_d, sub_type, install_days_type, is_active_7, is_edit_selfi_7, is_active_90, is_edit_selfi_90, i, model_name)
        # models.append(stacking)
        model_train(d, e_d, sub_type, install_days_type_1, install_days_type_2
                    , is_active_7_1, is_active_7_2, is_edit_selfi_7_1, is_edit_selfi_7_2
                    , is_active_30_1, is_active_30_2, is_edit_selfi_30_1, is_edit_selfi_30_2
                    , is_active_60_1, is_active_60_2, is_edit_selfi_60_1, is_edit_selfi_60_2
                    , is_active_90_1, is_active_90_2, is_edit_selfi_90_1, is_edit_selfi_90_2
                    , i, model_name, input_thred_1, input_thred_2)
        gc.collect()

    # for days in range(0, 1):
    #     print(f'days:{days}')
    #     # 先限制80w条以免挂了
    #     X_no_sub_now_real, y_no_sub_now_real, data_pre_real = read_data(d, e_d, days, sub_type, install_days_type_1,
    #                                                                     install_days_type_2
    #                                                                     , is_active_7_1, is_active_7_2,
    #                                                                     is_edit_selfi_7_1, is_edit_selfi_7_2
    #                                                                     , is_active_30_1, is_active_30_2,
    #                                                                     is_edit_selfi_30_1, is_edit_selfi_30_2
    #                                                                     , is_active_60_1, is_active_60_2,
    #                                                                     is_edit_selfi_60_1, is_edit_selfi_60_2
    #                                                                     , is_active_90_1, is_active_90_2,
    #                                                                     is_edit_selfi_90_1, is_edit_selfi_90_2)
    #     if X_no_sub_now_real.shape[0] == 0:
    #         continue
    #     outs = []
    #     for i in range(1, train_bucket):
    #         # model = models[i]3
    #         # out = real_predict(X_no_sub_now_real, model)
    #         out = real_predict(X_no_sub_now_real, i, model_name)
    #         outs.append(out)
    #     # 后续可以看一下几个模型的预测结果差多大
    #     fina_pred = bagging_final_res(outs, 'mean')
    #     del outs, out, X_no_sub_now_real
    #     # print(fina_pred.shape, y_no_sub_now_real.shape)
    #     metric_cal(data_pre_real, y_no_sub_now_real, fina_pred, e_d, days, sub_type, install_days_type_1,
    #                install_days_type_2
    #                , is_active_7_1, is_active_7_2, is_edit_selfi_7_1, is_edit_selfi_7_2
    #                , is_active_30_1, is_active_30_2, is_edit_selfi_30_1, is_edit_selfi_30_2
    #                , is_active_60_1, is_active_60_2, is_edit_selfi_60_1, is_edit_selfi_60_2
    #                , is_active_90_1, is_active_90_2, is_edit_selfi_90_1, is_edit_selfi_90_2)
    #     del y_no_sub_now_real, data_pre_real, fina_pred
    #     gc.collect()










