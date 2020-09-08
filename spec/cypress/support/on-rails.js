import { camelToSnakeCase } from '../utils'

Cypress.Commands.add('appCommands', function (body) {
  cy.log('APP: ' + JSON.stringify(body))
  return cy
    .request({
      method: 'POST',
      url: '/__cypress__/command',
      body: JSON.stringify(body),
      log: true,
      failOnStatusCode: true
    })
    .then(response => {
      return response.body
    })
})

// We're snake casing the name passed to the app command to use the camelCase version
// in Cypress specs (e.g. `cy.app('generateToken')`) and use the snake_case style
// command names in Ruby (e.g. app_commands/generate_token.rb).
Cypress.Commands.add('app', function (name, command_options) {
  return cy
    .appCommands({ name: camelToSnakeCase(name), options: command_options })
    .then(body => {
      return body[0]
    })
})

Cypress.Commands.add('appScenario', function (name, options = {}) {
  return cy.app('scenarios/' + camelToSnakeCase(name), options)
})

Cypress.Commands.add('appEval', function (code) {
  return cy.app('eval', code)
})

Cypress.Commands.add('appFactories', function (options) {
  return cy.app('factory_bot', options)
})

Cypress.on('fail', (err, runnable) => {
  // allow app to generate additional logging data
  Cypress.$.ajax({
    url: '/__cypress__/command',
    data: JSON.stringify({
      name: 'log_fail',
      options: {
        error_message: err.message,
        runnable_full_title: runnable.fullTitle()
      }
    }),
    async: false,
    method: 'POST'
  })

  throw err
})
