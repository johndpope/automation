import * as XRay from 'aws-xray-sdk';
import * as AWSSDK from 'aws-sdk';

const AWS = XRay.captureAWS(AWSSDK);

export default async (event: any): Promise<void> => {
  const project = event.detail.pipeline;

  const client = new AWS.Lambda({
    region: process.env.DEFAULT_REGION,
  });

  // 非同期でLambdaを呼び出す
  await client
    .invoke({
      FunctionName: process.env.CALL_SLACK_FUNCTION as string,
      InvocationType: 'Event',
      Payload: JSON.stringify({
        message: `Code Pipeline Build Success...\nProject: ${project}`,
      }),
    })
    .promise();
};
