import { ScheduledEvent } from 'aws-lambda';
import app from './app';

// イベント入口
export const handler = async (event: ScheduledEvent) => {
  // イベントデータ
  console.log(event);

  try {
    const res = await app(event);

    // 処理結果
    console.log(res);

    return res;
  } catch (error) {
    console.log(error);

    throw error;
  }
};
