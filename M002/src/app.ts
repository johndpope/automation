import { ScheduledEvent } from 'aws-lambda';
import * as XRay from 'aws-xray-sdk';
import * as AWSSDK from 'aws-sdk';
import { DynamoDB } from 'aws-sdk';
import * as moment from 'moment';

const AWS = XRay.captureAWS(AWSSDK);
const REGION = (process.env.REGION ? process.env.REGION : process.env.DEFAULT_REGION) as string;
const TABLES = process.env.TABLES ? process.env.TABLES : '';

let client: DynamoDB;

export default async (event: ScheduledEvent) => {
  console.log('11111111', moment().format('YYYYMMDD'));
  // 初期化
  if (!client) {
    client = new AWS.DynamoDB({
      region: REGION,
    });
  }

  const tables = TABLES.split(',');

  // 対象が存在しない場合、処理終了
  if (tables.length === 0) return;

  // バックアップタスクを作成する
  const tasks = tables.map(item =>
    client
      .createBackup({
        TableName: item,
        BackupName: event.time,
      })
      .promise()
  );

  // バックアップ作成
  await Promise.all(tasks);
};
