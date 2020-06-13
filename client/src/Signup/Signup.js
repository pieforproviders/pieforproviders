import React, { useEffect, useState } from 'react'
import ReactGA from 'react-ga'
import { Link } from 'react-router-dom'
import CheckboxInput from '_shared/forms/CheckboxInput'
import DropdownInput from '_shared/forms/DropdownInput'
import Button from '_shared/forms/Button.js'
import TextInput from '_shared/forms/TextInput.js'
import ToggleInput from '_shared/forms/ToggleInput'
import ValidationError from '_shared/forms/ValidationError'
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
    multiBusiness: null,
    organization: null,
    password: null,
    passwordConfirmation: null,
    phoneType: null,
    phoneNumber: null,
    serviceAgreementAccepted: false
  })

  // deconstructs the react-hook-form elements we need
  const {
    errors,
    formState,
    handleSubmit,
    register,
    triggerValidation,
    watch
  } = useForm({
    mode: 'onBlur'
  })

  // we'll use isValid to see if we should allow the submit button to be pressed
  const { isValid } = formState

  const onSubmit = data => {
    console.log(`userData JSON: ${JSON.stringify(userData)}`)
    console.log('data', data)
  }

  // Google Analytics
  useEffect(() => {
    if (process.env.NODE_ENV === 'production') {
      ReactGA.pageview(window.location.pathname + window.location.search)
      ReactGA.event({
        category: 'Guest',
        action: 'Landed on Signup Page'
      })
    }
  }, [])

  // Label for the Terms and Conditions checkbox with a link embedded
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
            defaultValue={userData.organization}
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
          />

          <TextInput
            containerClasses="mb-4"
            defaultValue={userData.fullName}
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
          />

          <TextInput
            containerClasses="mb-4"
            defaultValue={userData.greetingName}
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
          />

          <DropdownInput
            containerClasses="mb-4"
            defaultValue={userData.multiBusiness}
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
            register={register({
              required: 'Single or multi-business option is required.'
            })}
            required
          />

          {/* 
            TODO: Refactor combo boxes into their own component
            Combo box input; dropdown on the left, text on the right
          */}
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
                showValidationError={false}
              />
              <TextInput
                aria-labelledby="phone-type-label"
                comboSide="right"
                defaultValue={userData.phoneNumber}
                errors={errors.phoneNumber}
                inputId="phoneNumber"
                onInput={event => {
                  // TODO: refactor this into a reusable masker?
                  // masks input to US phone number format
                  var x = event.target.value
                    .replace(/\D/g, '')
                    .match(/(\d{0,3})(\d{0,3})(\d{0,4})/)
                  event.target.value = !x[2]
                    ? x[1]
                    : '(' + x[1] + ') ' + x[2] + (x[3] ? '-' + x[3] : '')
                  setUserData({ ...userData, phoneNumber: event.target.value })
                }}
                placeholder="(888) 888-8888"
                register={register({
                  pattern: {
                    value: /(?:\d{1}\s)?\(?(\d{3})\)?-?\s?(\d{3})-?\s?(\d{4})/,
                    message: 'Please provide a valid phone number.'
                  }
                })}
                showValidationError={false}
                type="tel"
              />
            </div>
            {/*
              places validationError on the parent component so we don't get
              multiple error messages or misplaced messages; the phoneType box should
              be highlighted like an error if the phoneNumber is invalid, but
              the message only needs to be displayed once for the whole "fieldset"
             */}
            {errors.phoneNumber && (
              <ValidationError errorMessage={errors.phoneNumber.message} />
            )}
          </div>

          <ToggleInput
            errors={errors.language}
            inputId="language"
            label="Preferred language"
            labelClasses="mb-4"
            onChange={event =>
              setUserData({ ...userData, language: event.target.value })
            }
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
            defaultValue={userData.email}
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
          />

          <TextInput
            containerClasses="mb-4"
            defaultValue={userData.password}
            errors={errors.password}
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
          />

          <TextInput
            containerClasses="mb-4"
            defaultValue={userData.passwordConfirmation}
            errors={errors.passwordConfirmation}
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
              validate: value =>
                value === watch('password') ||
                'Password confirmation must match password'
            })}
            required
          />

          <div className="medium:text-center">
            <CheckboxInput
              containerClasses="mt-8 large:text-left"
              checked={userData.serviceAgreementAccepted}
              errors={errors.serviceAgreementAccepted}
              inputId="serviceAgreementAccepted"
              label={<TermsLabel />}
              onChange={() => {
                // adds a validation trigger on change so the user doesn't have to
                // click away from the checkbox before clicking the submit button
                triggerValidation('serviceAgreementAccepted')
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
              disabled={!isValid} // disabled until the form input is valid
              label="Sign Up"
              type="submit"
            />
          </div>
        </form>
      </main>
    </div>
  )
}
