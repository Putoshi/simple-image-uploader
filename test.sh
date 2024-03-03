#!/bin/bash

# 画像ファイルのパス
IMAGE_PATH="image.jpg"
# APIのURL
API_URL="https://XXXXXXXX.execute-api.ap-northeast-1.amazonaws.com/v1/upload"

# 画像をBase64にエンコード
ENCODED_IMAGE=$(base64 -i $IMAGE_PATH)

# JSONデータを作成
JSON_DATA="{\"image\":\"${ENCODED_IMAGE}\"}"

# cURLを使用してAPIにPOSTリクエストを送信
curl -X POST $API_URL \
     -H "Content-Type: application/json" \
     -d $JSON_DATA

echo $JSON_DATA

