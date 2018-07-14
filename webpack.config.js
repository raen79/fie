const path = require('path');

module.exports = {
  entry: './lib/javascript/fie.js',
  output: {
    filename: 'fie.js',
    path: path.resolve(__dirname, 'vendor/javascript')
  },
  watch: true,
  mode: 'production'
};