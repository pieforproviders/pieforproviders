import faker from 'faker'
import { createSelector } from '../utils'

const { name, internet } = faker
const firstName = name.firstName()
const fullName = name.findName(firstName)
const email = internet.email(firstName)
const password = internet.password()

describe('Login', () => {
  describe('confirmed users', () => {
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

    describe('valid credentials', () => {
      it('allows a user to log in', () => {
        cy.intercept({
          method: 'POST',
          url: '/login'
        }).as('login')

        cy.visit('/login')
        cy.get(createSelector('email')).type(email)
        cy.get(createSelector('password')).type(password)
        cy.get(createSelector('loginBtn')).click()
        cy.wait('@login')
        cy.location('pathname').should('eq', '/getting-started')
      })
    })

    describe('invalid credentials', () => {
      it('displays an error message', () => {
        cy.intercept({
          method: 'POST',
          url: '/login'
        }).as('login')

        cy.visit('/login')
        cy.get(createSelector('email')).type(email)
        cy.get(createSelector('password')).type(internet.password())
        cy.get(createSelector('loginBtn')).click()
        cy.wait('@login')
        cy.get(createSelector('authError')).should('exist')
      })
    })
  })

  describe('unconfirmed users', () => {
    beforeEach(() => {
      cy.app('clean')
      cy.appFactories([
        [
          'create',
          'user',
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

    it('displays an error message and allows the user to resend the confirmation email', () => {
      cy.intercept({
        method: 'POST',
        url: '/login'
      }).as('login')
      cy.intercept({
        method: 'POST',
        url: '/confirmation'
      }).as('confirmation')

      cy.visit('/login')
      cy.get(createSelector('email')).type(email)
      cy.get(createSelector('password')).type(password)
      cy.get(createSelector('loginBtn')).click()
      cy.wait('@login')
      cy.get(createSelector('authError')).should('exist')

      cy.get(createSelector('resendConfirmationLink')).click()
      cy.wait('@confirmation')
      cy.get(createSelector('successMessage')).contains('Email resent')
    })
  })

  describe('non-existent users', () => {
    it('displays an error message', () => {
      cy.intercept({
        method: 'POST',
        url: '/login'
      }).as('login')

      cy.visit('/login')
      cy.get(createSelector('email')).type(internet.email())
      cy.get(createSelector('password')).type(internet.password())
      cy.get(createSelector('loginBtn')).click()
      cy.wait('@login')
      cy.get(createSelector('authError')).should('exist')
    })
  })
})
