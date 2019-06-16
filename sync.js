const glob = require('glob');
const cpx = require('cpx');

const SRC_PATH = 'BASIC';
const ENTRY_NAME = '*.*';
const FUNCTION = process.env.FUNCTION;

const targets = glob.sync(`${SRC_PATH}/**/${ENTRY_NAME}`);
const filters = ['app.ts', 'index.ts', 'package.json', 'main.tf', 'webpack.prod.ts'];

targets.forEach(item => {
  const finded = filters.find(block => item.indexOf(block) !== -1);

  // Block対象ファイル
  if (finded !== undefined) {
    return;
  }

  const paths = item.replace(`${SRC_PATH}\/`, `${FUNCTION}\/`).split('/');

  // ファイルを削除する
  paths.pop();

  const dest = paths.join('/');

  // コピー
  cpx.copySync('./BASIC/configs/webpack.base.ts', './M003/configs/');
});
