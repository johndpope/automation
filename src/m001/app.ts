import { ScheduledEvent } from 'aws-lambda';
import { CloudWatchLogs } from 'aws-sdk';
import * as XRay from 'aws-xray-sdk';
import * as AWSSDK from 'aws-sdk';
import * as moment from 'moment';

const AWS = XRay.captureAWS(AWSSDK);

const GROUPNAME_PREFIX = process.env.GROUPNAME_PREFIX as string;
const client = new AWS.CloudWatchLogs({ region: process.env.AWS_DEFAULT_REGION });

export default async (event: ScheduledEvent): Promise<void> => {
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

  const startTime = moment(event.time)
    .add(-15, 'm')
    .unix();
  const endTime = moment(event.time).unix();

  // 計算
  for (const idx in groups) {
    results.push(await task(groups[idx], startTime, endTime));
  }

  console.log('Query Results:', results);

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

  const request: CloudWatchLogs.Types.StartQueryRequest = {
    logGroupName: logGroup.logGroupName,
    queryString: 'stats count() | filter @message like /(ERROR)/',
    startTime,
    endTime,
  };

  console.log('request', request);

  const res = await client.startQuery(request).promise();

  // 検索失敗
  if (!res.queryId) return null;

  let queryResults: CloudWatchLogs.ResultField[][] | undefined;

  while (true) {
    // 検索待ち
    await sleep(500);

    const results = await client.getQueryResults({ queryId: res.queryId }).promise();

    if (results.status != 'Running') {
      queryResults = results.results;
      break;
    }
  }

  // 検索結果なし
  if (!queryResults || queryResults.length === 0) return null;

  console.log(queryResults);
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
