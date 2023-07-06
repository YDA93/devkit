# FeCare
alias fecare-proxy='./cloud_sql_proxy -instances="fe-sale:europe-west3:fesale-cloud"=tcp:3306'
alias fecare-sync-static='gsutil -o "GSUtil:parallel_process_count=1" -m rsync -r -j html,txt,css,js ./static gs://fecare-static-bucket/'
alias code-fecare-django='code Desktop/dev/fecare-django/'
alias code-fecare-flutter='code Desktop/dev/fecare_flutter/'

# FeSale
alias fesale-proxy='./cloud_sql_proxy -instances="fe-sale:europe-west3:fesale-cloud"=tcp:3306'
alias fesale-sync-static='gsutil -o "GSUtil:parallel_process_count=1" -m rsync -r -j html,txt,css,js ./static gs://fesale-static/'
alias code-fesale-django='code Desktop/dev/fesale-django/'
alias code-fesale-flutter='code Desktop/dev/fesale_flutter/'
alias fesale-build='gcloud builds submit --config cloudmigrate.yaml --substitutions _INSTANCE_NAME=fesale-cloud,_REGION=europe-west3'
alias fesale-deploy='gcloud run deploy fesale-service --platform managed --region europe-west1 --image gcr.io/fe-sale/fesale-service --add-cloudsql-instances fe-sale:europe-west3:fesale-cloud --allow-unauthenticated'
alias fesale-redeploy='gcloud run deploy fesale-service --platform managed --region europe-west1 --image gcr.io/fe-sale/fesale-service'
alias fesale-redeploy-build='gcloud builds submit --config cloudmigrate.yaml --substitutions _INSTANCE_NAME=fesale-cloud,_REGION=europe-west3 && gcloud run deploy fesale-service --platform managed --region europe-west1 --image gcr.io/fe-sale/fesale-service'