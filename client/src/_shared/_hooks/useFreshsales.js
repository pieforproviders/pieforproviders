const { useEffect } = require('react')

const useFreshsales = () => {
  useEffect(() => {
    const script = document.createElement('script')
    script.src = '//fw-cdn.com/1908453/2703732.js'
    script.setAttribute('chat', 'false')

    document.head.appendChild(script)

    return () => {
      document.head.removeChild(script)
    }
  }, [])
}

export default useFreshsales
