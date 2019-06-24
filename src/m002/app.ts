import { ScheduledEvent } from 'aws-lambda';
import * as XRay from 'aws-xray-sdk';
import * as AWSSDK from 'aws-sdk';
import { DynamoDB } from 'aws-sdk';
import * as _ from 'lodash';
import * as moment from 'moment';

const AWS = XRay.captureAWS(AWSSDK);
const REGION = (process.env.REGION ? process.env.REGION : process.env.DEFAULT_REGION) as string;
const GENERATIONS = Number(process.env.BACKUP_GENERATIONS ? process.env.BACKUP_GENERATIONS : '7');
const TABLES = process.env.TABLES ? process.env.TABLES : '';

let client: DynamoDB;

export default async (event: ScheduledEvent) => {
  // 初期化
  if (!client) {
    client = new AWS.DynamoDB({
      region: REGION,
    });
  }

  // 対象が存在しない場合、処理終了
  if (TABLES.length === 0) return;

  const tables = TABLES.split(',');

  // バックアップタスクを作成する
  const tasks = tables.map(item =>
    client
      .createBackup({
        TableName: item,
        BackupName: moment().format('YYYYMMDDHHmmss'),
      })
      .promise()
  );

  // バックアップ作成
  await Promise.all(tasks);

  // バックアップ世代管理
  const backups = await client
    .listBackups({
      BackupType: 'USER',
    })
    .promise();

  const summaries = backups.BackupSummaries;

  console.log('バックアップ情報', summaries);

  // 最大世代数より小さいの場合、処理終了
  if (!summaries || summaries.length < GENERATIONS) return;

  console.log('世代数管理開始');
  const delTasks = tables.map(tableName => {
    let targets = summaries.filter(summary => summary.TableName === tableName);

    console.log(`対象テーブル：${tableName}、世帯数：${targets.length}`);

    // 最大世代数以下の場合、処理終了
    if (targets.length <= GENERATIONS) {
      return;
    }

    // バックアップ時間の昇順でソートする
    _.sortBy(targets, 'BackupCreationDateTime');

    // 削除対象を作成する
    targets = targets.splice(0, targets.length - GENERATIONS);

    console.log('削除対象', targets);

    return targets.map(item =>
      client
        .deleteBackup({
          BackupArn: item.BackupArn as string,
        })
        .promise()
    );
  });

  console.log('削除処理開始');
  // 削除処理開始
  await Promise.all(delTasks);
  console.log('削除処理終了');

  console.log('世代数管理終了');
};
