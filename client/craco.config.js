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
              '@error-color': '#D23C2A',
              '@highlight-color': '#D23C2A',
              '@primary-4': '#F3F8FA',

              // Typography
              'text-color': '#333333',
              'line-height-base': '1.14285',
              '@heading-color': '@primary-color',
              '@heading-1-size': 'ceil(@font-size-base * 2.57)',
              '@heading-2-size': 'ceil(@font-size-base * 2)',
              '@heading-3-size': 'ceil(@font-size-base * 1.57)',
              '@heading-4-size': 'ceil(@font-size-base * 1.07)',

              // Card
              '@card-background': '@primary-4',
              '@card-radius': '5px'
            },
            javascriptEnabled: true
          }
        }
      }
    }
  ]
}
