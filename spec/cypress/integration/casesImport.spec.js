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
  })

  describe('imports a file', () => {
    ;['csv', 'xls', 'xlsx'].forEach(type => {
      it(`imports ${type} file`, () => {
        cy.get('input[type="file"]').attachFile(`test.${type}`)
        // it seems like we can't pass a data-cy attribute or an id to the antd Table element
        // so I'm targeting an inline class auto-assigned by Ant.  I don't like this and would
        // love for someone else to take a swing at this and see what I'm missing
        cy.get('[class="ant-table-wrapper"]').should('exist')
        cy.get('[class="ant-table-wrapper"]').should('exist')
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
