/*jshint esversion: 6 */

const webpack = require('webpack');

module.exports = {
  context: __dirname,
  entry: {
    vendor: [
      'babel-polyfill',
      'jquery',
      'jquery-ujs',
      'react-dom',
      'react-dom/server',
      'react',
      'es5-shim/es5-shim',
      'es5-shim/es5-sham',
    ],
    app: [
      './app/assets/javascripts/components.jsx',
    ],
  },
  output: {
    filename: '[name]-bundle.js',
    path: './app/assets/webpack',
  },
  resolve: {
    extensions: ['', '.js', '.jsx'],
  },
  plugins: [
    new webpack.DefinePlugin({
      'process.env': {
        NODE_ENV: JSON.stringify("development"), // the production build doesn't seem to work...?
      },
    }),
    new webpack.optimize.CommonsChunkPlugin({
      name: 'vendor',
      filename: 'vendor-bundle.js',
      minChunks: Infinity,
    }),
  ],
  module: {
    loaders: [
      // For react-rails we need to expose these deps to global object
      {
        test: /\.jsx?$/,
        loader: 'babel-loader',
        exclude: /node_modules/,
      },
      { test: require.resolve('jquery'), loader: 'expose?jQuery' },
      { test: require.resolve('jquery'), loader: 'expose?$' },
      {
        test: require.resolve('react'),
        loader: 'imports?shim=es5-shim/es5-shim&sham=es5-shim/es5-sham',
      },
      { test: require.resolve('react'), loader: 'expose?React' },
      { test: require.resolve('react-dom'), loader: 'expose?ReactDOM' },
      { test: require.resolve('react-dom/server'), loader: 'expose?ReactDOMServer' }
    ],
  },
};
