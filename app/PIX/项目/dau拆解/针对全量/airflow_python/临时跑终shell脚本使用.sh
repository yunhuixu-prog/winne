sudo su - #切换到root权限

cd /home/yunhui/bp
# 取选择日期的一年前训练(日期写当前，训练时间选取写的日期的一年前)
nohup bash bp/portrait_split_sub_model_bp.sh '2025-04-01' > bp/log/bp_365_model_train.log 2>&1 &
cat bp/log/bp_365_model_train.log
nohup bash portrait_split_sub_model_bp.sh '2025-04-01' > log/bp_365_model_train.log 2>&1 &
cat log/bp_365_model_train.log

# airbrush(还没跑，周五来不及跑了下周再跑)
nohup bash ab/portrait_split_sub_model_ab.sh '2025-04-01' > ab/log/ab_365_model_train.log 2>&1 &
cat ab/log/ab_365_model_train.log
nohup bash portrait_split_sub_model_ab.sh '2025-04-01' > log/ab_365_model_train.log 2>&1 &
cat log/ab_365_model_train.log

# 取选择日期当天预测
nohup bash bp/portrait_split_sub_predict_bp.sh '2024-10-01' > bp/log/bp_365_predict.log 2>&1 &
cat bp/log/bp_365_predict.log
nohup bash portrait_split_sub_predict_bp.sh '2024-10-01' > log/bp_365_predict.log 2>&1 &
cat log/bp_365_predict.log

nohup bash ab/portrait_split_sub_predict_ab.sh '2024-07-08' > ab/log/ab_365_predict.log 2>&1 &
cat ab/log/ab_365_predict.log
nohup bash portrait_split_sub_predict_ab.sh '2024-07-08' > log/ab_365_predict.log 2>&1 &
cat log/ab_365_predict.log

# dau+roas
nohup bash dau/dau_split_sub_predict_bp.sh '2024-10-31' > dau/log/bp_dau_365_predict.log 2>&1 &
cat dau/log/bp_dau_365_predict.log
10-31,11-05,11-08之后

nohup bash dau/dau_split_sub_predict_ab.sh '2024-10-18' > dau/log/ab_dau_365_predict.log 2>&1 &
cat dau/log/ab_dau_365_predict.log


ps -aux
ps -aux | grep "portrait_split_sub_model"
ps -aux | grep "portrait_split_sub_predict"
ps -aux | grep "dau_split_sub_predict"

kill -9 17272

free -h

#查看内存
free -m

#1.1,1.9,1.10,1.20,2.1,3.1,4.1,5.1,6.1,7.1,7.9,7.10
# 跑错误的单个调度
#5.1，1.10
nohup bash -u /home/yunhui/temp_predict_for_340010.sh > dau/log/dau_365_predict_temp.log 2>&1 &
cat dau/log/dau_365_predict_temp.log
# B+ dau预测
#nohup python -u /home/yunhui/dau/dau_split_sub_predict_bp.py '2024-11-30' 'else' 1 2 1 0 all all all all all all 3 50000 > dau/log/bp_dau_365_predict_temp.log 2>&1 &
nohup python -u /home/yunhui/dau/dau_split_sub_predict_bp.py '2024-12-01' 'else' 3 4 0 0 1 0 all all all all 3 30000 > dau/log/bp_dau_365_predict_temp.log 2>&1 &
nohup python -u /home/yunhui/dau/dau_split_sub_predict_bp.py '2024-11-30' 'else' 3 4 0 0 1 1 all all all all 3 30000 > dau/log/bp_dau_365_predict_temp.log 2>&1 &
nohup python -u /home/yunhui/dau/dau_split_sub_predict_bp.py '2024-11-30' 'else' 3 4 1 0 all all all all all all 3 30000 > dau/log/bp_dau_365_predict_temp.log 2>&1 &
nohup python -u /home/yunhui/dau/dau_split_sub_predict_bp.py '2024-11-30' 'else' 5 6 0 0 0 0 1 0 all all 3 30000 > dau/log/bp_dau_365_predict_temp.log 2>&1 &
nohup python -u /home/yunhui/dau/dau_split_sub_predict_bp.py '2024-11-30' 'else' 5 6 0 0 0 0 1 1 all all 3 30000 > dau/log/bp_dau_365_predict_temp.log 2>&1 &
nohup python -u /home/yunhui/dau/dau_split_sub_predict_bp.py '2024-11-30' 'else' 5 6 1 1 all all all all all all 3 30000 > dau/log/bp_dau_365_predict_temp.log 2>&1 &
nohup python -u /home/yunhui/dau/dau_split_sub_predict_bp.py '2024-11-30' 'else' 7 10 1 1 all all all all all all 3 30000 > dau/log/bp_dau_365_predict_temp.log 2>&1 &
cat dau/log/bp_dau_365_predict_temp.log
# AB dau预测
nohup python -u /home/yunhui/dau/dau_split_sub_predict_ab.py '2024-11-30' 'else' 1 2 1 all all all all all all all 3 30000 > dau/log/ab_dau_365_predict_temp.log 2>&1 &
nohup python -u /home/yunhui/dau/dau_split_sub_predict_ab.py '2024-11-30' 'else' 3 4 0 0 1 all all all all all 3 30000 > dau/log/ab_dau_365_predict_temp.log 2>&1 &
nohup python -u /home/yunhui/dau/dau_split_sub_predict_ab.py '2024-11-30' 'else' 1 2 1 all all all all all all all 3 30000 > dau/log/ab_dau_365_predict_temp.log 2>&1 &
nohup python -u /home/yunhui/dau/dau_split_sub_predict_ab.py '2024-11-30' 'else' 5 6 0 0 0 0 1 0 all all 3 30000 > dau/log/ab_dau_365_predict_temp.log 2>&1 &
nohup python -u /home/yunhui/dau/dau_split_sub_predict_ab.py '2024-11-30' 'else' 5 6 0 0 0 0 1 1 all all 3 30000 > dau/log/ab_dau_365_predict_temp.log 2>&1 &
nohup python -u /home/yunhui/dau/dau_split_sub_predict_ab.py '2024-11-30' 'else' 7 10 0 0 0 0 1 0 all all 3 30000 > dau/log/ab_dau_365_predict_temp.log 2>&1 &
nohup python -u /home/yunhui/dau/dau_split_sub_predict_ab.py '2024-11-30' 'else' 7 10 0 0 0 0 1 1 all all 3 30000 > dau/log/ab_dau_365_predict_temp.log 2>&1 &
#nohup python -u /home/yunhui/dau/dau_split_sub_predict_ab.py '2024-10-04' 'trial_his' 1 4 all all all all all all all all 3 30000 > dau/log/ab_dau_365_predict_temp.log 2>&1 &
cat dau/log/ab_dau_365_predict_temp.log
# B+ 全量预测
#nohup python -u /home/yunhui/bp/portrait_split_sub_predict_bp.py '2024-10-03' 'trial_his' 7 10 0 0 0 0 1 all all all 3 50000 > bp/log/bp_365_predict_temp.log 2>&1 &
#nohup python -u /home/yunhui/bp/portrait_split_sub_predict_bp.py '2024-10-03' 'trial_his' 7 10 1 all all all all all all all 3 50000 > bp/log/bp_365_predict_temp.log 2>&1 &
nohup python -u /home/yunhui/bp/portrait_split_sub_predict_bp.py '2024-10-03' 'else' 7 10 0 0 0 0 0 0 0 0 3 50000 > bp/log/bp_365_predict_temp.log 2>&1 &
cat bp/log/bp_365_predict_temp.log
# AB 全量预测
nohup python -u /home/yunhui/ab/portrait_split_sub_predict_ab.py '2024-08-29' 'sub_his' 1 6 all all all all all all all all 3 50000 > ab/log/ab_365_predict_temp.log 2>&1 &
cat ab/log/ab_365_predict_temp.log


# B+ 训练
nohup python -u /home/yunhui/bp/portrait_split_sub_model_bp.py '2024-11-01' 'else' 1 2 1 1 all all all all all all 100000 400000 3 > bp/log/bp_365_model_temp.log 2>&1 &
nohup python -u /home/yunhui/bp/portrait_split_sub_model_bp.py '2024-11-01' 'else' 1 2 1 0 all all all all all all 100000 400000 3 > bp/log/bp_365_model_temp.log 2>&1 &
nohup python -u /home/yunhui/bp/portrait_split_sub_model_bp.py '2024-11-01' 'else' 3 4 1 1 all all all all all all 100000 400000 3 > bp/log/bp_365_model_temp.log 2>&1 &
nohup python -u /home/yunhui/bp/portrait_split_sub_model_bp.py '2024-11-01' 'else' 3 4 1 0 all all all all all all 100000 400000 3 > bp/log/bp_365_model_temp.log 2>&1 &
cat /home/yunhui/bp/log/bp_365_model_temp.log
# AB 训练
cat ab/log/ab_365_model_temp.log
# 调度
#bash /home/yunhui/bp/test_airflow.sh '2023-07-15'
##source /home/yunhui/bp/test_airflow.sh '2023-07-15'
#ps -aux | grep "test_airflow.sh"
sudo su - #切换到root权限
echo 3 > /proc/sys/vm/drop_caches
ps -aux --sort=-rss
ps -ef | grep python
ps -aux --sort=-rss | grep python
# 修改任务执行权限

/home/yunhui/bp/portrait_split_sub_predict_bp.sh {{ (execution_date + macros.timedelta(hours=8) + macros.timedelta(days=5) ) .strftime("%Y-%m-%d") }}
bash /home/yunhui/bp/portrait_split_sub_predict_bp.sh 2024-07-10

/home/yunhui/ab/portrait_split_sub_predict_ab.sh {{ (execution_date + macros.timedelta(hours=8) + macros.timedelta(days=5) ) .strftime("%Y-%m-%d") }}
bash /home/yunhui/ab/portrait_split_sub_predict_ab.sh 2024-07-10


chmod 700 portrait_split_sub_predict_ab.py
ps -aux | grep "portrait_split_sub_predict_bp.sh"
ps -aux | grep "portrait_split_sub_predict_ab.sh"
ps -aux | grep "portrait_split_sub_predict"
ps -aux | grep "portrait_split_sub"
# 模型训练调度-服务器上
crontab -e

# 每月1号10点
0 10 1 * * nohup bash /home/yunhui/bp/portrait_split_sub_model_bp.sh `date +"\%Y-\%m-\%d"` >> /home/yunhui/bp/log/bp_365_model_train_`date +"\%Y-\%m-\%d"`.log 2>&1
0 10 15 * * nohup bash /home/yunhui/ab/portrait_split_sub_model_ab.sh `date +"\%Y-\%m-\%d"` >> /home/yunhui/ab/log/ab_365_model_train_`date +"\%Y-\%m-\%d"`.log 2>&1

# test
0 10 * * * nohup bash /home/yunhui/bp/test_airflow.sh `date +"\%Y-\%m-\%d"` >> /home/yunhui/bp/log/test_`date +"\%Y-\%m-\%d"`.log 2>&1
* * * * * nohup bash /home/yunhui/bp/test_airflow.sh `date +"\%Y-\%m-\%d"` >> /home/yunhui/bp/log/test_`date +"\%Y-\%m-\%d"`.log 2>&1
* * * * * ls -l >> /home/yunhui/testcron.log


bash /home/yunhui/bp/test_airflow.sh "2024-07-15"

crontab -l
