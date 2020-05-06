![.github/workflows/deploy.yaml](https://github.com/pocket-cards/automation/workflows/.github/workflows/deploy.yaml/badge.svg?branch=master)

# 保守自動化

## 機能一覧

| 機能名 | 概要                                                             |
| ------ | ---------------------------------------------------------------- |
| M001   | 15 ごと、Lambda ログをスキャンし、エラーの場合、Slack に通知する |
| M002   | DynamoDB Table のバックアップ管理                                |
| M003   | Slack にメッセージ送信する                                       |
| M004   | CodeBuild 失敗の CloudWatch Event                                |
| M005   | CodePipeline 成功時、Slack へ通知                                |
| M006   | CloudFront Create Invalidation                                   |
