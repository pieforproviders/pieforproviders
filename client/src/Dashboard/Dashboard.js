import React, { useEffect, useState } from 'react'
import { useTranslation } from 'react-i18next'
import { useApiResponse } from '_shared/_hooks/useApiResponse'
import { useSelector } from 'react-redux'
import { Table, Typography } from 'antd'
import '_assets/styles/table-overrides.css'

export function Dashboard() {
  const [businessList, setBusinessList] = useState([])
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
        headers: {
          Accept: 'application/vnd.pieforproviders.v1+json',
          'Content-Type': 'application/json',
          Authorization: token
        }
      })
      const allBusinesses = await businesses.json()
      if (!allBusinesses.error) {
        setBusinessList(allBusinesses)
      }
    }

    // Interesting re: refresh tokens - https://github.com/waiting-for-dev/devise-jwt/issues/7#issuecomment-322115576
    responseValue()
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
      title: t('childName'),
      dataIndex: 'childName',
      key: 'childName',
      width: 150,
      onHeaderCell,
      sorter: (a, b) => columnSorter(a, b, 'childName'),
      sortDirections: ['descend', 'ascend']
    },
    {
      title: t('caseNumber'),
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
      title: t('minRevenue'),
      dataIndex: 'minRevenue',
      key: 'minRevenue',
      width: 150,
      onHeaderCell,
      sorter: (a, b) => numMatch(a.minRevenue) - numMatch(b.minRevenue),
      sortDirections: ['descend', 'ascend']
    },
    {
      title: t('maxRevenue'),
      dataIndex: 'maxRevenue',
      key: 'maxRevenue',
      width: 150,
      onHeaderCell,
      sorter: (a, b) => numMatch(a.maxRevenue) - numMatch(b.maxRevenue),
      sortDirections: ['descend', 'ascend']
    },
    {
      title: t('potentialRevenue'),
      dataIndex: 'potentialRevenue',
      key: 'potentialRevenue',
      width: 150,
      onHeaderCell,
      sorter: (a, b) => numMatch(a.potentialRevenue) - numMatch(b.potentialRevenue),
      sortDirections: ['descend', 'ascend']
    }

  ]

  // to be replaced with API data
  const staticData = [
    {
      key: '1',
      childName: 'Bessie Cooper',
      caseNumber: '282753',
      business: 'Lil Baby Ducklings',
      attendanceRate: '97%',
      minRevenue: '$1266.5',
      maxRevenue: '$1888.47',
      potentialRevenue: '$2000.80'
    },
    {
      key: '2',
      childName: 'Jenny Wilson',
      caseNumber: '172922',
      business: 'Austin Community Child Care',
      attendanceRate: '38%',
      minRevenue: '$1266.5',
      maxRevenue: '$1888.47',
      potentialRevenue: '$2030.80'
    },
    {
      key: '3',
      childName: 'Brooklyn Simmons',
      caseNumber: '282753',
      business: 'Goslings Grow',
      attendanceRate: '96%',
      minRevenue: '$2926.11',
      maxRevenue: '$1008.86',
      potentialRevenue: '$2299.80'
    },
    {
      key: '4',
      childName: 'Eleanor Pena',
      caseNumber: '363171',
      business: 'Austin Community Child Care',
      attendanceRate: '30%',
      minRevenue: '$342.58',
      maxRevenue: '$121.62',
      potentialRevenue: '$3003.80'
    },
    {
      key: '5',
      childName: 'Theresa Webb',
      caseNumber: '449003',
      business: 'Ravenswood Daycare',
      attendanceRate: '110%',
      minRevenue: '$4000.90',
      maxRevenue: '$5000.80',
      potentialRevenue: '$5002.80'
    },
    {
      key: '6',
      childName: 'Kathryn Murphy',
      caseNumber: '295340',
      business: 'Austin Community Child Care',
      attendanceRate: '50%',
      minRevenue: '$1240.90',
      maxRevenue: '$2000.50',
      potentialRevenue: '$3430.80'
    },
    {
      key: '7',
      childName: 'Leslie Alexander',
      caseNumber: '803162',
      business: 'Ravenswood Daycare',
      attendanceRate: '52%',
      minRevenue: '$1109.90',
      maxRevenue: '$2188',
      potentialRevenue: '$1500.80'
    }
  ]

  return (
    <div className="dashboard sm:mx-8">
      <div className="m-2">
        <Typography.Title>{t('dashboardTitle')}</Typography.Title>
        <Typography.Text className="md-3">
          {t('revenueProjections')}
        </Typography.Text>
      </div>
      <Table
        dataSource={staticData}
        columns={columns}
        bordered={true}
        size={'medium'}
        pagination={false}
        sticky
        className="dashboard-table"
        scroll={{ x: 'max-content' }}
      >
        {businessList &&
          businessList.map(business => {
            return <div key={business.name}>{business.name}</div>
          })}
      </Table>
    </div>
  )
}
