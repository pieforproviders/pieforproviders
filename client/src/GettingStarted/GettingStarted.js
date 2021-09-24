import React, { useEffect } from 'react'
import { Card, Typography } from 'antd'
import useHotjar from 'react-use-hotjar'
import { useApiResponse } from '_shared/_hooks/useApiResponse'
import Icon from '@material-ui/core/Icon'
import AssignmentIcon from '@material-ui/icons/Assignment'
import BusinessIcon from '@material-ui/icons/Business'
import CloudUploadIcon from '@material-ui/icons/CloudUpload'
import PlaylistAddIcon from '@material-ui/icons/PlaylistAdd'
import { useTranslation } from 'react-i18next'
import { PaddedButton } from '_shared/PaddedButton'
import { useDispatch, useSelector } from 'react-redux'
import { setUser } from '_reducers/userReducer'

// NB: we're using CSS grid instead of Ant grid for these cards
// because Ant grid doesn't flow into the next row when there are
// more cards than columns

export function GettingStarted() {
  const dispatch = useDispatch()
  const { identifyHotjar } = useHotjar()
  const { token, user } = useSelector(state => ({
    token: state.auth.token,
    user: state.user
  }))
  const { t } = useTranslation()
  const { makeRequest } = useApiResponse()

  useEffect(() => {
    const getUser = async () => {
      const response = await makeRequest({
        type: 'get',
        url: '/api/v1/profile',
        headers: {
          Authorization: token
        }
      })

      if (response.ok) {
        const resp = await response.json()
        dispatch(setUser(resp))
        identifyHotjar(resp.id ?? null)
      }
    }

    if (Object.keys(user).length === 0) {
      getUser()
    }
    // we only want this to run once; making the makeRequest hook a dependency causes an infinite re-run of this query
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [])

  const cards = [
    {
      description: t('gettingStartedBusinesses'),
      icon: <BusinessIcon fontSize="large" />,
      title: t('gettingStartedBusinessesTitle')
    },
    {
      description: t('gettingStartedUpload'),
      icon: <CloudUploadIcon fontSize="large" />,
      title: t('gettingStartedUploadTitle')
    },
    {
      description: t('gettingStartedDetails'),
      icon: <PlaylistAddIcon fontSize="large" />,
      title: t('gettingStartedDetailsTitle')
    },
    {
      description: t('gettingStartedAgencies'),
      icon: <AssignmentIcon fontSize="large" />,
      title: t('gettingStartedAgenciesTitle')
    }
  ]
  return (
    <div className="getting-started text-gray1">
      <div className="getting-started-content-area">
        <Typography.Title className="text-center h1-large">
          {t('gettingStartedWelcome')}
          {user.greeting_name && `, ${user.greeting_name}!`}
        </Typography.Title>

        <div className="mb-8">
          <Typography.Title level={3}>
            <div className="h3-large">{t('gettingStartedTitle')}</div>
          </Typography.Title>
          <p className="body-2-bold">{t('gettingStartedInstructions')}</p>
        </div>
        <Typography.Title level={3}>
          <div className="h3-large">{t('steps')}</div>
        </Typography.Title>
        <div className="grid grid-cols-1 xs:grid-cols-2 md:grid-cols-4 gap-4 mx-4">
          {cards.map((card, idx) => (
            <Card
              bordered={false}
              className="text-center text-gray1 mb-1"
              key={idx}
            >
              <Icon className="text-primaryBlue">{card.icon}</Icon>
              <p className="mt-4 mb-2 text-gray1 font-semibold">
                {idx + 1}. {card.title}
              </p>
              <p>{card.description}</p>
            </Card>
          ))}
        </div>

        <div className="mt-8 text-center">
          <PaddedButton text={t('gettingStartedButton')} />
        </div>
      </div>
    </div>
  )
}
