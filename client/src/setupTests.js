// jest-dom adds custom jest matchers for asserting on DOM nodes.
// allows you to do things like:
// expect(element).toHaveTextContent(/react/i)
// learn more: https://github.com/testing-library/jest-dom
import '@testing-library/jest-dom/extend-expect'
import React from 'react'
import { I18nextProvider } from 'react-i18next'
import i18n from 'i18n'
import PropTypes from 'prop-types'
import { render as rtlRender } from '@testing-library/react'
import { Provider } from 'react-redux'
import { createStore } from '@reduxjs/toolkit'
import rootReducer from '_reducers/rootReducer'
import dayjs from 'dayjs'

// window.matchMedia isn't implemented by JSDOM, but the responsive parts of
// the Antd React library make use of it, so we have to mock it:
// https://jestjs.io/docs/en/manual-mocks#mocking-methods-which-are-not-implemented-in-jsdom
Object.defineProperty(window, 'matchMedia', {
  writable: true,
  value: jest.fn().mockImplementation(query => ({
    matches: false,
    media: query,
    onchange: null,
    addListener: jest.fn(), // deprecated
    removeListener: jest.fn(), // deprecated
    addEventListener: jest.fn(),
    removeEventListener: jest.fn(),
    dispatchEvent: jest.fn()
  }))
})

function render(
  ui,
  {
    initialState = { auth: { token: null, expiration: dayjs().toDate() } },
    store = createStore(rootReducer, initialState),
    ...renderOptions
  } = {}
) {
  function Wrapper({ children }) {
    return (
      <I18nextProvider i18n={i18n}>
        <Provider store={store}>{children}</Provider>
      </I18nextProvider>
    )
  }
  Wrapper.propTypes = {
    children: PropTypes.object
  }
  return rtlRender(ui, { wrapper: Wrapper, ...renderOptions })
}

export * from '@testing-library/react'

export { render }
