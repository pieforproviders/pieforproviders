import React, { useEffect, useState } from 'react'
import { useTranslation } from 'react-i18next'
import { useApiResponse } from '_shared/_hooks/useApiResponse'
import { useCaseData } from '_shared/_hooks/useCaseData'
import { useDispatch, useSelector } from 'react-redux'
import useHotjar from 'react-use-hotjar'
import { setUser } from '_reducers/userReducer'
import DashboardDefintions from './DashboardDefinitions'
import DashboardStats from './DashboardStats'
import DashboardTable from './DashboardTable'
import DashboardTitle from './DashboardTitle'
import { setCaseData } from '_reducers/casesReducer'

export function Dashboard() {
  const dispatch = useDispatch()
  const { identifyHotjar } = useHotjar()
  const { reduceTableData } = useCaseData()
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
      totalApprovedRevenueWithFamilyFeeTotal: 0
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
  const [dates, setDates] = useState({
    asOf: '',
    dateFilterValue: {
      displayDate: '',
      date: ''
    },
    dateFilterMonths: []
  })
  const [activeKey, setActiveKey] = useState()
  const { makeRequest } = useApiResponse()
  const { t, i18n } = useTranslation()

  const handleDefinitionsPanel = () => setActiveKey(activeKey === 1 ? null : 1)

  const generateSummaryData = (td = tableData, totals = summaryDataTotals) => {
    if (user.state === 'NE') {
      return [
        {
          title: t('earnedRevenue'),
          stat: `${currencyFormatter.format(
            (totals.earnedRevenueTotal || 0).toFixed()
          )}`,
          definition: t('earnedRevenueDef')
        },
        {
          title: t('estimatedRevenue'),
          stat: `${currencyFormatter.format(
            (totals.estimatedRevenueTotal || 0).toFixed()
          )}`,
          definition: t(`estimatedRevenueDef`)
        }
        // {
        //   title: t(`maxRevenue`),
        //   stat: `${
        //     totals.maxRevenueTotal === 'n/a'
        //       ? totals.maxRevenueTotal
        //       : currencyFormatter.format(totals.maxRevenueTotal.toFixed())
        //   }`,
        //   definition: t(`comingSoon`)
        // },
        // [
        //   {
        //     title: t(`totalApproved`),
        //     stat: `${
        //       totals.totalApprovedTotal === 'n/a'
        //         ? totals.totalApprovedTotal
        //         : currencyFormatter.format(totals.totalApprovedTotal.toFixed())
        //     }`,
        //     definition: t(`comingSoon`)
        //   },
        //   {
        //     title: t(`totalApprovedWithFamilyFee`),
        //     stat: 'n/a',
        //     // `${currencyFormatter.format(
        //     //   totals.totalApprovedRevenueWithFamilyFeeTotal.toFixed()
        //     // )}`
        //     definition: t(`comingSoon`)
        //   }
        // ]
      ]
    } else if (totals.guaranteedRevenueTotal >= 0) {
      return [
        {
          title: t('earnedRevenue'),
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

  const reduceSummaryData = (data, res) => {
    if (user.state === 'NE') {
      return {
        ...data.reduce((acc, cv) => {
          return {
            ...acc,
            earnedRevenueTotal: acc.earnedRevenueTotal + cv.earnedRevenue,
            estimatedRevenueTotal:
              acc.estimatedRevenueTotal + cv.estimatedRevenue,
            totalApprovedRevenueWithFamilyFeeTotal:
              acc.totalApprovedWithFamilyFeeTotal
          }
        }, summaryDataTotalsConfig['ne']),
        ...res.reduce((acc, cv) => {
          const setTotal = (total, amount) =>
            total ??
            0 +
              (typeof amount === 'string' || amount instanceof String
                ? 0
                : amount)

          return {
            maxRevenueTotal:
              cv.max_revenue === 'N/A'
                ? 'n/a'
                : setTotal(acc.maxRevenueTotal, cv.max_revenue),
            totalApprovedTotal:
              cv.total_approved === 'N/A'
                ? 'n/a'
                : setTotal(acc.totalApprovedTotal, cv.total_approved)
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

  const makeMonth = (date = new Date()) => ({
    displayDate: date.toLocaleDateString('default', {
      month: 'short',
      year: 'numeric'
    }),
    date: date.toISOString().split('T')[0]
  })

  const reduceDates = (res, fd) => {
    const reduceDate = date_name => {
      return new Date(
        res.reduce((user1, user2) => {
          return new Date(user1.as_of) > new Date(user2.as_of) ? user1 : user2
        })[`${date_name}`]
      )
    }
    const monthDiff = (dateFrom, dateTo) => {
      return (
        dateTo.getMonth() -
        dateFrom.getMonth() +
        12 * (dateTo.getFullYear() - dateFrom.getFullYear())
      )
    }

    const firstMonth = reduceDate('first_approval_effective_date')
    let currentDate = new Date()
    const numOfMonths = monthDiff(firstMonth, currentDate)
    let dateFilterMonths = []
    dateFilterMonths.push(makeMonth(currentDate))

    for (let i = 0; i < numOfMonths; i++) {
      currentDate.setMonth(currentDate.getMonth() - 1)
      dateFilterMonths.push(makeMonth(currentDate))
    }

    return {
      asOf: reduceDate('as_of').toLocaleDateString('default', {
        month: 'short',
        day: 'numeric'
      }),
      dateFilterValue: fd ? makeMonth(new Date(fd)) : makeMonth(),
      dateFilterMonths
    }
  }

  const getDashboardData = async (filterDate = undefined) => {
    const baseUrl = '/api/v1/case_list_for_dashboard'
    const response = await makeRequest({
      type: 'get',
      url: filterDate ? baseUrl + `?filter_date=${filterDate}` : baseUrl,
      headers: { Authorization: token }
    })
    const parsedResponse = await response.json()

    if (!parsedResponse.error) {
      const tableData = reduceTableData(parsedResponse, user)
      const updatedSummaryDataTotals = reduceSummaryData(
        tableData,
        parsedResponse
      )
      const updatedDates = reduceDates(parsedResponse, filterDate)

      dispatch(setCaseData(tableData))
      setDates(updatedDates)
      setSummaryTotals(updatedSummaryDataTotals)
      setSummaryData(generateSummaryData(tableData, updatedSummaryDataTotals))
      setTableData(tableData)
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
        identifyHotjar(resp.id ?? null, resp, console.info)
        setSummaryTotals(
          summaryDataTotalsConfig[`${resp.state === 'NE' ? 'ne' : 'default'}`]
        )
      }
    }

    if (Object.keys(user).length !== 0) {
      getDashboardData(dates.dateFilterValue.date)
    }

    if (Object.keys(user).length === 0) {
      getUserData()
    }
    // Interesting re: refresh tokens - https://github.com/waiting-for-dev/devise-jwt/issues/7#issuecomment-322115576
    // still haven't found a better way around this - sometimes we really do
    // only want the useEffect to fire on the first component load
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [user, dates.dateFilterValue.date])

  return (
    <div className="dashboard sm:mx-8">
      <DashboardTitle dates={dates} setDates={setDates} />
      <DashboardStats summaryData={summaryData} />
      <DashboardTable
        dateFilterValue={dates.dateFilterValue}
        tableData={tableData}
        userState={user.state ?? ''}
        setActiveKey={href => {
          if (activeKey) {
            return
          } else {
            handleDefinitionsPanel()
            setTimeout(() => {
              document.getElementById(href).click()
            }, 200)
          }
        }}
      />
      <DashboardDefintions
        activeKey={activeKey}
        setActiveKey={handleDefinitionsPanel}
      />
    </div>
  )
}
