import React, { useEffect, useState } from 'react'
import ReactGA from 'react-ga'
import { Link } from 'react-router-dom'
import CheckboxInput from '_shared/forms/CheckboxInput'
import DropdownInput from '_shared/forms/DropdownInput'
import Button from '_shared/forms/Button.js'
import TextInput from '_shared/forms/TextInput.js'
import ToggleInput from '_shared/forms/ToggleInput'
import piefulltanlogo from '_assets/piefulltanlogo.svg'
import { useForm } from 'react-hook-form'
import '_assets/styles/layouts/signup.css'

/**
 * User Signup Page
 */

export function Signup() {
  const [userData, setUserData] = useState({
    fullName: null,
    greetingName: null,
    email: null,
    language: 'en',
    multiBusiness: '',
    organization: null,
    password: null,
    passwordConfirmation: null,
    phoneType: 'cellPhone',
    phoneNumber: null,
    serviceAgreementAccepted: false
  })

  const { register, handleSubmit, watch, errors } = useForm({
    mode: 'onChange'
  })

  const onSubmit = data => {
    console.log(`userData JSON: ${JSON.stringify(userData)}`)
    console.log('data', data)
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
          <span className="font-bold uppercase">Sign Up</span> or{' '}
          <Link to="/login" className="uppercase">
            Log In
          </Link>
        </p>
        <form onSubmit={handleSubmit(onSubmit)}>
          <TextInput
            containerClasses="mb-4"
            errors={errors.organization}
            inputId="organization"
            label="Name of organization"
            labelClasses="mb-4"
            onInput={event =>
              setUserData({ ...userData, organization: event.target.value })
            }
            placeholder="Amanda's Daycare"
            register={register({
              required: 'Name of organization is required.'
            })}
            required
            value={userData.organization}
          />

          <TextInput
            containerClasses="mb-4"
            errors={errors.fullName}
            inputId="fullName"
            label="Full name"
            labelClasses="mb-4"
            onInput={event =>
              setUserData({ ...userData, fullName: event.target.value })
            }
            placeholder="Amanda Diaz"
            register={register({ required: 'Full name is required.' })}
            required
            value={userData.fullName}
          />

          <TextInput
            containerClasses="mb-4"
            errors={errors.greetingName}
            inputId="greetingName"
            label="What should we call you?"
            labelClasses="mb-4"
            onInput={event =>
              setUserData({ ...userData, greetingName: event.target.value })
            }
            placeholder="Amanda"
            register={register({ required: 'Greeting name is required.' })}
            required
            value={userData.greetingName}
          />

          <DropdownInput
            containerClasses="mb-4"
            errors={errors.multiBusiness}
            inputId="multiBusiness"
            label="Are you managing subsidy cases for multiple child care businesses?"
            labelClasses="mb-4"
            onChange={event => {
              setUserData({ ...userData, multiBusiness: event.target.value })
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
            register={register({ required: true })}
            required
            value={userData.multiBusiness}
          />

          <div className="phone-input mb-4">
            <label
              htmlFor="phoneType"
              className="block mb-4"
              id="phone-type-label"
            >
              Phone number (we will only call or text if you want us to)
            </label>
            <div className="grid">
              <DropdownInput
                comboSide="left"
                errors={errors.phoneNumber}
                inputId="phoneType"
                options={[
                  { label: 'Cell', value: 'cellPhone' },
                  { label: 'Home', value: 'homePhone' },
                  { label: 'Work', value: 'workPhone' }
                ]}
                onChange={event =>
                  setUserData({ ...userData, phoneType: event.target.value })
                }
                value={userData.phoneType}
              />
              <TextInput
                aria-labelledby="phone-type-label"
                comboSide="right"
                errors={errors.phoneNumber}
                inputId="phoneNumber"
                onInput={event => {
                  setUserData({ ...userData, phoneNumber: event.target.value })
                }}
                placeholder="888-888-8888"
                register={register({
                  pattern: {
                    value: /(?:\d{1}\s)?\(?(\d{3})\)?-?\s?(\d{3})-?\s?(\d{4})/,
                    message: 'Please provide a valid phone number.'
                  }
                })}
                type="tel"
                value={userData.phoneNumber}
              />
            </div>
          </div>

          <ToggleInput
            errors={errors.language}
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
            register={register({ required: 'Language is required' })}
            required
            selectClasses="grid-cols-2"
            selectedOption={userData.language}
          />

          <TextInput
            containerClasses="mb-4"
            errors={errors.email}
            inputId="email"
            label="Email"
            labelClasses="mb-4"
            onInput={event =>
              setUserData({ ...userData, email: event.target.value })
            }
            placeholder="amanda@gmail.com"
            register={register({
              required: 'Email is required',
              pattern: {
                value: /[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?/,
                message: 'Please provide a valid email address'
              }
            })}
            required
            type="email"
            value={userData.email}
          />

          <TextInput
            containerClasses="mb-4"
            inputClasses={errors.password && 'error-input'}
            inputId="password"
            label="Password"
            labelClasses="mb-4"
            onInput={event =>
              setUserData({ ...userData, password: event.target.value })
            }
            type="password"
            placeholder="8+ characters, letters, and numbers"
            register={register({
              required: 'Password is required',
              pattern: {
                value: /^(?=.*\d)(?=.*[a-zA-Z]).{8,}$/,
                message:
                  'Password must be a minimum of 8 characters, and include numbers and letters.'
              }
            })}
            required
            value={userData.password}
          />

          <TextInput
            containerClasses="mb-4"
            inputClasses={errors.passwordConfirmation && 'error-input'}
            inputId="passwordConfirmation"
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
            register={register({
              required: 'Password confirmation is required',
              validate: value => value === watch('password')
            })}
            required
            value={userData.passwordConfirmation}
          />

          <div className="medium:text-center">
            <CheckboxInput
              containerClasses="mt-8 large:text-left"
              checked={userData.serviceAgreementAccepted}
              inputId="serviceAgreementAccepted"
              inputClasses={errors.serviceAgreementAccepted && 'error-input'}
              label={<TermsLabel />}
              onChange={() => {
                setUserData({
                  ...userData,
                  serviceAgreementAccepted: !userData.serviceAgreementAccepted
                })
              }}
              register={register({
                required: 'Please read and agree to our Terms of Service'
              })}
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
