import { CloudWatchLogsEvent, Callback } from 'aws-lambda';
import app from './app';

// イベント入口
export const handler = (event: CloudWatchLogsEvent, _: any, callback: Callback<any>) => {
  // イベントログ
  console.log(event);

  app(event)
    .then(() => {
      console.log('Success');
      // 終了ログ
      callback(null, 'Success');
    })
    .catch(err => {
      // エラーログ
      console.log('Error:', err);
      callback(err, null);
    });
};
