프로젝트 소개
  ECS Blue/Green Deployment Architecture
  AWS ECS, ALB, CodeDeploy, Github Actions 기반 CI/CD 자동화 및 무중단 배포 환경 구축 프로젝트

Architecture
<img width="1064" height="928" alt="image" src="https://github.com/user-attachments/assets/ff08117c-b580-4294-84b3-dc39f2d41142" />

Terraform Module 구조
  terraform/
   - acm
   - alb
   - autoscaling
   - cloudfront
   - cloudwatch_loggroup
   - cloudwatch_monitoring
   ├─ codedeploy
   ├─ ec2
   ├─ ecr
   ├─ ecs
   ├─ eventbridge
   ├─ iam_role
   ├─ rds
   ├─ route53
   ├─ s3
   ├─ secrets_manager
   ├─ security_group
   ├─ sns
   ├─ vpc

CI/CD Flow
  Github Push - Github Actions Build - ECR Push - CodeDeploy ECS Deployment - Blue/Green Traffic Shift

주요 기능
  - ECS Blue/Green 무중단 배포
  - CloudWatch Alarm 기반 자동 Rollback
  - Auto Scaling 기반 ECS 확장
  - Slack 기반 배포/장애 알림
  - S3 + CloudFront 기반 정적 리소스 구성

장애 대응
  - ALB 5XX 기반 CloudWatch Alarm 감지
  - CodeDeploy 배포 자동 중단
  - 기존 Task Set 자동 Rollback
  - Slack 실시간 알림

향후 개선 사항
  - S3 Gateway VPC Endpoint 기반 NAT 비용 최적화
  - Presigned URL 기반 Direct Upload
  - Prometheus / Grafana 기반 Observability 강화
  - Route53 Failover 기반 DR 구조 개선
