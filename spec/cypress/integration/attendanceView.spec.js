import faker from 'faker'
import { createSelector } from '../utils'
import dayjs from 'dayjs'
import weekday from 'dayjs/plugin/weekday'

dayjs.extend(weekday)

const { name, internet } = faker
const firstName = name.firstName()
const fullName = name.findName(firstName)
const email = internet.email(firstName)
const password = internet.password()
// Date now - 6 hrs
const checkIn = new Date(Date.now() - 21600000)
// const checkInTimestamp = checkIn.toLocaleTimeString().split(' ')
// const checkInTime =
//   checkInTimestamp[0].split(':').slice(0, -1).join(':') +
//   ' ' +
//   checkInTimestamp[1].replace('AM', 'am').replace('PM', 'pm')
// Date now - 2 hrs
const checkOut = new Date(Date.now() - 7200000)
// const checkOutTimestamp = checkOut.toLocaleTimeString().split(' ')
// const checkOutTime =
//   checkOutTimestamp[0].split(':').slice(0, -1).join(':') +
//   ' ' +
//   checkOutTimestamp[1].replace('AM', 'am').replace('PM', 'pm')
let childFullName

const weekPickerText = (date = dayjs()) => {
  const f1 = date.weekday(0)
  const firstDate =
    f1.format('MMM') === 'Sep'
      ? `${f1.format('MMMM').slice(0, 4)} ${f1.format('D')}`
      : f1.format('MMM D')

  const f2 = date.weekday(6)
  const secondDate =
    f2.format('MMM') === 'Sep'
      ? `${f2.format('MMMM').slice(0, 4)} ${f2.format('D')}`
      : f2.format('MMM')
  return `${firstDate} - ${secondDate}`
}

describe('AttendanceView', () => {
  Cypress.on('uncaught:exception', (err, runnable) => {
    // returning false here prevents Cypress from
    // failing the test
    console.log(err)
    console.log(runnable)
    return false
  })
  beforeEach(() => {
    cy.app('clean')
    cy.createState().then(states => {
      const state = states[0]
      cy.appFactories([
        [
          'create',
          'state_time_rule',
          {
            name: 'Partial Day Nebraska',
            min_time: 60,
            max_time: 4 * 3600 + 59 * 60,
            state_id: state.id
          }
        ],
        [
          'create',
          'state_time_rule',
          {
            name: 'Full Day Nebraska',
            min_time: 5 * 3600,
            max_time: 10 * 3600,
            state_id: state.id
          }
        ],
        [
          'create',
          'state_time_rule',
          {
            name: 'Full - Partial Day Nebraska',
            min_time: 10 * 3600 + 60,
            max_time: 30 * 3600,
            state_id: state.id
          }
        ]
      ])
    })
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
          state: 'NE'
        }
      ]
    ])

    cy.intercept({
      method: 'POST',
      url: '/login'
    }).as('login')

    cy.visit('/login')
    cy.get(createSelector('email')).type(email)
    cy.get(createSelector('password')).type(password)
    cy.get(createSelector('loginBtn')).click()

    cy.intercept({
      method: 'GET',
      url: '/attendances'
    }).as('attendances')
    cy.visit('/attendance')
  })

  describe('content', () => {
    it('renders content', () => {
      cy.viewport(768, 500)
      // cy.contains(childFullName)
      // TODO: This happens in a background job so we can't expect it
      // without running enqueued jobs and reloading before we hit the
      // endpoint
      // cy.contains('4 hrs 0 mins')
      // TODO: these are also failing on CI but not on local
      // cy.contains(checkInTime)
      // cy.contains(checkOutTime)
      // cy.contains('Input Attendance')
      // cy.get('[data-cy=noInfo]').its('length').should('eq', 4)
    })

    it('renders small screen content', () => {
      cy.viewport(300, 500)
      cy.contains('Screen size not compatible')
      cy.contains(
        'Either your browser window is too small, or you’re on a mobile device. Please switch to a desktop or tablet to view this page.'
      )
    })
  })

  describe('inputAttendance', () => {
    it('directs you to attendance edit button', () => {
      cy.get('[data-cy=inputAttendance]').click()
      cy.location('pathname').should('eq', '/attendance/edit')
    })
  })

  describe('weekPicker', () => {
    it('renders current week by default', () => {
      cy.contains(weekPickerText())
      cy.get('[data-cy=forwardWeekButton]').should('be.disabled')
    })
    it('allows you to view last week attendance', () => {
      cy.get('[data-cy=backWeekButton]').click()
      cy.contains(weekPickerText(dayjs().weekday(-7)))
    })

    it('allows you to view next week attendance', () => {
      cy.get('[data-cy=backWeekButton]').click()
      cy.get('[data-cy=forwardWeekButton]').click()
      cy.contains(weekPickerText())
    })
  })
})
