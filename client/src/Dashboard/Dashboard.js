import React, { useEffect, useState } from 'react'
import { useTranslation } from 'react-i18next'
import { useApiResponse } from '_shared/_hooks/useApiResponse'
import { useSelector } from 'react-redux'
import { Col, Divider, Grid, Row, Table, Typography } from 'antd'
import '_assets/styles/table-overrides.css'

const { useBreakpoint } = Grid;

export function Dashboard() {
  const screens = useBreakpoint();
  console.log(screens)
  const token = useSelector(state => state.auth.token)
  const { makeRequest } = useApiResponse()
  const { t } = useTranslation()
  const staticSummaryStats = [
    {
      title: t('guaranteedRevenue'),
      stat: '$981',
      definition: t('guaranteedRevenueDef')
    },
    {
      title: t('potentialRevenue'),
      stat: '$1,200',
      definition: t('potentialRevenueDef')
    },
    {
      title: t('maxApprovedRevenue'),
      stat: '$1200',
      definition: t('maxApprovedRevenueDef')
    },
    {
      title: t('attendanceRate'),
      stat: '60%',
      definition: t('attendanceRateDef')
    }
  ]
  const [businessList, setBusinessList] = useState([])
  const [summaryStats, setSummaryStats] = useState(staticSummaryStats)
  const onHeaderCell = () => {
    return {
      style: {
        color: '#262626',
        fontWeight: 'bold'
      },
      role: 'columnheader'
    }
  }
  const columnSorter = (a, b, name) =>
    a[name] < b[name] ? -1 : a[name] > b[name] ? 1 : 0
  const numMatch = num => num.match(/\d+.\d{2}/) ?? 0
  // configuation for table columns
  const columns = [
    {
      title: t('childName'),
      dataIndex: 'childName',
      key: 'childName',
      width: 150,
      onHeaderCell,
      sorter: (a, b) => columnSorter(a, b, 'childName'),
      sortDirections: ['descend', 'ascend']
    },
    {
      title: t('caseNumberLowercase'),
      dataIndex: 'caseNumber',
      key: 'caseNumber',
      width: 150,
      onHeaderCell,
      sorter: (a, b) => columnSorter(a, b, 'caseNumber'),
      sortDirections: ['descend', 'ascend']
    },
    {
      title: t('business'),
      dataIndex: 'business',
      key: 'business',
      width: 150,
      onHeaderCell,
      sorter: (a, b) => columnSorter(a, b, 'business'),
      sortDirections: ['descend', 'ascend']
    },
    {
      title: t('attendanceRate'),
      dataIndex: 'attendanceRate',
      key: 'attendanceRate',
      width: 150,
      onHeaderCell,
      sorter: (a, b) =>
        a.attendanceRate.match(/\d+/) - b.attendanceRate.match(/\d+/),
      sortDirections: ['descend', 'ascend']
    },
    {
      title: t('guaranteedRevenue'),
      dataIndex: 'minRevenue',
      key: 'minRevenue',
      width: 150,
      onHeaderCell,
      sorter: (a, b) => numMatch(a.minRevenue) - numMatch(b.minRevenue),
      sortDirections: ['descend', 'ascend']
    },
    {
      title: t('potentialRevenue'),
      dataIndex: 'potentialRevenue',
      key: 'potentialRevenue',
      width: 150,
      onHeaderCell,
      sorter: (a, b) =>
        numMatch(a.potentialRevenue) - numMatch(b.potentialRevenue),
      sortDirections: ['descend', 'ascend']
    },
    {
      title: t('maxApprovedRevenue'),
      dataIndex: 'maxRevenue',
      key: 'maxRevenue',
      width: 150,
      onHeaderCell,
      sorter: (a, b) => numMatch(a.maxRevenue) - numMatch(b.maxRevenue),
      sortDirections: ['descend', 'ascend']
    }
  ]

  useEffect(() => {
    const getDashboardData = async () => {
      const response = await makeRequest({
        type: 'get',
        url: '/api/v1/case_list_for_dashboard',
        headers: { Authorization: token }
      })
      const parsedResponse = await response.json()

      if (!parsedResponse.error) {
        const data = parsedResponse.reduce((acc, cv, index) => {
          const {
            full_name: name = '',
            approvals: [{ case_number: caseNumber = '' }],
            business: { name: businessName = '' }
          } = cv

          return [
            ...acc,
            {
              key: index,
              childName: name,
              caseNumber: caseNumber,
              business: businessName,
              // these values will be updated as the case_list endpoint is updated
              attendanceRate: '',
              minRevenue: '',
              maxRevenue: '',
              potentialRevenue: ''
            }
          ]
        }, [])

        setDashboardData(data)
      }
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
      <div className="dashboard-stats grid grid-cols-2 sm:grid-cols-2 md:grid-cols-4 lg:grid-cols-6 mx-2 my-10">
        {summaryStats.map((stat, i) => {
          const renderDivider = () => {
            if ((screens.sm || screens.xs) && !screens.md) {
              // eslint-disable-next-line no-unused-expressions
              return i % 2 === 0 ? (
                <Divider
                  style={{ borderWidth: 0.5, borderColor: '#BDBDBD' }}
                  className="h-32 m-2"
                  type="vertical"
                />
              ) : null
            } else {
              // eslint-disable-next-line no-unused-expressions
              return summaryStats.length === i + 1 ? null : (
                <Divider
                  style={{ borderWidth: 0.5, borderColor: '#BDBDBD' }}
                  className="h-32 m:mr-4 lg:mr-6"
                  type="vertical"
                />
              )
            }
          }

          return (
            <div key={i} className="dashboard-stat flex">
              <div className="w-full mt-2">
                <p className="whitespace-no-wrap">
                  <Typography.Text>{stat.title}</Typography.Text>
                </p>
                <p className="mt-2">
                  <Typography.Text className="text-blue2 text-3xl font-semibold mt-2 mb-6">
                    {stat.stat}
                  </Typography.Text>
                </p>
                <Typography.Paragraph className="text-xs mt-5">
                  {stat.definition}
                </Typography.Paragraph>
              </div>
              {renderDivider()}
            </div>
          )
        })}
      </div>
      <Table
        dataSource={dashboardData}
        columns={columns}
        bordered={true}
        size={'medium'}
        pagination={false}
        sticky
        className="dashboard-table"
        scroll={{ x: 'max-content' }}
      />
    </div>
  )
}
