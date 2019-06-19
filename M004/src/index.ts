import { CloudWatchEvents } from 'aws-sdk';
import app from './app';

// イベント入口
export const handler = async (event: CloudWatchEvents) => {
  // イベントログ
  console.log(event);

  try {
    await app(event);

    console.log('Success');

    return;
  } catch (error) {
    console.log(error);
    throw error;
  }
};
