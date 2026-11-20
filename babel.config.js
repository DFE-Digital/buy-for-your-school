module.exports = function(api) {
  var validEnv = ['development', 'test', 'production']
  var currentEnv = api.env()
  var isDevelopmentEnv = api.env('development')
  var isProductionEnv = api.env('production')
  var isTestEnv = api.env('test')

  if (!validEnv.includes(currentEnv)) {
    throw new Error(
      'Please specify a valid `NODE_ENV` or ' +
        '`BABEL_ENV` environment variables. Valid values are "development", ' +
        '"test", and "production". Instead, received: ' +
        JSON.stringify(currentEnv) +
        '.'
    )
  }

  return {
    presets: [
      isTestEnv && [
        '@babel/preset-env',
        {
          targets: {
            node: 'current'
          },
          modules: 'commonjs'
        }
      ],
      (isProductionEnv || isDevelopmentEnv) && [
        '@babel/preset-env',
        {
          modules: false,
        }
      ]
    ].filter(Boolean),
    assumptions: {
      privateFieldsAsProperties: true,
      setPublicClassFields: true,
      setSpreadProperties: true
    },
    plugins: [
      'babel-plugin-macros',
      (isProductionEnv || isDevelopmentEnv) && [
        'babel-plugin-polyfill-corejs3',
        { method: 'entry-global', version: '3.50.0' }
      ],
      isTestEnv && 'babel-plugin-dynamic-import-node',
      '@babel/plugin-transform-destructuring',
      '@babel/plugin-transform-class-properties',
      '@babel/plugin-transform-object-rest-spread',
      '@babel/plugin-transform-private-methods',
      '@babel/plugin-transform-private-property-in-object',
      [
        '@babel/plugin-transform-regenerator',
        {
          async: false
        }
      ]
    ].filter(Boolean)
  }
}
