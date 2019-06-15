import { ScheduledEvent } from 'aws-lambda';
import app from './app';
import * as fs from 'fs';

// イベント入口
export const handler = async (event: ScheduledEvent) => {
  // イベントデータ
  console.log(event);
  // 環境変数
  console.log(process.env);

  var moduleDir = process.env.LAMBDA_RUNTIME_DIR + '/node_modules';
  fs.readdir(moduleDir, function(err, files) {
    if (err) {
      console.error('ERROR!');
    } else {
      console.log(files);
    }
  });

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
