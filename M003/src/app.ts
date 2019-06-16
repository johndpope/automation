import { M003Event } from 'src';
import * as XRay from 'aws-xray-sdk';
import * as AWSSDK from 'aws-sdk';
import axios from 'axios';

// 初期化
const AWS = XRay.captureAWS(AWSSDK);

// 環境変数
const PROJECT_NAME = process.env.PROJECT_NAME as string;
const SLACK_URL_KEY = process.env.SLACK_URL_KEY as string;

export default async (event: M003Event): Promise<void> => {
  // 初期化
  const client = new AWS.SSM({
    region: process.env.DEFAULT_REGION,
  });

  const result = await client
    .getParameter({
      Name: `/${PROJECT_NAME}/${SLACK_URL_KEY}`,
    })
    .promise();

  if (!result.Parameter || !result.Parameter.Value) {
    throw new Error('Can not get parameters.');
  }

  const slackUrl = result.Parameter.Value;

  await axios.post(slackUrl, event.message);
};
