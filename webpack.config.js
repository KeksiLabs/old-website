var webpack                 = require('webpack');

// Installs instantclick.js
module.exports = {
  entry: "./_assets/js/app.js",
  output: {
    filename: "./js/app.js"
  },
  plugins: [
        new webpack.optimize.UglifyJsPlugin({
            mangle: false,
            compress: {
                unused: false
            }
        })
    ]
}
