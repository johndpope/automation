import { CloudWatchLogsEvent } from 'aws-lambda';
import { SSM } from 'aws-sdk';
import axios from 'axios';

const PROJECT_NAME = process.env.PROJECT_NAME as string;
const SLACK_URL_KEY = process.env.SLACK_URL_KEY as string;

export default async (event: CloudWatchLogsEvent): Promise<void> => {
  const client = new SSM({
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

  // Slack Incoming Webhook URL
  const url = result.Parameter.Value;

  await axios.post(url, {
    text: 'AAAAAAAAAAAAAAAA',
  });
};
