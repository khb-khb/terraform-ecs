import express from "express";
import multer from "multer";
import { S3Client, PutObjectCommand } from "@aws-sdk/client-s3";

const app = express();
const upload = multer();

const s3 = new S3Client({
  region: process.env.AWS_REGION || "us-west-2"
});

const BUCKET_NAME = process.env.UPLOAD_BUCKET_NAME;
const CDN_DOMAIN = process.env.UPLOAD_CDN_DOMAIN || "https://uploads.kim-test.shop";

app.post("/upload", upload.single("file"), async (req, res) => {
  try {
    if (!req.file) {
      return res.status(400).json({ message: "file is required" });
    }

    const key = `www/${Date.now()}-${req.file.originalname}`;

    await s3.send(
      new PutObjectCommand({
        Bucket: BUCKET_NAME,
        Key: key,
        Body: req.file.buffer,
        ContentType: req.file.mimetype
      })
    );

    res.json({
      message: "upload success",
      key,
      url: `${CDN_DOMAIN}/${key}`
    });
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: "upload failed" });
  }
});

app.listen(3000, () => {
  console.log("upload api running on port 3000");
});