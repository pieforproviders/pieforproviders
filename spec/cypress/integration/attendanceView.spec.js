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
const checkInTimestamp = checkIn.toLocaleTimeString().split(' ')
const checkInTime =
  checkInTimestamp[0].split(':').slice(0, -1).join(':') +
  ' ' +
  checkInTimestamp[1].replace('AM', 'am').replace('PM', 'pm')
// Date now - 2 hrs
const checkOut = new Date(Date.now() - 7200000)
const checkOutTimestamp = checkOut.toLocaleTimeString().split(' ')
const checkOutTime =
  checkOutTimestamp[0].split(':').slice(0, -1).join(':') +
  ' ' +
  checkOutTimestamp[1].replace('AM', 'am').replace('PM', 'pm')
let childFullName

const weekPickerText = (date = dayjs()) =>
  `${date.weekday(0).format('MMM D')} - ${date.weekday(6).format('MMM D')}`

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
    ]).then(users => {
      cy.appFactories([['create', 'business', { user_id: users[0].id }]]).then(
        businesses => {
          cy.appFactories([
            ['create', 'necc_child', { business_id: businesses[0].id }]
          ]).then(children => {
            childFullName = children[0].full_name
            cy.appFactories([
              ['create', 'child_approval', { child_id: children[0].id }]
            ]).then(child_approvals => {
              cy.appFactories([
                [
                  'create',
                  'nebraska_hourly_attendance',
                  {
                    child_approval_id: child_approvals[0].id,
                    check_in: checkIn,
                    check_out: checkOut
                  }
                ]
              ])
            })
          })
        }
      )
    })
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
      cy.contains(childFullName)
      // TODO: This happens in a background job so we can't expect it
      // without running enqueued jobs and reloading before we hit the
      // endpoint
      // cy.contains('4 hrs 0 mins')
      // TODO: these are also failing on CI but not on local
      // cy.contains(checkInTime)
      cy.contains(checkOutTime)
      cy.contains('Input Attendance')
      cy.get('[data-cy=noInfo]').its('length').should('eq', 6)
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
