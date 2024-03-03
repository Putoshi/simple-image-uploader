# 画像アップローダーのセットアップ手順

## 必要なツール
- AWS CLI
- Terraform

## 導入

### 1. ラムダ関数の準備
```
$cd ./src                           # ディレクトリに移動
$zip -r ../image-uploader.zip       # ラムダ関数のコードをzipファイルに圧縮します。
```


### 2. ラムダ関数のアップロード
```
$aws s3 cp image-uploader.zip s3://image-upload-bucket-4glp8l4h/
```

### 3. Terraformの初期化（初回のみ）
```
$terraform init
```

### 4. デプロイ前のリソース計画を確認
```
$terraform plan
```

### 5. リソースをデプロイ
```
$terraform apply
```


## APIキーの取得
デプロイ後、APIキーを取得
```
$terraform output -raw api_key_value
```