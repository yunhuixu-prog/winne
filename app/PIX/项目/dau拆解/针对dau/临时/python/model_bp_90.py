def common_function(ds, **kwargs):
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
    # from joblib import dump

    def model_train(d, e_d, sub_type):
        # step1:导入训练数据(取投放日期在一年半-一年的数据)
        client = bigquery.Client()
        query_cnt = """
                select count(1)
                from 
                (
                    select 1
                    from beautyplus-bc0ed.temp.dws_dz_dau_split_final_user_behave_v
                    -- where date between DATE_SUB({0}, INTERVAL 120 DAY) and DATE_SUB({0}, INTERVAL 90 DAY)
                    -- where date between '2024-01-01' and '2024-01-14'
                    where date between '2023-11-01' and '2023-12-31'
                        and sub_90>0 
                        and sub_type={1} -- and is_new=0

                    union all

                    select 1
                    from beautyplus-bc0ed.temp.dws_dz_dau_split_final_user_behave_v
                    -- where date between DATE_SUB({0}, INTERVAL 120 DAY) and DATE_SUB({0}, INTERVAL 90 DAY)
                    -- where date between '2024-01-01' and '2024-01-14'
                    where date between '2023-11-01' and '2023-12-31'
                        and sub_90=0 
                        and rand()<0.005
                        and sub_type={1} -- and is_new=0
                )
                                 """.format(e_d, sub_type)
        cnt = client.query(query_cnt).to_dataframe().iloc[0, 0]
        print(f'cnt:{cnt}')

        query = """
                        select *except(user_pseudo_id,sub_type)
                        from beautyplus-bc0ed.temp.dws_dz_dau_split_final_user_behave_v
                        -- where date between DATE_SUB({0}, INTERVAL 120 DAY) and DATE_SUB({0}, INTERVAL 90 DAY)
                        -- where date between '2024-01-01' and '2024-01-14'
                        where date between '2023-11-01' and '2023-12-31'
                            and sub_90>0 
                            and rand()<1*least(600000/{1},1)
                            and sub_type={2} -- and is_new=0

                        union all

                        select *except(user_pseudo_id,sub_type)
                        from beautyplus-bc0ed.temp.dws_dz_dau_split_final_user_behave_v
                        -- where date between DATE_SUB({0}, INTERVAL 120 DAY) and DATE_SUB({0}, INTERVAL 90 DAY)
                        -- where date between '2024-01-01' and '2024-01-14'
                        where date between '2023-11-01' and '2023-12-31'
                            and sub_90=0 
                            and rand()<0.005*least(600000/{1},1)
                            and sub_type={2} -- and is_new=0
                            """.format(e_d, cnt, sub_type)

        print(f'date:{e_d}')
        print(f'query:{query}')

        raw_data = client.query(query).to_dataframe()
        # model_name = 'bias'
        print(f'model input shape:{raw_data.shape}')

        # 数据预处理
        # 舍弃异常样本及列（看一下分布）
        # 预测90收入
        # data_pre = raw_data.loc[:, ['date']]
        raw_data = (raw_data.drop(['sub_365', 'date'], axis=1))

        label = raw_data['platform']
        le = LabelEncoder()
        label = le.fit_transform(label)
        raw_data['platform'] = label

        label = raw_data['region']
        le = LabelEncoder()
        label = le.fit_transform(label)
        raw_data['region'] = label

        label = raw_data['brand']
        le = LabelEncoder()
        label = le.fit_transform(label)
        raw_data['brand'] = label

        label = raw_data['is_ua']
        le = LabelEncoder()
        label = le.fit_transform(label)
        raw_data['is_ua'] = label

        del label

        # 缺失值处理
        for column in raw_data.columns:
            if column == 'sub_90':
                continue
            raw_data.fillna({column: -1}, inplace=True)

        # 特征选择
        column_list = []
        for column in raw_data.columns:
            if 'pv_2级tab' in column:  # or '_31' in column or 'grow' in column:
                continue
            else:
                column_list.append(column)

        raw_data = raw_data.loc[:, column_list]

        # 提炼分类/回归样本
        X_no_sub_now = (raw_data.drop(['sub_90'], axis=1))
        y_no_sub_now = raw_data['sub_90']
        y_no_sub_now = y_no_sub_now.map(lambda x: 1 if x > 0 else 0)

        # 清除内存
        raw_data = pd.DataFrame()
        del raw_data

        print(f'classification model input shape:{X_no_sub_now.shape}')
        print(f'classification model value count:\n{y_no_sub_now.value_counts()}')

        # 模型训练-分类模型
        xtrain, xtest, ytrain, ytest = train_test_split(X_no_sub_now, y_no_sub_now, train_size=0.70, random_state=23)
        estimators = [
            ('rf', RandomForestClassifier(n_estimators=10, random_state=42)),
            ('xgbc', XGBC(n_estimators=10, random_state=24))
        ]
        stacking = StackingClassifier(
            estimators=estimators, final_estimator=LogisticRegression()
        )
        stacking.fit(xtrain, ytrain)

        # # 保存模型到文件
        # dump(stacking, 'model/stacking_model_'+model_name+'.joblib')

        # 预测和评估
        print("stacking分类器的训练误差:%.3f" % (1 - stacking.score(xtrain, ytrain)))
        print("stacking分类器的测试误差:%.3f" % (1 - stacking.score(xtest, ytest)))

        print("stacking分类器的auc:%.3f" % (AUC(ytrain, stacking.predict_proba(xtrain)[:, 1])))
        print("stacking分类器的auc:%.3f" % (AUC(ytest, stacking.predict_proba(xtest)[:, 1])))

        # 样本集验证效果，可以删除！
        # 测试集选择阈值
        ytest_predit = stacking.predict_proba(xtest)[:, 1]

        f1 = []
        precision = []
        recall = []
        for thred in np.arange(0, 1, 0.1):
            precision.append(precision_score(ytest, ytest_predit >= thred))
            recall.append(recall_score(ytest, ytest_predit >= thred))
            f1.append(f1_score(ytest, ytest_predit >= thred))

        print(f'classification thred choose-f1:{f1}')
        print(f'classification thred choose-precision:{precision}')
        print(f'classification thred choose-recall:{recall}')

        # 选定阈值输出分类预测（参考jupyter阈值选择）
        max_value = max(f1)
        max_index = f1.index(max_value)
        thred = np.arange(0, 1, 0.1)[max_index]
        print(f'classification thred choose:{thred}')

        y_no_sub_now_predit = stacking.predict_proba(X_no_sub_now)[:, 1]

        # 清除内存
        shape0 = X_no_sub_now.shape[0]
        X_no_sub_now = pd.DataFrame()
        del X_no_sub_now

        # 计算查准率
        precision = precision_score(y_no_sub_now, y_no_sub_now_predit >= thred)
        print(f'Precision: {precision:.2f}')

        # 计算查全率
        recall = recall_score(y_no_sub_now, y_no_sub_now_predit >= thred)
        print(f'Recall: {recall:.2f}')

        # 计算F1 Score
        f1 = f1_score(y_no_sub_now, y_no_sub_now_predit >= thred)
        print(f'F1 Score: {f1:.2f}')

        conf_matrix_real = confusion_matrix(y_no_sub_now, y_no_sub_now_predit >= thred)
        print(f'混淆矩阵: \n{conf_matrix_real}')

        return stacking

    def real_predict(stacking, d, e_d, diff1, diff2, sub_type):
        # 真实数据预测(拿历史数据预估，仅测试)
        print('真实样本')
        client = bigquery.Client()
        # 选择投放未满90天的数据
        query_real = """
                select *except(sub_type)
                from beautyplus-bc0ed.temp.dws_dz_dau_split_final_user_behave_v
                -- where date = DATE_SUB({0}, INTERVAL {1}+90 DAY) 
                where date = {0} and sub_type={3}
                    and active_days_90d_type={2} -- and is_new=0
                        -- 待分层
                     """.format(e_d, diff1, diff2, sub_type)

        print(f'date:{e_d}')
        print(f'dif1:{diff1}')
        print(f'dif2:{diff2}')
        print(f'sub_type:{sub_type}')
        print(f'query:{query_real}')

        X_no_sub_now_real = client.query(query_real).to_dataframe()

        print(f'predict input shape:{X_no_sub_now_real.shape}')

        # 数据处理
        data_pre_real = X_no_sub_now_real.loc[:,['date', 'user_pseudo_id','sub_90']]
        X_no_sub_now_real = (X_no_sub_now_real.drop(['sub_365', 'sub_90', 'date', 'user_pseudo_id'],
                                                    axis=1))

        y_no_sub_now_real = data_pre_real['sub_90']
        y_no_sub_now_real = y_no_sub_now_real.map(lambda x: 1 if x > 0 else 0)

        # 处理文本变量
        label = X_no_sub_now_real['platform']
        le = LabelEncoder()
        label = le.fit_transform(label)
        X_no_sub_now_real['platform'] = label

        label = X_no_sub_now_real['region']
        le = LabelEncoder()
        label = le.fit_transform(label)
        X_no_sub_now_real['region'] = label

        label = X_no_sub_now_real['brand']
        le = LabelEncoder()
        label = le.fit_transform(label)
        X_no_sub_now_real['brand'] = label

        label = X_no_sub_now_real['is_ua']
        le = LabelEncoder()
        label = le.fit_transform(label)
        X_no_sub_now_real['is_ua'] = label

        del label

        # 缺失值处理
        for column in X_no_sub_now_real.columns:
            X_no_sub_now_real.fillna({column: -1}, inplace=True)

        # 特征选择
        column_list = []
        for column in X_no_sub_now_real.columns:
            if 'pv_2级tab' in column:  # or '_31' in column or 'grow' in column:
                continue
            else:
                column_list.append(column)

        X_no_sub_now_real = X_no_sub_now_real.loc[:, column_list]

        print(f'classification input shape:{X_no_sub_now_real.shape}')

        y_no_sub_now_predit_real = stacking.predict_proba(X_no_sub_now_real)[:, 1]
        print("stacking分类器的auc:%.3f" % (AUC(y_no_sub_now_real, y_no_sub_now_predit_real)))

        # 清除内存
        shape0 = X_no_sub_now_real.shape[0]
        X_no_sub_now_real = pd.DataFrame()
        del X_no_sub_now_real

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
                                   ['date', 'user_pseudo_id', 'sub_90']]
                                      , pd.Series(y_no_sub_now_predit_real)
                                      , pd.Series(y_no_sub_now_predit_real >= thred_real)], axis=1)

        out_data_real['sub_type']=sub_type.strip('\'')
        # 清除内存
        data_pre_real = pd.DataFrame()
        del data_pre_real,y_no_sub_now_predit_real,y_no_sub_now_real

        out_data_real.columns = ['date', 'user_pseudo_id', 'sub_90',
                                 'predit_sub_90_proba', 'predit_sub_90', 'sub_type']

        # beautyplus-bc0ed.temp.ads_dz_dau_split_predict_sub_90_test
        table_id_user = 'temp.ads_dz_dau_split_predict_sub_90_test'
        credentials_path = os.environ['GOOGLE_APPLICATION_CREDENTIALS']
        credentials = service_account.Credentials.from_service_account_file(credentials_path)

        # 删除观测日期近7天数据
        query_delete = """
                        delete from beautyplus-bc0ed.temp.ads_dz_dau_split_predict_sub_90_test 
                        -- where date = DATE_SUB({0}, INTERVAL {1}+90 DAY) 
                        where date = {0} and sub_type={3}
                            and active_days_90d_type={2}
                        """.format(e_d, diff1, diff2, sub_type)
        query_job = client.query(query_delete)

        out_data_real.to_gbq(table_id_user, project_id='beautyplus-bc0ed', if_exists='append',  # replace
                             table_schema=[{'name': 'date', 'type': 'DATE'},
                                           {'name': 'user_pseudo_id', 'type': 'STRING'},
                                           {'name': 'sub_90', 'type': 'INT64'},
                                           {'name': 'predit_sub_90_proba', 'type': 'FLOAT'},
                                           {'name': 'predit_sub_90', 'type': 'INT64'},
                                           {'name': 'sub_type', 'type': 'STRING'}
                                           ]
                             , credentials=credentials)

        # 清除内存
        out_data_real = pd.DataFrame()
        del out_data_real

    # d = (kwargs['execution_date'] + datetime.timedelta(hours=8) - datetime.timedelta(days=0)).strftime("%Y-%m-%d")
    d = '2024-01-15'
    e_d = '\'' + d + '\''
    stacking = model_train(d, e_d, '\'' + 'else' + '\'')
    gc.collect()

    for diff1 in range(0, 1):
        for diff2 in range(1, 10):
            real_predict(stacking, d, e_d, diff1, diff2,  '\'' + 'else' + '\'')
            gc.collect()

    # for diff1 in range(0, 3):
    #     for diff2 in range(0, 13):
    #         real_predict(stacking, d, e_d, diff1, diff2)
    #         gc.collect()










