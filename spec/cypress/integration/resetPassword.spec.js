import dayjs from 'dayjs'
import faker from 'faker'
import { createSelector } from '../utils'

const { name, internet, random } = faker
const firstName = name.firstName()
const fullName = name.findName(firstName)
const email = internet.email(firstName)
const password = random.alphaNumeric(15)
let rawToken

describe('Password update', () => {
  describe('confirmed users', () => {
    beforeEach(() => {
      cy.app('clean')
      cy.app('generateToken').then(tokens => {
        rawToken = tokens[0]

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
              reset_password_token: tokens[1],
              reset_password_sent_at: new Date()
            }
          ]
        ])
      })
    })

    describe('valid password update link', () => {
      it('allows a user to update their password and logs them in', () => {
        const newPassword = random.alphaNumeric(15)
        cy.intercept({
          method: 'PUT',
          url: '/password'
        }).as('passwordReset')

        cy.visit(`/password/update?reset_password_token=${rawToken}`)
        cy.get(createSelector('password')).type(newPassword)
        cy.get(createSelector('passwordConfirmation')).type(newPassword)
        cy.get(createSelector('resetPasswordBtn')).click()

        cy.wait('@passwordReset')
        cy.location('pathname').should('eq', '/getting-started')
      })
    })

    describe('invalid password update link', () => {
      it('displays an error message', () => {
        const newPassword = random.alphaNumeric(15)
        const token = random.alphaNumeric()

        cy.intercept({
          method: 'PUT',
          url: '/password'
        }).as('passwordReset')

        cy.visit(`/password/update?reset_password_token=${token}`)
        cy.get(createSelector('password')).type(newPassword)
        cy.get(createSelector('passwordConfirmation')).type(newPassword)
        cy.get(createSelector('resetPasswordBtn')).click()

        cy.wait('@passwordReset')
        cy.get(createSelector('authError')).should('exist')
        cy.location('pathname').should('eq', '/login')
      })
    })

    describe('no password token provided', () => {
      it('displays an error message', () => {
        cy.visit('/password/update')
        cy.get(createSelector('authError')).should('exist')
        cy.location('pathname').should('eq', '/login')
      })
    })

    describe('already used reset password token', () => {
      it('displays an error message', () => {
        cy.appScenario('resetPasswordTokenUsed')
        const newPassword = random.alphaNumeric(15)

        cy.intercept({
          method: 'PUT',
          url: '/password'
        }).as('passwordReset')

        cy.visit(`/password/update?reset_password_token=${rawToken}`)
        cy.get(createSelector('password')).type(newPassword)
        cy.get(createSelector('passwordConfirmation')).type(newPassword)
        cy.get(createSelector('resetPasswordBtn')).click()

        cy.wait('@passwordReset')
        cy.get(createSelector('authError')).should('exist')
        cy.location('pathname').should('eq', '/login')
      })
    })
  })

  describe('unconfirmed users', () => {
    beforeEach(() => {
      cy.app('clean')
      cy.app('generateToken').then(tokens => {
        rawToken = tokens[0]

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
              confirmed_at: null,
              reset_password_token: tokens[1],
              reset_password_sent_at: new Date()
            }
          ]
        ])
      })
    })

    describe('valid password update link', () => {
      it('allows a user to update their password and redirects them to the login page', () => {
        const newPassword = random.alphaNumeric(15)
        cy.intercept({
          method: 'PUT',
          url: '/password'
        }).as('passwordReset')
        cy.intercept({
          method: 'POST',
          url: '/confirmation'
        }).as('confirmation')

        cy.visit(`/password/update?reset_password_token=${rawToken}`)
        cy.get(createSelector('password')).type(newPassword)
        cy.get(createSelector('passwordConfirmation')).type(newPassword)
        cy.get(createSelector('resetPasswordBtn')).click()

        cy.wait('@passwordReset')
        cy.location('pathname').should('eq', '/login')
        cy.get(createSelector('authError')).contains(
          'You have to confirm your email address before continuing',
          {
            matchCase: false
          }
        )

        cy.get(createSelector('resendConfirmationLink')).click()
        cy.wait('@confirmation')
        cy.get(createSelector('successMessage')).contains('Email resent')
      })
    })
  })

  describe('expired password reset tokens', () => {
    beforeEach(() => {
      cy.app('clean')
      cy.app('generateToken').then(tokens => {
        rawToken = tokens[0]

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
              confirmed_at: null,
              reset_password_token: tokens[1],
              reset_password_sent_at: dayjs().subtract('7', 'months').format()
            }
          ]
        ])
      })
    })

    it('displays an error message', () => {
      const newPassword = random.alphaNumeric(15)
      cy.intercept({
        method: 'PUT',
        url: '/password'
      }).as('passwordReset')

      cy.visit(`/password/update?reset_password_token=${rawToken}`)
      cy.get(createSelector('password')).type(newPassword)
      cy.get(createSelector('passwordConfirmation')).type(newPassword)
      cy.get(createSelector('resetPasswordBtn')).click()

      cy.wait('@passwordReset')
      cy.location('pathname').should('eq', '/login')
      cy.get(createSelector('authError')).contains(
        'Your password reset token has expired. Please request a new one.',
        {
          matchCase: false
        }
      )
    })
  })
})
