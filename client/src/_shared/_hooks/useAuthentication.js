import dayjs from 'dayjs'
import { useSelector } from 'react-redux'

// TODO: Something isn't working here, if I hit an authenticated route directly, it logs me out
export function useAuthentication() {
  const auth = useSelector(state => state.auth)
  /*
    if the token exists and the expiration is not later than today, we're
    going to let the user visit any page that uses this hook as a gatekeeper;
    any page that has an API call will return a 403 Forbidden, which will
    trigger a logout (see any call of removeAuth() that happens after an API
    call, as well as in the useUnauthorizedHandler hook)
  */
  return !!auth.token && !!auth.expiration && dayjs(auth.expiration) > dayjs()
}
