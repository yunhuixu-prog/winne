#!/bin/bash

#echo "正在激活yunhui的bash配置"
#source /home/yunhui/.bashrc

echo "start predict"
python -u /home/yunhui/dau/dau_split_sub_predict_bp.py '2024-09-08' 'else' 7 10 1 1 all all all all all all 3 50000
sleep 30
python -u /home/yunhui/dau/dau_split_sub_predict_bp.py '2024-09-08' 'else' 7 10 1 0 all all all all all all 3 50000
sleep 30
#python -u /home/yunhui/dau/dau_split_sub_predict_bp.py '2024-09-08' 'else' 7 10 0 0 1 1 all all all all 3 50000
#sleep 30
#python -u /home/yunhui/dau/dau_split_sub_predict_bp.py '2024-09-08' 'else' 7 10 0 0 1 0 all all all all 3 50000
#sleep 30
#python -u /home/yunhui/dau/dau_split_sub_predict_bp.py '2024-09-08' 'else' 7 10 0 0 0 0 1 1 all all 3 50000
#sleep 30
#python -u /home/yunhui/dau/dau_split_sub_predict_bp.py '2024-09-08' 'else' 7 10 0 0 0 0 1 0 all all 3 50000
#sleep 30
python -u /home/yunhui/dau/dau_split_sub_predict_bp.py '2024-09-08' 'trial_his' 1 4 all all all all all all all all 3 50000
sleep 30
python -u /home/yunhui/dau/dau_split_sub_predict_bp.py '2024-09-08' 'trial_his' 5 6 all all all all all all all all 3 50000
sleep 30
python -u /home/yunhui/dau/dau_split_sub_predict_bp.py '2024-09-08' 'trial_his' 7 10 1 all all all all all all all 3 50000
sleep 30
python -u /home/yunhui/dau/dau_split_sub_predict_bp.py '2024-09-08' 'trial_his' 7 10 0 0 1 all all all all all 3 50000
sleep 30
python -u /home/yunhui/dau/dau_split_sub_predict_bp.py '2024-09-08' 'trial_his' 7 10 0 0 0 0 1 all all all 3 50000
sleep 30
python -u /home/yunhui/dau/dau_split_sub_predict_bp.py '2024-09-08' 'sub_his' 1 6 all all all all all all all all 3 50000
sleep 30
python -u /home/yunhui/dau/dau_split_sub_predict_bp.py '2024-09-08' 'sub_his' 7 10 1 all all all all all all all 3 50000
sleep 30
python -u /home/yunhui/dau/dau_split_sub_predict_bp.py '2024-09-08' 'sub_his' 7 10 0 0 1 all all all all all 3 50000
sleep 30
python -u /home/yunhui/dau/dau_split_sub_predict_bp.py '2024-09-08' 'sub_his' 7 10 0 0 0 0 1 all all all 3 50000
sleep 30
python -u /home/yunhui/dau/dau_split_sub_predict_bp.py '2024-09-08' 'trial_now' 1 10 all all all all all all all all 3 50000
sleep 30

python -u /home/yunhui/dau/dau_split_sub_predict_bp.py '2024-09-09' 'else' 7 10 1 1 all all all all all all 3 50000
sleep 30
python -u /home/yunhui/dau/dau_split_sub_predict_bp.py '2024-09-09' 'else' 7 10 1 0 all all all all all all 3 50000
sleep 30
#python -u /home/yunhui/dau/dau_split_sub_predict_bp.py '2024-09-09' 'else' 7 10 0 0 1 1 all all all all 3 50000
#sleep 30
#python -u /home/yunhui/dau/dau_split_sub_predict_bp.py '2024-09-09' 'else' 7 10 0 0 1 0 all all all all 3 50000
#sleep 30
#python -u /home/yunhui/dau/dau_split_sub_predict_bp.py '2024-09-09' 'else' 7 10 0 0 0 0 1 1 all all 3 50000
#sleep 30
#python -u /home/yunhui/dau/dau_split_sub_predict_bp.py '2024-09-09' 'else' 7 10 0 0 0 0 1 0 all all 3 50000
#sleep 30
python -u /home/yunhui/dau/dau_split_sub_predict_bp.py '2024-09-09' 'trial_his' 1 4 all all all all all all all all 3 50000
sleep 30
python -u /home/yunhui/dau/dau_split_sub_predict_bp.py '2024-09-09' 'trial_his' 5 6 all all all all all all all all 3 50000
sleep 30
python -u /home/yunhui/dau/dau_split_sub_predict_bp.py '2024-09-09' 'trial_his' 7 10 1 all all all all all all all 3 50000
sleep 30
python -u /home/yunhui/dau/dau_split_sub_predict_bp.py '2024-09-09' 'trial_his' 7 10 0 0 1 all all all all all 3 50000
sleep 30
python -u /home/yunhui/dau/dau_split_sub_predict_bp.py '2024-09-09' 'trial_his' 7 10 0 0 0 0 1 all all all 3 50000
sleep 30
python -u /home/yunhui/dau/dau_split_sub_predict_bp.py '2024-09-09' 'sub_his' 1 6 all all all all all all all all 3 50000
sleep 30
python -u /home/yunhui/dau/dau_split_sub_predict_bp.py '2024-09-09' 'sub_his' 7 10 1 all all all all all all all 3 50000
sleep 30
python -u /home/yunhui/dau/dau_split_sub_predict_bp.py '2024-09-09' 'sub_his' 7 10 0 0 1 all all all all all 3 50000
sleep 30
python -u /home/yunhui/dau/dau_split_sub_predict_bp.py '2024-09-09' 'sub_his' 7 10 0 0 0 0 1 all all all 3 50000
sleep 30
python -u /home/yunhui/dau/dau_split_sub_predict_bp.py '2024-09-09' 'trial_now' 1 10 all all all all all all all all 3 50000
sleep 30

echo "预测完成！"