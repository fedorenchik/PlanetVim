const js = require('@eslint/js')
const globals = require('globals')

module.exports = [
  { ignores: ['dist/**'] },
  js.configs.recommended,
  { languageOptions: { sourceType: 'commonjs', globals: globals.node } },
  { files: ['preload.js'], languageOptions: { globals: globals.browser } },
  { files: ['renderer.js'], languageOptions: { sourceType: 'script', globals: globals.browser } }
]
