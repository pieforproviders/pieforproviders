import faker from 'faker'
import { createSelector } from '../utils'

const { name, internet, phone, company } = faker
const firstName = name.firstName()
const fullName = name.findName(firstName)
const email = internet.email(firstName)
const password = internet.password()
const phoneNumber = phone.phoneNumber()
const orgName = company.companyName()

describe('Signup', () => {
  beforeEach(() => {
    cy.app('clean')
    cy.server()
    cy.route({
      method: 'POST',
      url: '/signup'
    }).as('signup')
    cy.visit('/signup')
    cy.get(createSelector('organization')).type(orgName)
    cy.get(createSelector('name')).type(fullName)
    cy.get(createSelector('greetingName')).type(firstName)
    cy.get(createSelector('multiBusiness')).click()
    cy.get(createSelector('yesMultiBusiness')).click()
    cy.get(createSelector('phoneType')).click()
    cy.get(createSelector('homePhone')).click()
    cy.get(createSelector('languageEs')).click()
    cy.get(createSelector('password')).type(password)
    cy.get(createSelector('passwordConfirmation')).type(password)
    cy.get(createSelector('terms')).check()
  })
  describe('an existing user signs up', () => {
    beforeEach(() => {
      cy.appFactories([
        [
          'create',
          'user',
          {
            email,
            full_name: fullName,
            greeting_name: firstName,
            phoneNumber
          }
        ]
      ])
    })

    describe('duplicate phone', () => {
      it('returns an error', () => {
        cy.get(createSelector('phoneType')).select('home')
        cy.get(createSelector('phone')).type(phoneNumber)
        cy.get(createSelector('signupBtn')).click()
        // cy.wait('@signup')
        cy.location('pathname').should('eq', '/signup')
        // put expectation here for errors
      })
    })

    describe('duplicate email', () => {
      it('returns an error', () => {
        cy.get(createSelector('email')).type(email)
        cy.get(createSelector('signupBtn')).click()
        // cy.wait('@signup')
        cy.location('pathname').should('eq', '/signup')
        // put expectation here for errors
      })
    })
  })

  describe('new user signs up', () => {
    beforeEach(() => {
      cy.get(createSelector('phoneType')).select('home')
      cy.get(createSelector('phone')).type(phoneNumber)
      cy.get(createSelector('email')).type(email)
      cy.get(createSelector('signupBtn')).click()
      cy.wait('@signup')
    })
    it('allows the user to sign up and displays confirmation sent info', () => {
      cy.location('pathname').should('eq', '/signup')
      // expect confirmation sent content
    })
    it('allows the user to request new confirmation', () => {
      cy.location('pathname').should('eq', '/signup')
      // expect confirmation sent content
    })
  })
})
