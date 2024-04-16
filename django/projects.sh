# FeCare
alias fecare-proxy='./cloud-sql-proxy --port 3306 fecare-dae2d:europe-west3:fecare-cloud'
alias fecare-sync-static='gsutil -o "GSUtil:parallel_process_count=1" -m rsync -r -j html,txt,css,js ./static gs://fecare-static-bucket/'

# FeSale
alias fesale-proxy='./cloud-sql-proxy --port 3306 fe-sale:europe-west3:fesale-cloud'
alias fesale-sync-static='gsutil -o "GSUtil:parallel_process_count=1" -m rsync -r -j html,txt,css,js ./static gs://fesale-static/'
