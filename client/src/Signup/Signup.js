import React, { useEffect, useState } from 'react'
import ReactGA from 'react-ga'
import { Link } from 'react-router-dom'
import CheckboxInput from '_shared/forms/CheckboxInput'
import DropdownInput from '_shared/forms/DropdownInput'
import Input from 'react-phone-number-input/input'
import Button from '_shared/forms/Button.js'
import TextInput from '_shared/forms/TextInput.js'
import ToggleInput from '_shared/forms/ToggleInput'
import piefulltanlogo from '_assets/piefulltanlogo.svg'
import '_assets/styles/layouts/signup.css'

/**
 * User Signup Page
 */

export function Signup() {
  const [userData, setUserData] = useState({
    fullName: '',
    email: '',
    language: 'en',
    multiBusiness: '',
    organization: '',
    password: '',
    passwordConfirmation: '',
    phoneType: 'cellPhone',
    serviceAgreementAccepted: false
  })

  const handleSubmit = event => {
    event.preventDefault()
    console.log(`We're gonna post ${JSON.stringify(userData)}`)
  }

  useEffect(() => {
    if (process.env.NODE_ENV === 'production') {
      ReactGA.pageview(window.location.pathname + window.location.search)
      ReactGA.event({
        category: 'Guest',
        action: 'Landed on Signup Page'
      })
    }
  }, [])

  const TermsLabel = () => {
    return (
      <>
        I have read and agree to the{' '}
        <a
          href="https://www.pieforproviders.com/terms/"
          target="_blank"
          rel="noopener noreferrer"
        >
          Pie for Providers Terms of Use
        </a>
      </>
    )
  }

  return (
    <div id="layout-signup">
      <div className="left" aria-hidden="true" />
      <main role="region" className="right">
        {/* TODO: language switcher */}
        <p className="text-right mt-4">English</p>
        <img
          className="w-24 medium:w-48 mx-auto"
          alt="Pie for Providers logo"
          src={piefulltanlogo}
        />
        <h1 className="visually-hidden">Log In</h1>
        <p className="text-center my-8 medium:mt-16 large:text-left large:mt-12 large:mb-6">
          <span className="font-bold underline uppercase">Sign Up</span> or{' '}
          <Link to="/login" className="uppercase">
            Log In
          </Link>
        </p>
        <form onSubmit={handleSubmit}>
          <TextInput
            containerClasses="mb-4"
            inputId="organization"
            label="Name of organization"
            labelClasses="mb-4"
            onInput={event =>
              setUserData({ ...userData, organization: event.target.value })
            }
            placeholder="Amanda's Daycare"
            required
            value={userData.organization}
          />

          <TextInput
            containerClasses="mb-4"
            inputId="full-name"
            label="Full name"
            labelClasses="mb-4"
            onInput={event =>
              setUserData({ ...userData, fullName: event.target.value })
            }
            placeholder="Amanda Diaz"
            required
            value={userData.fullName}
          />

          <TextInput
            containerClasses="mb-4"
            inputId="greeting-name"
            label="What should we call you?"
            labelClasses="mb-4"
            onInput={event =>
              setUserData({ ...userData, greetingName: event.target.value })
            }
            placeholder="Amanda"
            required
            value={userData.greetingName}
          />

          <DropdownInput
            inputId="multi-business"
            label="Are you managing subsidy cases for multiple child care businesses?"
            labelClasses="mb-4"
            onChange={value => {
              setUserData({ ...userData, multiBusiness: value })
            }}
            options={[
              {
                label: 'Yes, managing multiple child care businesses',
                value: 'yes'
              },
              {
                label: 'No, I am managing 1 child care business only',
                value: 'no'
              }
            ]}
            placeholder="Choose one"
            required
            selectClasses="mb-4"
            value={userData.multiBusiness}
          />

          <div className="phone-input">
            <div className="mb-4" id="phone-type-label">
              Phone number (we will only call or text if you want us to)
            </div>
            <div className="grid">
              <DropdownInput
                combo
                inputId="phone-type"
                options={[
                  { label: 'Cell', value: 'cellPhone' },
                  { label: 'Home', value: 'homePhone' },
                  { label: 'Work', value: 'workPhone' }
                ]}
                selectClasses="mb-4"
                defaultOption="cellPhone"
                value={userData.phoneType}
                onChange={value =>
                  setUserData({ ...userData, phoneType: value })
                }
              />
              <Input
                aria-labelledby="phone-type-label"
                className="leading-4 phone-input-combo mb-4"
                country="US"
                id="phone"
                onChange={value =>
                  setUserData({ ...userData, phoneNumber: value })
                }
                placeholder="888-888-8888"
                type="tel"
                value={userData.phoneNumber}
              />
            </div>
          </div>

          <ToggleInput
            defaultOption={userData.language}
            inputId="language"
            label="Preferred language"
            labelClasses="mb-4"
            onChange={value => setUserData({ ...userData, language: value })}
            options={[
              {
                label: 'English',
                value: 'en'
              },
              {
                label: 'Español',
                value: 'es'
              }
            ]}
            required
            selectClasses="grid-cols-2 mb-4"
          />

          <TextInput
            containerClasses="mb-4"
            inputId="email"
            label="Email"
            labelClasses="mb-4"
            onInput={event =>
              setUserData({ ...userData, email: event.target.value })
            }
            placeholder="amanda@gmail.com"
            required
            type="email"
            value={userData.email}
          />

          <TextInput
            containerClasses="mb-4"
            inputId="password"
            label="Password"
            labelClasses="mb-4"
            onInput={event =>
              setUserData({ ...userData, password: event.target.value })
            }
            type="password"
            placeholder="8+ characters, letters, and numbers"
            required
            value={userData.password}
          />

          <TextInput
            containerClasses="mb-4"
            inputId="password-confirmation"
            label="Confirm password"
            labelClasses="mb-4"
            onInput={event =>
              setUserData({
                ...userData,
                passwordConfirmation: event.target.value
              })
            }
            type="password"
            placeholder="Confirm your password"
            required
            value={userData.passwordConfirmation}
          />
          <div className="medium:text-center">
            <CheckboxInput
              containerClasses="mt-8 large:text-left"
              checked={userData.serviceAgreementAccepted}
              inputId="service-agreement-accepted"
              label={<TermsLabel />}
              onChange={() => {
                setUserData({
                  ...userData,
                  serviceAgreementAccepted: !userData.serviceAgreementAccepted
                })
              }}
              required
            />

            <Button
              buttonClasses="submit block text-center mx-auto my-10"
              label="Sign Up"
              type="submit"
            />
          </div>
        </form>
      </main>
    </div>
  )
}
