import { SNSEvent } from 'aws-lambda';
import app from './app';

// イベント入口
export const handler = async (event: SNSEvent) => {
  // イベントログ
  console.log(event);

  try {
    await app();

    return;
  } catch (error) {
    console.log(error);
    throw error;
  }
};
