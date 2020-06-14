import { useApi } from 'react-use-fetch-api'
import { useEffect, useState } from 'react'

export const useApiResponse = request => {
  const [apiResponse, setApiResponse] = useState(null)

  const {
    type,
    url,
    data,
    headers = {
      Accept: 'application/vnd.pieforproviders.v1+json'
    }
  } = request

  function onUnauthorized(err) {
    console.log('onUnauthorized')
    return err
  }

  function onError(err) {
    console.log('onError')
    return err
  }

  const { get, post, put, del } = useApi(onUnauthorized, onError)

  useEffect(() => {
    const makeRequest = async () => {
      const result = await (() => {
        switch (type) {
          case 'get':
            return async () => {
              await get(url, headers)
            }
          case 'post':
            return async () => {
              await post(url, data, headers)
            }
          case 'put':
            return async () => {
              await put(url, data, headers)
            }
          case 'del':
            return async () => {
              await del(url, headers)
            }
        }
        console.log('result:', result)
      })
    }
    setApiResponse(makeRequest())
  }, [])
  return apiResponse
}
