import React, { useEffect, useState } from 'react'
import { useTranslation } from 'react-i18next'
import { useApiResponse } from '_shared/_hooks/useApiResponse'
import { useDispatch, useSelector } from 'react-redux'
import { Typography } from 'antd'
import { setUser } from '_reducers/userReducer'
import DashboardStats from './DashboardStats'
import DashboardTable from './DashboardTable'

export function Dashboard() {
  const dispatch = useDispatch()
  const { token, user } = useSelector(state => ({
    token: state.auth.token,
    user: state.user
  }))
  const [dashboardData, setDashboardData] = useState({
    tableData: [],
    summaryData: []
  })
  const { makeRequest } = useApiResponse()
  const { t } = useTranslation()

  const reduceTableData = res => {
    return res.reduce((acc, cv, index) => {
      const {
        full_name: childName = '',
        approvals: [{ case_number: caseNumber = '' }],
        business: { name: business = '' },
        attendance_rate: rate = '',
        attendance_risk: riskCategory = '',
        guaranteed_revenue: guaranteedRevenue = 0,
        max_approved_revenue: maxRevenue = 0,
        potential_revenue: potentialRevenue = 0
      } = cv

      return [
        ...acc,
        {
          key: index,
          childName,
          caseNumber,
          business,
          attendanceRate: { rate, riskCategory },
          guaranteedRevenue,
          maxRevenue,
          potentialRevenue
        }
      ]
    }, [])
  }

  const reduceSummaryData = data => {
    return data.reduce(
      (acc, cv) => {
        const {
          guaranteedRevenue,
          maxRevenue,
          potentialRevenue,
          attendanceRate: { rate }
        } = cv
        return {
          guaranteedRevenueTotal:
            acc.guaranteedRevenueTotal + guaranteedRevenue,
          potentialRevenueTotal: acc.potentialRevenueTotal + potentialRevenue,
          maxApprovedRevenueTotal: acc.maxApprovedRevenueTotal + maxRevenue,
          attendanceRateTotal: acc.attendanceRateTotal + rate
        }
      },
      {
        guaranteedRevenueTotal: 0,
        potentialRevenueTotal: 0,
        maxApprovedRevenueTotal: 0,
        attendanceRateTotal: 0
      }
    )
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
        // NOTE: user state will be used to configure these
        const tableData = reduceTableData(parsedResponse)
        const summaryDataTotals = reduceSummaryData(tableData)
        const currencyFormatter = new Intl.NumberFormat('en-US', {
          style: 'currency',
          currency: 'USD'
        })
        const summaryData = [
          {
            title: t('guaranteedRevenue'),
            stat: `${currencyFormatter.format(
              summaryDataTotals.guaranteedRevenueTotal.toFixed(2)
            )}`,
            definition: t('guaranteedRevenueDef')
          },
          {
            title: t('potentialRevenue'),
            stat: `${currencyFormatter.format(
              summaryDataTotals.potentialRevenueTotal.toFixed(2)
            )}`,
            definition: t('potentialRevenueDef')
          },
          {
            title: t('maxApprovedRevenue'),
            stat: `${currencyFormatter.format(
              summaryDataTotals.maxApprovedRevenueTotal.toFixed(2)
            )}`,
            definition: t('maxApprovedRevenueDef')
          },
          {
            title: t('attendanceRate'),
            stat: `${
              (summaryDataTotals.attendanceRateTotal / tableData.length) * 100
            }%`,
            definition: t('attendanceRateDef')
          }
        ]

        setDashboardData({ tableData, summaryData })
      }
    }

    if (Object.keys(user).length === 0) {
      getUserData()
    }
    // Interesting re: refresh tokens - https://github.com/waiting-for-dev/devise-jwt/issues/7#issuecomment-322115576
    getDashboardData()
    // still haven't found a better way around this - sometimes we really do
    // only want the useEffect to fire on the first component load
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [])

  return (
    <div className="dashboard sm:mx-8">
      <div className="dashboard-title m-2">
        <Typography.Title>{t('dashboardTitle')}</Typography.Title>
        <Typography.Text className="md-3 text-base">
          {t('revenueProjections')}
        </Typography.Text>
      </div>
      <DashboardStats summaryData={dashboardData.summaryData} />
      <DashboardTable
        tableData={dashboardData.tableData}
        userState={user.state ?? ''}
      />
    </div>
  )
}
