import React from 'react'
import ReactDOM from 'react-dom'
import App from './App'
import './App.less'
import './tailwind.generated.css'
import './i18n'
import { configureStore } from '@reduxjs/toolkit'
import { Provider } from 'react-redux'
import rootReducer from '_reducers/rootReducer'
import runtimeEnv from '@mars/heroku-js-runtime-env'
import TagManager from 'react-gtm-module'

export const store = configureStore({
  reducer: rootReducer,
  devTools: process.env.NODE_ENV !== 'production'
})

const env = runtimeEnv()

const tagManagerArgs = {
  gtmId: env.REACT_APP_GTM_ID,
  auth: env.REACT_APP_GTM_AUTH,
  preview: env.REACT_APP_GTM_PREVIEW
}

TagManager.initialize(tagManagerArgs)

ReactDOM.render(
  <Provider store={store}>
    <App />
  </Provider>,
  document.getElementById('root')
)
