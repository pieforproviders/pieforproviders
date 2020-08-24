import React from 'react'
import ReactDOM from 'react-dom'
import App from './App'
import './App.less'
import './tailwind.generated.css'
import * as Sentry from '@sentry/browser'
import './i18n'

if (
  process.env.NODE_ENV === 'production' &&
  process.env.REACT_APP_SENTRY_DSN_FRONTEND
) {
  Sentry.init({
    dsn: process.env.REACT_APP_SENTRY_DSN_FRONTEND
  })
}

ReactDOM.render(<App />, document.getElementById('root'))
