import express from "express";
import multer from "multer";
import { S3Client, PutObjectCommand } from "@aws-sdk/client-s3";
import cors from "cors";
import mysql from "mysql2/promise";

const app = express();
const upload = multer();

const s3 = new S3Client({
  region: process.env.AWS_REGION || "us-west-2"
});

const BUCKET_NAME = process.env.UPLOAD_BUCKET_NAME;
const CDN_DOMAIN = process.env.UPLOAD_CDN_DOMAIN || "https://uploads.kim-test.shop";

app.use(cors({
  origin: [
    "https://kim-test.shop",
    "https://www.kim-test.shop",
    "https://admin.kim-test.shop"
  ]
}));

app.get("/api/health", (req, res) => {
  res.status(200).send("ok");
});

app.post("/api/upload", upload.single("file"), async (req, res) => {
  let connection;

  try {
    const { username, email } = req.body;

    if (!username || !email || !req.file) {
      return res.status(400).json({
        message: "username, email, file are required"
      });
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

    const imageUrl = `${CDN_DOMAIN}/${key}`;

    connection = await mysql.createConnection({
      host: process.env.DB_HOST,
      port: Number(process.env.DB_PORT || 3306),
      user: process.env.DB_USER,
      password: process.env.DB_PASSWORD,
      database: process.env.DB_NAME
    });

    await connection.execute(
      `
      INSERT INTO user_uploads
      (username, email, image_key, image_url)
      VALUES (?, ?, ?, ?)
      `,
      [username, email, key, imageUrl]
    );

    res.json({
      status: "ok",
      message: "upload success",
      result: {
        username,
        email,
        imageUrl
      }
    });

  } catch (err) {
    console.error(err);

    res.status(500).json({
      status: "error",
      message: "upload failed"
    });

  } finally {
    if (connection) {
      await connection.end();
    }
  }
});

app.get("/api/admin/uploads", async (req, res) => {
  let connection;

  try {
    connection = await mysql.createConnection({
      host: process.env.DB_HOST,
      port: Number(process.env.DB_PORT || 3306),
      user: process.env.DB_USER,
      password: process.env.DB_PASSWORD,
      database: process.env.DB_NAME
    });

    const [rows] = await connection.execute(
      `
      SELECT id, username, email, image_url, created_at
      FROM user_uploads
      ORDER BY created_at DESC
      `
    );

    res.json({
      status: "ok",
      result: rows
    });
  } catch (err) {
    console.error(err);

    res.status(500).json({
      status: "error",
      message: " 업로드 목록 조회 실패 "
    });
  } finally {
    if (connection) {
      await connection.end();
    }
  }
});

app.get("/api/error-test", (req, res) => {
  res.status(500).json({
    status: "error",
    message: "intentional 5xx test"
  });
});

app.listen(3000, () => {
  console.log("upload api running on port 3000");
});
