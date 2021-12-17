import { useLocation } from 'react-router-dom'
import runtimeEnv from '@mars/heroku-js-runtime-env'
import { useSelector } from 'react-redux'

const env = runtimeEnv()

export function useGoogleAnalytics() {
  const user = useSelector(state => state.user)
  let location = useLocation()

  const initGoogleAnalytics = () => {
    if (!window.gtag) return
    window.gtag('config', env.REACT_APP_GA_MEASUREMENT_ID, {
      page_path: location.pathname,
      user_id: user.id ?? ''
    })
    window.gtag('set', 'page_title', location.pathname)
  }

  const sendGAEvent = (eventName, payload) => {
    if (!window.gtag) return
    window.gtag('event', eventName, payload)
  }

  return {
    initGoogleAnalytics,
    sendGAEvent
  }
}
