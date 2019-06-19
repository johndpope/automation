import * as XRay from 'aws-xray-sdk';
import * as AWSSDK from 'aws-sdk';

const AWS = XRay.captureAWS(AWSSDK);

export default async (event: any): Promise<void> => {
  const logLink = event.detail['additional-information'].logs['deep-link'];
  const project = event.detail['project-name'];

  const client = new AWS.Lambda({
    region: process.env.DEFAULT_REGION,
  });

  // 非同期でLambdaを呼び出す
  await client
    .invoke({
      FunctionName: 'PocketCards-M003',
      InvocationType: 'Event',
      Payload: JSON.stringify({
        message: `CodeBuild Error...\nProject: ${project}\nLog Link: <${logLink}|CloudWatch Logs>`,
      }),
    })
    .promise();
};
