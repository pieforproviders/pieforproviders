const { useEffect } = require('react')

const useFreshsales = () => {
  useEffect(() => {
    const scriptHead = document.createElement('script')
    scriptHead.src = '//fw-cdn.com/1908453/2703732.js'
    scriptHead.setAttribute('chat', 'false')

    const scriptBody = document.createElement('script')
    scriptBody.src = '//fw-cdn.com/1908453/2703732.js'
    scriptBody.setAttribute('chat', 'false')
    document.head.insertBefore(scriptHead, document.head.querySelector('title'))
    document.body.insertBefore(
      scriptBody,
      document.body.querySelector('noscript')
    )

    return () => {
      document.head.removeChild(scriptHead)
      document.body.removeChild(scriptBody)
    }
  }, [])
}

export default useFreshsales
