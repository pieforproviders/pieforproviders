import React, { useEffect, useState } from 'react'
import { useTranslation } from 'react-i18next'
import { useApiResponse } from '_shared/_hooks/useApiResponse'
import { useSelector } from 'react-redux'
import { Table, Typography } from 'antd'
import '_assets/styles/table-overrides.css'

// const STATICDATA = [
//   {
//     key: '1',
//     childName: 'Bessie Cooper',
//     caseNumber: '282753',
//     business: 'Lil Baby Ducklings',
//     attendanceRate: '97%',
//     minRevenue: '$1266.5',
//     maxRevenue: '$1888.47'
//   },
//   {
//     key: '2',
//     childName: 'Jenny Wilson',
//     caseNumber: '172922',
//     business: 'Austin Community Child Care',
//     attendanceRate: '38%',
//     minRevenue: '$1266.5',
//     maxRevenue: '$1888.47'
//   },
//   {
//     key: '3',
//     childName: 'Brooklyn Simmons',
//     caseNumber: '282753',
//     business: 'Goslings Grow',
//     attendanceRate: '96%',
//     minRevenue: '$2926.11',
//     maxRevenue: '$1008.86'
//   },
//   {
//     key: '4',
//     childName: 'Eleanor Pena',
//     caseNumber: '363171',
//     business: 'Austin Community Child Care',
//     attendanceRate: '30%',
//     minRevenue: '$342.58',
//     maxRevenue: '$121.62'
//   },
//   {
//     key: '5',
//     childName: 'Theresa Webb',
//     caseNumber: '449003',
//     business: 'Ravenswood Daycare',
//     attendanceRate: '110%',
//     minRevenue: '$4000.90',
//     maxRevenue: '$5000.80'
//   },
//   {
//     key: '6',
//     childName: 'Kathryn Murphy',
//     caseNumber: '295340',
//     business: 'Austin Community Child Care',
//     attendanceRate: '50%',
//     minRevenue: '$1240.90',
//     maxRevenue: '$2000.50'
//   },
//   {
//     key: '7',
//     childName: 'Leslie Alexander',
//     caseNumber: '803162',
//     business: 'Ravenswood Daycare',
//     attendanceRate: '52%',
//     minRevenue: '$1109.90',
//     maxRevenue: '$2188'
//   }
// ]


export function Dashboard() {
  const [businessList, setBusinessList] = useState([])
  const [dashboardData, setDashboardData] = useState([])
  const token = useSelector(state => state.auth.token)
  const { makeRequest } = useApiResponse()
  const { t } = useTranslation()
  const onHeaderCell = () => {
    return {
      style: {
        color: '#262626',
        fontWeight: 'bold'
      }
    }
  }

  useEffect(() => {
    const responseValue = async () => {
      const businesses = await makeRequest({
        type: 'get',
        url: '/api/v1/businesses',
        headers: { Authorization: token }
      })
      const allBusinesses = await businesses.json()
      if (!allBusinesses.error) {
        setBusinessList(allBusinesses)
      }
    }
    const getDashboardData = async () => {
      const response = await makeRequest({
        type: 'get',
        url: '/api/v1/case_list_for_dashboard',
        headers: { Authorization: token }
      })
      const parsedResponse = await response.json()
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
    // Interesting re: refresh tokens - https://github.com/waiting-for-dev/devise-jwt/issues/7#issuecomment-322115576
    responseValue()
    getDashboardData()
    // still haven't found a better way around this - sometimes we really do
    // only want the useEffect to fire on the first component load
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [])

  const columnSorter = (a, b, name) =>
    a[name] < b[name] ? -1 : a[name] > b[name] ? 1 : 0

  const numMatch = num => num.match(/\d+.\d{2}/) ?? 0

  // configuation for table columns
  const columns = [
    {
      title: 'Child name',
      dataIndex: 'childName',
      key: 'childName',
      width: 150,
      onHeaderCell,
      sorter: (a, b) => columnSorter(a, b, 'childName'),
      sortDirections: ['descend', 'ascend']
    },
    {
      title: 'Case number',
      dataIndex: 'caseNumber',
      key: 'caseNumber',
      width: 150,
      onHeaderCell,
      sorter: (a, b) => columnSorter(a, b, 'caseNumber'),
      sortDirections: ['descend', 'ascend']
    },
    {
      title: 'Business',
      dataIndex: 'business',
      key: 'business',
      width: 150,
      onHeaderCell,
      sorter: (a, b) => columnSorter(a, b, 'business'),
      sortDirections: ['descend', 'ascend']
    },
    {
      title: 'Attendance rate',
      dataIndex: 'attendanceRate',
      key: 'attendanceRate',
      width: 150,
      onHeaderCell,
      sorter: (a, b) =>
        a.attendanceRate.match(/\d+/) - b.attendanceRate.match(/\d+/),
      sortDirections: ['descend', 'ascend']
    },
    {
      title: 'Min. revenue',
      dataIndex: 'minRevenue',
      key: 'minRevenue',
      width: 150,
      onHeaderCell,
      sorter: (a, b) => numMatch(a.minRevenue) - numMatch(b.minRevenue),
      sortDirections: ['descend', 'ascend']
    },
    {
      title: 'Max. revenue',
      dataIndex: 'maxRevenue',
      key: 'maxRevenue',
      width: 150,
      onHeaderCell,
      sorter: (a, b) => numMatch(a.maxRevenue) - numMatch(b.maxRevenue),
      sortDirections: ['descend', 'ascend']
    }
  ]

  return (
    <div className="dashboard">
      <div className="m-2">
        <Typography.Title>{t('dashboardTitle')}</Typography.Title>
        <Typography.Text className="md-3">
          {t('revenueProjections')}
        </Typography.Text>
      </div>
      <Table
        dataSource={dashboardData}
        columns={columns}
        bordered={true}
        size={'medium'}
        pagination={false}
        sticky
        className="dashboard-table"
      >
        {businessList &&
          businessList.map(business => {
            return <div key={business.name}>{business.name}</div>
          })}
      </Table>
    </div>
  )
}
