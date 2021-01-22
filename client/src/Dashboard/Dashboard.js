import React, { useEffect, useState } from 'react'
import { useTranslation } from 'react-i18next'
import { useApiResponse } from '_shared/_hooks/useApiResponse'
import { useDispatch, useSelector } from 'react-redux'
import { Button, Typography } from 'antd'
import { setUser } from '_reducers/userReducer'
import DashboardStats from './DashboardStats'
import DashboardTable from './DashboardTable'
import '_assets/styles/dashboard-overrides.css'

export function Dashboard() {
  const dispatch = useDispatch()
  const currencyFormatter = new Intl.NumberFormat('en-US', {
    style: 'currency',
    currency: 'USD',
    minimumFractionDigits: 0
  })
  const { token, user } = useSelector(state => ({
    token: state.auth.token,
    user: state.user
  }))

  const summaryDataTotalsConfig = {
    ne: {
      earnedRevenueTotal: 0,
      estimatedRevenueTotal: 0,
      maxRevenueTotal: 0,
      totalApprovedTotal: 0,
      transportationRevenueTotal: 0
    },
    default: {
      guaranteedRevenueTotal: 0,
      potentialRevenueTotal: 0,
      maxApprovedRevenueTotal: 0,
      attendanceRateTotal: 0
    }
  }
  const [summaryDataTotals, setSummaryTotals] = useState(
    summaryDataTotalsConfig[`${user.state === 'NE' ? 'ne' : 'default'}`]
  )
  const [summaryData, setSummaryData] = useState([])
  const [tableData, setTableData] = useState([])
  const [dates, setDates] = useState({ asOf: '', dateFilter: '' })
  const { makeRequest } = useApiResponse()
  const { t, i18n } = useTranslation()

  const generateSummaryData = (td = tableData, totals = summaryDataTotals) => {
    if (user.state === 'NE' && totals.earnedRevenueTotal >= 0) {
      return [
        {
          title: t('earnedRevenue'),
          stat: `${currencyFormatter.format(
            totals.earnedRevenueTotal.toFixed()
          )}`,
          definition: t('earnedRevenueDef')
        },
        {
          title: t('estimatedRevenue'),
          stat: `${currencyFormatter.format(
            totals.estimatedRevenueTotal.toFixed()
          )}`,
          definition: t(`estimatedRevenueDef`)
        },
        {
          title: t(`maxRevenue`),
          stat: `${currencyFormatter.format(totals.maxRevenueTotal.toFixed())}`,
          definition: t(`maxRevenueDef`)
        },
        [
          {
            title: t(`totalApproved`),
            stat: `${currencyFormatter.format(
              totals.totalApprovedTotal.toFixed()
            )}`,
            definition: t(`totalApprovedDef`)
          },
          {
            title: t(`transportation`),
            stat: `${currencyFormatter.format(
              totals.transportationRevenueTotal.toFixed()
            )}`,
            definition: t(`transportationDef`)
          }
        ]
      ]
    } else if (totals.guaranteedRevenueTotal >= 0) {
      return [
        {
          title: t('guaranteedRevenue'),
          stat: `${currencyFormatter.format(
            totals.guaranteedRevenueTotal.toFixed()
          )}`,
          definition: t('guaranteedRevenueDef')
        },
        {
          title: t('potentialRevenue'),
          stat: `${currencyFormatter.format(
            totals.potentialRevenueTotal.toFixed()
          )}`,
          definition: t('potentialRevenueDef')
        },
        {
          title: t('maxApprovedRevenue'),
          stat: `${currencyFormatter.format(
            totals.maxApprovedRevenueTotal.toFixed()
          )}`,
          definition: t('maxApprovedRevenueDef')
        },
        {
          title: t('attendanceRate'),
          stat: `${(totals.attendanceRateTotal / td.length) * 100}%`,
          definition: t('attendanceRateDef')
        }
      ]
    }

    return []
  }

  i18n.on('languageChanged', () => setSummaryData(generateSummaryData()))

  const reduceTableData = res => {
    return res.flatMap(userResponse => {
      return userResponse.businesses.flatMap(business => {
        return business.cases.flatMap((childCase, index) => {
          return user.state === 'NE'
            ? {
                key: index,
                absences: childCase.absences ?? '',
                child: {
                  childName: childCase.full_name ?? '',
                  cNumber: childCase.case_number ?? '',
                  business: business.name ?? ''
                },
                earnedRevenue: childCase.earned_revenue ?? '',
                estimatedRevenue: childCase.estimated_revenue,
                fullDays: {
                  text: childCase.full_days ?? '',
                  tag: childCase.attendance_risk ?? ''
                },
                hours: childCase.hours ?? '',
                transportationRevenue: childCase.transportation_revenue ?? ''
              }
            : {
                key: index,
                childName: childCase.full_name ?? '',
                cNumber: childCase.case_number ?? '',
                business: business.name ?? '',
                attendanceRate: {
                  rate: childCase.attendance_rate ?? '',
                  riskCategory: childCase.attendance_risk ?? ''
                },
                guaranteedRevenue: childCase.guaranteed_revenue ?? '',
                maxApprovedRevenue: childCase.max_approved_revenue ?? '',
                potentialRevenue: childCase.potential_revenue ?? ''
              }
        })
      })
    })
  }

  const reduceSummaryData = (data, res) => {
    if (user.state === 'NE') {
      return {
        ...data.reduce((acc, cv) => {
          return {
            ...acc,
            earnedRevenueTotal: acc.earnedRevenueTotal + cv.earnedRevenue,
            estimatedRevenueTotal:
              acc.estimatedRevenueTotal + cv.estimatedRevenue,
            transportationRevenueTotal:
              acc.transportationRevenueTotal +
              Number(cv.transportationRevenue.match(/([0-9]+.[0-9]{2})/)[0])
          }
        }, summaryDataTotalsConfig['ne']),
        ...res.reduce((acc, cv) => {
          return {
            maxRevenueTotal: acc.maxRevenueTotal ?? 0 + cv.max_revenue,
            totalApprovedTotal: acc.totalApprovedTotal ?? 0 + cv.total_approved
          }
        }, {})
      }
    }
    return data.reduce((acc, cv) => {
      const {
        guaranteedRevenue,
        maxApprovedRevenue,
        potentialRevenue,
        attendanceRate: { rate }
      } = cv

      return {
        guaranteedRevenueTotal: acc.guaranteedRevenueTotal + guaranteedRevenue,
        potentialRevenueTotal: acc.potentialRevenueTotal + potentialRevenue,
        maxApprovedRevenueTotal:
          acc.maxApprovedRevenueTotal + maxApprovedRevenue,
        attendanceRateTotal: acc.attendanceRateTotal + rate
      }
    }, summaryDataTotalsConfig['default'])
  }

  const reduceAsOfDate = res => {
    const date = new Date(
      res.reduce((user1, user2) => {
        return new Date(user1.as_of) > new Date(user2.as_of) ? user1 : user2
      }).as_of
    )

    return {
      asOf: date.toLocaleDateString('default', {
        month: 'short',
        day: 'numeric'
      }),
      dateFilter: new Date().toLocaleDateString('default', {
        month: 'short',
        year: 'numeric'
      })
    }
  }

  useEffect(() => {
    const getUserData = async () => {
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
        setSummaryTotals(
          summaryDataTotalsConfig[`${resp.state === 'NE' ? 'ne' : 'default'}`]
        )
      }
    }

    const getDashboardData = async () => {
      const response = await makeRequest({
        type: 'get',
        url: '/api/v1/case_list_for_dashboard',
        headers: { Authorization: token }
      })
      const parsedResponse = await response.json()

      if (!parsedResponse.error) {
        const tableData = reduceTableData(parsedResponse)
        const updatedSummaryDataTotals = reduceSummaryData(
          tableData,
          parsedResponse
        )
        setDates(reduceAsOfDate(parsedResponse))
        setSummaryTotals(updatedSummaryDataTotals)
        setSummaryData(generateSummaryData(tableData, updatedSummaryDataTotals))
        setTableData(tableData)
      }
    }

    if (Object.keys(user).length !== 0) {
      getDashboardData()
    }

    if (Object.keys(user).length === 0) {
      getUserData()
    }
    // Interesting re: refresh tokens - https://github.com/waiting-for-dev/devise-jwt/issues/7#issuecomment-322115576
    // still haven't found a better way around this - sometimes we really do
    // only want the useEffect to fire on the first component load
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [user])

  return (
    <div className="dashboard sm:mx-8">
      <div className="dashboard-title m-2">
        <div className="flex items-center mb-3">
          <Typography.Title className="dashboard-title mr-4">
            {t('dashboardTitle')}
          </Typography.Title>
          <Button className="date-filter-button mr-2 text-base py-2 px-4">
            {dates.dateFilter}
          </Button>
          <Typography.Text className="text-gray3">{`As of: ${dates.asOf}`}</Typography.Text>
        </div>
        <Typography.Text className="md-3 text-base">
          {t('revenueProjections')}
        </Typography.Text>
      </div>
      <DashboardStats summaryData={summaryData} />
      <DashboardTable tableData={tableData} userState={user.state ?? ''} />
    </div>
  )
}
