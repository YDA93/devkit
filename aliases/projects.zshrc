# FeCare
alias fecare-proxy='./cloud_sql_proxy -instances="fe-sale:europe-west3:fesale-cloud"=tcp:3306'
alias fecare-sync-static='gsutil -o "GSUtil:parallel_process_count=1" -m rsync -r -j html,txt,css,js ./static gs://fecare-static-bucket/'
alias fecare-code-django='code Desktop/dev/fecare-django/'
alias fecare-code-flutter='code Desktop/dev/fecare_flutter/'

# FeSale
alias fesale-proxy='./cloud_sql_proxy -instances="fe-sale:europe-west3:fesale-cloud"=tcp:3306'
alias fesale-sync-static='gsutil -o "GSUtil:parallel_process_count=1" -m rsync -r -j html,txt,css,js ./static gs://fesale-static/'
alias fesale-code-django='code Desktop/dev/fesale-django/'
alias fesale-code-flutter='code Desktop/dev/fesale_flutter/'