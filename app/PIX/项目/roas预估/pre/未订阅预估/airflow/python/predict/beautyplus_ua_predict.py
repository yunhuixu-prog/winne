def common_function(ds, **kwargs):
    # py_dws_dz_roi_predict_bp_ua_model
    import gc
    import os
    import datetime
    from google.oauth2 import service_account
    from google.cloud import bigquery
    import numpy as np
    import pandas as pd
    # 数据预处理
    from sklearn.preprocessing import LabelEncoder,StandardScaler
    from sklearn.model_selection import train_test_split
    # 模型
    from xgboost import XGBRegressor as XGBR
    from xgboost import XGBClassifier as XGBC
    from sklearn.pipeline import make_pipeline
    from sklearn.ensemble import StackingRegressor,StackingClassifier,RandomForestClassifier
    from sklearn.linear_model import LogisticRegression
    # from sklearn.linear_model import RidgeCV, LassoCV
    # from sklearn.neighbors import KNeighborsRegressor
    # from sklearn.svm import LinearSVC

    # 模型评估
    from sklearn.metrics import roc_auc_score as AUC
    from sklearn.metrics import confusion_matrix,precision_score, recall_score, f1_score
    from sklearn.metrics import mean_squared_error,r2_score

    import sys
    # from joblib import dump

    def model_train(d,e_d):
        # step1:导入训练数据(取投放日期在一年半-一年的数据)
        client = bigquery.Client()
        query_cnt = """
                        select count(1)
                        from 
                        (
                            select *,0 random
                            from beautyplus-bc0ed.temp.dws_dz_roi_predict_final_model_input_delete_v
                            where types='ua' and Attributed_Touch_Date between DATE_SUB({0}, INTERVAL 458 DAY) and DATE_SUB({0}, INTERVAL 365 DAY)
                                and sub_now=0 and sub_no_trial_365>0 and days between 0 and 6

                            union all

                            select *,0 random
                            from beautyplus-bc0ed.temp.dws_dz_roi_predict_final_model_input_delete_v
                            where types='ua' and Attributed_Touch_Date between DATE_SUB({0}, INTERVAL 458 DAY) and DATE_SUB({0}, INTERVAL 365 DAY)
                                and sub_now=0 and sub_no_trial_365>0 and days between 7 and 365
                                and rand()<0.05

                            union all

                            select *,rand() random
                            from beautyplus-bc0ed.temp.dws_dz_roi_predict_final_model_input_delete_v
                            where types='ua' and Attributed_Touch_Date between DATE_SUB({0}, INTERVAL 458 DAY) and DATE_SUB({0}, INTERVAL 365 DAY)
                                and sub_now=0 and sub_no_trial_365=0 and days between 0 and 6
                                and rand()<0.04 -- 可以调整

                            union all

                            select *,rand() random
                            from beautyplus-bc0ed.temp.dws_dz_roi_predict_final_model_input_delete_v
                            where types='ua' and Attributed_Touch_Date between DATE_SUB({0}, INTERVAL 458 DAY) and DATE_SUB({0}, INTERVAL 365 DAY)
                                and sub_now=0 and sub_no_trial_365=0 and days between 7 and 365
                                and rand()<0.002 -- 可以调整
                        )
                                         """.format(e_d)
        cnt = client.query(query_cnt).to_dataframe().iloc[0, 0]
        print(f'cnt:{cnt}')

        query = """
                        select *,0 random
                        from beautyplus-bc0ed.temp.dws_dz_roi_predict_final_model_input_delete_v
                        where types='ua' and Attributed_Touch_Date between DATE_SUB({0}, INTERVAL 458 DAY) and DATE_SUB({0}, INTERVAL 365 DAY)
                            and sub_now=0 and sub_no_trial_365>0 and days between 0 and 6
                            and rand()<1*least(600000/{1},1)

                        union all

                        select *,0 random
                        from beautyplus-bc0ed.temp.dws_dz_roi_predict_final_model_input_delete_v
                        where types='ua' and Attributed_Touch_Date between DATE_SUB({0}, INTERVAL 458 DAY) and DATE_SUB({0}, INTERVAL 365 DAY)
                            and sub_now=0 and sub_no_trial_365>0 and days between 7 and 365
                            and rand()<0.05*least(600000/{1},1)

                        union all

                        select *,rand() random
                        from beautyplus-bc0ed.temp.dws_dz_roi_predict_final_model_input_delete_v
                        where types='ua' and Attributed_Touch_Date between DATE_SUB({0}, INTERVAL 458 DAY) and DATE_SUB({0}, INTERVAL 365 DAY)
                            and sub_now=0 and sub_no_trial_365=0 and days between 0 and 6
                            and rand()<0.04*least(600000/{1},1)

                        union all

                        select *,rand() random
                        from beautyplus-bc0ed.temp.dws_dz_roi_predict_final_model_input_delete_v
                        where types='ua' and Attributed_Touch_Date between DATE_SUB({0}, INTERVAL 458 DAY) and DATE_SUB({0}, INTERVAL 365 DAY)
                            and sub_now=0 and sub_no_trial_365=0 and days between 7 and 365
                            and rand()<0.002*least(600000/{1},1)
                             """.format(e_d, cnt)

        print(f'date:{e_d}')
        print(f'query:{query}')

        raw_data = client.query(query).to_dataframe()
        # model_name = 'bias'
        print(f'model input shape:{raw_data.shape}')

        # 数据预处理
        # 舍弃异常样本及列（看一下分布）
        data_pre=raw_data.loc[:,['sub_no_trial_365', 'sub_revenue_365', 'date', 'Attributed_Touch_Date', 'days']]
        raw_data=(raw_data.drop(['sub_now','sub_revenue_now','is_sub_now','sub_365','date','Attributed_Touch_Date','user_pseudo_id','types'],axis=1))

        label = raw_data['platform']
        le = LabelEncoder()
        label = le.fit_transform(label)
        raw_data['platform']=label

        label = raw_data['region']
        le = LabelEncoder()
        label = le.fit_transform(label)
        raw_data['region']=label

        label = raw_data['brand']
        le = LabelEncoder()
        label = le.fit_transform(label)
        raw_data['brand']=label

        del label

        # 缺失值处理
        for column in raw_data.columns:
            if column=='sub_no_trial_365' or column=='sub_revenue_365':
                continue
            raw_data.fillna({column:-1}, inplace=True)

        # 特征选择
        column_list=[]
        for column in raw_data.columns:
            if 'pv_2级tab' in column: # or '_31' in column or 'grow' in column:
                continue
            else:
                column_list.append(column)

        raw_data=raw_data.loc[:,column_list]


        # 提炼分类/回归样本
        X_no_sub_now=(raw_data.drop(['sub_no_trial_365','sub_revenue_365', 'random'],axis=1))
        y_no_sub_now=raw_data['sub_no_trial_365']
        y_no_sub_now=y_no_sub_now.map(lambda x:1 if x>0 else 0)

        X_revenue_365=(raw_data.drop(['sub_no_trial_365','sub_revenue_365', 'random'],axis=1)).loc[(raw_data['random']<0.025) & (raw_data['sub_revenue_365']<=150)]
        y_revenue_365=raw_data.loc[(raw_data['random']<0.025) & (raw_data['sub_revenue_365']<=150),'sub_revenue_365']

        # 清除内存
        raw_data = pd.DataFrame()
        del raw_data

        print(f'classification input shape:{X_no_sub_now.shape}')
        print(f'classification value count:\n{y_no_sub_now.value_counts()}')

        print(f'regression input shape:{X_revenue_365.shape}')
        print(f'regression summary:\n{y_revenue_365.describe()}')


        # 模型训练-分类模型
        xtrain, xtest, ytrain, ytest = train_test_split(X_no_sub_now,y_no_sub_now,train_size=0.70,random_state=23)
        estimators = [
            ('rf', RandomForestClassifier(n_estimators=10, random_state=42)),
            ('xgbc', XGBC(n_estimators=10, random_state=24))
        ]
        stacking = StackingClassifier(
            estimators=estimators, final_estimator=LogisticRegression()
        )
        stacking.fit(xtrain,ytrain)


        # # 保存模型到文件
        # dump(stacking, 'model/stacking_model_'+model_name+'.joblib')

        # 预测和评估
        print("stacking分类器的训练误差:%.3f" % (1 - stacking.score(xtrain, ytrain)))
        print("stacking分类器的测试误差:%.3f" % (1 - stacking.score(xtest, ytest)))

        print("stacking分类器的auc:%.3f" % (AUC(ytrain,stacking.predict_proba(xtrain)[:,1])))
        print("stacking分类器的auc:%.3f" % (AUC(ytest,stacking.predict_proba(xtest)[:,1])))

        del xtrain, ytrain


        # 模型训练-回归模型
        xtrain_r, xtest_r, ytrain_r, ytest_r = train_test_split(X_revenue_365,y_revenue_365,train_size=0.70,random_state=123)
        # 清除内存
        X_revenue_365 = pd.DataFrame()
        del X_revenue_365,y_revenue_365

        xgbr = XGBR(n_estimators=500,eta=0.5,max_depth=6,colsample_bytree=0.8,random_state=24)
        # 训练模型
        xgbr.fit(xtrain_r, ytrain_r)


        # xgbr.save_model('model/xgbr_model_'+model_name+'.json')

        # 预测和评估
        ytrain_pred_r = xgbr.predict(xtrain_r)
        ytrain_pred_r = np.maximum(ytrain_pred_r, 0)
        mse_train = mean_squared_error(ytrain_r, ytrain_pred_r)
        rmse_train = mse_train ** 0.5
        r2_train = r2_score(ytrain_r, ytrain_pred_r)

        ytest_pred_r = xgbr.predict(xtest_r)
        ytest_pred_r = np.maximum(ytest_pred_r, 0)
        mse_test = mean_squared_error(ytest_r, ytest_pred_r)
        rmse_test = mse_test ** 0.5
        r2_test = r2_score(ytest_r, ytest_pred_r)

        print('训练集')
        print(f"MSE: {mse_train}")
        print(f"RMSE: {rmse_train}")
        print(f"R-squared: {r2_train}")

        print('测试集')
        print(f"MSE: {mse_test}")
        print(f"RMSE: {rmse_test}")
        print(f"R-squared: {r2_test}")

        del xtrain_r, xtest_r, ytrain_r, ytest_r, ytrain_pred_r, ytest_pred_r


        # 样本集验证效果，可以删除！
        # 选定阈值输出分类预测
        # ytest_predit=stacking.predict_proba(xtest)[:,1]
        #
        # f1=[]
        # precision=[]
        # recall=[]
        # for thred in np.arange(0,1,0.1):
        #     precision.append(precision_score(ytest,ytest_predit>=thred))
        #     recall.append(recall_score(ytest,ytest_predit>=thred))
        #     f1.append(f1_score(ytest,ytest_predit>=thred))
        #
        # print(f'classification thred choose-f1:{f1}')
        # print(f'classification thred choose-precision:{precision}')
        # print(f'classification thred choose-recall:{recall}')
        #
        # # 选定阈值输出分类预测（参考jupyter阈值选择）
        # max_value = max(f1)
        # max_index = f1.index(max_value)
        # thred = np.arange(0,1,0.1)[max_index]
        thred = 0.3 # 有时是0.4额，不过这个对预测结果也没啥影响
        print(f'classification thred choose:{thred}')

        del xtest,ytest

        y_no_sub_now_predit=stacking.predict_proba(X_no_sub_now)[:,1]

        # 计算查准率
        precision = precision_score(y_no_sub_now,y_no_sub_now_predit>=thred)
        print(f'Precision: {precision:.2f}')

        # 计算查全率
        recall = recall_score(y_no_sub_now,y_no_sub_now_predit>=thred)
        print(f'Recall: {recall:.2f}')

        # 计算F1 Score
        f1 = f1_score(y_no_sub_now,y_no_sub_now_predit>=thred)
        print(f'F1 Score: {f1:.2f}')

        conf_matrix_real = confusion_matrix(y_no_sub_now,y_no_sub_now_predit>=thred)
        print(f'混淆矩阵: \n{conf_matrix_real}')

        # 提炼进入回归模型的样本
        X_to_regression_revenue_365=X_no_sub_now.loc[y_no_sub_now_predit>=thred,:]
        # 清除内存
        shape0 = X_no_sub_now.shape[0]
        X_no_sub_now = pd.DataFrame()
        del X_no_sub_now,y_no_sub_now

        # xgbr = XGBR()
        # xgbr.load_model('model/xgbr_model_'+model_name+'.json')

        # 对提炼样本进行回归预测
        y_to_regression_predict_revenue_365 = xgbr.predict(X_to_regression_revenue_365)
        y_to_regression_predict_revenue_365 = np.maximum(y_to_regression_predict_revenue_365, 0)

        # 清除内存
        X_to_regression_revenue_365 = pd.DataFrame()
        del X_to_regression_revenue_365

        # 加上未进入预测模型的数据，未预测部分全部记为0
        y_revenue_365_predict = pd.Series([0.0] * shape0)
        y_revenue_365_predict.loc[y_no_sub_now_predit >= thred] = y_to_regression_predict_revenue_365

        # 原数据加入预测数据进行比较
        out_data = pd.concat([data_pre.loc[:,
                              ['date', 'Attributed_Touch_Date', 'days',
                               # 'user_pseudo_id', 'sub_now', 'sub_revenue_now',
                               # 'is_sub_now', 'sub_365', 'sub_no_trial_365',
                               'sub_revenue_365']], pd.Series(y_no_sub_now_predit)
                                , pd.Series(y_no_sub_now_predit >= thred)
                                , pd.Series(y_revenue_365_predict)], axis=1)
        # 清除内存
        data_pre = pd.DataFrame()
        del data_pre,y_no_sub_now_predit,y_to_regression_predict_revenue_365,y_revenue_365_predict

        out_data.columns = ['date', 'Attributed_Touch_Date', 'days',
                            # 'user_pseudo_id', 'sub_now', 'sub_revenue_now',
                            # 'is_sub_now', 'sub_365', 'sub_no_trial_365',
                            'sub_revenue_365',
                            'predit_no_trial_sub_365_proba','predit_no_trial_sub_365',
                            'predict_sub_revenue_365']

        # 分投放天数评估预测准确率
        evaluate = out_data.groupby('days').agg({'sub_revenue_365': 'sum', 'predict_sub_revenue_365': 'sum'})
        evaluate['precision'] = evaluate['predict_sub_revenue_365'] / evaluate['sub_revenue_365']
        evaluate['date']=d
        evaluate['days']=evaluate.index
        evaluate['types']='sample'

        # 清除内存
        out_data = pd.DataFrame()
        del out_data

        # beautyplus-bc0ed.temp.ads_dz_roi_predict_sample_evaluate
        table_id ='temp.ads_dz_roi_predict_sample_evaluate'
        credentials_path = os.environ['GOOGLE_APPLICATION_CREDENTIALS']
        credentials = service_account.Credentials.from_service_account_file(credentials_path)
        # 删除观测日期近7天数据
        query_delete = """
                delete from beautyplus-bc0ed.temp.ads_dz_roi_predict_sample_evaluate where date = {0}
                """.format(e_d)
        query_job = client.query(query_delete)

        evaluate.to_gbq(table_id, project_id='beautyplus-bc0ed', if_exists='append', # replace
                            table_schema=[{'name': 'sub_revenue_365','type': 'FLOAT'},
                                       {'name': 'predict_sub_revenue_365','type': 'FLOAT'},
                                       {'name': 'precision','type': 'FLOAT'},
                                       {'name': 'date','type': 'DATE'},
                                       {'name': 'days','type': 'INT64'},
                                       {'name': 'types','type': 'STRING'}
                                       ]
                                       , credentials=credentials)

        return stacking, xgbr



    def real_predict(stacking,xgbr,d,e_d,diff1,diff2):
        # 真实数据预测(观测日期近7天数据重新预测)
        print('真实样本')
        client = bigquery.Client()
        # 选择投放未满365天的数据
        query_real = """
                select *
                from beautyplus-bc0ed.temp.dws_dz_roi_predict_final_model_input_delete_v
                where types='ua' and date = DATE_SUB({0}, INTERVAL {1} DAY) 
                        and sub_now=0 
                        -- and last_active_days<=60 
                        and days >= 3*{2} and days < 3*({2}+1)
                     """.format(e_d,diff1,diff2)
        print(f'date:{e_d}')
        print(f'dif1:{diff1}')
        print(f'dif2:{diff2}')
        print(f'query:{query_real}')

        X_no_sub_now_real = client.query(query_real).to_dataframe()

        print(f'predict input shape:{X_no_sub_now_real.shape}')
        if X_no_sub_now_real.shape[0]==0:
            return

        # 数据处理
        data_pre_real = X_no_sub_now_real.loc[:,['date','Attributed_Touch_Date','user_pseudo_id','days']]
        X_no_sub_now_real=(X_no_sub_now_real.drop(['sub_now','sub_revenue_now'
                                               ,'is_sub_now','sub_365','sub_no_trial_365','sub_revenue_365'
                                               ,'date','Attributed_Touch_Date','user_pseudo_id','types'],axis=1))

        # 处理文本变量
        label = X_no_sub_now_real['platform']
        le = LabelEncoder()
        label = le.fit_transform(label)
        X_no_sub_now_real['platform']=label

        label = X_no_sub_now_real['region']
        le = LabelEncoder()
        label = le.fit_transform(label)
        X_no_sub_now_real['region']=label

        label = X_no_sub_now_real['brand']
        le = LabelEncoder()
        label = le.fit_transform(label)
        X_no_sub_now_real['brand']=label

        del label

        # 缺失值处理
        for column in X_no_sub_now_real.columns:
            X_no_sub_now_real.fillna({column:-1}, inplace=True)


        # 特征选择
        column_list=[]
        for column in X_no_sub_now_real.columns:
            if 'pv_2级tab' in column: # or '_31' in column or 'grow' in column:
                continue
            else:
                column_list.append(column)

        X_no_sub_now_real=X_no_sub_now_real.loc[:,column_list]

        print(f'classification input shape:{X_no_sub_now_real.shape}')


        y_no_sub_now_predit_real=stacking.predict_proba(X_no_sub_now_real)[:,1]

        # 回归部分预测-先选定阈值
        thred_real = 0.8  # 时而0.9
        X_to_regression_revenue_365_real = X_no_sub_now_real.loc[y_no_sub_now_predit_real >= thred_real, :]
        # 清除内存
        shape0 = X_no_sub_now_real.shape[0]
        X_no_sub_now_real = pd.DataFrame()
        del X_no_sub_now_real

        print(f'regression input shape:{X_to_regression_revenue_365_real.shape}')

        y_to_regression_predict_revenue_365_real = xgbr.predict(X_to_regression_revenue_365_real)
        y_to_regression_predict_revenue_365_real = np.maximum(y_to_regression_predict_revenue_365_real, 0)

        # 清除内存
        X_to_regression_revenue_365_real = pd.DataFrame()
        del X_to_regression_revenue_365_real

        # 加上未进入预测模型的数据，未预测部分全部记为0
        y_revenue_365_predict_real = pd.Series([0.0] * shape0)
        y_revenue_365_predict_real.loc[y_no_sub_now_predit_real >= thred_real] = y_to_regression_predict_revenue_365_real



        # 原数据加入预测数据进行比较
        out_data_real = pd.concat([data_pre_real.loc[:,
                              ['date', 'Attributed_Touch_Date', 'days', 'user_pseudo_id']]
                                , pd.Series(y_no_sub_now_predit_real)
                                , pd.Series(y_no_sub_now_predit_real >= thred_real)
                                , pd.Series(y_revenue_365_predict_real)], axis=1)
        out_data_real.columns = ['date', 'Attributed_Touch_Date', 'days', 'user_pseudo_id',
                            'predit_no_trial_sub_365_proba','predit_no_trial_sub_365',
                            'predict_sub_revenue_365']

        # 清除内存
        data_pre_real = pd.DataFrame()
        del data_pre_real,y_no_sub_now_predit_real,y_to_regression_predict_revenue_365_real,y_revenue_365_predict_real


        # beautyplus-bc0ed.temp.ads_dz_roi_predict_user_predict_sub_revenue
        table_id_user ='temp.ads_dz_roi_predict_user_predict_sub_revenue'
        credentials_path = os.environ['GOOGLE_APPLICATION_CREDENTIALS']
        credentials = service_account.Credentials.from_service_account_file(credentials_path)

        # 删除观测日期近7天数据
        query_delete = """
                delete from beautyplus-bc0ed.temp.ads_dz_roi_predict_user_predict_sub_revenue 
                where date = DATE_SUB({0}, INTERVAL {1} DAY) 
                    and days >= 3*{2} and days < 3*({2}+1)
                """.format(e_d,diff1,diff2)
        query_job = client.query(query_delete)

        out_data_real.to_gbq(table_id_user, project_id='beautyplus-bc0ed', if_exists='append', # replace
                            table_schema=[{'name': 'date','type': 'DATE'},
                                        {'name': 'Attributed_Touch_Date','type': 'DATE'},
                                        {'name': 'days','type': 'INT64'},
                                        {'name': 'user_pseudo_id','type': 'STRING'},
                                        {'name': 'predit_no_trial_sub_365_proba','type': 'FLOAT'},
                                        {'name': 'predit_no_trial_sub_365','type': 'INT64'},
                                       {'name': 'predict_sub_revenue_365','type': 'FLOAT'}
                                       ]
                                       , credentials=credentials)

        # 清除内存
        out_data_real = pd.DataFrame()
        del out_data_real


    d=(kwargs['execution_date'] + datetime.timedelta(hours=8) - datetime.timedelta(days=0)).strftime("%Y-%m-%d")
    e_d='\''+d+'\''
    stacking,xgbr = model_train(d, "'2024-03-20'")
    # stacking_size_in_bytes = sys.getsizeof(stacking)
    # print(f"stacking size in bytes: {stacking_size_in_bytes}")
    # xgbr_size_in_bytes = sys.getsizeof(xgbr)
    # print(f"xgbr size in bytes: {xgbr_size_in_bytes}")

    gc.collect()
    for diff1 in range(0,3):
        for diff2 in range(0, 122):
            real_predict(stacking, xgbr, d, e_d, diff1, diff2)
            gc.collect()





