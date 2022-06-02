#!/bin/bash

TODAY=$(date +'%Y.%m.%d')
echo Today $TODAY indices will be stored in S3.

ELASTIC_SEARCH_HOST="${node}"
ELASTIC_SEARCH_PORT="9200"
REPOSITORY_NAME="es_s3_backup"
SNAPSHOT_NAME="snapshot-${node}-"$TODAY

echo Starting Snapshot $SNAPSHOT_NAME
echo host ${node}
echo ELASTIC_SEARCH_HOST $ELASTIC_SEARCH_HOST

curl -X PUT "$ELASTIC_SEARCH_HOST:$ELASTIC_SEARCH_PORT/_snapshot/$REPOSITORY_NAME?pretty" -H 'Content-Type: application/json' -d'
{
"type": "s3",
"settings": {
    "bucket": "example-es-backup",
    "region": "ap-south-1"
   }
}
'

curl -X PUT "$ELASTIC_SEARCH_HOST:$ELASTIC_SEARCH_PORT/_snapshot/$REPOSITORY_NAME/$SNAPSHOT_NAME?wait_for_completion=true" -H 'Content-Type:application/json' -d'
{
  "indices": "products,payment,earning,blogs",
  "ignore_unavailable": true,
  "include_global_state": false
 }
'

echo Successfully completed storing "$SNAPSHOT_NAME" in S3

## weekly backup on 06:00pm Nepal Time
# 15 0 * * 5 /home/ubuntu/s3_backup_script.sh > /home/ubuntu/s3_backup_script.log 2>&1
