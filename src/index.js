const AWS = require("aws-sdk");
const s3 = new AWS.S3();
const { v4: uuidv4 } = require("uuid");

exports.handler = async (event) => {
  // バケット名を指定
  const bucketName = process.env.BUCKET_NAME;

  try {
    console.log("event:", event);
    console.log("event.body:", event.body);

    // API Gatewayからのイベントを解析
    const body = JSON.parse(event.body);
    const imageContent = body.image; // 画像データ（base64エンコードされた文字列）
    const imageBuffer = Buffer.from(imageContent, "base64");

    // S3にアップロードするファイル名を生成
    const fileName = `uploads/${uuidv4()}.jpg`;
    console.log("fileName:", fileName);

    // S3に画像をアップロード
    const s3Response = await s3
      .putObject({
        Bucket: bucketName,
        Key: fileName,
        Body: imageBuffer,
        ContentType: "image/jpeg",
      })
      .promise();

    // レスポンスを返す
    return {
      statusCode: 200,
      body: JSON.stringify({
        message: "Image uploaded successfully",
        s3Response,
        uploadPath: `https://${bucketName}.s3.amazonaws.com/${fileName}`,
      }),
    };
  } catch (error) {
    console.error(error);
    return {
      statusCode: 500,
      body: JSON.stringify({
        message: "Failed to upload image",
        errorMessage: error.message,
      }),
    };
  }
};
