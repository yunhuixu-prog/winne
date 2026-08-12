def common_function(ds, **kwargs):
    from scipy.optimize import curve_fit
    from google.oauth2 import service_account
    from google.cloud import bigquery
    import numpy as np
    import pandas as pd
    import os
    # import matplotlib.pyplot as plt
    from sklearn.preprocessing import LabelEncoder
    from sklearn.metrics import roc_auc_score as AUC
    from sklearn.model_selection import train_test_split

    client = bigquery.Client()

    # 导入数据
    # 每次都重新计算过去半年的数据
    query = """
        select 
            *
        from `beautyplus-bc0ed.temp.dws_dz_roi_predict_model_input`
        where Attributed_Touch_Date between '2023-01-01' and '2023-02-20'
        limit 100
             """

    raw_data = client.query(query).to_dataframe()

    X_no_sub_now = (raw_data.drop(
        ['sub_365', 'sub_no_trial_365', 'sub_revenue_365', 'date', 'Attributed_Touch_Date', 'user_pseudo_id'],
        axis=1)).fillna(0).loc[(raw_data['is_sub_now'] == 0) & (raw_data['sub_now'] == 0)]
    y_no_sub_now = raw_data.loc[(raw_data['is_sub_now'] == 0) & (raw_data['sub_now'] == 0), 'sub_365']

    # label变为0/1分类变量
    y_no_sub_now = y_no_sub_now.map(lambda x: 1 if x > 0 else 0)

    # 处理文本变量
    label = X_no_sub_now['platform']
    le = LabelEncoder()
    label = le.fit_transform(label)
    X_no_sub_now['platform'] = label

    label = X_no_sub_now['region']
    le = LabelEncoder()
    label = le.fit_transform(label)
    X_no_sub_now['region'] = label

    print(raw_data.shape)
    print(X_no_sub_now.shape)
    print(y_no_sub_now.shape)
    print(y_no_sub_now.value_counts())

    xtrain, xtest, ytrain, ytest = train_test_split(X_no_sub_now, y_no_sub_now, train_size=0.70, random_state=123)

    from xgboost import XGBClassifier as XGBC
    xgbc = XGBC(random_state=24)
    xgbc.fit(xtrain, ytrain)

    print("xgboost分类器的训练误差:%.3f" % (1 - xgbc.score(xtrain, ytrain)))
    print("xgboost分类器的测试误差:%.3f" % (1 - xgbc.score(xtest, ytest)))

    print("xgboost分类器的auc:%.3f" % (AUC(ytrain, xgbc.predict_proba(xtrain)[:, 1])))
    print("xgboost分类器的auc:%.3f" % (AUC(ytest, xgbc.predict_proba(xtest)[:, 1])))



    # table_id = 'user_ltv.dws_forecast_new_retention_function_daily'
    # credentials_path = os.environ['GOOGLE_APPLICATION_CREDENTIALS']
    # credentials = service_account.Credentials.from_service_account_file(credentials_path)
    # df_func.to_gbq(table_id, project_id='dataintegration-265403', if_exists='append',
    #                table_schema=[{'name': 'date', 'type': 'STRING'},
    #                              {'name': 'app_id', 'type': 'STRING'},
    #                              {'name': 'country', 'type': 'STRING'},
    #                              {'name': 'platform', 'type': 'STRING'},
    #                              {'name': 'is_UA', 'type': 'STRING'},
    #                              {'name': 'subscription_user_type', 'type': 'STRING'},
    #                              {'name': 'subscription_period', 'type': 'STRING'},
    #                              {'name': 'popt_a', 'type': 'FLOAT'},
    #                              {'name': 'popt_b', 'type': 'FLOAT'},
    #                              {'name': 'R_squared', 'type': 'FLOAT'},
    #                              {'name': 'max_LT', 'type': 'FLOAT'}
    #                              ]
    #                , credentials=credentials)