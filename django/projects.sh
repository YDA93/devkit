# FeCare
alias fecare-proxy='./cloud_sql_proxy -instances="fe-sale:europe-west3:fesale-cloud"=tcp:3306'
alias fecare-sync-static='gsutil -o "GSUtil:parallel_process_count=1" -m rsync -r -j html,txt,css,js ./static gs://fecare-static-bucket/'

# FeSale
alias fesale-proxy='./cloud_sql_proxy -instances="fe-sale:europe-west3:fesale-cloud"=tcp:3306'
alias fesale-sync-static='gsutil -o "GSUtil:parallel_process_count=1" -m rsync -r -j html,txt,css,js ./static gs://fesale-static/'
