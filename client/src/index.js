import React from 'react'
import ReactDOM from 'react-dom'
import App from './App'
import './App.less'
import './tailwind.generated.css'
import './i18n'
import { Provider } from 'react-redux'
import { store } from './configureStore'

ReactDOM.render(
  <Provider store={store}>
    <App />
  </Provider>,
  document.getElementById('root')
)
