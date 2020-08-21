// jest-dom adds custom jest matchers for asserting on DOM nodes.
// allows you to do things like:
// expect(element).toHaveTextContent(/react/i)
// learn more: https://github.com/testing-library/jest-dom
import '@testing-library/jest-dom/extend-expect'
import React from 'react'
import { I18nextProvider } from 'react-i18next'
import i18n from 'i18n'
import { render } from '@testing-library/react'

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

export const renderWithi18next = Component => {
  const Comp = React.cloneElement(Component, {
    changeLanguage: lng => {
      i18n.changeLanguage(lng)
      rerender(<I18nextProvider i18n={i18n}>{Comp}</I18nextProvider>)
    }
  })
  const defaultRender = render(
    <I18nextProvider i18n={i18n}>{Comp}</I18nextProvider>
  )
  const { rerender } = defaultRender
  return defaultRender
}
