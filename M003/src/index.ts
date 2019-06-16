import app from './app';

// イベント入口
export const handler = async (event: M003Event) => {
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

export interface M003Event {
  message: string;
}
