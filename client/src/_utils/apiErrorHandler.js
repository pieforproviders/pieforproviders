import { sendSpan } from './appSignal'

export default function apiErrorHandler() {
  const handler = response => {
    sendSpan({ params: response, error: new Error('API 500 error') })

    return response
  }

  return handler
}
