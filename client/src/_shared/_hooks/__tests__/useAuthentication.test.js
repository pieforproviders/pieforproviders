import React from 'react'
import { render } from 'setupTests'
import { useAuthentication } from '_shared/_hooks/useAuthentication'
import dayjs from 'dayjs'

function TestComponent() {
  const isAuthenticated = useAuthentication()
  return (
    <div>
      {isAuthenticated ? <div>Authenticated</div> : <div>Unauthenticated</div>}
    </div>
  )
}

const setupAuthenticated = () => {
  return render(<TestComponent />, {
    initialState: {
      auth: { token: 'whatever', expiration: dayjs().add('2', 'days').toDate() }
    }
  })
}

const setupExpired = () => {
  return render(<TestComponent />, {
    initialState: { auth: { token: 'whatever', expiration: dayjs().toDate() } }
  })
}

const setupNoToken = () => {
  return render(<TestComponent />, {
    initialState: {
      auth: { token: null, expiration: dayjs().add('2', 'days').toDate() }
    }
  })
}

const setupNoTokenNoExpiration = () => {
  return render(<TestComponent />, {
    initialState: { auth: { token: null, expiration: null } }
  })
}

describe('useAuthentication', () => {
  it('returns true when user has an unexpired token', () => {
    const { container } = setupAuthenticated()
    expect(container).toHaveTextContent('Authenticated')
  })

  it('returns false when user has an expired token', () => {
    const { container } = setupExpired()
    expect(container).toHaveTextContent('Unauthenticated')
  })

  it('returns false when user has no token and an expiration date', () => {
    const { container } = setupNoToken()
    expect(container).toHaveTextContent('Unauthenticated')
  })

  it('returns false when user has no token and no expiration date', () => {
    const { container } = setupNoTokenNoExpiration()
    expect(container).toHaveTextContent('Unauthenticated')
  })
})
