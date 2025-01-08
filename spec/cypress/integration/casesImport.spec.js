// import faker from 'faker'
// import { createSelector } from '../utils'

// const { name, internet } = faker
// const firstName = name.firstName()
// const fullName = name.findName(firstName)
// const email = internet.email(firstName)
// const password = internet.password()

// describe('CasesImport', () => {
//   beforeEach(() => {
//     cy.app('clean')
//     cy.createState().then(states => {
//       const state = states[0]
//       cy.appFactories([
//         [
//           'create',
//           'state_time_rule',
//           {
//             name: 'Partial Day Nebraska',
//             min_time: 60,
//             max_time: 4 * 3600 + 59 * 60,
//             state_id: state.id
//           }
//         ],
//         [
//           'create',
//           'state_time_rule',
//           {
//             name: 'Full Day Nebraska',
//             min_time: 5 * 3600,
//             max_time: 10 * 3600,
//             state_id: state.id
//           }
//         ],
//         [
//           'create',
//           'state_time_rule',
//           {
//             name: 'Full - Partial Day Nebraska',
//             min_time: 10 * 3600 + 60,
//             max_time: 30 * 3600,
//             state_id: state.id
//           }
//         ]
//       ])
//     })
//     cy.appFactories([
//       [
//         'create',
//         'confirmed_user',
//         {
//           email,
//           full_name: fullName,
//           greeting_name: firstName,
//           password,
//           password_confirmation: password
//         }
//       ]
//     ])
//     cy.intercept({
//       method: 'POST',
//       url: '/login'
//     }).as('login')

//     cy.visit('/login')
//     cy.get(createSelector('email')).type(email)
//     cy.get(createSelector('password')).type(password)
//     cy.get(createSelector('loginBtn')).click()
//     cy.visit('/cases/import')
//     cy.get(createSelector('cases-upload')).should('exist')
//   })

//   describe('imports a file', () => {
//     ;['csv', 'xls', 'xlsx']?.forEach(type => {
//       it(`imports ${type} file`, () => {
//         cy.get(createSelector('cases-upload')).attachFile(`test.${type}`)
//         cy.get(createSelector('cases-table')).should('exist')
//         cy.get('tbody')
//           .first()
//           .get('tr')
//           .first()
//           .get('td')
//           .first()
//           .contains(type.toUpperCase())
//       })
//     })
//   })
// })
