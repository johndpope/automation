import { ScheduledEvent } from 'aws-lambda';
import app from './app';

// イベント入口
export const handler = async (event: ScheduledEvent) => {
  // イベントデータ
  console.log(event);
  // 環境変数
  console.log(process.env);

  try {
    const res = await app(event);

    // 処理結果
    console.log(res);

    return res;
  } catch (error) {
    console.log(error);

    return error;
  }
};
