import faker from 'faker'
import { createSelector } from '../utils'

const { name, internet } = faker
const firstName = name.firstName()
const fullName = name.findName(firstName)
const email = internet.email(firstName)
const password = internet.password()
const confirmationToken = 'hotdog'
const confirmationDate = new Date()

describe('Confirmation', () => {
  describe('unconfirmed users', () => {
    beforeEach(() => {
      cy.app('clean')
      cy.appFactories([
        [
          'create',
          'unconfirmed_user',
          {
            email,
            full_name: fullName,
            greeting_name: firstName,
            password,
            password_confirmation: password,
            confirmation_token: confirmationToken,
            confirmed_at: null
          }
        ]
      ])
    })

    describe('valid confirmation link', () => {
      it('allows a user to confirm and redirects them', () => {
        cy.intercept({
          method: 'GET',
          url: `/confirmation?confirmation_token=${confirmationToken}`
        }).as('confirmation')

        cy.visit(`/confirm?confirmation_token=${confirmationToken}`)
        cy.location('pathname').should('eq', '/dashboard')
      })
    })

    describe('invalid confirmation link', () => {
      it('displays an error message', () => {
        cy.intercept({
          method: 'GET',
          url: '/confirmation?confirmation_token=cactus'
        }).as('confirmation')

        cy.visit(`/confirm?confirmation_token=cactus`)
        cy.get(createSelector('authError')).should('exist')
        cy.location('pathname').should('eq', '/login')
      })
    })

    describe('no confirmation token provided', () => {
      it('displays an error message', () => {
        cy.intercept({
          method: 'GET',
          url: '/confirmation'
        }).as('confirmation')

        cy.visit('/confirm')
        cy.get(createSelector('authError')).should('exist')
        cy.location('pathname').should('eq', '/login')
      })
    })

    describe('expired confirmation token', () => {
      it('displays an error message', () => {
        cy.appScenario('confirmationTokenExpired')
        cy.intercept({
          method: 'GET',
          url: `/confirmation?confirmation_token=${confirmationToken}`
        }).as('confirmation')

        cy.visit(`/confirm?confirmation_token=${confirmationToken}`)
        cy.get(createSelector('authError')).contains(
          'Your confirmation period has expired.',
          {
            matchCase: false
          }
        )
        cy.location('pathname').should('eq', '/login')
      })
    })
  })

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
            password_confirmation: password,
            confirmation_token: confirmationToken,
            confirmed_at: confirmationDate
          }
        ]
      ])
    })

    it('displays an error message', () => {
      cy.intercept({
        method: 'GET',
        url: `/confirmation?confirmation_token=${confirmationToken}`
      }).as('confirmation')

      cy.visit(`/confirm?confirmation_token=${confirmationToken}`)
      cy.get(createSelector('authError')).should('exist')
      cy.location('pathname').should('eq', '/login')
    })
  })
})
