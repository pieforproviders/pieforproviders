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
  const currencyFormatter = new Intl.NumberFormat('en-US', {
    style: 'currency',
    currency: 'USD',
    minimumFractionDigits: 0
  })
  const { token, user } = useSelector(state => ({
    token: state.auth.token,
    user: state.user
  }))
  const [summaryDataTotals, setSummaryTotals] = useState({
    guaranteedRevenueTotal: 0,
    potentialRevenueTotal: 0,
    maxApprovedRevenueTotal: 0,
    attendanceRateTotal: 0
  })
  const [summaryData, setSummaryData] = useState([])
  const [tableData, setTableData] = useState([])
  const { makeRequest } = useApiResponse()
  const { t, i18n } = useTranslation()

  const generateSummaryData = (totals = summaryDataTotals, td = tableData) => {
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

  i18n.on('languageChanged', () => setSummaryData(generateSummaryData()))

  const reduceTableData = res => {
    return res.reduce((acc, cv, index) => {
      // if (user.state === "NE") {
      //   debugger
      //   const {

      //   } = cv
      // }
      const {
        full_name: childName = '',
        approvals: [{ case_number: cNumber = '' }],
        business: { name: business = '' },
        attendance_rate: rate = '',
        attendance_risk: riskCategory = '',
        guaranteed_revenue: guaranteedRevenue = 0,
        max_approved_revenue: maxApprovedRevenue = 0,
        potential_revenue: potentialRevenue = 0
      } = cv

      return [
        ...acc,
        {
          key: index,
          childName,
          cNumber,
          business,
          attendanceRate: { rate, riskCategory },
          guaranteedRevenue,
          maxApprovedRevenue,
          potentialRevenue
        }
      ]
    }, [])
  }

  const reduceSummaryData = data => {
    debugger;
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
        maxApprovedRevenueTotal: acc.maxApprovedRevenueTotal + maxApprovedRevenue,
        attendanceRateTotal: acc.attendanceRateTotal + rate
      }
    }, summaryDataTotals)
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
        setSummaryTotals(summaryDataTotals)
        setTableData(tableData)
        setSummaryData(generateSummaryData(summaryDataTotals, tableData))
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
  }, [user])

  return (
    <div className="dashboard sm:mx-8">
      <div className="dashboard-title m-2">
        <Typography.Title>{t('dashboardTitle')}</Typography.Title>
        <Typography.Text className="md-3 text-base">
          {t('revenueProjections')}
        </Typography.Text>
      </div>
      <DashboardStats summaryData={summaryData} />
      <DashboardTable tableData={tableData} userState={user.state ?? ''} />
    </div>
  )
}
