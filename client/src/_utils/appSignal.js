import Appsignal from '@appsignal/javascript'
import runtimeEnv from '@mars/heroku-js-runtime-env'

const env = runtimeEnv()
let appSignal
if (env.REACT_APP_APPSIGNAL_KEY) {
  appSignal = new Appsignal({
    key: env.REACT_APP_APPSIGNAL_KEY
  })
}

export const sendSpan = ({ tags = {}, params = {}, error = {} }) => {
  if (appSignal) {
    const span = appSignal.createSpan(span => {
      span.setTags(tags)
      span.setParams(params)
      return span.setError(error)
    })

    appSignal.send(span)
  }
}

export default appSignal
