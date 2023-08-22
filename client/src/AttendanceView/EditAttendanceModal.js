import React from 'react'
import PropTypes from 'prop-types'
import { Modal } from 'antd'
import '_assets/styles/modal-button-overrides.css'
import { useTranslation } from 'react-i18next'
import AttendanceDataCell from '_shared/AttendanceDataCell'

export function EditAttendanceModal({
  editAttendanceModalData = null,
  handleModalSave = () => {},
  modalButtonDisabled = true,
  setEditAttendanceModalData = () => {},
  setUpdatedAttendanceData = () => {},
  titleData = {}
}) {
  const { t } = useTranslation()
  return (
    <Modal
      open={editAttendanceModalData}
      onCancel={() => {
        setUpdatedAttendanceData({
          absenceType: null,
          date: null,
          attendances: [{}, {}]
        })
        setEditAttendanceModalData(null)
      }}
      okButtonProps={{
        disabled: modalButtonDisabled
      }}
      onOk={handleModalSave}
      okText={'Save'}
      title={
        <div className="text-gray1">
          <span className="font-semibold">{titleData.childName + ' - '}</span>
          {t(`${titleData.columnDate?.format('ddd').toLocaleLowerCase()}`) +
            ' ' +
            t(`${titleData.columnDate?.format('MMM')}`) +
            ' ' +
            titleData.columnDate?.format('DD')}
        </div>
      }
      maskClosable={false}
    >
      <AttendanceDataCell {...editAttendanceModalData} />
    </Modal>
  )
}

EditAttendanceModal.propTypes = {
  editAttendanceModalData: PropTypes.object,
  modalButtonDisabled: PropTypes.bool,
  handleModalSave: PropTypes.func,
  setEditAttendanceModalData: PropTypes.func,
  setUpdatedAttendanceData: PropTypes.func,
  titleData: PropTypes.shape({
    childName: PropTypes.string,
    columnDate: PropTypes.object
  })
}
