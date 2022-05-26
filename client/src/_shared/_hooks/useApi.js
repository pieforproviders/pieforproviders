import fetchProgress from 'fetch-progress'
import { store } from 'index'
import { setLoading, setProgress } from '_reducers/uiReducer'

const GET = 'GET'
const POST = 'POST'
const PUT = 'PUT'
const DEL = 'DELETE'

const defaultHeaders = {
  'Content-Type': 'application/json',
  Accept: 'application/json'
}

async function fetchData({
  path,
  method,
  data,
  headers,
  onUnauthorized,
  onError
}) {
  const { dispatch } = store
  dispatch(setLoading(true))
  const response = await fetch(path, {
    method: method,
    body: data ? JSON.stringify(data) : null,
    headers: headers ? headers : defaultHeaders
  })
    .then(
      fetchProgress({
        onProgress(progress) {
          dispatch(setProgress(progress))
        },
        onError(err) {
          console.log(err)
        }
      })
    )
    .then(response => {
      if (response.status === 204) {
        return {}
      } else if (response.status === 401 && !!onUnauthorized) {
        return onUnauthorized(response)
      } else if (response.status >= 500 && !!onError) {
        return onError(response)
      } else {
        return response
      }
    })
  dispatch(setLoading(false))
  return response
}

export function useApi(onUnauthorized, onError) {
  return {
    get: (path, headers) =>
      fetchData({
        path: path,
        method: GET,
        data: null,
        headers: headers,
        onUnauthorized: onUnauthorized,
        onError: onError
      }),
    post: (path, data, headers) =>
      fetchData({
        path: path,
        method: POST,
        data: data,
        headers: headers,
        onUnauthorized: onUnauthorized,
        onError: onError
      }),
    put: (path, data, headers) =>
      fetchData({
        path: path,
        method: PUT,
        data: data,
        headers: headers,
        onUnauthorized: onUnauthorized,
        onError: onError
      }),
    del: (path, headers) =>
      fetchData({
        path: path,
        method: DEL,
        data: null,
        headers: headers,
        onUnauthorized: onUnauthorized,
        onError: onError
      })
  }
}

export default useApi
