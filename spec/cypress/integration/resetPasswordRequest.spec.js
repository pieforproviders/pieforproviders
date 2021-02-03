import faker from 'faker'
import { createSelector } from '../utils'

const { name, internet } = faker
const firstName = name.firstName()
const fullName = name.findName(firstName)
const email = internet.email(firstName)
const password = internet.password()

describe('Reset password request', () => {
  describe('existing users', () => {
    beforeEach(() => {
      cy.app('clean')
      cy.appFactories([
        [
          'create',
          'confirmed_user',
          {
            email,
            full_name: fullName,
            greeting_name: firstName,
            password,
            password_confirmation: password
          }
        ]
      ])
    })

    it('sends password reset instructions', () => {
      cy.intercept({
        method: 'POST',
        url: '/password'
      }).as('resetPasswordRequest')

      cy.visit('/login')
      cy.get(createSelector('resetPasswordBtn')).click()
      cy.get(createSelector('resetPasswordEmail')).type(email)
      cy.get(createSelector('resetPasswordSubmitBtn')).click()
      cy.get(createSelector('successMessage')).should('exist')
    })
  })

  describe('non-existent users', () => {
    it('displays an error message', () => {
      cy.intercept({
        method: 'POST',
        url: '/password'
      }).as('resetPasswordRequest')

      cy.visit('/login')
      cy.get(createSelector('resetPasswordBtn')).click()
      cy.get(createSelector('resetPasswordEmail')).type(internet.email())
      cy.get(createSelector('resetPasswordSubmitBtn')).click()
      cy.get(createSelector('errorMessage')).should('exist')
    })
  })
})
