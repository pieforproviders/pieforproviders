import { useApi } from 'react-use-fetch-api'

export const useApiResponse = () => {
  function onUnauthorized(err) {
    console.log('onUnauthorized', err)
    // TODO: send to sentry
    return err
  }

  function onError(err) {
    console.log('onError', err)
    // TODO: send to sentry
    return err
  }

  const { get, post, put, del } = useApi(onUnauthorized, onError)

  const makeRequest = async request => {
    const {
      type,
      url,
      data,
      headers = {
        Accept: 'application/vnd.pieforproviders.v1+json',
        'Content-Type': 'application/json'
      }
    } = request

    const result = (async () => {
      switch (type) {
        case 'post':
          return await post(url, data, headers)
        case 'put':
          return await put(url, data, headers)
        case 'del':
          return await del(url, headers)
        case 'get':
        default:
          return await get(url, headers)
      }
    })()
    return result
  }

  return {
    makeRequest: makeRequest
  }
}
