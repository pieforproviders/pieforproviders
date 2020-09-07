import React, { useState } from 'react'
import { Alert, Typography } from 'antd'
import { useTranslation } from 'react-i18next'
import { CasesImportReview } from './CasesImportReview'
import { parserTypes, getColumns, randomHash } from './utils'

const { Title } = Typography

export function CasesImport() {
  const [kids, setKids] = useState([])
  const [error, setError] = useState('')
  const { t } = useTranslation()

  const columns = getColumns(t)

  const getType = file => {
    const nameArray = file.name.split('.')
    const extension = nameArray[nameArray.length - 1]
    // sometimes xls files come in with an empty type so we want to parse
    // the extension to verify what parser to use
    if (file.type === '' && ['xls', 'xlsx'].includes(extension)) {
      return 'application/vnd.ms-excel'
    } else {
      return file.type
    }
  }

  const onFileChange = e => {
    setError('')

    const [file] = e.target.files
    if (file) {
      const type = getType(file)
      if (!(type in parserTypes)) {
        setKids([])
        setError(t('uploadCasesInvalidFileFormat'))
        return
      }

      const reader = new FileReader()
      const readAsBinaryString = !!reader.readAsBinaryString
      reader.onload = e => {
        const { data } = parserTypes[type].parse(e.target.result, {
          readAsBinaryString
        })
        // Skip the instruction, header and column description rows
        const rows = data.slice(3)
        const kids = rows
          .map(row =>
            row.reduce(
              (acc, item, index) => ({
                ...acc,
                [columns[index]?.key]: item
              }),
              {}
            )
          )
          .map(kid => ({
            ...kid,
            key: randomHash([kid.firstName, kid.lastName, kid.dateOfBirth])
          }))
          .filter(kid => kid.firstName && kid.lastName && kid.dateOfBirth)
        setKids(kids)
      }

      if (readAsBinaryString) {
        return reader.readAsBinaryString(file)
      }

      reader.readAsArrayBuffer(file)
    }
  }

  return (
    <div>
      <Title>{t('uploadCases')}</Title>
      {error && (
        <Alert
          message={error}
          type="error"
          showIcon
          style={{ marginBottom: '16px' }}
        />
      )}
      <input
        type="file"
        id="cases-upload"
        accept=".csv,.xls,.xlsx"
        data-cy="cases-upload"
        onChange={onFileChange}
      />
      <CasesImportReview kids={kids} />
    </div>
  )
}
