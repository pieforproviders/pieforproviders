import React, { useEffect, useState } from 'react'
import { useDispatch, useSelector } from 'react-redux'
import dayjs from 'dayjs'
import PropTypes from 'prop-types'
import { Button, Modal, Select, Table, Tag } from 'antd'
import { useTranslation } from 'react-i18next'
import { attendanceCategories, fullDayCategories } from '_utils/constants'
import { useApiResponse } from '_shared/_hooks/useApiResponse'
import { LoadingDisplay } from '_shared/LoadingDisplay'
import { updateCase } from '_reducers/casesReducer'
import DatePicker from './DatePicker'
import { useGoogleAnalytics } from '_shared/_hooks/useGoogleAnalytics'
import ellipse from '_assets/ellipse.svg'
import questionMark from '_assets/questionMark.svg'
import vector from '_assets/vector.svg'
import editIcon from '_assets/editIcon.svg'
import '_assets/styles/table-overrides.css'
import '_assets/styles/tag-overrides.css'
import '_assets/styles/select-overrides.css'
import CsvDownloader from '_shared/_components/CsvDownloader/CsvDownloader'
import runtimeEnv from '@mars/heroku-js-runtime-env'

const env = runtimeEnv()
export default function DashboardTable({
  tableData,
  userState,
  setActiveKey,
  dateFilterValue
}) {
  const dispatch = useDispatch()
  const { sendGAEvent } = useGoogleAnalytics()
  const [isMIModalVisible, setIsMIModalVisible] = useState(false)
  const [isAUModalVisible, setIsAUModalVisible] = useState(false)
  const [selectedChild, setSelectedChild] = useState({})
  const [effectiveDate, setEffectiveDate] = useState(null)
  const [expirationDate, setExpirationDate] = useState(null)
  const [inactiveDate, setInactiveDate] = useState(null)
  const [activeDate, setActiveDate] = useState(null)
  const [inactiveReason, setInactiveReason] = useState(null)
  const [sortedRows, setSortedRows] = useState([])
  const [aUErrorMessage, setAUErrorMessage] = useState('')
  const { user } = useSelector(state => ({
    user: state.user
  }))

  const { makeRequest } = useApiResponse()
  const currencyFormatter = new Intl.NumberFormat('en-US', {
    style: 'currency',
    currency: 'USD',
    minimumFractionDigits: 2
  })
  const { isLoading, token } = useSelector(state => ({
    token: state.auth.token,
    isLoading: state.ui.isLoading || false
  }))
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

  const datePickerStyle = {
    width: '256px',
    height: '40px',
    border: '1px solid #D9D9D9',
    color: '#BFBFBF'
  }

  const isInactive = record => !record?.active

  const isNotApproved = record => record.approvalEffectiveOn === null

  const renderAttendanceRate = (attendanceRate, record) => {
    if (isInactive(record) || !attendanceRate) {
      return '-'
    }

    const createTag = (color, text) => (
      <Tag className={`${color}-tag custom-tag`}>
        {`${(attendanceRate?.rate * 100).toFixed(1)}% - ${t(text)}`}
      </Tag>
    )

    switch (attendanceRate?.riskCategory) {
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
          {user.is_admin ? (
            <p className="mb-1">{fullday?.text}</p>
          ) : (
            <p className="mb-1">{fullday?.text.split(' ')[0]}</p>
          )}
          <Tag className={`${color}-tag custom-tag`}>{t(text)}</Tag>
        </div>
      )
    }
    switch (fullday?.tag) {
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

  const renderHoursOrPartDays = (text, record) => {
    let control_date = dayjs('2023-06-30 23:59')
    if (dayjs(dateFilterValue?.date) > control_date) {
      return isInactive(record) ? (
        '-'
      ) : user.is_admin ? (
        <div>{record.partDays?.text}</div>
      ) : (
        <div>{record.partDays?.info}</div>
      )
    }
    return isInactive(record) ? '-' : user.is_admin ? text : text?.split(' ')[0]
    // return isInactive(record) ? '-' : text
  }

  const renderRemainingHoursOrPartDays = (text, record) => {
    let control_date = dayjs('2023-06-30 23:59')
    if (dayjs(dateFilterValue?.date) > control_date) {
      return isInactive(record) || record.remainingPartDays === null ? (
        '-'
      ) : (
        <div>{`${record.remainingPartDays} (of ${record.totalPartDays?.info})`}</div>
      )
    }
    return isInactive(record)
      ? '-'
      : `${record.hoursRemaining} (of ${record.hoursAuthorized})`
  }

  const renderChild = (child, record) => {
    return child ? (
      <div key={child.cNumber}>
        <p className="mb-1 text-lg">
          {`${child.childFirstName} ${child.childLastName}`}
          {isInactive(record) ? `  (${t('inactive')})` : ''}
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

  const generateColumns = columns => {
    return columns.map(({ name = '', children = [], ...options }) => {
      const hasDefinition = [
        'attendance',
        'attendanceRate',
        'guaranteedRevenue',
        'totalAuthorizationPeriod',
        'authorizedPeriod'
      ]
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
              {t('maxHours')}
              <br />
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

  const replaceText = (
    text,
    translation,
    is_absence = false,
    absences_dates = null
  ) =>
    !is_absence ? (
      <div>{text?.replace(translation, t(translation))}</div>
    ) : (
      <div>
        <div>{text?.replace(translation, t(translation))}</div>
        <div>{render_absences_dates(absences_dates)}</div>
      </div>
    )

  const render_absences_dates = dates => {
    const last_date = dates?.at(-1)
    const formated_dates = dates?.map(date => {
      const splited_date = date.trim().split('/')
      const month = parseInt(splited_date[0], 10)
      const day = parseInt(splited_date[1], 10)
      return user.is_admin ? (
        `${month}/${day}${last_date === date ? ' ' : ', '}`
      ) : (
        <>
          {`${parseInt(/-(\d{2})-(\d{2})/.exec(date)[1], 10)}/${parseInt(
            /-(\d{2})-(\d{2})/.exec(date)[2],
            10
          )}`}
          {last_date === date ? '' : ', '}
        </>
      )
    })
    return formated_dates
  }

  const renderAuthInfo = child => {
    if (Object.keys(child).length === 0) {
      return <></>
    } else {
      const full_name =
        child.child.childFirstName + ' ' + child.child.childLastName
      const effective_date = child?.approvalEffectiveOn
      const expiration_date = child?.approvalExpiresOn
      return (
        <>
          <p className="text-lg text-gray10">{full_name}</p>
          <p className="text-base text-gray8">Current Effective Date:</p>
          <p>{effective_date}</p>
          <p className="text-base text-gray8">Current Expiration Date:</p>
          <p>{expiration_date}</p>
          <br></br>
          <p className="text-base text-gray10">New Effective Date</p>
          <DatePicker
            style={datePickerStyle}
            onChange={(_, dateString) => {
              setEffectiveDate(dateString)
            }}
            value={effectiveDate ? dayjs(effectiveDate, 'YYYY-MM-DD') : null}
          />
          <div style={{ height: 20 }}></div>
          <p className="text-base text-gray10">New Expiration Date</p>
          <DatePicker
            style={datePickerStyle}
            onChange={(_, dateString) => {
              setExpirationDate(dateString)
            }}
            value={expirationDate ? dayjs(expirationDate, 'YYYY-MM-DD') : null}
          />
          {auModalErrorMessage(aUErrorMessage)}
        </>
      )
    }
  }

  const renderActions = (_text, record) => (
    <div>
      <div>
        <Button
          type="link"
          className="flex items-start"
          onClick={() => handleInactiveClick(record)}
        >
          <img
            alt="vector"
            src={isInactive(record) ? editIcon : vector}
            className="mr-2"
          />
          <span className="underline hover:text-blue2">
            {isInactive(record) ? t('markActive') : t('markInactive')}
          </span>
        </Button>
      </div>
      <div>
        <Button
          type="link"
          className="flex items-start"
          onClick={() => handleEditAuthClick(record)}
        >
          <span className="underline hover:text-blue2">
            {'\u27F3'} Update Authorization
          </span>
        </Button>
      </div>
    </div>
  )

  const handleEditAuthClick = record => {
    setSelectedChild(record)
    setIsAUModalVisible(true)
  }

  const handleInactiveClick = record => {
    setSelectedChild(record)
    setIsMIModalVisible(true)
  }

  const handleModalCancel = () => {
    setSelectedChild({})
    setInactiveReason(null)
    setInactiveDate(null)
    setIsMIModalVisible(false)
  }

  const shouldAllowToExport = () => {
    return env?.REACT_APP_WHITELIST_EXPORT_CSV?.includes(user?.email)
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
          ...(isInactive(selectedChild)
            ? { active: true, last_inactive_date: activeDate }
            : {
                active: false,
                inactive_reason: inactiveReason,
                last_active_date: inactiveDate
              })
        }
      }
    })

    if (response.ok) {
      !isInactive(selectedChild) &&
        sendGAEvent('mark_inactive', {
          date: inactiveDate,
          page_title: 'dashboard',
          reason_selected: inactiveReason
        })
      dispatch(
        updateCase({
          childId: selectedChild?.id,
          updates: { active: isInactive(selectedChild) ? true : false }
        })
      )
    }
    handleModalCancel()
  }

  const auModalErrorMessage = type => {
    let error_message = ''
    switch (type) {
      case 'wrong_date':
        error_message = 'Expiration date must be after the Effective date'
        break
      case 'empty_dates':
        error_message = 'Date fields cannot be empty'
        break
      default:
        error_message = ''
    }
    return (
      <div style={{ marginTop: 25, marginBottom: 25 }}>
        <p className="text-sm text-red-500">{error_message}</p>
      </div>
    )
  }

  const handleAUModalOk = async () => {
    if (expirationDate < effectiveDate) {
      setAUErrorMessage('wrong_date')
    } else if (expirationDate === null || effectiveDate === null) {
      setAUErrorMessage('empty_dates')
    } else {
      const response = await makeRequest({
        type: 'patch',
        url: `/api/v1/children/${selectedChild.id}/update_auth`,
        headers: {
          Authorization: token
        },
        data: {
          current_effective_date: selectedChild.approvalEffectiveOn,
          current_expiration_date: selectedChild.approvalExpiresOn,
          new_effective_date: effectiveDate,
          new_expiration_date: expirationDate
        }
      })
      if (response.ok) {
        dispatch(
          updateCase({
            childId: selectedChild?.id,
            updates: {
              approvalEffectiveOn: effectiveDate,
              approvalExpiresOn: expirationDate
            }
          })
        )
        setIsAUModalVisible(false)
      }
    }
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
                a.child.childLastName.match(/([A-zÀ-ú])+/)[0],
                b.child.childLastName.match(/([A-zÀ-ú])+/)[0]
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
            name:
              dayjs(dateFilterValue?.date) > dayjs('2023-06-30 23:59')
                ? t('partialDays')
                : 'hours',
            sorter: (a, b) =>
              user.is_admin
                ? a.partDays.text.match(/^\d+/)[0] -
                  b.partDays.text.match(/^\d+/)[0]
                : a.hours.match(/^\d+/)[0] - b.hours.match(/^\d+/)[0],
            render: renderHoursOrPartDays
          },
          {
            name: 'absences',
            sorter: (a, b) =>
              a.absences.match(/^\d+/)[0] - b.absences.match(/^\d+/)[0],
            render: (text, record) =>
              isInactive(record)
                ? '-'
                : replaceText(text, 'of', true, record.absences_dates)
          },
          // {
          //   name: 'hours',
          //   sorter: (a, b) =>
          //     a.hours.match(/^\d+/)[0] - b.hours.match(/^\d+/)[0],
          //   render: (text, record) =>
          //     isInactive(record) ? '-' : text.split(' ')[0]
          // },
          {
            name: 'hoursAttended',
            sorter: (a, b) =>
              user.is_admin
                ? a.hoursAttended.match(/^\d+/)[0] -
                  b.hoursAttended.match(/^\d+/)[0]
                : a.hours.match(/^\d+/)[0] - b.hours.match(/^\d+/)[0],
            render: (text, record) =>
              isInactive(record) ? '-' : replaceText(text, 'of')
          }
        ]
      },
      {
        name: 'revenue',
        children: user.is_admin
          ? [
              {
                name: 'familyFee',
                sorter: (a, b) => a.familyFee - b.familyFee,
                render: renderDollarAmount
              }
            ]
          : [
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
        name: 'totalAuthorizationPeriod',
        children: user.is_admin
          ? [
              {
                name: 'authorizedPeriod',
                sorter: (a, b) =>
                  dayjs(a.approvalEffectiveOn) - dayjs(b.approvalEffectiveOn),
                render: (text, record) =>
                  isInactive(record)
                    ? '-'
                    : isNotApproved(record)
                    ? 'unknown'
                    : `${dayjs(record.approvalEffectiveOn).format('M/D/YY')}${
                        record.approvalExpiresOn
                          ? ` - ${dayjs(record.approvalExpiresOn).format(
                              'M/D/YY'
                            )}`
                          : ''
                      }`
              }
            ]
          : [
              {
                name: 'authorizedPeriod',
                sorter: (a, b) =>
                  dayjs(a.approvalEffectiveOn) - dayjs(b.approvalEffectiveOn),
                render: (text, record) =>
                  isInactive(record)
                    ? '-'
                    : isNotApproved(record)
                    ? 'unknown'
                    : `${dayjs(record.approvalEffectiveOn).format('M/D/YY')}${
                        record.approvalExpiresOn
                          ? ` - ${dayjs(record.approvalExpiresOn).format(
                              'M/D/YY'
                            )}`
                          : ''
                      }`
              },
              {
                name: 'fullDaysRemaining',
                sorter: (a, b) => a.fullDaysRemaining - b.fullDaysRemaining,
                render: (text, record) =>
                  isInactive(record)
                    ? '-'
                    : `${record.fullDaysRemaining} (of ${record.fullDaysAuthorized})`
              },
              {
                name:
                  dayjs(dateFilterValue?.date) > dayjs('2023-06-30 23:59')
                    ? t('partialDaysRemaining')
                    : 'hoursRemaining',
                sorter: (a, b) => a.hoursRemaining - b.hoursRemaining,
                render: renderRemainingHoursOrPartDays
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
        name: 'child',
        sorter: (a, b) => columnSorter(a.childLastName, b.childLastName),
        // eslint-disable-next-line react/display-name
        render: (text, record) => (
          <div>
            <p className="mb-1 text-lg">
              {`${record.childFirstName} ${record.childLastName}`}
              {isInactive(record) ? `  (${t('inactive')})` : ''}
            </p>
            <p className="flex flex-wrap mt-0.5">
              {record.business}{' '}
              <img className="mx-1" alt="ellipse" src={ellipse} />{' '}
              {record.cNumber}
            </p>
          </div>
        )
      },
      {
        name: 'fullDaysAttended',
        render: (text, record) => text
      },
      {
        name: 'partDaysAttended',
        render: (text, record) => text
      },
      {
        name: 'attendanceRate',
        sorter: (a, b) => a.attendanceRate.rate - b.attendanceRate.rate,
        render: renderAttendanceRate
      },
      {
        name: 'guaranteedRevenue',
        sorter: (a, b) => a.guaranteedRevenue - b.guaranteedRevenue,
        render: renderDollarAmount
      },
      // {
      //   name: 'potentialRevenue',
      //   sorter: (a, b) => a.potentialRevenue - b.potentialRevenue,
      //   render: renderDollarAmount
      // },

      // {
      //   name: 'maxApprovedRevenue',
      //   sorter: (a, b) => a.maxApprovedRevenue - b.maxApprovedRevenue,
      //   render: renderDollarAmount
      // },
      {
        name: 'authorizedPeriod',
        sorter: (a, b) =>
          dayjs(a.approvalEffectiveOn) - dayjs(b.approvalEffectiveOn),
        render: (text, record) =>
          isInactive(record)
            ? '-'
            : isNotApproved(record)
            ? 'unknown'
            : `${dayjs(record.approvalEffectiveOn).format('M/D/YY')}${
                record.approvalExpiresOn
                  ? ` - ${dayjs(record.approvalExpiresOn).format('M/D/YY')}`
                  : ''
              }`
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
        (!isInactive(a) && !isInactive(b)) || (isInactive(a) && isInactive(b))
          ? 0
          : isInactive(b)
          ? -1
          : 1
      )
    )
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [tableData])

  return (
    <>
      {shouldAllowToExport() && (
        <CsvDownloader data={sortedRows} filename={'dashboard.csv'} />
      )}
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
        loading={{
          delay: 500,
          spinning: isLoading,
          indicator: <LoadingDisplay />
        }}
      />
      <Modal
        title={
          <div className="text-lg font-semibold text-gray9">
            <p>
              {(isInactive(selectedChild)
                ? t('markActive')
                : t('markInactive')) +
                ': ' +
                (`${selectedChild?.child?.childFirstName} ${selectedChild?.child?.childLastName}` ||
                  `${selectedChild?.childFirstName} ${selectedChild?.childLastName}`)}
            </p>
          </div>
        }
        open={isMIModalVisible}
        onOk={handleMIModalOk}
        onCancel={handleModalCancel}
        footer={[
          <Button key="cancelModal" onClick={handleModalCancel}>
            {t('cancel')}
          </Button>,
          <Button
            key="okModal"
            disabled={
              (!isInactive(selectedChild) && inactiveDate && inactiveReason) ||
              (isInactive(selectedChild) && activeDate)
                ? false
                : true
            }
            onClick={handleMIModalOk}
            type="primary"
          >
            {isInactive(selectedChild) ? t('markActive') : t('markInactive')}
          </Button>
        ]}
      >
        <p className="text-base text-gray8">
          {!isInactive(selectedChild)
            ? t('markInactiveInfo1') + ' ' + t('markInactiveInfo2')
            : t('markActiveInfo')}
        </p>
        {!isInactive(selectedChild) && (
          <>
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
              <Select.Option value="no_longer_receiving_subsidies">
                {t('inactiveReason2')}
              </Select.Option>
              <Select.Option value="other">
                {t('inactiveReason3')}
              </Select.Option>
            </Select>
          </>
        )}
        <p className="mb-3 text-base text-gray8">
          {isInactive(selectedChild)
            ? t('markActiveCalendarPrompt')
            : t('markInactiveCalendarPrompt')}
        </p>
        <DatePicker
          style={{
            width: '256px',
            height: '40px',
            border: '1px solid #D9D9D9',
            color: '#BFBFBF'
          }}
          onChange={(_, dateString) =>
            !isInactive(selectedChild)
              ? setInactiveDate(dateString)
              : setActiveDate(dateString)
          }
          value={
            inactiveDate || activeDate
              ? dayjs(inactiveDate || activeDate, 'YYYY-MM-DD')
              : inactiveDate || activeDate
          }
        />
      </Modal>
      <>
        <Modal
          title="Update Authorization"
          open={isAUModalVisible}
          onOk={handleAUModalOk}
          onCancel={() => setIsAUModalVisible(false)}
          okText="Update Authorization"
        >
          {renderAuthInfo(selectedChild)}
        </Modal>
      </>
    </>
  )
}

DashboardTable.propTypes = {
  dateFilterValue: PropTypes.object,
  tableData: PropTypes.array.isRequired,
  userState: PropTypes.string,
  setActiveKey: PropTypes.func.isRequired
}
