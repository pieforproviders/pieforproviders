import { setProgress } from '_reducers/uiReducer'
import { useDispatch } from 'react-redux'

export function useProgress() {
  const dispatch = useDispatch()
  // this logic comes from: https://javascript.info/fetch-progress
  const parseResult = async response => {
    const reader = response.body.getReader()
    const contentLength = +response.headers.get('Content-Length')

    let receivedLength = 0
    let chunks = []
    // eslint-disable-next-line no-constant-condition
    while (true) {
      const { done, value } = await reader.read()

      if (done) {
        break
      }

      chunks.push(value)
      receivedLength += value.length
      const progressPercentage = contentLength
        ? Math.round((receivedLength / contentLength) * 100)
        : 100

      dispatch(setProgress(progressPercentage))
    }

    let chunksAll = new Uint8Array(receivedLength)
    let position = 0

    for (let chunk of chunks) {
      chunksAll.set(chunk, position)
      position += chunk.length
    }

    let result = new TextDecoder('utf-8').decode(chunksAll)

    return JSON.parse(result)
  }

  return { parseResult }
}
