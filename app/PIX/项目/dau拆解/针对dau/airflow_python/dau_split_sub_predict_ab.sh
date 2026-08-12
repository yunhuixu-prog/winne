#!/bin/bash
# 该文件位于/home/yunhui/dau/dau_split_sub_predict_ab.sh
# python预测文件位于/home/yunhui/dau/dau_split_sub_predict_ab.py
# 训练的模型位于/home/yunhui/ab/model/
# python每次预测拉取的临时数据位于/home/yunhui/dau/data_ab/predict/dau_predict_data_ab/
# 预测云端地址gs://bq2azure-adls/dau_predict_data_ab
# python每次预测拉取的shell脚本位于/home/yunhui/dau/load_dau_predict_data_ab.sh

# 依次预测
echo "Shell 传递参数！"
echo "date=:$1"
date="$1"

echo "正在激活yunhui的bash配置"
source /home/yunhui/.bashrc

echo "start predict"
python -u /home/yunhui/dau/dau_split_sub_predict_ab.py ${date} 'else' 1 2 1 all all all all all all all 3 30000
sleep 30
python -u /home/yunhui/dau/dau_split_sub_predict_ab.py ${date} 'else' 3 4 1 all all all all all all all 3 30000
sleep 30
python -u /home/yunhui/dau/dau_split_sub_predict_ab.py ${date} 'else' 3 4 0 0 1 all all all all all 3 30000
sleep 30
python -u /home/yunhui/dau/dau_split_sub_predict_ab.py ${date} 'else' 5 6 1 all all all all all all all 3 30000
sleep 30
python -u /home/yunhui/dau/dau_split_sub_predict_ab.py ${date} 'else' 5 6 0 0 1 all all all all all 3 30000
sleep 30
python -u /home/yunhui/dau/dau_split_sub_predict_ab.py ${date} 'else' 5 6 0 0 0 0 1 1 all all 3 30000
sleep 30
python -u /home/yunhui/dau/dau_split_sub_predict_ab.py ${date} 'else' 5 6 0 0 0 0 1 0 all all 3 30000
sleep 30
python -u /home/yunhui/dau/dau_split_sub_predict_ab.py ${date} 'else' 5 6 0 0 0 0 0 0 all all 3 30000
sleep 30
python -u /home/yunhui/dau/dau_split_sub_predict_ab.py ${date} 'else' 7 10 1 1 all all all all all all 3 30000
sleep 30
python -u /home/yunhui/dau/dau_split_sub_predict_ab.py ${date} 'else' 7 10 1 0 all all all all all all 3 30000
sleep 30
python -u /home/yunhui/dau/dau_split_sub_predict_ab.py ${date} 'else' 7 10 0 0 1 1 all all all all 3 30000
sleep 30
python -u /home/yunhui/dau/dau_split_sub_predict_ab.py ${date} 'else' 7 10 0 0 1 0 all all all all 3 30000
sleep 30
python -u /home/yunhui/dau/dau_split_sub_predict_ab.py ${date} 'else' 7 10 0 0 0 0 1 1 all all 3 30000
sleep 30
python -u /home/yunhui/dau/dau_split_sub_predict_ab.py ${date} 'else' 7 10 0 0 0 0 1 0 all all 3 30000
sleep 30
#python -u /home/yunhui/dau/dau_split_sub_predict_ab.py ${date} 'else' 7 10 0 0 0 0 0 0 1 1 3 30000
#sleep 30
#python -u /home/yunhui/dau/dau_split_sub_predict_ab.py ${date} 'else' 7 10 0 0 0 0 0 0 1 0 3 30000
#sleep 30
#python -u /home/yunhui/dau/dau_split_sub_predict_ab.py ${date} 'else' 7 10 0 0 0 0 0 0 0 0 3 30000
#sleep 30
python -u /home/yunhui/dau/dau_split_sub_predict_ab.py ${date} 'trial_his' 1 4 all all all all all all all all 3 30000
sleep 30
python -u /home/yunhui/dau/dau_split_sub_predict_ab.py ${date} 'trial_his' 5 6 all all all all all all all all 3 30000
sleep 30
python -u /home/yunhui/dau/dau_split_sub_predict_ab.py ${date} 'trial_his' 7 10 1 all all all all all all all 3 30000
sleep 30
python -u /home/yunhui/dau/dau_split_sub_predict_ab.py ${date} 'trial_his' 7 10 0 0 1 all all all all all 3 30000
sleep 30
python -u /home/yunhui/dau/dau_split_sub_predict_ab.py ${date} 'trial_his' 7 10 0 0 0 0 1 all all all 3 30000
sleep 30
#python -u /home/yunhui/dau/dau_split_sub_predict_ab.py ${date} 'trial_his' 7 10 0 0 0 0 0 0 1 all 3 30000
#sleep 30
#python -u /home/yunhui/dau/dau_split_sub_predict_ab.py ${date} 'trial_his' 7 10 0 0 0 0 0 0 0 0 3 30000
#sleep 30
python -u /home/yunhui/dau/dau_split_sub_predict_ab.py ${date} 'sub_his' 1 6 all all all all all all all all 3 30000
sleep 30
python -u /home/yunhui/dau/dau_split_sub_predict_ab.py ${date} 'sub_his' 7 10 1 all all all all all all all 3 30000
sleep 30
python -u /home/yunhui/dau/dau_split_sub_predict_ab.py ${date} 'sub_his' 7 10 0 0 1 all all all all all 3 30000
sleep 30
python -u /home/yunhui/dau/dau_split_sub_predict_ab.py ${date} 'sub_his' 7 10 0 0 0 0 1 all all all 3 30000
sleep 30
#python -u /home/yunhui/dau/dau_split_sub_predict_ab.py ${date} 'sub_his' 7 10 0 0 0 0 0 0 1 all 3 30000
#sleep 30
#python -u /home/yunhui/dau/dau_split_sub_predict_ab.py ${date} 'sub_his' 7 10 0 0 0 0 0 0 0 0 3 30000
#sleep 30
python -u /home/yunhui/dau/dau_split_sub_predict_ab.py ${date} 'trial_now' 1 10 all all all all all all all all 3 30000
sleep 30

echo "预测完成"


