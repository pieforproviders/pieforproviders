import Appsignal from '@appsignal/javascript'

let appSignal
if (process.env.REACT_APP_APPSIGNAL_KEY) {
  appSignal = new Appsignal({
    key: process.env.REACT_APP_APPSIGNAL_KEY
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
