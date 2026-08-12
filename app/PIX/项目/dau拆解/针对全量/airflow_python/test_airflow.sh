#!/bin/bash

echo "Shell 传递参数！"
echo "date=:$1"
date="$1"

echo "正在激活yunhui的bash配置"
source /home/yunhui/.bashrc

echo "start predict"
python -u /home/yunhui/bp/test.py ${date}
