import { SNSEvent } from 'aws-lambda';
import { CloudWatchLogs } from 'aws-sdk';
import * as XRay from 'aws-xray-sdk';
import * as AWSSDK from 'aws-sdk';
import * as moment from 'moment';

const AWS = XRay.captureAWS(AWSSDK);

const GROUPNAME_PREFIX = process.env.GROUPNAME_PREFIX as string;
const client = new AWS.CloudWatchLogs({ region: process.env.AWS_DEFAULT_REGION });

export default async (event: SNSEvent): Promise<void> => {
  // パラメータチェック
  if (event.Records.length === 0) {
    return;
  }

  const groupList = await client.describeLogGroups({ logGroupNamePrefix: GROUPNAME_PREFIX }).promise();
  let logGroups = groupList.logGroups;

  // 対象のロググループが存在しない
  if (!logGroups || logGroups.length === 0) {
    return;
  }

  const logTasks = logGroups.map(async item => {
    const result = await client.describeLogStreams({ logGroupName: item.logGroupName as string }).promise();

    return result.logStreams && result.logStreams.length > 0 ? item : null;
  });

  // 対象
  const groups = ((await Promise.all(logTasks)).filter(item => item != null) as unknown) as CloudWatchLogs.LogGroup[];
  const results: (string | null)[] = [];

  console.log(groups);

  const record = event.Records[0];
  const time = record.Sns.Timestamp;
  const startTime = moment(time)
    .add(-1, 'm')
    .unix();
  const endTime = moment(time).unix();

  // 計算
  for (const idx in groups) {
    results.push(await task(groups[idx], startTime, endTime));
  }

  const messages: string[] = ['Lambda Error... Functons:'];

  // メッセージ作成
  results.forEach(item => {
    if (item) messages.push(item);
  });

  // Slack経由送信
  await send(messages.join('\n'));
};

const task = async (logGroup: CloudWatchLogs.LogGroup, startTime: number, endTime: number) => {
  if (!logGroup.logGroupName) return null;

  const res = await client
    .startQuery({
      logGroupName: logGroup.logGroupName,
      queryString: 'fields @message | limit 1 | filter @message like /(Exception|error|fail)/',
      startTime,
      endTime,
      limit: 1,
    })
    .promise();

  // 検索失敗
  if (!res.queryId) return null;

  let queryResults: CloudWatchLogs.ResultField[][] | undefined;

  while (true) {
    // 検索待ち
    await sleep(100);

    const results = await client.getQueryResults({ queryId: res.queryId }).promise();

    if (results.status != 'Running') {
      queryResults = results.results;
      break;
    }
  }

  // 検索結果なし
  if (!queryResults) return null;

  return logGroup.logGroupName.replace('/aws/lambda/', '');
};

const send = async (message: string) => {
  const client = new AWS.Lambda({
    region: process.env.AWS_DEFAULT_REGION,
  });

  await client
    .invoke({
      FunctionName: process.env.CALL_SLACK_FUNCTION as string,
      InvocationType: 'Event',
      Payload: JSON.stringify({
        message: message,
      }),
    })
    .promise();
};

const sleep = (time: number) => new Promise(resolve => setTimeout(resolve, time));
