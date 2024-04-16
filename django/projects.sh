# FeCare
alias fecare-proxy='./cloud-sql-proxy --port 3306 fecare-dae2d:europe-west3:fecare-cloud'
alias fecare-sync-static='gsutil -o "GSUtil:parallel_process_count=1" -m rsync -r -j html,txt,css,js ./static gs://fecare-static-bucket/'
alias fecare-set-cross-origin='gsutil cors set cross-origin.json gs://fecare-media-bucket && gsutil cors set cross-origin.json gs://fecare-static-bucket'
alias fecare-set-public-read-to-buckets='gsutil defacl set public-read gs://fecare-static-bucket && gsutil defacl set public-read gs://fecare-media-bucket'
alias fecare-cloud-build='gcloud builds submit --config cloudmigrate.yaml --substitutions _INSTANCE_NAME=fecare-cloud,_REGION=europe-west3'
alias fecare-deploy-first-time='gcloud run deploy fecare-service --platform managed --region europe-west3 --image gcr.io/fecare-dae2d/fecare-service --add-cloudsql-instances fecare-dae2d:europe-west3:fecare-cloud --allow-unauthenticated'
alias fecare-redeploy='gcloud run deploy fecare-service --platform managed --region europe-west3 --image gcr.io/fecare-dae2d/fecare-service'
alias fecare-update-service-url-env='SERVICE_URL=$(gcloud run services describe fecare-service --platform managed --region europe-west3 --format "value(status.url)") && gcloud run services update fecare-service --platform managed --region europe-west3 --set-env-vars CLOUDRUN_SERVICE_URL=$SERVICE_URL'
alias fecare-build-and-deploy-first-time='fecare-cloud-build && fecare-deploy-first-time && fecare-update-service-url-env'
alias fecare-build-and-redeploy='fecare-cloud-build && fecare-redeploy && fecare-update-service-url-env'
# FeSale
alias fesale-proxy='./cloud-sql-proxy --port 3306 fe-sale:europe-west3:fesale-cloud'
alias fesale-sync-static='gsutil -o "GSUtil:parallel_process_count=1" -m rsync -r -j html,txt,css,js ./static gs://fesale-static/'
