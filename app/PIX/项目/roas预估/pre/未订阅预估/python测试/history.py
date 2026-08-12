from xgboost import XGBClassifier as XGBC

initial_params = {
    # 'n_estimators': 100,
    # 'eta': 0.3,
    # 'max_depth': 5,
    # 'min_child_weight': 4,
    # 'lambda': 0,
    # 'alpha': 0,
    # 'subsample': 1,
    # 'colsample_bytree': 1,
    # 'objective': 'binary:logistic',
    'random_state': 23
}
xgbc=XGBC(**initial_params)
xgbc.fit(xtrain,ytrain)

xgbc.save_model('model/xgbc_model_'+model_name+'.json')

print("xgboost分类器的训练误差:%.3f" % (1 - xgbc.score(xtrain, ytrain)))
print("xgboost分类器的测试误差:%.3f" % (1 - xgbc.score(xtest, ytest)))

print("xgboost分类器的auc:%.3f" % (AUC(ytrain,xgbc.predict_proba(xtrain)[:,1])))
print("xgboost分类器的auc:%.3f" % (AUC(ytest,xgbc.predict_proba(xtest)[:,1])))

# 分投放天数查看模型效果
day_auc_xgb=[]
for i in range(start_day,end_day):
    x_day=X_no_sub_now.loc[X_no_sub_now['days']==i]
    y_day=y_no_sub_now.loc[X_no_sub_now['days']==i]
    day_auc_xgb.append(AUC(y_day,xgbc.predict_proba(x_day)[:,1]))
plt.plot(range(start_day,end_day), day_auc_xgb)

import lightgbm as lgb
## 构建lgb中的Dataset格式
lgb_train = lgb.Dataset(xtrain, ytrain)
lgb_eval = lgb.Dataset(xtest, ytest, reference=lgb_train)
## 敲定好一组参数
params = {
    'task': 'train',
    'boosting_type': 'gbdt',
    'objective': 'binary',
    'metric': {'l2', 'auc'},
    # 'max_depth': 6,
    'num_leaves': 31,
    'learning_rate': 0.1,
    'feature_fraction': 0.9,
    'bagging_fraction': 0.8,
    'bagging_freq': 5,
    'verbose': 0
}
print('开始训练...')
## 训练
gbm = lgb.train(params,
                lgb_train,
                num_boost_round=150,
                valid_sets=lgb_eval)

gbm.save_model('model/gbm_model_'+model_name+'.json')

print("lgboost分类器的auc:%.3f" % (AUC(ytrain,gbm.predict(xtrain))))
print("lgboost分类器的auc:%.3f" % (AUC(ytest,gbm.predict(xtest))))

# 分投放天数查看模型效果
day_auc_lgb=[]
for i in range(start_day,end_day):
    x_day=X_no_sub_now.loc[X_no_sub_now['days']==i]
    y_day=y_no_sub_now.loc[X_no_sub_now['days']==i]
    day_auc_lgb.append(AUC(y_day,gbm.predict(x_day)))
plt.plot(range(start_day,end_day), day_auc_lgb)

import imbalance_xgboost as imxgb
from xgboost import XGBClassifier

# from imxgboost.imbalance_xgb import imbalance_xgboost as imb_xgb
# from sklearn.model_selection import GridSearchCV
# xgboster_focal = imb_xgb(special_objective='focal')
# CV_focal_booster = GridSearchCV(xgboster_focal, {"focal_gamma":[1.0,1.5,2.0,2.5,3.0]})
# CV_focal_booster.fit(xtrain.to_numpy(),ytrain.to_numpy())
# opt_focal_booster = CV_focal_booster.best_estimator_
# print("imxgboost分类器的auc:%.3f" % (AUC(ytrain,opt_focal_booster.predict_sigmoid(xtrain))))
# print("imxgboost分类器的auc:%.3f" % (AUC(ytest,opt_focal_booster.predict_sigmoid(xtest))))

imxgb = imxgb.core.XGBClassifier(scale_pos_weight=1,special_objective='focal')

# 训练模型
imxgb.fit(xtrain,ytrain)

imxgb.save_model('model/imxgb_model_'+model_name+'.json')
print("imxgboost分类器的auc:%.3f" % (AUC(ytrain,imxgb.predict_proba(xtrain)[:,1])))
print("imxgboost分类器的auc:%.3f" % (AUC(ytest,imxgb.predict_proba(xtest)[:,1])))

from catboost import CatBoostClassifier
cat_features = [0, 1]
# Initialize CatBoostRegressor
catboost = CatBoostClassifier(iterations=200,
                           learning_rate=0.1,
                           depth=3)
# Fit model
catboost.fit(xtrain,ytrain,cat_features)

catboost.save_model('model/catboost_model_'+model_name+'.json')

print("catboost分类器的训练误差:%.3f" % (1 - catboost.score(xtrain, ytrain)))
print("catboost分类器的测试误差:%.3f" % (1 - catboost.score(xtest, ytest)))

print("catboost分类器的auc:%.3f" % (AUC(ytrain,catboost.predict_proba(xtrain)[:,1])))
print("catboost分类器的auc:%.3f" % (AUC(ytest,catboost.predict_proba(xtest)[:,1])))











# 回归先这样吧,不管了

import numpy as np
from sklearn.datasets import load_diabetes
from sklearn.ensemble import StackingRegressor
from sklearn.linear_model import RidgeCV, LassoCV
from sklearn.neighbors import KNeighborsRegressor
from sklearn.model_selection import train_test_split
from sklearn.metrics import mean_squared_error,r2_score
from xgboost import XGBRegressor as XGBR
from joblib import dump


# 定义基模型
base_models = [
    ('ridge', RidgeCV()),
    ('lasso', LassoCV(random_state=42)),
    # ('knn', KNeighborsRegressor(n_neighbors=5)),
    ('xgbr', XGBR(random_state=24))
]

# 定义元学习器（最终的回归模型）
final_estimator = RidgeCV()

# 构建Stacking回归模型
stacked_regressor = StackingRegressor(estimators=base_models,
                                      final_estimator=final_estimator)

# 训练模型
stacked_regressor.fit(xtrain_r, ytrain_r)

dump(stacked_regressor, 'model/regression_stacking_model_'+model_name+'.joblib')

# 预测和评估
ytrain_pred_r = stacked_regressor.predict(xtrain_r)
mse_train = mean_squared_error(ytrain_r, ytrain_pred_r)
rmse_train = mse_train ** 0.5
r2_train = r2_score(ytrain_r, ytrain_pred_r)


ytest_pred_r = stacked_regressor.predict(xtest_r)
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







