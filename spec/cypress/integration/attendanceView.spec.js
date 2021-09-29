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
// Date now - 2 hrs
const checkOut = new Date(Date.now() - 7200000)
let childFullName

const weekPickerText = (date = dayjs()) =>
  `${date.weekday(0).format('MMM D')} - ${date.weekday(6).format('MMM D')}`

describe('AttendanceView', () => {
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
      cy.viewport(500, 500)
      cy.contains(childFullName)
      cy.contains('4 hrs 0 mins')
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
    })
    it('allows you to view last week attendance', () => {
      cy.get('[data-cy=backWeekButton]').click()
      cy.contains(weekPickerText(dayjs().weekday(-7)))
    })

    it('allows you to view next week attendance', () => {
      cy.get('[data-cy=forwardWeekButton]').click()
      cy.contains(weekPickerText(dayjs().weekday(7)))
    })
  })
})
