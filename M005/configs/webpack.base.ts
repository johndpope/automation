import * as path from 'path';
import { Configuration, NoEmitOnErrorsPlugin, LoaderOptionsPlugin } from 'webpack';
import { CleanWebpackPlugin } from 'clean-webpack-plugin';

const configs: Configuration = {
  target: 'node',
  entry: './src/index',
  output: {
    filename: '[name].js',
    path: path.resolve(__dirname, '../build'),
    publicPath: '/',
    libraryTarget: 'commonjs2',
  },
  resolve: {
    extensions: ['.ts', '.js'],
    alias: {
      '@utils': path.resolve(__dirname, '../src/Z0'),
      '@typings': path.resolve(__dirname, '../typings'),
    },
  },
  externals: ['aws-sdk', 'aws-xray-sdk', 'moment', 'lodash', 'axios'],
  module: {
    rules: [
      {
        test: /\.ts$/,
        exclude: /node_modules/,
        use: [
          {
            loader: 'ts-loader',
          },
        ],
      },
    ],
  },
  plugins: [
    new NoEmitOnErrorsPlugin(),
    new LoaderOptionsPlugin({
      debug: false,
    }),
    new CleanWebpackPlugin(),
  ],
  bail: true,
};

export default configs;
