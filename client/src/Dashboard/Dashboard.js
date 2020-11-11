import React, { useEffect, useState } from 'react'
import { useTranslation } from 'react-i18next'
import { useApiResponse } from '_shared/_hooks/useApiResponse'
import { useSelector } from 'react-redux'
import { Col, Divider, Row, Table, Typography } from 'antd'
import '_assets/styles/table-overrides.css'


export function Dashboard() {
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
      title: t('minRevenue'),
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
      title: t('maxRevenue'),
      dataIndex: 'maxRevenue',
      key: 'maxRevenue',
      width: 150,
      onHeaderCell,
      sorter: (a, b) => numMatch(a.maxRevenue) - numMatch(b.maxRevenue),
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
        <Typography.Text className="md-3 text-base">
          {t('revenueProjections')}
        </Typography.Text>
      </div>
      <div className="mx-2 my-10">
        <Row justify="start">
          {summaryStats.map((stat, i) => (
            <>
              <Col span={4}>
                <Row>
                  <Typography.Text>{stat.title}</Typography.Text>
                </Row>
                <Row>
                  <Typography.Text className="text-blue2 text-3xl font-semibold mt-2 mb-6">
                      {stat.stat}
                  </Typography.Text>
                </Row>
                <Row>
                  <Typography.Paragraph className="text-xs w-2/3">
                    {stat.definition}
                  </Typography.Paragraph>
                </Row>
              </Col>
              {i + 1 === summaryStats.length ? null : (
                <Divider
                  style={{ borderWidth: 1, borderColor: '#BDBDBD' }}
                  className="h-32 mx-8 -ml-2"
                  type="vertical"
                />
              )}
            </>
          ))}
          {/* <Col span={3}>
            <Row>
              <Typography.Text>{t('potentialRevenue')}</Typography.Text>
            </Row>
            <Row>number</Row>
            <Row>
              <Typography.Text>{t('potentialRevenueDef')}</Typography.Text>
            </Row>
          </Col>
          <Divider
            style={{ borderWidth: 1, borderColor: '#BDBDBD' }}
            className="h-32 mx-8"
            type="vertical"
          />
          <Col span={3}>
            <Row>
              <Typography.Text>{t('maxApprovedRevenue')}</Typography.Text>
            </Row>
            <Row>number</Row>
            <Row>{t('maxApprovedRevenueDef')}</Row>
          </Col>
          <Divider
            style={{ borderWidth: 1, borderColor: '#BDBDBD' }}
            className="h-32 mx-8"
            type="vertical"
          />
          <Col span={3}>
            <Row>
              <Typography.Text>{t('attendanceRate')}</Typography.Text>
            </Row>
            <Row>number</Row>
            <Row>{t('attendanceRateDef')}</Row>
          </Col>
          <Divider
            style={{ borderWidth: 1, borderColor: '#BDBDBD' }}
            className="h-32 mx-8"
            type="vertical"
          /> */}
        </Row>
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
