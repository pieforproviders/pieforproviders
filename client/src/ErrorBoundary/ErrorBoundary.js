import React, { Component } from 'react'
import PropTypes from 'prop-types'
import * as Sentry from '@sentry/browser'
import { withTranslation } from 'react-i18next'

class ErrorBoundary extends Component {
  constructor(props) {
    super(props)
    this.state = { eventId: null }
  }

  static getDerivedStateFromError() {
    return { hasError: true }
  }

  componentDidCatch(error, errorInfo) {
    // TODO: Add user info when we have user authentication ready
    // Ref: https://docs.sentry.io/platforms/javascript/#capturing-the-user
    Sentry.withScope(scope => {
      scope.setExtras(errorInfo)
      const eventId = Sentry.captureException(error)
      this.setState({ eventId })
    })
  }

  render() {
    const { t } = this.props

    if (this.state.hasError) {
      // TODO: add some language here for error handling for users
      return (
        <button
          className="border border-primaryBlue"
          onClick={() =>
            Sentry.showReportDialog({ eventId: this.state.eventId })
          }
        >
          {t('reportFeedback')}
        </button>
      )
    }

    return this.props.children
  }
}

ErrorBoundary.propTypes = {
  t: PropTypes.func.isRequired,
  children: PropTypes.node.isRequired
}

export const ErrorBoundaryComponent = withTranslation()(ErrorBoundary)
