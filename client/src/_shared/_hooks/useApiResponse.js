import useApi from 'react-use-fetch-api'
import apiErrorHandler from '_utils/apiErrorHandler'
import useUnauthorizedHandler from '_shared/_hooks/useUnauthorizedHandler'

export const useApiResponse = () => {
  const { get, post, put, del } = useApi(
    useUnauthorizedHandler(),
    apiErrorHandler()
  )

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
