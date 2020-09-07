import faker from 'faker'
import { createSelector } from '../utils'

const { name, internet } = faker
const firstName = name.firstName()
const fullName = name.findName(firstName)
const email = internet.email(firstName)
const password = internet.password()

describe('CasesImport', () => {
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
    cy.server()
    cy.route({
      method: 'POST',
      url: '/login'
    }).as('login')

    cy.visit('/login')
    cy.get(createSelector('email')).type(email)
    cy.get(createSelector('password')).type(password)
    cy.get(createSelector('loginBtn')).click()
    cy.wait('@login')
    cy.visit('/cases/import')
    cy.get(createSelector('cases-upload')).should('exist')
  })

  describe('imports a file', () => {
    ;['csv', 'xls', 'xlsx'].forEach(type => {
      it(`imports ${type} file`, () => {
        cy.get(createSelector('cases-upload')).attachFile(`test.${type}`)
        cy.get(createSelector('cases-table')).should('exist')
        cy.get('tbody')
          .first()
          .get('tr')
          .first()
          .get('td')
          .first()
          .contains(type.toUpperCase())
      })
    })
  })
})
