export default function apiErrorHandler() {
  const handler = err => {
    console.log('api err:', err)
    // TODO: Sentry
    // TODO: what other errors might there be? investigate
    // localStorage.removeItem('token')
    // history.push('/login')
    return err
  }

  return handler
}
