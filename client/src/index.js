import React from 'react'
import ReactDOM from 'react-dom'
import App from './App'
import './App.less'
import './tailwind.generated.css'
import * as Sentry from '@sentry/browser'
import './i18n'
import { createStore } from 'redux'
import { Provider } from 'react-redux'
import rootReducer from '_reducers/rootReducer'

export const store = createStore(rootReducer)

if (process.env.NODE_ENV === 'production' && process.env.REACT_APP_SENTRY_DSN) {
  Sentry.init({
    dsn: process.env.REACT_APP_SENTRY_DSN
  })
}

ReactDOM.render(
  <Provider store={store}>
    <App />
  </Provider>,
  document.getElementById('root')
)
