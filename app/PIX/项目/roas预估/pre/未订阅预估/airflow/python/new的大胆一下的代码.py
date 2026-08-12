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
    from xgboost import XGBRegressor as XGBR
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

    def model_train(d, e_d, types):
        client = bigquery.Client()
        if types=='classfication_second':
            query_cnt = """
                                select count(1)
                                from 
                                (
                                    select *,0 random
                                    from beautyplus-bc0ed.temp.dws_dz_roi_predict_final_model_input_delete_v
                                    where types='new' and Attributed_Touch_Date between DATE_SUB({0}, INTERVAL 458 DAY) and DATE_SUB({0}, INTERVAL 365 DAY)
                                        and sub_now=0 and sub_no_trial_365>0 and days between 7 and 365
                                        and rand()<0.2
    
                                    union all
    
                                    select *,rand() random
                                    from beautyplus-bc0ed.temp.dws_dz_roi_predict_final_model_input_delete_v
                                    where types='new' and Attributed_Touch_Date between DATE_SUB({0}, INTERVAL 458 DAY) and DATE_SUB({0}, INTERVAL 365 DAY)
                                        and sub_now=0 and sub_no_trial_365=0 and days between 7 and 365
                                        and rand()<0.0002 -- 可以调整
                                )
                                     """.format(e_d)
            cnt = client.query(query_cnt).to_dataframe().iloc[0, 0]
            print(f'cnt:{cnt}')

            query = """
                            select *except(user_pseudo_id),0 random
                            from beautyplus-bc0ed.temp.dws_dz_roi_predict_final_model_input_delete_v
                            where types='new' and Attributed_Touch_Date between DATE_SUB({0}, INTERVAL 458 DAY) and DATE_SUB({0}, INTERVAL 365 DAY)
                                and sub_now=0 and sub_no_trial_365>0 and days between 7 and 365
                                and rand()<0.2*least(800000/{1},1)

                            union all
    
                            select *except(user_pseudo_id),rand() random
                            from beautyplus-bc0ed.temp.dws_dz_roi_predict_final_model_input_delete_v
                            where types='new' and Attributed_Touch_Date between DATE_SUB({0}, INTERVAL 458 DAY) and DATE_SUB({0}, INTERVAL 365 DAY)
                                and sub_now=0 and sub_no_trial_365=0 and days between 7 and 365
                                and rand()<0.0002*least(800000/{1},1) -- 可以调整
                                 """.format(e_d, cnt)
        if types == 'others':
            query_cnt = """
                                select count(1)
                                from 
                                (
                                    select *,0 random
                                    from beautyplus-bc0ed.temp.dws_dz_roi_predict_final_model_input_delete_v
                                    where types='new' and Attributed_Touch_Date between DATE_SUB({0}, INTERVAL 458 DAY) and DATE_SUB({0}, INTERVAL 365 DAY)
                                        and sub_now=0 and sub_no_trial_365>0 and days between 0 and 6
                                        and rand()<1

                                    union all

                                    select *,rand() random
                                    from beautyplus-bc0ed.temp.dws_dz_roi_predict_final_model_input_delete_v
                                    where types='new' and Attributed_Touch_Date between DATE_SUB({0}, INTERVAL 458 DAY) and DATE_SUB({0}, INTERVAL 365 DAY)
                                        and sub_now=0 and sub_no_trial_365=0 and days between 0 and 6
                                        and rand()<0.015 -- 可以调整
                                )
                                     """.format(e_d)
            cnt = client.query(query_cnt).to_dataframe().iloc[0, 0]
            print(f'cnt:{cnt}')

            query = """
                            select *except(user_pseudo_id),0 random
                            from beautyplus-bc0ed.temp.dws_dz_roi_predict_final_model_input_delete_v
                            where types='new' and Attributed_Touch_Date between DATE_SUB({0}, INTERVAL 458 DAY) and DATE_SUB({0}, INTERVAL 365 DAY)
                                and sub_now=0 and sub_no_trial_365>0 and days between 0 and 6
                                and rand()<1*least(800000/{1},1)


                            union all

                            select *except(user_pseudo_id),rand() random
                            from beautyplus-bc0ed.temp.dws_dz_roi_predict_final_model_input_delete_v
                            where types='new' and Attributed_Touch_Date between DATE_SUB({0}, INTERVAL 458 DAY) and DATE_SUB({0}, INTERVAL 365 DAY)
                                and sub_now=0 and sub_no_trial_365=0 and days between 0 and 6
                                and rand()<0.015*least(800000/{1},1) -- 可以调整
                                
                                 """.format(e_d, cnt)

        print(f'date:{e_d}')
        print(f'query:{query}')

        raw_data = client.query(query).to_dataframe()
        # model_name = 'bias'
        print(f'model input shape:{raw_data.shape}')

        # 数据预处理
        # 舍弃异常样本及列（看一下分布）
        # raw_data = (data.drop(['model', 'last_app_version', 'sub_now', 'sub_revenue_now', 'is_sub_now', 'sub_365', 'date',
        #                        'Attributed_Touch_Date', 'user_pseudo_id'], axis=1))
        raw_data = (raw_data.drop(['sub_now', 'sub_revenue_now', 'is_sub_now', 'sub_365', 'date',
                                   'Attributed_Touch_Date', 'types'], axis=1))

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

        # 缺失值处理
        for column in raw_data.columns:
            if column == 'sub_no_trial_365' or column == 'sub_revenue_365':
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

        column_pre = []
        column_af = []
        for column in raw_data.columns:
            if column in ['sub_no_trial_365', 'sub_revenue_365', 'random']:
                continue
            elif column in ['brand', 'last_active_days', 'active_category', 'life_time_active_days']:
                column_pre.append(column)
                column_af.append(column)
            elif '_7' in column or '_14' in column or '_31' in column or '_60' in column or '_90' in column:
                column_af.append(column)
            else:
                column_pre.append(column)

        # 提炼分类/回归样本
        X_no_sub_now = (raw_data.drop(['sub_no_trial_365', 'sub_revenue_365', 'random'], axis=1))
        y_no_sub_now = raw_data['sub_no_trial_365']
        y_no_sub_now = y_no_sub_now.map(lambda x: 1 if x > 0 else 0)

        # print(f'classification model input shape:{X_no_sub_now.shape}')
        # print(f'classification model value count:\n{y_no_sub_now.value_counts()}')
        if types=='classfication_second':
            # 清除内存
            raw_data = pd.DataFrame()
            del raw_data
            print(f"classification2 model input shape:{(X_no_sub_now.loc[X_no_sub_now['days'] > 6, column_af]).shape}")
            print(f"classification2 model value count:\n{(y_no_sub_now.loc[X_no_sub_now['days'] > 6]).value_counts()}")

            # 模型训练-分类模型2
            xtrain_, xtest_, ytrain_, ytest_ = train_test_split(X_no_sub_now.loc[X_no_sub_now['days'] > 6, column_af],
                                                                y_no_sub_now.loc[X_no_sub_now['days'] > 6],
                                                                train_size=0.70,
                                                                random_state=23)
            X_no_sub_now = pd.DataFrame()
            del X_no_sub_now,y_no_sub_now

            estimators_ = [
                ('rf', RandomForestClassifier(n_estimators=10, random_state=42)),
                ('xgbc', XGBC(n_estimators=10, random_state=24))
            ]
            stacking_ = StackingClassifier(
                estimators=estimators_, final_estimator=LogisticRegression()
            )
            stacking_.fit(xtrain_, ytrain_)

            # 预测和评估
            print("stacking2分类器的训练误差:%.3f" % (1 - stacking_.score(xtrain_, ytrain_)))
            print("stacking2分类器的测试误差:%.3f" % (1 - stacking_.score(xtest_, ytest_)))

            print("stacking2分类器的auc:%.3f" % (AUC(ytrain_, stacking_.predict_proba(xtrain_)[:, 1])))
            print("stacking2分类器的auc:%.3f" % (AUC(ytest_, stacking_.predict_proba(xtest_)[:, 1])))

            del xtrain_, xtest_, ytrain_, ytest_

            return stacking_

        if types == 'others':
            X_revenue_365 = (raw_data.drop(['sub_no_trial_365', 'sub_revenue_365', 'random'], axis=1)).loc[
                (raw_data['random'] < 0.025) & (raw_data['sub_revenue_365'] <= 150)]
            y_revenue_365 = raw_data.loc[
                (raw_data['random'] < 0.025) & (raw_data['sub_revenue_365'] <= 150), 'sub_revenue_365']

            # 清除内存
            raw_data = pd.DataFrame()
            del raw_data

            print(f"classification1 model input shape:{(X_no_sub_now.loc[X_no_sub_now['days'] <= 6, column_pre]).shape}")
            print(f"classification1 model value count:\n{(y_no_sub_now.loc[X_no_sub_now['days'] <= 6]).value_counts()}")

            print(f'regression model input shape:{X_revenue_365.shape}')
            print(f'regression model summary:\n{y_revenue_365.describe()}')

            # 模型训练-分类模型1
            xtrain, xtest, ytrain, ytest = train_test_split(X_no_sub_now.loc[X_no_sub_now['days'] <= 6, column_pre],
                                                            y_no_sub_now.loc[X_no_sub_now['days'] <= 6], train_size=0.70,
                                                            random_state=23)
            X_no_sub_now = pd.DataFrame()
            del X_no_sub_now, y_no_sub_now

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
            print("stacking1分类器的训练误差:%.3f" % (1 - stacking.score(xtrain, ytrain)))
            print("stacking1分类器的测试误差:%.3f" % (1 - stacking.score(xtest, ytest)))

            print("stacking1分类器的auc:%.3f" % (AUC(ytrain, stacking.predict_proba(xtrain)[:, 1])))
            print("stacking1分类器的auc:%.3f" % (AUC(ytest, stacking.predict_proba(xtest)[:, 1])))

            del xtrain,ytrain

            # 测试集选择阈值
            ytest_predit = stacking.predict_proba(xtest)[:, 1]
            del xtest

            f1 = []
            precision = []
            recall = []
            for thred in np.arange(0, 1, 0.1):
                precision.append(precision_score(ytest, ytest_predit >= thred))
                recall.append(recall_score(ytest, ytest_predit >= thred))
                f1.append(f1_score(ytest, ytest_predit >= thred))

            del ytest

            print(f'classification1 thred choose-f1:{f1}')
            print(f'classification1 thred choose-precision:{precision}')
            print(f'classification1 thred choose-recall:{recall}')

            # 选定阈值输出分类预测（参考jupyter阈值选择）
            max_value = max(f1)
            max_index = f1.index(max_value)
            thred = np.arange(0, 1, 0.1)[max_index]
            print(f'classification1 thred choose:{thred}') # 0.4

            # 模型训练-回归模型
            xtrain_r, xtest_r, ytrain_r, ytest_r = train_test_split(X_revenue_365, y_revenue_365, train_size=0.70,
                                                                    random_state=123)
            # 清除内存
            X_revenue_365 = pd.DataFrame()
            del X_revenue_365,y_revenue_365

            xgbr = XGBR(n_estimators=500, eta=0.5, max_depth=6, colsample_bytree=0.8, random_state=24)
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

            del xtrain_r, xtest_r, ytrain_r, ytest_r

            return stacking,xgbr,thred

    def model_evaluate(d, e_d, stacking, stacking_, xgbr, thred, thred_diff):
        # step1:导入训练数据(取投放日期在一年半-一年的数据)
        client = bigquery.Client()
        query_cnt = """
                    select count(1)
                    from 
                    (
                        select *,0 random
                        from beautyplus-bc0ed.temp.dws_dz_roi_predict_final_model_input_delete_v
                        where types='new' and Attributed_Touch_Date between DATE_SUB({0}, INTERVAL 458 DAY) and DATE_SUB({0}, INTERVAL 365 DAY)
                            and sub_now=0 and sub_no_trial_365>0 and days between 0 and 6
                            and rand()<1

                        union all

                        select *,0 random
                        from beautyplus-bc0ed.temp.dws_dz_roi_predict_final_model_input_delete_v
                        where types='new' and Attributed_Touch_Date between DATE_SUB({0}, INTERVAL 458 DAY) and DATE_SUB({0}, INTERVAL 365 DAY)
                            and sub_now=0 and sub_no_trial_365>0 and days between 7 and 365
                            and rand()<0.08

                        union all

                        select *,rand() random
                        from beautyplus-bc0ed.temp.dws_dz_roi_predict_final_model_input_delete_v
                        where types='new' and Attributed_Touch_Date between DATE_SUB({0}, INTERVAL 458 DAY) and DATE_SUB({0}, INTERVAL 365 DAY)
                            and sub_now=0 and sub_no_trial_365=0 and days between 0 and 6
                            and rand()<0.01 -- 可以调整

                        union all

                        select *,rand() random
                        from beautyplus-bc0ed.temp.dws_dz_roi_predict_final_model_input_delete_v
                        where types='new' and Attributed_Touch_Date between DATE_SUB({0}, INTERVAL 458 DAY) and DATE_SUB({0}, INTERVAL 365 DAY)
                            and sub_now=0 and sub_no_trial_365=0 and days between 7 and 365
                            and rand()<0.00008 -- 可以调整
                    )
                         """.format(e_d)
        cnt = client.query(query_cnt).to_dataframe().iloc[0, 0]
        print(f'cnt:{cnt}')

        query = """
                select *,0 random
                from beautyplus-bc0ed.temp.dws_dz_roi_predict_final_model_input_delete_v
                where types='new' and Attributed_Touch_Date between DATE_SUB({0}, INTERVAL 458 DAY) and DATE_SUB({0}, INTERVAL 365 DAY)
                    and sub_now=0 and sub_no_trial_365>0 and days between 0 and 6
                    and rand()<1*least(700000/{1},1)

                union all

                select *,0 random
                from beautyplus-bc0ed.temp.dws_dz_roi_predict_final_model_input_delete_v
                where types='new' and Attributed_Touch_Date between DATE_SUB({0}, INTERVAL 458 DAY) and DATE_SUB({0}, INTERVAL 365 DAY)
                    and sub_now=0 and sub_no_trial_365>0 and days between 7 and 365
                    and rand()<0.08*least(700000/{1},1)

                union all

                select *,rand() random
                from beautyplus-bc0ed.temp.dws_dz_roi_predict_final_model_input_delete_v
                where types='new' and Attributed_Touch_Date between DATE_SUB({0}, INTERVAL 458 DAY) and DATE_SUB({0}, INTERVAL 365 DAY)
                    and sub_now=0 and sub_no_trial_365=0 and days between 0 and 6
                    and rand()<0.01*least(700000/{1},1) -- 可以调整

                union all

                select *,rand() random
                from beautyplus-bc0ed.temp.dws_dz_roi_predict_final_model_input_delete_v
                where types='new' and Attributed_Touch_Date between DATE_SUB({0}, INTERVAL 458 DAY) and DATE_SUB({0}, INTERVAL 365 DAY)
                    and sub_now=0 and sub_no_trial_365=0 and days between 7 and 365
                    and rand()<0.00008*least(700000/{1},1) -- 可以调整
                     """.format(e_d, cnt)

        print(f'date:{e_d}')
        print(f'query:{query}')

        raw_data = client.query(query).to_dataframe()
        # model_name = 'bias'
        print(f'model input shape:{raw_data.shape}')

        # 数据预处理
        # 舍弃异常样本及列（看一下分布）
        # raw_data = (data.drop(['model', 'last_app_version', 'sub_now', 'sub_revenue_now', 'is_sub_now', 'sub_365', 'date',
        #                        'Attributed_Touch_Date', 'user_pseudo_id'], axis=1))
        data_pre = raw_data.loc[:, ['sub_no_trial_365', 'sub_revenue_365', 'date', 'Attributed_Touch_Date', 'days']]
        raw_data = (raw_data.drop(['sub_now', 'sub_revenue_now', 'is_sub_now', 'sub_365', 'date',
                                   'Attributed_Touch_Date', 'user_pseudo_id', 'types'], axis=1))

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

        # 缺失值处理
        for column in raw_data.columns:
            if column == 'sub_no_trial_365' or column == 'sub_revenue_365':
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

        column_pre = []
        column_af = []
        for column in raw_data.columns:
            if column in ['sub_no_trial_365', 'sub_revenue_365', 'random']:
                continue
            elif column in ['brand','last_active_days','active_category','life_time_active_days']:
                column_pre.append(column)
                column_af.append(column)
            elif '_7' in column or '_14' in column or '_31' in column or '_60' in column or '_90' in column:
                column_af.append(column)
            else:
                column_pre.append(column)


        # 提炼分类/回归样本
        X_no_sub_now = (raw_data.drop(['sub_no_trial_365', 'sub_revenue_365', 'random'], axis=1))
        y_no_sub_now = raw_data['sub_no_trial_365']
        y_no_sub_now = y_no_sub_now.map(lambda x: 1 if x > 0 else 0)

        # 清除内存
        raw_data = pd.DataFrame()
        del raw_data

        y_no_sub_now_predit = stacking.predict_proba(X_no_sub_now.loc[:,column_pre])[:, 1]

        # 计算查准率
        precision = precision_score(y_no_sub_now, y_no_sub_now_predit >= thred)
        print(f'Precision1: {precision:.2f}')

        # 计算查全率
        recall = recall_score(y_no_sub_now, y_no_sub_now_predit >= thred)
        print(f'Recall1: {recall:.2f}')

        # 计算F1 Score
        f1 = f1_score(y_no_sub_now, y_no_sub_now_predit >= thred)
        print(f'F1 Score1: {f1:.2f}')

        conf_matrix_real = confusion_matrix(y_no_sub_now, y_no_sub_now_predit >= thred)
        print(f'混淆矩阵1: \n{conf_matrix_real}')

        # 第二层stacking模型
        flag1=(y_no_sub_now_predit >= (thred-thred_diff)) & (X_no_sub_now['days'] > 6)
        y_no_sub_now_second_predit = stacking_.predict_proba(X_no_sub_now.loc[flag1, column_af])[:, 1]

        f1_ = []
        precision_ = []
        recall_ = []
        for thred in np.arange(0, 1, 0.1):
            precision_.append(precision_score(y_no_sub_now.loc[flag1], y_no_sub_now_second_predit >= thred))
            recall_.append(recall_score(y_no_sub_now.loc[flag1], y_no_sub_now_second_predit >= thred))
            f1_.append(f1_score(y_no_sub_now.loc[flag1], y_no_sub_now_second_predit >= thred))

        print(f'classification2 thred choose-f1:{f1_}')
        print(f'classification2 thred choose-precision:{precision_}')
        print(f'classification2 thred choose-recall:{recall_}')

        # 选定阈值输出分类预测（参考jupyter阈值选择）
        max_value_ = max(f1_)
        max_index_ = f1_.index(max_value_)
        thred_ = np.arange(0, 1, 0.1)[max_index_]
        print(f'classification2 thred choose:{thred_}')
        print(f'Precision2:{precision_[max_index_]}')
        print(f'Recall2:{recall_[max_index_]}')
        print(f'F1 Score2:{f1_[max_index_]}')


        # 计算两步模型结果
        flag2=pd.Series([False] * X_no_sub_now.shape[0])
        flag2.loc[flag1]= (y_no_sub_now_second_predit>=thred_)
        flag=(flag1*flag2) | ((y_no_sub_now_predit >= thred) & (X_no_sub_now['days'] <= 6))
        # 计算查准率
        precision_ = precision_score(y_no_sub_now, flag)
        print('----------------------------------------')
        print('final classfication')
        print(f'Precision: {precision_:.2f}')

        # 计算查全率
        recall_ = recall_score(y_no_sub_now, flag)
        print(f'Recall: {recall_:.2f}')

        # 计算F1 Score
        f1_ = f1_score(y_no_sub_now, flag)
        print(f'F1 Score: {f1_:.2f}')

        conf_matrix_real_ = confusion_matrix(y_no_sub_now, flag)
        print(f'混淆矩阵: \n{conf_matrix_real_}')


        # 提炼进入回归模型的样本
        X_to_regression_revenue_365 = X_no_sub_now.loc[flag, :]

        # 清除内存
        shape0 = X_no_sub_now.shape[0]
        X_no_sub_now = pd.DataFrame()
        del X_no_sub_now

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
        y_revenue_365_predict.loc[flag] = y_to_regression_predict_revenue_365

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
        del data_pre

        out_data.columns = ['date', 'Attributed_Touch_Date', 'days',
                            # 'user_pseudo_id', 'sub_now', 'sub_revenue_now',
                            # 'is_sub_now', 'sub_365', 'sub_no_trial_365',
                            'sub_revenue_365',
                            'predit_no_trial_sub_365_proba', 'predit_no_trial_sub_365',
                            'predict_sub_revenue_365']

        # 分投放天数评估预测准确率
        evaluate = out_data.groupby('days').agg({'sub_revenue_365': 'sum', 'predict_sub_revenue_365': 'sum'})
        evaluate['precision'] = evaluate['predict_sub_revenue_365'] / evaluate['sub_revenue_365']
        evaluate['date'] = d
        evaluate['days'] = evaluate.index
        evaluate['types'] = 'sample'

        # 清除内存
        out_data = pd.DataFrame()
        del out_data

        return evaluate

    def real_predict(stacking, stacking_, xgbr, evaluate, d, e_d, diff1, diff2, thred_diff):
        # 真实数据预测(拿历史数据预估，仅测试)
        print('真实样本')
        client = bigquery.Client()
        # 选择投放未满365天的数据
        query_real = """
                select *
                from beautyplus-bc0ed.temp.dws_dz_roi_predict_final_model_input_delete_v
                -- where Attributed_Touch_Date>DATE_SUB(mDATE, INTERVAL 365 DAY)
                -- where types='ua' and Attributed_Touch_Date between DATE_SUB({0}, INTERVAL 458 DAY) and DATE_SUB({0}, INTERVAL 365 DAY)
                where types='new' 
                        and Attributed_Touch_Date = DATE_SUB({0}, INTERVAL {1}+365 DAY) 
                        and sub_now=0 
                        and days >= 7*{2} and days < 7*({2}+1)
                        -- and last_active_days<=60
                     """.format(e_d, diff1, diff2)

        print(f'date:{e_d}')
        print(f'dif1:{diff1}')
        print(f'dif2:{diff2}')
        print(f'query:{query_real}')

        X_no_sub_now_real = client.query(query_real).to_dataframe()

        print(f'predict input shape:{X_no_sub_now_real.shape}')

        # 数据处理
        # X_no_sub_now_real = (X_no_sub_now_real.drop(['model', 'last_app_version', 'sub_now', 'sub_revenue_now'
        #                                             , 'is_sub_now', 'sub_365', 'sub_no_trial_365', 'sub_revenue_365'
        #                                             , 'date', 'Attributed_Touch_Date', 'user_pseudo_id'], axis=1))
        data_pre_real = X_no_sub_now_real.loc[:,
                        ['sub_no_trial_365', 'sub_revenue_365', 'date', 'Attributed_Touch_Date', 'user_pseudo_id',
                         'days']]
        X_no_sub_now_real = (X_no_sub_now_real.drop(['sub_now', 'sub_revenue_now'
                                                        , 'is_sub_now', 'sub_365', 'sub_no_trial_365', 'sub_revenue_365'
                                                        , 'date', 'Attributed_Touch_Date', 'user_pseudo_id', 'types'],
                                                    axis=1))

        y_no_sub_now_real = data_pre_real['sub_no_trial_365']
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

        column_pre = []
        column_af = []
        for column in X_no_sub_now_real.columns:
            if column in ['brand', 'last_active_days', 'active_category', 'life_time_active_days']:
                column_pre.append(column)
                column_af.append(column)
            elif '_7' in column or '_14' in column or '_31' in column or '_60' in column or '_90' in column:
                column_af.append(column)
            else:
                column_pre.append(column)

        # 第一步分层模型
        y_no_sub_now_predit_real = stacking.predict_proba(X_no_sub_now_real.loc[:,column_pre])[:, 1]
        # print("stacking分类器的auc:%.3f" % (AUC(y_no_sub_now_real, y_no_sub_now_predit_real)))
        print(f'classification1 input shape:{X_no_sub_now_real.loc[:,column_pre].shape}')

        # # 选定阈值
        # f1 = []
        # precision = []
        # recall = []
        # for thred_real in np.arange(0, 1, 0.1):
        #     precision.append(precision_score(y_no_sub_now_real, y_no_sub_now_predit_real >= thred_real))
        #     recall.append(recall_score(y_no_sub_now_real, y_no_sub_now_predit_real >= thred_real))
        #     f1.append(f1_score(y_no_sub_now_real, y_no_sub_now_predit_real >= thred_real))
        #
        # print(f'real classification1 thred choose-f1:{f1}')
        # print(f'real classification1 thred choose-precision:{precision}')
        # print(f'real classification1 thred choose-recall:{recall}')
        #
        # # 选定阈值输出分类预测
        # max_value = max(f1)
        # max_index = f1.index(max_value)
        # thred_real = np.arange(0, 1, 0.1)[max_index]
        thred_real = 0.9
        print(f'real classification1 thred choose:{thred_real}')

        # 计算查准率
        precision = precision_score(y_no_sub_now_real, y_no_sub_now_predit_real >= thred_real)
        print(f'Precision1: {precision:.2f}')

        # 计算查全率
        recall = recall_score(y_no_sub_now_real, y_no_sub_now_predit_real >= thred_real)
        print(f'Recall1: {recall:.2f}')

        # 计算F1 Score
        f1 = f1_score(y_no_sub_now_real, y_no_sub_now_predit_real >= thred_real)
        print(f'F1 Score1: {f1:.2f}')

        conf_matrix_real = confusion_matrix(y_no_sub_now_real, y_no_sub_now_predit_real >= thred_real)
        print(f'混淆矩阵1: \n{conf_matrix_real}')

        # 第二层stacking模型
        flag1_real = (y_no_sub_now_predit_real >= (thred_real-thred_diff)) & (X_no_sub_now_real['days'] > 6)
        if flag1_real.sum()>0:
            print(f'classification2 input shape:{X_no_sub_now_real.loc[flag1_real, column_af].shape}')
            y_no_sub_now_second_predit_real = stacking_.predict_proba(X_no_sub_now_real.loc[flag1_real, column_af])[:, 1]

            # f1_ = []
            # precision_ = []
            # recall_ = []
            # for thred in np.arange(0, 1, 0.1):
            #     precision_.append(precision_score(y_no_sub_now_real.loc[flag1_real], y_no_sub_now_second_predit_real >= thred))
            #     recall_.append(recall_score(y_no_sub_now_real.loc[flag1_real], y_no_sub_now_second_predit_real >= thred))
            #     f1_.append(f1_score(y_no_sub_now_real.loc[flag1_real], y_no_sub_now_second_predit_real >= thred))
            #
            # print(f'classification2 thred choose-f1:{f1_}')
            # print(f'classification2 thred choose-precision:{precision_}')
            # print(f'classification2 thred choose-recall:{recall_}')
            #
            # # 选定阈值输出分类预测（参考jupyter阈值选择）
            # max_value_ = max(f1_)
            # max_index_ = f1_.index(max_value_)
            # thred_real_ = np.arange(0, 1, 0.1)[max_index_]
            thred_real_ = 0.5
            print(f'classification2 thred choose:{thred_real_}')
            # print(f'Precision2:{precision_[max_index_]}')
            # print(f'Recall2:{recall_[max_index_]}')
            # print(f'F1 Score2:{f1_[max_index_]}')

            # 计算两步模型结果
            flag2_real = pd.Series([False] * X_no_sub_now_real.shape[0])
            flag2_real.loc[flag1_real] = (y_no_sub_now_second_predit_real >= thred_real_)
            flag_real = (flag1_real * flag2_real) | ((y_no_sub_now_predit_real >= thred_real) & (X_no_sub_now_real['days'] <= 6))
        else:
            flag_real=((y_no_sub_now_predit_real >= thred_real))

        # 计算查准率
        precision_ = precision_score(y_no_sub_now_real, flag_real)
        print('---------------------------------------------')
        print('final classfication')
        print(f'Precision: {precision_:.2f}')

        # 计算查全率
        recall_ = recall_score(y_no_sub_now_real, flag_real)
        print(f'Recall: {recall_:.2f}')

        # 计算F1 Score
        f1_ = f1_score(y_no_sub_now_real, flag_real)
        print(f'F1 Score: {f1_:.2f}')

        conf_matrix_real_ = confusion_matrix(y_no_sub_now_real, flag_real)
        print(f'混淆矩阵: \n{conf_matrix_real_}')

        # 回归部分预测-先选定阈值
        X_to_regression_revenue_365_real = X_no_sub_now_real.loc[flag_real, :]

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
        y_revenue_365_predict_real.loc[flag_real] = y_to_regression_predict_revenue_365_real

        # # 原数据加入预测数据进行比较
        # out_data_real = pd.concat([data_pre_real.loc[:,
        #                            ['date', 'Attributed_Touch_Date', 'days',
        #                             # 'user_pseudo_id', 'sub_now', 'sub_revenue_now',
        #                             # 'is_sub_now', 'sub_365', 'sub_no_trial_365',
        #                             'sub_revenue_365']], pd.Series(y_no_sub_now_predit_real)
        #                               , pd.Series(y_no_sub_now_predit_real >= thred_real)
        #                               , pd.Series(y_revenue_365_predict_real)], axis=1)
        # out_data_real.columns = ['date', 'Attributed_Touch_Date', 'days',
        #                          # 'user_pseudo_id', 'sub_now', 'sub_revenue_now',
        #                          # 'is_sub_now', 'sub_365', 'sub_no_trial_365',
        #                          'sub_revenue_365',
        #                          'predit_no_trial_sub_365_proba', 'predit_no_trial_sub_365',
        #                          'predict_sub_revenue_365']
        #
        # # 清除内存
        # data_pre_real = pd.DataFrame()
        # del data_pre_real
        #
        # # 分投放天数进行比较
        # evaluate_real = out_data_real.groupby('days').agg({'sub_revenue_365': 'sum', 'predict_sub_revenue_365': 'sum'})
        # evaluate_real['precision'] = evaluate_real['predict_sub_revenue_365'] / evaluate_real['sub_revenue_365']
        # evaluate_real['date'] = d
        # evaluate_real['days'] = evaluate_real.index
        # evaluate_real['types'] = 'real'
        #
        # # 清除内存
        # out_data_real = pd.DataFrame()
        # del out_data_real
        #
        # evaluate_all = pd.concat([evaluate, evaluate_real], axis=0)
        #
        # # beautyplus-bc0ed.temp.ads_dz_roi_predict_new_sample_evaluate_test
        # table_id = 'temp.ads_dz_roi_predict_new_sample_evaluate_test'
        # credentials_path = os.environ['GOOGLE_APPLICATION_CREDENTIALS']
        # credentials = service_account.Credentials.from_service_account_file(credentials_path)
        # evaluate_all.to_gbq(table_id, project_id='beautyplus-bc0ed', if_exists='replace',  # append
        #                     table_schema=[{'name': 'sub_revenue_365', 'type': 'FLOAT'},
        #                                   {'name': 'predict_sub_revenue_365', 'type': 'FLOAT'},
        #                                   {'name': 'precision', 'type': 'FLOAT'},
        #                                   {'name': 'date', 'type': 'DATE'},
        #                                   {'name': 'days', 'type': 'INT64'},
        #                                   {'name': 'types', 'type': 'STRING'}
        #                                   ]
        #                     , credentials=credentials)

        # 原数据加入预测数据进行比较
        out_data_real = pd.concat([data_pre_real.loc[:,
                                   ['date', 'Attributed_Touch_Date', 'days', 'user_pseudo_id', 'sub_revenue_365']]
                                      , pd.Series(y_no_sub_now_predit_real)
                                      , pd.Series(flag_real)
                                      , pd.Series(y_revenue_365_predict_real)], axis=1)

        # 清除内存
        data_pre_real = pd.DataFrame()
        del data_pre_real

        out_data_real.columns = ['date', 'Attributed_Touch_Date', 'days', 'user_pseudo_id', 'sub_revenue_365',
                                 'predit_no_trial_sub_365_proba', 'predit_no_trial_sub_365',
                                 'predict_sub_revenue_365']

        # beautyplus-bc0ed.temp.ads_dz_roi_predict_new_user_predict_sub_revenue_test
        table_id_user = 'temp.ads_dz_roi_predict_new_user_predict_sub_revenue_test'
        credentials_path = os.environ['GOOGLE_APPLICATION_CREDENTIALS']
        credentials = service_account.Credentials.from_service_account_file(credentials_path)

        # 删除观测日期近7天数据
        query_delete = """
                        delete from beautyplus-bc0ed.temp.ads_dz_roi_predict_new_user_predict_sub_revenue_test
                        where Attributed_Touch_Date = DATE_SUB({0}, INTERVAL {1}+365 DAY)
                                and days >= 7*{2} and days < 7*({2}+1)
                        """.format(e_d, diff1, diff2)
        query_job = client.query(query_delete)

        out_data_real.to_gbq(table_id_user, project_id='beautyplus-bc0ed', if_exists='append',  # replace
                             table_schema=[{'name': 'date', 'type': 'DATE'},
                                           {'name': 'Attributed_Touch_Date', 'type': 'DATE'},
                                           {'name': 'days', 'type': 'INT64'},
                                           {'name': 'user_pseudo_id', 'type': 'STRING'},
                                           {'name': 'sub_revenue_365', 'type': 'FLOAT'},
                                           {'name': 'predit_no_trial_sub_365_proba', 'type': 'FLOAT'},
                                           {'name': 'predit_no_trial_sub_365', 'type': 'INT64'},
                                           {'name': 'predict_sub_revenue_365', 'type': 'FLOAT'}
                                           ]
                             , credentials=credentials)

        # 清除内存
        out_data_real = pd.DataFrame()
        del out_data_real

    d = (kwargs['execution_date'] + datetime.timedelta(hours=8) - datetime.timedelta(days=0)).strftime("%Y-%m-%d")
    e_d = '\'' + d + '\''
    stacking_ = model_train(d, e_d, 'classfication_second')
    stacking, xgbr, thred = model_train(d, e_d, 'others')
    evaluate = model_evaluate(d, e_d, stacking, stacking_, xgbr, thred, 0.05)
    # stacking_size_in_bytes = sys.getsizeof(stacking)
    # print(f"stacking size in bytes: {stacking_size_in_bytes}")
    # xgbr_size_in_bytes = sys.getsizeof(xgbr)
    # print(f"xgbr size in bytes: {xgbr_size_in_bytes}")

    gc.collect()
    for diff1 in range(0, 3):
        for diff2 in range(0, 53):
            real_predict(stacking, stacking_, xgbr, evaluate, d, e_d, diff1, diff2, 0.05)
            gc.collect()










