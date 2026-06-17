const path    = require("path")
const webpack = require("webpack")
const { execFileSync } = require("child_process")

const mode = process.env.NODE_ENV === 'development' ? 'development' : 'production';
const govukPublishingComponentsPath = execFileSync("bundle", [
  "exec",
  "ruby",
  "-e",
  "print Gem::Specification.find_by_name('govuk_publishing_components').gem_dir"
], { encoding: "utf8" });

module.exports = {
  mode,
  entry: {
    application: "./app/javascript/application.js",
  },
  optimization: {
    moduleIds: 'deterministic',
  },
  output: {
    filename: "[name].js",
    sourceMapFilename: "[file].map",
    path: path.resolve(__dirname, '..', '..', 'app/assets/builds'),
  },
  resolve: {
    alias: {
      govuk_publishing_components: path.join(
        govukPublishingComponentsPath,
        "app/assets/javascripts/govuk_publishing_components"
      ),
    },
  },
  plugins: [
    new webpack.optimize.LimitChunkCountPlugin({
      maxChunks: 1
    })
  ],
  module: {
    rules: [
      {
        test: /\.(js|jsx|ts|tsx|)$/,
        exclude: /node_modules/,
        use: ['babel-loader'],
      }
    ]
  },
}


