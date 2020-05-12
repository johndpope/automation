import { CloudFront } from 'aws-sdk';

const DISTRIBUTION_ID = process.env.DISTRIBUTION_ID as string;

export default async (): Promise<void> => {
  const cloudFront = new CloudFront();

  await cloudFront
    .createInvalidation({
      DistributionId: DISTRIBUTION_ID,
      InvalidationBatch: {
        Paths: {
          Quantity: 1,
          Items: ['/'],
        },
        CallerReference: new Date().toUTCString(),
      },
    })
    .promise();
};
