# 该文件位于/home/yunhui/ab/portrait_split_sub_model_ab.sh
# python训练文件位于/home/yunhui/ab/portrait_split_sub_model_ab.py
# 训练的模型位于/home/yunhui/ab/model/
# python每次训练拉取的临时数据位于/home/yunhui/ab/data/train/train_data_ab/
# python每次训练拉取的shell脚本位于/home/yunhui/ab/load_train_data_ab.sh

# !/bin/bash
# 依次训练模型（包括评估）
echo "Shell 传递参数！"
echo "date=:$1"
date="$1"

echo "正在激活yunhui的bash配置"
source /home/yunhui/.bashrc

echo "start train model"

python -u /home/yunhui/ab/portrait_split_sub_model_ab.py ${date} 'else' 1 2 1 all all all all all all all 200000 800000 3
sleep 30
python -u /home/yunhui/ab/portrait_split_sub_model_ab.py ${date} 'else' 3 4 1 all all all all all all all 200000 800000 3
sleep 30
python -u /home/yunhui/ab/portrait_split_sub_model_ab.py ${date} 'else' 3 4 0 0 1 all all all all all 200000 800000 3
sleep 30
python -u /home/yunhui/ab/portrait_split_sub_model_ab.py ${date} 'else' 5 6 1 all all all all all all all 200000 600000 3
sleep 30
python -u /home/yunhui/ab/portrait_split_sub_model_ab.py ${date} 'else' 5 6 0 0 1 all all all all all 200000 600000 3
sleep 30
python -u /home/yunhui/ab/portrait_split_sub_model_ab.py ${date} 'else' 5 6 0 0 0 0 1 1 all all 200000 600000 3
sleep 30
python -u /home/yunhui/ab/portrait_split_sub_model_ab.py ${date} 'else' 5 6 0 0 0 0 1 0 all all 200000 600000 3
sleep 30
python -u /home/yunhui/ab/portrait_split_sub_model_ab.py ${date} 'else' 5 6 0 0 0 0 0 0 all all 200000 600000 3
sleep 30
python -u /home/yunhui/ab/portrait_split_sub_model_ab.py ${date} 'else' 7 10 1 1 all all all all all all 200000 600000 3
sleep 30
python -u /home/yunhui/ab/portrait_split_sub_model_ab.py ${date} 'else' 7 10 1 0 all all all all all all 200000 600000 3
sleep 30
python -u /home/yunhui/ab/portrait_split_sub_model_ab.py ${date} 'else' 7 10 0 0 1 1 all all all all 200000 600000 3
sleep 30
python -u /home/yunhui/ab/portrait_split_sub_model_ab.py ${date} 'else' 7 10 0 0 1 0 all all all all 200000 600000 3
sleep 30
python -u /home/yunhui/ab/portrait_split_sub_model_ab.py ${date} 'else' 7 10 0 0 0 0 1 1 all all 200000 600000 3
sleep 30
python -u /home/yunhui/ab/portrait_split_sub_model_ab.py ${date} 'else' 7 10 0 0 0 0 1 0 all all 200000 600000 3
sleep 30
python -u /home/yunhui/ab/portrait_split_sub_model_ab.py ${date} 'else' 7 10 0 0 0 0 0 0 1 1 200000 600000 3
sleep 30
python -u /home/yunhui/ab/portrait_split_sub_model_ab.py ${date} 'else' 7 10 0 0 0 0 0 0 1 0 200000 600000 3
sleep 30
python -u /home/yunhui/ab/portrait_split_sub_model_ab.py ${date} 'else' 7 10 0 0 0 0 0 0 0 0 200000 600000 3
sleep 30
python -u /home/yunhui/ab/portrait_split_sub_model_ab.py ${date} 'trial_his' 1 4 all all all all all all all all 200000 800000 3
sleep 30
python -u /home/yunhui/ab/portrait_split_sub_model_ab.py ${date} 'trial_his' 5 6 all all all all all all all all 200000 600000 3
sleep 30
python -u /home/yunhui/ab/portrait_split_sub_model_ab.py ${date} 'trial_his' 7 10 1 all all all all all all all 200000 600000 3
sleep 30
python -u /home/yunhui/ab/portrait_split_sub_model_ab.py ${date} 'trial_his' 7 10 0 0 1 all all all all all 200000 600000 3
sleep 30
python -u /home/yunhui/ab/portrait_split_sub_model_ab.py ${date} 'trial_his' 7 10 0 0 0 0 1 all all all 200000 600000 3
sleep 30
python -u /home/yunhui/ab/portrait_split_sub_model_ab.py ${date} 'trial_his' 7 10 0 0 0 0 0 0 1 all 200000 600000 3
sleep 30
python -u /home/yunhui/ab/portrait_split_sub_model_ab.py ${date} 'trial_his' 7 10 0 0 0 0 0 0 0 0 200000 600000 3
sleep 30
python -u /home/yunhui/ab/portrait_split_sub_model_ab.py ${date} 'sub_his' 1 6 all all all all all all all all 200000 600000 3
sleep 30
python -u /home/yunhui/ab/portrait_split_sub_model_ab.py ${date} 'sub_his' 7 10 1 all all all all all all all 200000 600000 3
sleep 30
python -u /home/yunhui/ab/portrait_split_sub_model_ab.py ${date} 'sub_his' 7 10 0 0 1 all all all all all 200000 600000 3
sleep 30
python -u /home/yunhui/ab/portrait_split_sub_model_ab.py ${date} 'sub_his' 7 10 0 0 0 0 1 all all all 200000 600000 3
sleep 30
python -u /home/yunhui/ab/portrait_split_sub_model_ab.py ${date} 'sub_his' 7 10 0 0 0 0 0 0 1 all 200000 600000 3
sleep 30
python -u /home/yunhui/ab/portrait_split_sub_model_ab.py ${date} 'sub_his' 7 10 0 0 0 0 0 0 0 0 200000 600000 3
sleep 30
python -u /home/yunhui/ab/portrait_split_sub_model_ab.py ${date} 'trial_now' 1 10 all all all all all all all all 200000 600000 3


echo "预测完成"