echo "load predict data！"
gcloud auth activate-service-account --key-file=/home/bigdata/dataintegration-prod.json
#https://console.cloud.google.com/storage/browser/bq2azure-adls;tab=objects?project=devops-325206&prefix=&forceOnObjectsSortingFiltering=false
gcloud config set project airbrush-1324
# 提取数据到云端
gsutil rm -r gs://bq2azure-adls/dau_predict_data_ab
bq extract \
--destination_format NEWLINE_DELIMITED_JSON 'temp.dws_dz_dau_split_final_user_behave_extract_batch' \
gs://bq2azure-adls/dau_predict_data_ab/projecsdfsadfa_*.json
rm -rf /home/yunhui/dau/data_ab/predict/*
echo "数据下载，需要等待"
sleep 6
gsutil cp -r gs://bq2azure-adls/dau_predict_data_ab /home/yunhui/dau/data_ab/predict/
gsutil rm -r gs://bq2azure-adls/dau_predict_data_ab
