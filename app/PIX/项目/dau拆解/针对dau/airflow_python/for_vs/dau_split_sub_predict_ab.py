# -*- coding: UTF-8 -*-
# import第三方库
import gc
import os
import datetime
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

def data_process(X_no_sub_now_real, d, e_d, sub_type, install_days_type_1, install_days_type_2
                 , is_active_7_1, is_active_7_2, is_edit_selfi_7_1, is_edit_selfi_7_2
                 , is_active_30_1, is_active_30_2, is_edit_selfi_30_1, is_edit_selfi_30_2
                 , is_active_60_1, is_active_60_2, is_edit_selfi_60_1, is_edit_selfi_60_2
                 , is_active_90_1, is_active_90_2, is_edit_selfi_90_1, is_edit_selfi_90_2):
    X_no_sub_now_real = X_no_sub_now_real.loc[(X_no_sub_now_real['date'] == d) &
                                              (X_no_sub_now_real['sub_type'] == sub_type.strip('\'')) &
                                              (X_no_sub_now_real['install_days_type'] >= int(install_days_type_1)) &
                                              (X_no_sub_now_real['install_days_type'] <= int(install_days_type_2)) &
                                              (X_no_sub_now_real['is_active_7'] >= int(is_active_7_1)) &
                                              (X_no_sub_now_real['is_active_7'] <= int(is_active_7_2)) &
                                              (X_no_sub_now_real['is_edit_selfi_7'] >= int(is_edit_selfi_7_1)) &
                                              (X_no_sub_now_real['is_edit_selfi_7'] <= int(is_edit_selfi_7_2)) &
                                              (X_no_sub_now_real['is_active_30'] >= int(is_active_30_1)) &
                                              (X_no_sub_now_real['is_active_30'] <= int(is_active_30_2)) &
                                              (X_no_sub_now_real['is_edit_selfi_30'] >= int(is_edit_selfi_30_1)) &
                                              (X_no_sub_now_real['is_edit_selfi_30'] <= int(is_edit_selfi_30_2)) &
                                              (X_no_sub_now_real['is_active_60'] >= int(is_active_60_1)) &
                                              (X_no_sub_now_real['is_active_60'] <= int(is_active_60_2)) &
                                              (X_no_sub_now_real['is_edit_selfi_60'] >= int(is_edit_selfi_60_1)) &
                                              (X_no_sub_now_real['is_edit_selfi_60'] <= int(is_edit_selfi_60_2)) &
                                              (X_no_sub_now_real['is_active_90'] >= int(is_active_90_1)) &
                                              (X_no_sub_now_real['is_active_90'] <= int(is_active_90_2)) &
                                              (X_no_sub_now_real['is_edit_selfi_90'] >= int(is_edit_selfi_90_1)) &
                                              (X_no_sub_now_real['is_edit_selfi_90'] <= int(is_edit_selfi_90_2))
    , :]
    print(f'real predict input shape:{X_no_sub_now_real.shape}')

    if X_no_sub_now_real.shape[0] == 0:
        return X_no_sub_now_real, 0, 0

    # 数据处理
    data_pre_real = X_no_sub_now_real.loc[:, ['date', 'uuid', 'sub_365'
                                                 , 'install_days_type'
                                                 , 'is_active_7', 'is_edit_selfi_7'
                                                 , 'is_active_30', 'is_edit_selfi_30'
                                                 , 'is_active_60', 'is_edit_selfi_60'
                                                 , 'is_active_90', 'is_edit_selfi_90']]
    X_no_sub_now_real = (
        X_no_sub_now_real.drop(['sub_365', 'sub_7', 'sub_30', 'sub_90', 'date', 'uuid', 'sub_type', 'bucket'],
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

    # 缺失值处理(已提前在BQ中处理好)
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


def metric_cal(data_pre_real, y_no_sub_now_real, y_no_sub_now_predit_real, e_d, sub_type
               , install_days_type_1, install_days_type_2
               , is_active_7_1, is_active_7_2, is_edit_selfi_7_1, is_edit_selfi_7_2
               , is_active_30_1, is_active_30_2, is_edit_selfi_30_1, is_edit_selfi_30_2
               , is_active_60_1, is_active_60_2, is_edit_selfi_60_1, is_edit_selfi_60_2
               , is_active_90_1, is_active_90_2, is_edit_selfi_90_1, is_edit_selfi_90_2):
    # # 选定阈值
    # f1 = []
    # precision = []
    # recall = []
    # for thred_real in np.arange(0, 1, 0.1):
    #     precision.append(precision_score(y_no_sub_now_real, y_no_sub_now_predit_real >= thred_real))
    #     recall.append(recall_score(y_no_sub_now_real, y_no_sub_now_predit_real >= thred_real))
    #     f1.append(f1_score(y_no_sub_now_real, y_no_sub_now_predit_real >= thred_real))
    #
    # # print(f'real classification thred choose-f1:{f1}')
    # # print(f'real classification thred choose-precision:{precision}')
    # # print(f'real classification thred choose-recall:{recall}')
    #
    # # 选定阈值输出分类预测
    # max_value = max(f1)
    # max_index = f1.index(max_value)
    # thred_real = np.arange(0, 1, 0.1)[max_index]
    # print(f'real classification thred choose:{thred_real}')

    # 计算查准率
    # precision = precision_score(y_no_sub_now_real, y_no_sub_now_predit_real >= thred_real)
    # print(f'Precision: {precision:.2f}')

    # 计算查全率
    # recall = recall_score(y_no_sub_now_real, y_no_sub_now_predit_real >= thred_real)
    # print(f'Recall: {recall:.2f}')

    # 计算F1 Score
    # f1 = f1_score(y_no_sub_now_real, y_no_sub_now_predit_real >= thred_real)
    # print(f'F1 Score: {f1:.2f}')

    # conf_matrix_real = confusion_matrix(y_no_sub_now_real, y_no_sub_now_predit_real >= thred_real)
    # print(f'混淆矩阵: \n{conf_matrix_real}')

    # 原数据加入预测数据进行比较
    thred_real = 0.25
    data_pre_real['uuid'] = data_pre_real['uuid'].astype('str')
    out_data_real = pd.concat([data_pre_real.loc[:,
                               ['date', 'uuid', 'sub_365'
                                   , 'install_days_type'
                                   , 'is_active_7', 'is_edit_selfi_7'
                                   , 'is_active_30', 'is_edit_selfi_30'
                                   , 'is_active_60', 'is_edit_selfi_60'
                                   , 'is_active_90', 'is_edit_selfi_90']]
                                  , pd.Series(y_no_sub_now_predit_real, index=data_pre_real.index)
                                  , pd.Series(y_no_sub_now_predit_real >= thred_real, index=data_pre_real.index)],
                              axis=1)

    out_data_real['sub_type'] = sub_type.strip('\'')

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
    # print(out_data_real.dtypes)
    # print(out_data_real)
    out_data_real['uuid'] = out_data_real['uuid'].astype('str')
    out_data_real['predit_sub_365'] = out_data_real['predit_sub_365'].astype('int64')
    out_data_real['sub_type'] = out_data_real['sub_type'].astype('str')

    # airbrush-1324.temp.ads_dz_dau_split_predict_sub_365
    table_id_user = 'temp.ads_dz_dau_split_predict_sub_365'
    credentials_path = os.environ['GOOGLE_APPLICATION_CREDENTIALS']
    credentials = service_account.Credentials.from_service_account_file(credentials_path)

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


def table_initial(e_d, sub_type, install_days_type_1, install_days_type_2
                  , is_active_7_1, is_active_7_2, is_edit_selfi_7_1, is_edit_selfi_7_2
                  , is_active_30_1, is_active_30_2, is_edit_selfi_30_1, is_edit_selfi_30_2
                  , is_active_60_1, is_active_60_2, is_edit_selfi_60_1, is_edit_selfi_60_2
                  , is_active_90_1, is_active_90_2, is_edit_selfi_90_1, is_edit_selfi_90_2):
    client = bigquery.Client()
    # 删除输出表观测日期数据
    query_delete = """
                        delete from airbrush-1324.temp.ads_dz_dau_split_predict_sub_365
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
                                   , is_active_90_1, is_active_90_2, is_edit_selfi_90_1, is_edit_selfi_90_2)
    query_job = client.query(query_delete)
    query_job.result()


def load_data(e_d, sub_type, install_days_type_1, install_days_type_2
              , is_active_7_1, is_active_7_2, is_edit_selfi_7_1, is_edit_selfi_7_2
              , is_active_30_1, is_active_30_2, is_edit_selfi_30_1, is_edit_selfi_30_2
              , is_active_60_1, is_active_60_2, is_edit_selfi_60_1, is_edit_selfi_60_2
              , is_active_90_1, is_active_90_2, is_edit_selfi_90_1, is_edit_selfi_90_2, bucket_1, bucket_2):
    client = bigquery.Client()

    query_drop = """ drop table if exists airbrush-1324.temp.dws_dz_dau_split_final_user_behave_extract_batch """
    drop_job = client.query(query_drop)
    drop_job.result()

    # 选择要预测的数据
    query_create = """
                create table airbrush-1324.temp.dws_dz_dau_split_final_user_behave_extract_batch as 

                select *
                from airbrush-1324.temp.dws_dz_dau_split_and_roas_final_user_behave_v
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
                    and bucket between {20} and {21}
                     """.format(e_d, sub_type, install_days_type_1, install_days_type_2
                                , is_active_7_1, is_active_7_2, is_edit_selfi_7_1, is_edit_selfi_7_2
                                , is_active_30_1, is_active_30_2, is_edit_selfi_30_1, is_edit_selfi_30_2
                                , is_active_60_1, is_active_60_2, is_edit_selfi_60_1, is_edit_selfi_60_2
                                , is_active_90_1, is_active_90_2, is_edit_selfi_90_1, is_edit_selfi_90_2
                                , bucket_1, bucket_2)
    print(f'query:{query_create}')
    create_job = client.query(query_create)
    print("Table created successfully.")
    create_job.result()

    query_test = """
                        select *
                        from airbrush-1324.temp.dws_dz_dau_split_final_user_behave_extract_batch
                        limit 10
                                     """
    data_test = client.query(query_test).to_dataframe()
    if data_test.shape[0] == 0:
        print(f'异常！！表格数量为0')
    else:
        if 'pv_camera_enter_all_all' not in data_test.columns:
            print(f'异常！！表格指标错误')
        else:
            print(f'表格正常')

    os.system("bash /home/yunhui/dau/load_dau_predict_data_ab.sh")


def bagging_final_res(res, stra='mean'):
    """res:[]"""
    res = np.array(res)
    if stra == "mean":
        return res.mean(axis=0)
    elif stra == "max":
        return res.max(axis=0)


def start_predict(raw_data, d, e_d, sub_type,install_days_type_1, install_days_type_2
                       , is_active_7_1, is_active_7_2,is_edit_selfi_7_1, is_edit_selfi_7_2
                       , is_active_30_1, is_active_30_2,is_edit_selfi_30_1, is_edit_selfi_30_2
                       , is_active_60_1, is_active_60_2,is_edit_selfi_60_1, is_edit_selfi_60_2
                       , is_active_90_1, is_active_90_2,is_edit_selfi_90_1, is_edit_selfi_90_2
                       , model_name, train_bucket):
    X_no_sub_now_real, y_no_sub_now_real, data_pre_real = data_process(raw_data, d, e_d, sub_type,
                                                                       install_days_type_1, install_days_type_2
                                                                       , is_active_7_1, is_active_7_2,
                                                                       is_edit_selfi_7_1, is_edit_selfi_7_2
                                                                       , is_active_30_1, is_active_30_2,
                                                                       is_edit_selfi_30_1, is_edit_selfi_30_2
                                                                       , is_active_60_1, is_active_60_2,
                                                                       is_edit_selfi_60_1, is_edit_selfi_60_2
                                                                       , is_active_90_1, is_active_90_2,
                                                                       is_edit_selfi_90_1, is_edit_selfi_90_2)
    if X_no_sub_now_real.shape[0] == 0:
        return
    outs = []
    for i in range(1, train_bucket):
        out = real_predict(X_no_sub_now_real, i, model_name)
        outs.append(out)
    # 后续可以看一下几个模型的预测结果差多大
    fina_pred = bagging_final_res(outs, 'mean')
    del outs, out, X_no_sub_now_real
    # print(fina_pred.shape, y_no_sub_now_real.shape)
    metric_cal(data_pre_real, y_no_sub_now_real, fina_pred, e_d, sub_type, install_days_type_1,
               install_days_type_2
               , is_active_7_1, is_active_7_2, is_edit_selfi_7_1, is_edit_selfi_7_2
               , is_active_30_1, is_active_30_2, is_edit_selfi_30_1, is_edit_selfi_30_2
               , is_active_60_1, is_active_60_2, is_edit_selfi_60_1, is_edit_selfi_60_2
               , is_active_90_1, is_active_90_2, is_edit_selfi_90_1, is_edit_selfi_90_2)
    del y_no_sub_now_real, data_pre_real, fina_pred


def predict_data(e_d, sub_type, install_days_type_1, install_days_type_2
                  , is_active_7_1, is_active_7_2, is_edit_selfi_7_1, is_edit_selfi_7_2
                  , is_active_30_1, is_active_30_2, is_edit_selfi_30_1, is_edit_selfi_30_2
                  , is_active_60_1, is_active_60_2, is_edit_selfi_60_1, is_edit_selfi_60_2
                  , is_active_90_1, is_active_90_2, is_edit_selfi_90_1, is_edit_selfi_90_2
                  , model_name, train_bucket, chunk_size):
    # 读取所有json文件
    files = os.listdir('/home/yunhui/dau/data_ab/predict/dau_predict_data_ab')
    raw_data = pd.DataFrame()
    for file in files:
        print(f'read file:{file}')
        reader = pd.read_json('/home/yunhui/dau/data_ab/predict/dau_predict_data_ab/' + file, chunksize=10000,
                              lines=True)
        batch_num = 0
        for batch_data in reader:
            # print(batch_num)
            batch_num = batch_num + 1
            raw_data = pd.concat([raw_data, batch_data], ignore_index=True)
            print(raw_data.shape)
            if raw_data.shape[0] >= chunk_size:
                print('enough to start predict')
                start_predict(raw_data, d, e_d, sub_type, install_days_type_1, install_days_type_2
                              , is_active_7_1, is_active_7_2, is_edit_selfi_7_1, is_edit_selfi_7_2
                              , is_active_30_1, is_active_30_2, is_edit_selfi_30_1, is_edit_selfi_30_2
                              , is_active_60_1, is_active_60_2, is_edit_selfi_60_1, is_edit_selfi_60_2
                              , is_active_90_1, is_active_90_2, is_edit_selfi_90_1, is_edit_selfi_90_2
                              , model_name, train_bucket)
                gc.collect()
                raw_data = pd.DataFrame()
    if raw_data.shape[0] > 0:
        print('start final predict')
        start_predict(raw_data, d, e_d, sub_type, install_days_type_1, install_days_type_2
                      , is_active_7_1, is_active_7_2, is_edit_selfi_7_1, is_edit_selfi_7_2
                      , is_active_30_1, is_active_30_2, is_edit_selfi_30_1, is_edit_selfi_30_2
                      , is_active_60_1, is_active_60_2, is_edit_selfi_60_1, is_edit_selfi_60_2
                      , is_active_90_1, is_active_90_2, is_edit_selfi_90_1, is_edit_selfi_90_2
                      , model_name, train_bucket)

# def check_file():
#     # 检查是否有异常，有异常重跑一遍
#     files = os.listdir('/home/yunhui/dau/data_ab/predict/dau_predict_data_ab')
#     if len(files) == 0:
#         print(f'load no file')
#         return 'error'
#     reader = pd.read_json('/home/yunhui/dau/data_ab/predict/dau_predict_data_ab/' + files[0], chunksize=10,lines=True)
#     batch_num = 0
#     for batch_data in reader:
#         data = pd.DataFrame(batch_data)
#         batch_num = batch_num + 1
#         if data.shape[0] == 0:
#             print(f'load no data')
#             return 'error'
#         if 'pv_camera_enter_all_all' not in data.columns:
#             print(f'load wrong columns')
#             return 'error'
#         if batch_num > 0:
#             break
#     return 'ok'


def check_predict(e_d, sub_type, install_days_type_1, install_days_type_2
                                       , is_active_7_1, is_active_7_2, is_edit_selfi_7_1, is_edit_selfi_7_2
                                       , is_active_30_1, is_active_30_2, is_edit_selfi_30_1, is_edit_selfi_30_2
                                       , is_active_60_1, is_active_60_2, is_edit_selfi_60_1, is_edit_selfi_60_2
                                       , is_active_90_1, is_active_90_2, is_edit_selfi_90_1, is_edit_selfi_90_2):
    # 检查最终预测是否正常
    client = bigquery.Client()
    query_final = """
                            select *
                            from airbrush-1324.temp.ads_dz_dau_split_predict_sub_365
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
                            limit 10
                            """.format(e_d, sub_type, install_days_type_1, install_days_type_2
                                       , is_active_7_1, is_active_7_2, is_edit_selfi_7_1, is_edit_selfi_7_2
                                       , is_active_30_1, is_active_30_2, is_edit_selfi_30_1, is_edit_selfi_30_2
                                       , is_active_60_1, is_active_60_2, is_edit_selfi_60_1, is_edit_selfi_60_2
                                       , is_active_90_1, is_active_90_2, is_edit_selfi_90_1, is_edit_selfi_90_2)
    data_test = client.query(query_final).to_dataframe()
    if data_test.shape[0] == 0:
        print(f'异常！！预测数量为0')
        return 'error'
    else:
        print(f'batch预测成功')
        return 'ok'

def final_predict(e_d, sub_type, install_days_type_1, install_days_type_2
                  , is_active_7_1, is_active_7_2, is_edit_selfi_7_1, is_edit_selfi_7_2
                  , is_active_30_1, is_active_30_2, is_edit_selfi_30_1, is_edit_selfi_30_2
                  , is_active_60_1, is_active_60_2, is_edit_selfi_60_1, is_edit_selfi_60_2
                  , is_active_90_1, is_active_90_2, is_edit_selfi_90_1, is_edit_selfi_90_2
                  , bucket_1, bucket_2, model_name, train_bucket, chunk_size):
    load_data(e_d, sub_type, install_days_type_1, install_days_type_2
              , is_active_7_1, is_active_7_2, is_edit_selfi_7_1, is_edit_selfi_7_2
              , is_active_30_1, is_active_30_2, is_edit_selfi_30_1, is_edit_selfi_30_2
              , is_active_60_1, is_active_60_2, is_edit_selfi_60_1, is_edit_selfi_60_2
              , is_active_90_1, is_active_90_2, is_edit_selfi_90_1, is_edit_selfi_90_2
              , bucket_1, bucket_2)

    predict_data(e_d, sub_type, install_days_type_1, install_days_type_2
                 , is_active_7_1, is_active_7_2, is_edit_selfi_7_1, is_edit_selfi_7_2
                 , is_active_30_1, is_active_30_2, is_edit_selfi_30_1, is_edit_selfi_30_2
                 , is_active_60_1, is_active_60_2, is_edit_selfi_60_1, is_edit_selfi_60_2
                 , is_active_90_1, is_active_90_2, is_edit_selfi_90_1, is_edit_selfi_90_2
                 , model_name, train_bucket, chunk_size)



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

    train_bucket = int(sys.argv[13])
    chunk_size = int(sys.argv[14])
    start_predict_batch = int(sys.argv[15]) if len(sys.argv) > 15 else 0

    # input_thred_1 = sys.argv[13]
    # input_thred_2 = sys.argv[14]
    # train_bucket = int(sys.argv[15])

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
    # print(f'input_thred_1:{input_thred_1}')
    # print(f'input_thred_2:{input_thred_2}')
    print(f'train_bucket:{train_bucket}')
    print(f'chunk_size:{chunk_size}')
    print(f'start_predict_batch:{start_predict_batch}')

    # 检查模型是否存在，不存在提示
    flag = 0
    for i in range(1, train_bucket):
        if os.path.exists('/home/yunhui/ab/model/stacking_' + model_name + '_bucket_' + str(i) + '.joblib'):
            print(f'has model:{i}')
        else:
            print(f'need train model first:{i}')
            flag = 1
    if flag == 0:
        if (is_active_90 == '0' and is_edit_selfi_90 == '0'
                and sub_type == '\'' + 'else' + '\'' and start_predict_batch > 0):
            print(f'not initial table')
        else:
            print(f'initial table')
            table_initial(e_d, sub_type, install_days_type_1, install_days_type_2
                          , is_active_7_1, is_active_7_2, is_edit_selfi_7_1, is_edit_selfi_7_2
                          , is_active_30_1, is_active_30_2, is_edit_selfi_30_1, is_edit_selfi_30_2
                          , is_active_60_1, is_active_60_2, is_edit_selfi_60_1, is_edit_selfi_60_2
                          , is_active_90_1, is_active_90_2, is_edit_selfi_90_1, is_edit_selfi_90_2)
        # 将表拉取到本地
        if is_active_90 == '0' and is_edit_selfi_90 == '0' and sub_type == '\'' + 'else' + '\'':
            for bucket in range(start_predict_batch, 6):
                print(f'predict bucket:{bucket}')
                final_predict(e_d, sub_type, install_days_type_1, install_days_type_2
                              , is_active_7_1, is_active_7_2, is_edit_selfi_7_1, is_edit_selfi_7_2
                              , is_active_30_1, is_active_30_2, is_edit_selfi_30_1, is_edit_selfi_30_2
                              , is_active_60_1, is_active_60_2, is_edit_selfi_60_1, is_edit_selfi_60_2
                              , is_active_90_1, is_active_90_2, is_edit_selfi_90_1, is_edit_selfi_90_2
                              , bucket, bucket, model_name, train_bucket, chunk_size)

                if check_predict(e_d, sub_type, install_days_type_1, install_days_type_2
                                       , is_active_7_1, is_active_7_2, is_edit_selfi_7_1, is_edit_selfi_7_2
                                       , is_active_30_1, is_active_30_2, is_edit_selfi_30_1, is_edit_selfi_30_2
                                       , is_active_60_1, is_active_60_2, is_edit_selfi_60_1, is_edit_selfi_60_2
                                       , is_active_90_1, is_active_90_2, is_edit_selfi_90_1, is_edit_selfi_90_2) == 'error':
                    os.system("sleep 180")
                    print(f'predict again')
                    final_predict(e_d, sub_type, install_days_type_1, install_days_type_2
                                  , is_active_7_1, is_active_7_2, is_edit_selfi_7_1, is_edit_selfi_7_2
                                  , is_active_30_1, is_active_30_2, is_edit_selfi_30_1, is_edit_selfi_30_2
                                  , is_active_60_1, is_active_60_2, is_edit_selfi_60_1, is_edit_selfi_60_2
                                  , is_active_90_1, is_active_90_2, is_edit_selfi_90_1, is_edit_selfi_90_2
                                  , bucket, bucket, model_name, train_bucket, chunk_size)
        else:
            final_predict(e_d, sub_type, install_days_type_1, install_days_type_2
                          , is_active_7_1, is_active_7_2, is_edit_selfi_7_1, is_edit_selfi_7_2
                          , is_active_30_1, is_active_30_2, is_edit_selfi_30_1, is_edit_selfi_30_2
                          , is_active_60_1, is_active_60_2, is_edit_selfi_60_1, is_edit_selfi_60_2
                          , is_active_90_1, is_active_90_2, is_edit_selfi_90_1, is_edit_selfi_90_2
                          , 0, 5, model_name, train_bucket, chunk_size)

            if check_predict(e_d, sub_type, install_days_type_1, install_days_type_2
                    , is_active_7_1, is_active_7_2, is_edit_selfi_7_1, is_edit_selfi_7_2
                    , is_active_30_1, is_active_30_2, is_edit_selfi_30_1, is_edit_selfi_30_2
                    , is_active_60_1, is_active_60_2, is_edit_selfi_60_1, is_edit_selfi_60_2
                    , is_active_90_1, is_active_90_2, is_edit_selfi_90_1, is_edit_selfi_90_2) == 'error':
                os.system("sleep 180")
                print(f'predict again')
                final_predict(e_d, sub_type, install_days_type_1, install_days_type_2
                              , is_active_7_1, is_active_7_2, is_edit_selfi_7_1, is_edit_selfi_7_2
                              , is_active_30_1, is_active_30_2, is_edit_selfi_30_1, is_edit_selfi_30_2
                              , is_active_60_1, is_active_60_2, is_edit_selfi_60_1, is_edit_selfi_60_2
                              , is_active_90_1, is_active_90_2, is_edit_selfi_90_1, is_edit_selfi_90_2
                              , 0, 5, model_name, train_bucket, chunk_size)


