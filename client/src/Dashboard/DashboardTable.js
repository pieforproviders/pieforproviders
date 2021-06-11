import React, { useEffect, useState } from 'react'
import { useSelector } from 'react-redux'
import dayjs from 'dayjs'
import PropTypes from 'prop-types'
import { Button, Modal, Select, Table, Tag } from 'antd'
import { useTranslation } from 'react-i18next'
import { attendanceCategories, fullDayCategories } from '_utils/constants'
import { useApiResponse } from '_shared/_hooks/useApiResponse'
import DatePicker from './DatePicker'
import ellipse from '_assets/ellipse.svg'
import questionMark from '_assets/questionMark.svg'
import vector from '_assets/vector.svg'
import grayVector from '_assets/gray-vector.svg'
import '_assets/styles/table-overrides.css'
import '_assets/styles/tag-overrides.css'
import '_assets/styles/select-overrides.css'

export default function DashboardTable({ tableData, userState, setActiveKey }) {
  const [isMIModalVisible, setIsMIModalVisible] = useState(false)
  const [selectedChild, setSelectedChild] = useState({})
  const [inactiveDate, setInactiveDate] = useState(null)
  const [inactiveReason, setInactiveReason] = useState(null)
  const [inactiveCases, setInactiveCases] = useState([])
  const [sortedRows, setSortedRows] = useState([])
  const { makeRequest } = useApiResponse()
  const currencyFormatter = new Intl.NumberFormat('en-US', {
    style: 'currency',
    currency: 'USD',
    minimumFractionDigits: 2
  })
  const { token } = useSelector(state => ({ token: state.auth.token }))
  const { t } = useTranslation()
  const columnSorter = (a, b) => (a < b ? -1 : a > b ? 1 : 0)
  const onHeaderCell = () => {
    return {
      style: {
        color: '#262626',
        fontWeight: 'bold'
      },
      role: 'columnheader'
    }
  }

  const isInactive = record =>
    !record.active || inactiveCases.includes(record.key)

  const renderAttendanceRate = (attendanceRate, record) => {
    if (isInactive(record)) {
      return '-'
    }

    const createTag = (color, text) => (
      <Tag className={`${color}-tag custom-tag`}>
        {`${(attendanceRate.rate * 100).toFixed(1)}% - ${t(text)}`}
      </Tag>
    )

    switch (attendanceRate.riskCategory) {
      case attendanceCategories.AHEADOFSCHEDULE:
        return createTag('green', 'aheadOfSchedule')
      case attendanceCategories.ONTRACK:
        return createTag('green', 'onTrack')
      case attendanceCategories.SUREBET:
        return createTag('green', 'sureBet')
      case attendanceCategories.ATRISK:
        return createTag('orange', 'atRisk')
      case attendanceCategories.WILLNOTMEET:
        return createTag('orange', 'willNotMeet')
      case attendanceCategories.NOTENOUGHINFO:
      default:
        return createTag('grey', 'notEnoughInfo')
    }
  }

  const renderFullDays = (fullday, record) => {
    if (isInactive(record)) {
      return '-'
    }

    const renderCell = (color, text) => {
      return (
        <div className="-mb-4">
          <p className="mb-1">{fullday.text.split(' ')[0]}</p>
          <Tag className={`${color}-tag custom-tag`}>{t(text)}</Tag>
        </div>
      )
    }
    switch (fullday.tag) {
      case fullDayCategories.AHEADOFSCHEDULE:
        return renderCell('green', 'aheadOfSchedule')
      case fullDayCategories.ONTRACK:
        return renderCell('green', 'onTrack')
      case fullDayCategories.ATRISK:
        return renderCell('orange', 'atRisk')
      case fullDayCategories.EXCEEDEDLIMIT:
        return renderCell('red', 'exceededLimit')
      default:
        return renderCell('grey', 'notEnoughInfo')
    }
  }

  const renderChild = (child, record) => {
    return child ? (
      <div>
        <p className="text-lg mb-1">
          {child.childName}
          {isInactive(record) ? `(${t('inactive')})` : ''}
        </p>
        <p className="flex flex-wrap mt-0.5">
          {child.business} <img className="mx-1" alt="ellipse" src={ellipse} />{' '}
          {child.cNumber}
        </p>
      </div>
    ) : (
      <></>
    )
  }
  const getCurrentWeek = () => {
    const current = new Date()
    const first = current.getDate() - current.getDay()
    const last = first + 6
    const firstDay = new Date(current.setDate(first)).toLocaleDateString(
      'default',
      {
        month: 'short',
        day: 'numeric'
      }
    )
    const lastDay = new Date(current.setDate(last)).toLocaleDateString(
      'default',
      {
        month: 'short',
        day: 'numeric'
      }
    )

    const matchAndReplaceDate = (dateString = '') => {
      const match = dateString.match(/^[A-Za-z]+/)
      return match
        ? dateString.replace(match[0], t(match[0].toLowerCase()))
        : ''
    }

    return `${matchAndReplaceDate(firstDay)} - ${matchAndReplaceDate(lastDay)}`
  }

  const generateColumns = columns => {
    return columns.map(({ name = '', children = [], ...options }) => {
      const hasDefinition = ['attendance', 'revenue']
      return {
        // eslint-disable-next-line react/display-name
        title: () =>
          hasDefinition.includes(name) ? (
            <div className="flex">
              {t(`${name}`)}
              <a
                href={'#definitions'}
                onClick={() => setActiveKey(name)}
                id={name}
              >
                <img
                  className={`ml-1`}
                  src={questionMark}
                  alt="question mark"
                />
              </a>
            </div>
          ) : name === 'hoursAttended' ? (
            <p>
              {t(`${name}`)}
              <br />
              {getCurrentWeek()}
            </p>
          ) : (
            t(`${name}`)
          ),
        dataIndex: name,
        key: name,
        width: 200,
        onHeaderCell,
        children: generateColumns(children),
        sortDirections: ['descend', 'ascend'],
        ...options
      }
    })
  }

  const renderDollarAmount = (num, record) =>
    isInactive(record) ? '-' : <div>{currencyFormatter.format(num)}</div>

  const replaceText = (text, translation) => (
    <div>{text.replace(translation, t(translation))}</div>
  )

  const renderActions = (_text, record) => (
    <div>
      <Button
        disabled={isInactive(record)}
        type="link"
        className="flex items-start"
        onClick={() => handleInactiveClick(record)}
      >
        <img
          alt="vector"
          src={isInactive(record) ? grayVector : vector}
          className="mr-2"
        />
        {t('markInactive')}
      </Button>
    </div>
  )

  const handleInactiveClick = record => {
    setSelectedChild(record)
    setIsMIModalVisible(true)
  }

  const handleModalClose = () => {
    setSelectedChild({})
    setInactiveReason(null)
    setInactiveDate(null)
    setIsMIModalVisible(false)
  }

  const handleMIModalOk = async () => {
    const response = await makeRequest({
      type: 'put',
      url: '/api/v1/children/' + selectedChild?.id ?? '',
      headers: {
        Authorization: token
      },
      data: {
        child: {
          active: false,
          last_active_date: inactiveDate,
          inactive_reason: inactiveReason
        }
      }
    })

    if (response.ok) {
      setInactiveCases(inactiveCases.concat(selectedChild.key))
    }
    handleModalClose()
  }

  const columnConfig = {
    ne: [
      {
        children: [
          {
            name: 'child',
            render: renderChild,
            width: 250,
            sorter: (a, b) =>
              columnSorter(
                a.child.childName.match(/([A-zÀ-ú])+$/)[0],
                b.child.childName.match(/([A-zÀ-ú])+$/)[0]
              )
          }
        ]
      },
      {
        name: 'attendance',
        children: [
          {
            name: 'fullDays',
            sorter: (a, b) =>
              a.fullDays.text.match(/^\d+/)[0] -
              b.fullDays.text.match(/^\d+/)[0],
            render: renderFullDays
          },
          {
            name: 'hours',
            sorter: (a, b) =>
              a.hours.match(/^\d+/)[0] - b.hours.match(/^\d+/)[0],
            render: (text, record) =>
              isInactive(record) ? '-' : text.split(' ')[0]
          },
          {
            name: 'absences',
            sorter: (a, b) =>
              a.absences.match(/^\d+/)[0] - b.absences.match(/^\d+/)[0],
            render: (text, record) =>
              isInactive(record) ? '-' : replaceText(text, 'of')
          },
          {
            name: 'hoursAttended',
            sorter: (a, b) =>
              a.hours.match(/^\d+/)[0] - b.hours.match(/^\d+/)[0],
            render: (text, record) =>
              isInactive(record) ? '-' : replaceText(text, 'of')
          }
        ]
      },
      {
        name: 'revenue',
        children: [
          {
            name: 'earnedRevenue',
            sorter: (a, b) => a.earnedRevenue - b.earnedRevenue,
            render: renderDollarAmount
          },
          {
            name: 'estimatedRevenue',
            sorter: (a, b) => a.estimatedRevenue - b.estimatedRevenue,
            render: renderDollarAmount
          },
          {
            name: 'familyFee',
            sorter: (a, b) => a.familyFee - b.familyFee,
            render: renderDollarAmount
          }
        ]
      },
      {
        children: [
          {
            name: 'actions',
            render: renderActions,
            width: 175
          }
        ]
      }
    ],
    default: [
      {
        name: 'childName',
        sorter: (a, b) => columnSorter(a.childName, b.childName),
        // eslint-disable-next-line react/display-name
        render: (text, record) =>
          isInactive(record) ? (
            <div>
              <p>{text}</p>
              <p>{t('inactive')}</p>
            </div>
          ) : (
            text
          )
      },
      {
        name: 'cNumber',
        sorter: (a, b) => columnSorter(a.cNumber, b.cNumber),
        render: (text, record) => (isInactive(record) ? '-' : text)
      },
      {
        name: 'business',
        sorter: (a, b) => columnSorter(a.business, b.business),
        render: (text, record) => (isInactive(record) ? '-' : text)
      },
      {
        name: 'attendanceRate',
        sorter: (a, b) => a.attendanceRate.rate - b.attendanceRate.rate,
        render: renderAttendanceRate
      },
      {
        name: 'earnedRevenue',
        sorter: (a, b) => a.guaranteedRevenue - b.guaranteedRevenue,
        render: renderDollarAmount
      },
      {
        name: 'potentialRevenue',
        sorter: (a, b) => a.potentialRevenue - b.potentialRevenue,
        render: renderDollarAmount
      },
      {
        name: 'maxApprovedRevenue',
        sorter: (a, b) => a.maxApprovedRevenue - b.maxApprovedRevenue,
        render: renderDollarAmount
      },
      {
        name: 'actions',
        render: renderActions,
        width: 175
      }
    ]
  }

  useEffect(() => {
    setSortedRows(
      [...tableData].sort((a, b) =>
        inactiveCases.includes(a.key) && inactiveCases.includes(b.key)
          ? 0
          : inactiveCases.includes(a.key)
          ? 1
          : -1
      )
    )
  }, [inactiveCases, tableData])

  useEffect(() => {
    setSortedRows(
      [...tableData].sort((a, b) =>
        !a.active && !b.active ? 0 : !a.active ? 1 : -1
      )
    )
  }, [tableData])

  return (
    <>
      <Table
        dataSource={sortedRows}
        columns={
          userState === 'NE'
            ? generateColumns(columnConfig['ne'])
            : generateColumns(columnConfig['default'])
        }
        bordered={true}
        size={'medium'}
        pagination={false}
        sticky
        className="dashboard-table"
        scroll={{ x: 'max-content' }}
        locale={{
          triggerDesc: t('sortDesc'),
          triggerAsc: t('sortAsc'),
          cancelSort: t('sortCancel')
        }}
      />
      <Modal
        title={
          <div className="text-gray9 font-semibold text-lg">
            <p>
              {t('markInactive') +
                ': ' +
                (selectedChild?.child?.childName || selectedChild?.childName)}
            </p>
          </div>
        }
        visible={isMIModalVisible}
        onOk={handleMIModalOk}
        onCancel={handleModalClose}
        footer={[
          <Button key="cancelModal" onClick={handleModalClose}>
            {t('cancel')}
          </Button>,
          <Button
            key="okModal"
            disabled={inactiveDate && inactiveReason ? false : true}
            onClick={handleMIModalOk}
            type="primary"
          >
            {t('markInactive')}
          </Button>
        ]}
      >
        <p className="text-gray8 text-base">
          {t('markInactiveInfo1')} {t('markInactiveInfo2')}
        </p>
        <Select
          className="inactive-select"
          dropdownStyle={{ minWidth: `28%` }}
          placeholder={t('markInactiveReason')}
          bordered={false}
          onChange={value => setInactiveReason(value)}
          value={inactiveReason}
        >
          <Select.Option value="no_longer_in_my_care">
            {t('inactiveReason1')}
          </Select.Option>
          <Select.Option value="no_longer_recieving_subsidies">
            {t('inactiveReason2')}
          </Select.Option>
          <Select.Option value="other">{t('inactiveReason3')}</Select.Option>
        </Select>
        <p className="text-gray8 text-base mb-3">
          {t('markInactiveCalendarPrompt')}
        </p>
        <DatePicker
          style={{
            width: '256px',
            height: '40px',
            border: '1px solid #D9D9D9',
            color: '#BFBFBF'
          }}
          onChange={(_, dateString) => setInactiveDate(dateString)}
          value={
            inactiveDate ? dayjs(inactiveDate, 'YYYY-MM-DD') : inactiveDate
          }
        />
      </Modal>
    </>
  )
}

DashboardTable.propTypes = {
  tableData: PropTypes.array.isRequired,
  userState: PropTypes.string,
  setActiveKey: PropTypes.func.isRequired
}
