var webpack                 = require('webpack');

// Installs instantclick.js
module.exports = {
  entry: {
    app: "./_build/js/app.js"
  },
  output: {
    filename: "./_assets/js/[name].js"
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
