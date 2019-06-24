import * as XRay from 'aws-xray-sdk';
import * as AWSSDK from 'aws-sdk';
import axios from 'axios';
import { M003Event } from './index';

// 初期化
const AWS = XRay.captureAWS(AWSSDK);

// 環境変数
const SLACK_URL_KEY = process.env.SLACK_URL_KEY as string;

export default async (event: M003Event): Promise<void> => {
  // 初期化
  const client = new AWS.SSM({
    region: process.env.DEFAULT_REGION,
  });

  const result = await client
    .getParameter({
      Name: SLACK_URL_KEY,
    })
    .promise();

  if (!result.Parameter || !result.Parameter.Value) {
    throw new Error('Can not get parameters.');
  }

  const slackUrl = result.Parameter.Value;

  // Slackにメッセージに送信する
  await axios.post(slackUrl, {
    text: event.message,
  });
};
