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
          'user',
          {
            email,
            full_name: fullName,
            greeting_name: firstName,
            password,
            password_confirmation: password,
            confirmation_token: confirmationToken,
            confirmed_at: confirmationDate,
          },
        ],
      ])
    })

    describe('valid confirmation link', () => {
      it('allows a user to confirm and redirects them', () => {
        cy.server()
        cy.route({
          method: 'POST',
          url: `/confirmation?confirmation_token=${confirmationToken}`,
        }).as('confirmation')

        cy.visit(`/confirmation?confirmation_token=${confirmationToken}`)
        cy.wait('@confirmation')
        cy.location('pathname').should('eq', '/getting-started')
      })
    })

    describe('invalid confirmation link', () => {
      it('displays an error message', () => {
        cy.server()
        cy.route({
          method: 'POST',
          url: `/confirmation?confirmation_token=cactus`,
        }).as('confirmation')

        cy.visit(`/confirmation?confirmation_token=cactus`)
        cy.wait('@confirmation')
        cy.get(
          createSelector('loginError')
        ).contains('Invalid email or password', { matchCase: false })
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
            confirmed_at: confirmationDate,
          },
        ],
      ])
    })

    it('displays an error message', () => {
      cy.server()
      cy.route({
        method: 'POST',
        url: `/confirmation?confirmation_token=${confirmationToken}`,
      }).as('confirmation')

      cy.visit(`/confirmation?confirmation_token=${confirmationToken}`)
      cy.wait('@confirmation')
      cy.get(createSelector('loginError')).contains(
        'You have to confirm your email address before continuing',
        {
          matchCase: false,
        }
      )
    })
  })
})
