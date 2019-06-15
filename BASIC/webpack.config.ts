import * as path from 'path';
import { Configuration, LoaderOptionsPlugin } from 'webpack';
import * as merge from 'webpack-merge';
import baseConfig from '../configs/webpack.base';

const prod: Configuration = {
  mode: 'production',
  output: {
    path: path.resolve(__dirname, './build'),
  },
  optimization: {
    minimize: false,
  },
  plugins: [
    new LoaderOptionsPlugin({
      debug: false,
    }),
  ],
};

export default merge(baseConfig, prod);