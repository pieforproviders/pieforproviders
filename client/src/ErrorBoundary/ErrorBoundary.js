import React, { Component } from 'react'
import PropTypes from 'prop-types'
import { connect } from 'react-redux'
import { sendSpan } from '../_utils/appSignal'
import { withTranslation } from 'react-i18next'
import { ErrorDisplay } from '../_shared'

class ErrorBoundary extends Component {
  constructor(props) {
    super(props)
    this.state = { hasError: false }
  }

  static getDerivedStateFromError() {
    return { hasError: true }
  }

  componentDidCatch(error, errorInfo) {
    sendSpan({
      tags: {
        userId: this.state.user?.id
      },
      params: errorInfo,
      error
    })
    this.setState({ hasError: true })
  }

  render() {
    if (this.state.hasError) return <ErrorDisplay />

    return this.props.children
  }
}
const mapStateToProps = state => ({ user: state.user })

ErrorBoundary.propTypes = {
  t: PropTypes.func.isRequired,
  children: PropTypes.node.isRequired
}

export const ErrorBoundaryComponent = connect(mapStateToProps)(
  withTranslation()(ErrorBoundary)
)
