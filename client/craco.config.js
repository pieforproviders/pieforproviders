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
              '@font-family': 'Proxima Nova',
              '@input-border-color': '@primary-color',
              '@select-border-color': '@primary-color',
              '@select-background': '#E2EBF3',
              '@select-item-selected-color': '#3B3B3B',
              '@label-color': '@primary-color',
              '@input-placeholder-color': '#676767',
              '@error-color': '#D64B3A',
              '@highlight-color': '#D64B3A'
            },
            javascriptEnabled: true
          }
        }
      }
    }
  ]
}
