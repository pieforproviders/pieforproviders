const CracoLessPlugin = require('craco-less')

module.exports = {
  plugins: [
    {
      plugin: CracoLessPlugin,
      options: {
        lessLoaderOptions: {
          lessOptions: {
            modifyVars: {
              '@primary-color': '#006C9E',
              '@font-family': "'Proxima Nova'",
              '@heading-color': '@primary-color',
              '@heading-1-size': 'ceil(@font-size-base * 2.57)',
              '@heading-2-size': 'ceil(@font-size-base * 2)',
              '@heading-3-size': 'ceil(@font-size-base * 1.57)',
              '@heading-4-size': 'ceil(@font-size-base * 1.07)',
            },
            javascriptEnabled: true
          }
        }
      }
    }
  ]
}
