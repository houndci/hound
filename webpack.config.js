/*jshint esversion: 6 */

const webpack = require('webpack');

const nodeEnv = process.env.NODE_ENV || 'development';
const isProd = nodeEnv === 'production';

console.log(` preparing [${nodeEnv}] build - set NODE_ENV to 'development' or 'production' to change it accordingly`);

const plugins = [
  new webpack.optimize.CommonsChunkPlugin({
    name: 'vendor',
    minChunks: Infinity
  }),
  new webpack.DefinePlugin({
    'process.env': { NODE_ENV: JSON.stringify(nodeEnv) }
  })
];

if (isProd) {
  plugins.push(
    new webpack.LoaderOptionsPlugin({
      minimize: true,
      debug: false
    }),
    new webpack.optimize.UglifyJsPlugin({
      compress: {
        warnings: false,
        screw_ie8: true,
        conditionals: true,
        unused: true,
        comparisons: true,
        sequences: true,
        dead_code: true,
        evaluate: true,
        if_return: true,
        join_vars: true,
      },
      // Mangling would reduce the size of the bundle, but it made the deploys
      // crash on Heroku. The reason is yet unknown.
      // So, in lieu of that - let's disable it.
      mangle: false,
      output: {
        comments: false
      },
      sourceMap: false
    })
  );
}

module.exports = {
  context: __dirname,
  devtool: isProd ? false : 'inline-source-map',
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
      'lodash'
    ],
    app: [
      './app/assets/javascripts/components.jsx',
    ]
  },
  output: {
    filename: '[name]-bundle.js',
    path: __dirname + '/app/assets/webpack',
  },
  plugins,
  module: {
    rules: [
      {
        test: /\.(js|jsx)$/,
        exclude: /node_modules/,
        use: [
          {
            loader: 'babel-loader',
            options: {
              presets: [
                [ "es2015", {"modules": false} ],
                "stage-0",
                "stage-1",
                "stage-2",
                "react"
              ]
            }
          }
        ],
      },
      {
        test: require.resolve('jquery'),
        loader: 'expose-loader?jQuery',
      },
      {
        test: require.resolve('jquery'),
        loader: 'expose-loader?$',
      },
      {
        test: require.resolve('react'),
        loader: 'imports-loader?shim=es5-shim/es5-shim&sham=es5-shim/es5-sham',
      },
      {
        test: require.resolve('react'),
        loader: 'expose-loader?React'
      },
      {
        test: require.resolve('react-dom'),
        loader: 'expose-loader?ReactDOM'
      },
      {
        test: require.resolve('react-dom/server'),
        loader: 'expose-loader?ReactDOMServer'
      }
    ],
  }
};
