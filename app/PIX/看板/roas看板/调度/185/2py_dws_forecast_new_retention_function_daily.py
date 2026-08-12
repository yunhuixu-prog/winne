def common_function(ds, **kwargs):
    import pandas as pd
    from scipy.optimize import curve_fit
    import numpy as np
    from google.oauth2 import service_account
    from google.cloud import bigquery
    import os
    client = bigquery.Client()

    # 导入数据
    # 每次都重新计算过去半年的数据
    query1 = """
        select 
            distinct cast(date as string) date,app_id,country,platform,is_UA,subscription_user_type,subscription_period,period,period_rate
        from `dataintegration-265403.user_ltv.dws_gather_new_retention_for_py_tmp_daily`
       -- where date between '2020-08-01' and '2021-09-30'
             """
    query2 = """
        select 
            distinct cast(date as string) date,app_id,country,platform,is_UA,subscription_user_type,subscription_period
        from `dataintegration-265403.user_ltv.dws_gather_new_retention_for_py_tmp_daily`
       -- where date between  '2020-08-01' and '2021-09-30'

            """

    raw_data = client.query(query1).to_dataframe()
    forecast_type = client.query(query2).to_dataframe()

    # 创建一个空表记录函数
    dtypes_func = np.dtype([('date', str), ('app_id', str), ('country', str), ('platform', str), ('is_UA', str),
                            ('subscription_user_type', str), ('subscription_period', str), ('popt_a', float),
                            ('popt_b', float), ('R_squared', float), ('max_LT', float)])
    data_func = np.empty(0, dtype=dtypes_func)
    df_func = pd.DataFrame(data_func)

    def func(x, a, b):  # x-shifted log
        return a * np.log(x) + b

    for i in range(len(forecast_type)):
        d = forecast_type['date'][i]
        a = forecast_type['app_id'][i]
        c = forecast_type['country'][i]
        p = forecast_type['platform'][i]
        ua = forecast_type['is_UA'][i]
        sut = forecast_type['subscription_user_type'][i]
        pe = forecast_type['subscription_period'][i]
        data = raw_data.query(
            "(date == @d)&(app_id == @a)& (country == @c) & (platform == @p) & (is_UA == @ua)& (subscription_user_type == @sut)&(subscription_period == @pe)")
        x = data['period']
        y = data['period_rate']
        # popt, pcov = curve_fit(func, x, y)
        popt, pcov = curve_fit(func, x, y)

        # 计算均方差和R方
        modelPredictions = func(x, *popt)
        absError = modelPredictions - y
        SE = np.square(absError)  # squared errors
        MSE = np.mean(SE)  # mean squared errors
        RMSE = np.sqrt(MSE)  # Root Mean Squared Error, RMSE
        # Rsquared = 1.0 - (np.var(absError) / np.var(y))
        if np.var(y) == 0:
            Rsquared = 0.0
        else:
            Rsquared = 1.0 - (np.var(absError) / np.var(y))

        # 计算LT
        lt = np.exp(-popt[1] / popt[0])
        # 存表 对数函数的值
        # append_data = {"date":d,"app_id": a,"country":c,"platform":p,"is_UA":ua,"subscription_user_type":sut,"subscription_period":pe,"popt_a":popt[0],"popt_b":popt[1],"R_squared":Rsquared,'max_LT':lt}
        # df_func = df_func.append(append_data,ignore_index=True)
        append_data = pd.DataFrame({'date': [d], 'app_id': [a], 'country': [c], 'platform': [p], 'is_UA': [ua],
                                    'subscription_user_type': [sut], 'subscription_period': [pe], 'popt_a': [popt[0]],
                                    'popt_b': [popt[1]], 'R_squared': [Rsquared], 'max_LT': [lt]})
        df_func = pd.concat([df_func, append_data])

    table_id = 'user_ltv.dws_forecast_new_retention_function_daily'
    credentials_path = os.environ['GOOGLE_APPLICATION_CREDENTIALS']
    credentials = service_account.Credentials.from_service_account_file(credentials_path)
    df_func.to_gbq(table_id, project_id='dataintegration-265403', if_exists='append',
                   table_schema=[{'name': 'date', 'type': 'STRING'},
                                 {'name': 'app_id', 'type': 'STRING'},
                                 {'name': 'country', 'type': 'STRING'},
                                 {'name': 'platform', 'type': 'STRING'},
                                 {'name': 'is_UA', 'type': 'STRING'},
                                 {'name': 'subscription_user_type', 'type': 'STRING'},
                                 {'name': 'subscription_period', 'type': 'STRING'},
                                 {'name': 'popt_a', 'type': 'FLOAT'},
                                 {'name': 'popt_b', 'type': 'FLOAT'},
                                 {'name': 'R_squared', 'type': 'FLOAT'},
                                 {'name': 'max_LT', 'type': 'FLOAT'}
                                 ]
                   , credentials=credentials)