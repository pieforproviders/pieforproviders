/* eslint-disable no-debugger */
import React, { useEffect, useState } from 'react'
import { useTranslation } from 'react-i18next'
import { Modal } from 'antd'
import { useApiResponse } from '_shared/_hooks/useApiResponse'
import { useCaseData } from '_shared/_hooks/useCaseData'
import { useProgress } from '_shared/_hooks/useProgress'
import { useDispatch, useSelector } from 'react-redux'
import useHotjar from 'react-use-hotjar'
import runtimeEnv from '@mars/heroku-js-runtime-env'
import { setUser } from '_reducers/userReducer'
import DashboardDefinitions from './DashboardDefinitions'
import DashboardStats from './DashboardStats'
import DashboardTable from './DashboardTable'
import DashboardTitle from './DashboardTitle'
import { setBusinesses } from '_reducers/businessesReducer'
import { setCaseData } from '_reducers/casesReducer'
import { setLoading } from '_reducers/uiReducer'
import Notifications from './Notifications'
import { setFilteredCases } from '_reducers/uiReducer'
import '_assets/styles/notification-modal-overrides.css'

const env = runtimeEnv()

export function Dashboard() {
  const dispatch = useDispatch()
  const { parseResult } = useProgress()
  const { identifyHotjar } = useHotjar()
  const { reduceTableData } = useCaseData()
  const { makeRequest } = useApiResponse()
  const { t, i18n } = useTranslation()
  const currencyFormatter = new Intl.NumberFormat('en-US', {
    style: 'currency',
    currency: 'USD',
    minimumFractionDigits: 0
  })
  const { businesses, token, user, filteredCases, cases } = useSelector(
    state => ({
      businesses: state.businesses,
      token: state.auth.token,
      user: state.user,
      filteredCases: state.ui.filteredCases,
      cases: state.cases
    })
  )

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
  const [notificationMessages, setNotificationMessages] = useState([])
  const [dates, setDates] = useState({
    asOf: '',
    dateFilterValue: {
      displayDate: '',
      date: ''
    },
    dateFilterMonths: []
  })
  const [activeKey, setActiveKey] = useState()
  const [showNotificationsModal, setShowNotificationsModal] = useState(false)

  const handleDefinitionsPanel = () => setActiveKey(activeKey === 1 ? null : 1)

  const generateSummaryData = (td = tableData, totals = summaryDataTotals) => {
    if (user.state === 'NE') {
      return [
        // {
        //   title: t('earnedRevenue'),
        //   stat: `${currencyFormatter.format(
        //     (totals.earnedRevenueTotal || 0).toFixed()
        //   )}`,
        //   definition: t('earnedRevenueDef')
        // },
        // {
        //   title: t('estimatedRevenue'),
        //   stat: `${currencyFormatter.format(
        //     (totals.estimatedRevenueTotal || 0).toFixed()
        //   )}`,
        //   definition: t(`estimatedRevenueDef`)
        // }
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
        // {
        //   title: t('potentialRevenue'),
        //   stat: `${currencyFormatter.format(
        //     totals.potentialRevenueTotal.toFixed()
        //   )}`,
        //   definition: t('potentialRevenueDef')
        // },
        // {
        //   title: t('maxApprovedRevenue'),
        //   stat: `${currencyFormatter.format(
        //     totals.maxApprovedRevenueTotal.toFixed()
        //   )}`,
        //   definition: t('maxApprovedRevenueDef')
        // },
        {
          title: t('attendanceRate'),
          stat: `${((totals.attendanceRateTotal / td.length) * 100).toFixed(
            2
          )}%`,
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
            earnedRevenueTotal: cv.active
              ? acc.earnedRevenueTotal + cv.earnedRevenue
              : acc.earnedRevenueTotal,
            estimatedRevenueTotal: cv.active
              ? acc.estimatedRevenueTotal + cv.estimatedRevenue
              : acc.estimatedRevenueTotal,
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
        res?.reduce((user1, user2) => {
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
      currentDate.setDate(currentDate.getDate() - 31)
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

  const getDashboardData = async ({
    businessIds = [],
    filterDate = undefined
  } = {}) => {
    dispatch(setLoading(true))
    const baseUrl = '/api/v1/case_list_for_dashboard'
    const response = await makeRequest({
      type: 'get',
      url:
        businessIds.length > 0 || filterDate
          ? baseUrl +
            `?filter_date=${filterDate}&business=${businessIds.join(',')}`
          : baseUrl,
      headers: { Authorization: token }
    })
    const parsedResponse = await parseResult(response)

    if (!parsedResponse.error) {
      const tableData = reduceTableData(parsedResponse, user)
      const updatedSummaryDataTotals = reduceSummaryData(
        tableData,
        parsedResponse
      )

      if (dates.asOf === '') {
        const updatedDates = reduceDates(parsedResponse, filterDate)
        setDates(updatedDates)
      }
      dispatch(setFilteredCases(businessIds))
      dispatch(setCaseData(tableData))
      setSummaryTotals(updatedSummaryDataTotals)
      setSummaryData(generateSummaryData(tableData, updatedSummaryDataTotals))
    }
    dispatch(setLoading(false))
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

    const getBusinessData = async () => {
      const response = await makeRequest({
        type: 'get',
        url: '/api/v1/businesses',
        headers: {
          Authorization: token
        }
      })

      if (response.ok) {
        const resp = await response.json()

        dispatch(setBusinesses(resp))
      }
    }

    const getNotifications = async () => {
      const response = await makeRequest({
        type: 'get',
        url: '/api/v1/notifications',
        headers: {
          Authorization: token
        }
      })

      if (response.ok) {
        const resp = await response.json()

        setNotificationMessages(resp)
      }
    }

    if (Object.keys(user).length !== 0) {
      getDashboardData({
        filterDate: dates?.dateFilterValue?.date,
        businessIds: filteredCases
      })
    }

    if (Object.keys(user).length === 0) {
      getUserData()
    }

    if (businesses.length === 0) {
      getBusinessData()
    }

    if (notificationMessages.length === 0) {
      getNotifications()
    }
    // Interesting re: refresh tokens - https://github.com/waiting-for-dev/devise-jwt/issues/7#issuecomment-322115576
    // still haven't found a better way around this - sometimes we really do
    // only want the useEffect to fire on the first component load
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [user])

  useEffect(() => {
    setTableData(cases)
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [cases])

  return (
    <div className="dashboard sm:mx-8">
      <DashboardTitle
        dates={dates}
        setDates={setDates}
        makeMonth={makeMonth}
        businesses={businesses}
        filteredCases={filteredCases}
        getDashboardData={getDashboardData}
      />
      <div className="flex mb-10 md:flex-row xs:flex-col">
        <DashboardStats summaryData={summaryData} />
        {env.REACT_APP_DASHBOARD_NOTIFICATIONS === 'true' ? (
          <Notifications
            messages={notificationMessages}
            setShowModal={setShowNotificationsModal}
            isModal={false}
          />
        ) : null}
      </div>
      <DashboardTable
        dateFilterValue={dates?.dateFilterValue}
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
      <DashboardDefinitions
        activeKey={activeKey}
        setActiveKey={handleDefinitionsPanel}
        state={user.state}
      />
      <Modal
        className="notifications-modal"
        open={showNotificationsModal}
        cancelButtonProps={{ style: { display: 'none' } }}
        onOk={() => setShowNotificationsModal(false)}
        onCancel={() => setShowNotificationsModal(false)}
      >
        <Notifications messages={notificationMessages} isModal={true} />
      </Modal>
    </div>
  )
}
